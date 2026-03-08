# Hardware-OS Formal State Machine Specification

Status: Draft  
Version: 1.0  
Last Updated: 2026-02-08  
Depends on: `../03-rfcs/RFC-0001-hardware-os-core.md`, `SPECIFICATION.md`, `../04-implementation/REFERENCE_IMPLEMENTATION.md`

This document formalizes the Hardware-OS kernel as a deterministic
state transition system. It defines the semantics for manifest/layer/history
validation and deterministic replay digesting.

This spec is **normative for semantics**, not for API/CLI UX.

## 0. Notation and Conventions

- `Σ` denotes a kernel state.
- `σ` denotes a JSON object.
- `bytes(σ)` denotes canonical JSON bytes (defined below).
- `H(x)` denotes `sha256(x)` producing 32 bytes.
- `hex(H(x))` denotes lowercase 64-character hex.
- `⊥` denotes invalid / error.
- `⊢` denotes a judgment.

Unless otherwise stated, all functions are deterministic and total over valid inputs.

## 1. Canonical JSON Bytes

### 1.1 Canonicalization function

Define a canonical serialization function:

```text
canon : JSON -> bytes
```

Such that:

- keys are sorted lexicographically
- object and array structures are preserved
- serialization uses separators `(",", ":")` (no extra whitespace)
- ASCII escaping is applied (`ensure_ascii = true`)
- output is UTF-8 bytes of the resulting string

This is equivalent to the reference implementation behavior:

```text
canon(σ) = utf8(dumps(σ, sort_keys=true, separators=(",", ":"), ensure_ascii=true))
```

### 1.2 Hash function

Define:

```text
hashJSON(σ) = hex(H(canon(σ)))
```

## 2. Data Domains

### 2.1 Manifest

A manifest is a JSON object `M` with:

- `M.layers`: non-empty list of layer descriptors
- each descriptor has:
  - `layerId`: non-empty string
  - `file`: non-empty string
- optional:
  - `M.history`: object with `file`: non-empty string

This spec does not require history unless in strict mode (see §6.2).

### 2.2 Layer (JSON Canvas style)

A layer is a JSON object `L` with:

- `L.nodes`: array
- `L.edges`: array

Node objects minimally include:

- `id`: non-empty string

Edge objects minimally include:

- `fromNode`: non-empty string
- `toNode`: non-empty string

No further node/edge fields are required by this kernel.

### 2.3 History (NDJSON)

A history file is a sequence of JSON objects `[E0, E1, ..., En-1]` stored as NDJSON.

Each event `Ei` is a JSON object containing at least:

- `hash`: 64-char hex string
- `prev_hash`: 64-char hex string

Other fields (`t`, `op`, `target`, etc.) are opaque to the kernel for chain validity purposes.

## 3. Kernel State Space

### 3.1 Bundle

Define a Bundle:

```text
B = (M, Layers, Hist)
```

Where:

- `M` is the parsed manifest object
- `Layers` is a finite map: `layerId -> layerObject`
- `Hist` is a finite list of event objects (possibly empty)

### 3.2 Kernel state

Kernel state is:

```text
Σ = (B, mode)
mode ∈ { nonstrict, strict }
```

No mutable runtime state is required for validation/replay semantics.

## 4. Transition System Overview

Hardware-OS kernel is defined as a labeled transition system:

```text
(Σ, Act, ->)
```

Actions (`Act`) include:

- `Load(projectPath)`
- `Validate`
- `ReplayDigest`
- `InitSkeleton(outputDir, projectName?)` (constructor action)

Only `InitSkeleton` produces new filesystem artifacts; all others are pure over the loaded bundle.

## 5. Judgments

### 5.1 Manifest well-formedness

Judgment:

```text
⊢ M : Manifest
```

holds iff:

1. `M` is an object
2. `M.layers` exists and is a non-empty list
3. each element in `M.layers` is an object with:
   - `layerId` non-empty string
   - `file` non-empty string
4. if `M.history` exists then:
   - it is an object
   - it has `file` as a non-empty string

### 5.2 Layer well-formedness

Judgment:

```text
⊢ L : Layer
```

holds iff:

1. `L` is an object
2. `L.nodes` is an array
3. `L.edges` is an array
4. every node element is an object
5. every edge element is an object

### 5.3 Layer graph validity

Given `L.nodes` and `L.edges`, define:

- `nodeIds(L) = [n.id | n ∈ L.nodes, n.id is string]`

Judgment:

```text
⊢ L : GraphValid
```

holds iff:

1. for each node `n`, `n.id` exists and is a non-empty string
2. `nodeIds(L)` has no duplicates
3. for each edge `e`:
   - `e.fromNode` and `e.toNode` exist and are non-empty strings
   - both are in the set `set(nodeIds(L))`

### 5.4 Conditional dependency validity

Let `Deps` be the dependency relation:

- `geometry` depends on `[]`
- `power` depends on `["geometry"]`
- `signal` depends on `["power"]`
- `runtime` depends on `["signal"]`

Given `present = keys(Layers)`:

Judgment:

```text
⊢ present : DependenciesOK
```

holds iff:

For every `layerId ∈ present`:
for every `d ∈ Deps(layerId)`:
`d ∈ present`.

Important: Dependencies are enforced **only when layerId is present**.

### 5.5 Cross-layer identity validity (geometry-rooted)

If `geometry ∉ present`, cross-layer identity is vacuously satisfied.

If `geometry ∈ present`, define:

- `G = Layers["geometry"]`
- `GeoIds = set(nodeIds(G))`

Judgment:

```text
⊢ Layers : CrossLayerOK
```

holds iff for every `layerId ∈ present` where `layerId != "geometry"`:
for every node id `x ∈ nodeIds(Layers[layerId])`:
`x ∈ GeoIds`.

### 5.6 History chain validity

Define `stripHash(E)` as event object `E` with the `"hash"` field removed if present.

Define computed event hash:

```text
computedHash(E) = hashJSON(stripHash(E))
```

Define ZERO hash constant:

```text
ZERO = "0" repeated 64 times
```

Judgment:

```text
⊢ Hist : ChainOK
```

holds iff:

1. For empty history, ChainOK holds.
2. For non-empty history `[E0, E1, ..., En-1]`:
   - `E0.prev_hash = ZERO`
   - For all `i > 0`, `Ei.prev_hash = Ei-1.hash`
   - For all `i`, `Ei.hash = computedHash(Ei)`
   - Each `hash` and `prev_hash` are 64-character lowercase hex strings
     (implementations MAY accept uppercase but MUST output lowercase in canonicalization contexts)

This matches `SPECIFICATION.md` and the reference implementation.

## 6. Validation Semantics

Validation is defined as a partial function:

```text
validate(Σ) : Result
Result ∈ { OK, ERR(errors), WARN(warnings), ERRWARN(errors,warnings) }
```

A conforming implementation MAY report warnings; only errors affect validity.

### 6.1 Validation rules (nonstrict mode)

Given `Σ = (B, nonstrict)` where `B = (M, Layers, Hist)`:

Validation succeeds (`OK`) iff all are satisfied:

1. `⊢ M : Manifest`
2. For every loaded layer object `L`:
   - `⊢ L : Layer` and `⊢ L : GraphValid`
3. `⊢ keys(Layers) : DependenciesOK`
4. `⊢ Layers : CrossLayerOK`
5. History:
   - If `M.history` is absent: no history checks are required
   - If `M.history` is present: `⊢ Hist : ChainOK` is required

### 6.2 Validation rules (strict mode)

Given `Σ = (B, strict)`:

All nonstrict rules apply, plus:

- `M.history` MUST be present
- and `⊢ Hist : ChainOK` MUST hold

### 6.3 Deterministic diagnostics

A conforming implementation SHOULD:

- accumulate all errors instead of failing fast
- present diagnostics in deterministic order (manifest, layers, deps, cross-layer, history)

### 6.4 Validity predicate

Define the validity predicate:

```text
Valid(Σ) ⇔ validate(Σ) has no errors
```

## 7. Replay Digest Semantics

Replay digest is defined as a pure function over bundle contents.

### 7.1 Bundle construction

Given `B = (M, Layers, Hist)`, define a JSON object:

```text
BundleJSON(B) = {
  "manifest": M,
  "layers": LayersObject,
  "history": Hist
}
```

Where `LayersObject` is a JSON object mapping each `layerId` to the corresponding layer JSON object.

### 7.2 Digest

Define:

```text
ReplayDigest(B) = hashJSON(BundleJSON(B))
```

This MUST match the reference implementation's `hd replay` output.

ReplayDigest is defined even if the bundle is invalid; however, implementations MAY refuse to compute it on invalid bundles.

## 8. Init Skeleton Semantics

`InitSkeleton(dir, projectName?)` is a constructor action that produces a new bundle on disk.

Minimal requirements for a conforming init skeleton:

- Create `dir/layers/` and `dir/build/`
- Write `dir/manifest.json`
- Write at least `geometry.canvas.json` and `power.canvas.json`
- Write `build/history.ndjson` with a valid hash chain
- Ensure `power` includes at least one node id that also exists in geometry (cross-layer identity demo)

The exact example contents are not normative, but they MUST validate in nonstrict mode.

## 9. Extensibility Hooks (Non-Normative Today)

The following are reserved for future kernel extensions:

- branch DAG metadata (RFC-0004)
- merge events and conflict resolution (RFC-0003/5)
- distributed sync (RFC-0006)
- snapshot compression (RFC-0007)

These features MUST NOT alter the semantics in §6 and §7.
They may only add additional validations and/or additional derived views.

## 10. Security Considerations

- All external inputs are untrusted.
- Validation MUST verify hash chain correctness, not just presence.
- Layer references MUST be checked to prevent dangling edges.
- Safe-mode restrictions for inspector serving are out-of-scope here but recommended operationally.

## 11. Conformance Checklist

An implementation conforms to this state machine spec if:

- canonical JSON bytes match §1 exactly
- history chaining matches §5.6
- validation results match §6
- replay digest matches §7

Given the same project directory contents, two conforming implementations MUST output identical replay digests.
