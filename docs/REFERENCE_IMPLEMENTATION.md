# Reference Implementation Specification

Status: Draft  
Version: 1.0  
Last Updated: 2026-02-08  
Applies to: This repository's reference implementation (`tools/hd`, `tools/hd-serve`)

This document specifies the **reference implementation behavior** for Hardware-OS as shipped in this repo. It is the normative behavior baseline for conformance until superseded by a more formal test-vector suite.

**Key principle**: the reference implementation is minimal and deterministic. It defines *kernel behavior* and the *inspector adapter* interface used by the viewer.

Related docs:
- `RFC-0001-hardware-os-core.md`
- `RFC-0002-inspector-protocol.md`
- `SPECIFICATION.md` (hash canonicalization freeze)
- `KERNEL.md` (human-readable kernel contract)

## 1. Scope

This spec covers:

- `tools/hd` (kernel CLI): `init`, `validate`, `replay`
- `tools/hd-validate` compatibility wrapper
- `tools/hd-serve` (local inspector adapter server): `/api/bundle`, `/api/validate`, static `/viewer/*`
- Demo harness: `demos/run-all.sh`
- Example project: `examples/infinity-cube`

This spec does **not** cover:

- Distributed sync (future / RFC-0006 implementation)
- Merge engine tooling (future)
- Branch timeline storage formats (future)
- Any write/edit protocol (future)

## 2. Repository Layout

The reference implementation assumes the following paths exist:

- Kernel CLI:
  - `tools/hd` (Python executable)
  - `tools/hd-validate` (Python executable wrapper)
- Inspector adapter server:
  - `tools/hd-serve` (Python executable)
  - `viewer/index.html` (static webapp)
- Schemas (optional best-effort):
  - `schemas/kernel/manifest-schema.json`
- Docs:
  - `README.md`, `ARCHITECTURE.md`, `KERNEL.md`, `INSPECTOR.md`, `DEMO_SUITE.md`, `SECURITY.md`, `ROADMAP.md`
  - RFCs: `RFC-0001-*.md` etc.
- Example:
  - `examples/infinity-cube/manifest.json`
  - `examples/infinity-cube/layers/*.canvas.json`
  - `examples/infinity-cube/build/history.ndjson`

## 3. Kernel CLI: `tools/hd`

### 3.1 Invocation

The CLI is invoked as:

```bash
tools/hd <command> [args...]
```

Commands:

- `init`
- `validate`
- `replay`

The CLI MUST be runnable with system Python3 and MUST NOT require third-party deps.

### 3.2 Canonical JSON bytes (internal primitive)

The reference implementation defines canonical JSON bytes for hashing as:

- `json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=True)`
- UTF-8 encoding of that string

This is used for history hashing and replay digesting.

### 3.3 Project resolution

For commands that accept a `target`:

- If `target` is a directory: the manifest path is `target/manifest.json`
- If `target` is a file: it is treated as the manifest path

## 4. `hd init`

### 4.1 Syntax

```bash
tools/hd init <dir> [--project <name>]
```

### 4.2 Behavior

`init` MUST:

1. Create `<dir>/` if missing
2. Create subdirectories:
   - `<dir>/layers/`
   - `<dir>/build/`
3. Write:
   - `<dir>/manifest.json`
   - `<dir>/layers/geometry.canvas.json`
   - `<dir>/layers/power.canvas.json`
   - `<dir>/build/history.ndjson`

### 4.3 Generated manifest

The manifest MUST include:

- `hdVersion` (string, currently `"1"`)
- `schemaVersion` (string, currently `"1.0.0"`)
- `project` (string, defaults to basename(dir) unless `--project`)
- `layers` array including at least:
  - `{ "layerId": "geometry", "file": "layers/geometry.canvas.json" }`
  - `{ "layerId": "power", "file": "layers/power.canvas.json" }`
- `history` object:
  - `{ "file": "build/history.ndjson" }`

### 4.4 Generated layers

Generated layer files MUST be JSON Canvas style objects:

```json
{ "nodes": [...], "edges": [...] }
```

`geometry` MUST define at least one node with:

- `id: "edge0"`
- `type: "text"`
- rectangle geometry fields (`x`, `y`, `width`, `height`)
- `text` string

`power` MUST include a node referencing the same `id` (`"edge0"`) to demonstrate cross-layer identity linkage.

### 4.5 Generated history

The reference implementation generates a minimal chain of at least two events:

- `prev_hash` of first event MUST be 64 zeros
- `hash` computed as SHA256(canonical_json(event_without_hash))

The events MUST be written as NDJSON (one event per line).

### 4.6 Output and exit code

On success:

- Print the path to the manifest (`<dir>/manifest.json`) to stdout
- Exit code `0`

On failure:

- Print a diagnostic to stderr (best-effort)
- Exit code non-zero

## 5. `hd validate`

### 5.1 Syntax

```bash
tools/hd validate <manifest.json|project_dir> [--strict] [--format text|json|github]
```

### 5.2 Formats

- `--format=text` (default): emits human-readable issues or `ISOMORPHIC ✓` on success
- `--format=json`: emits a JSON array of `{kind,message}` objects (empty `[]` on success)
- `--format=github`: emits GitHub Actions annotation lines (`::error::...` / `::warning::...`)

### 5.3 Validation stages

The reference validator performs:

#### A) Manifest parse + structure

- manifest must exist
- manifest must be a JSON object
- `manifest.layers` MUST be a non-empty array of objects
- each layer entry MUST include non-empty strings:
  - `layerId`
  - `file`

#### B) Optional JSON Schema validation (best effort)

If BOTH are true:

- local schema exists at `schemas/kernel/manifest-schema.json`
- Python package `jsonschema` is importable

Then:

- validate manifest against schema
- in `--strict` mode schema failure is an **error**
- otherwise schema failure is a **warning**

#### C) Load layer files

For each layer in manifest:

- layer file MUST exist
- layer file MUST parse as JSON object

#### D) Layer dependency presence (conditional)

The reference implementation defines a minimal dependency mapping:

- geometry: []
- power: ["geometry"]
- signal: ["power"]
- runtime: ["signal"]
- history: []

Rule: dependencies are enforced **only when a layer is present**.
Example: if `power` exists, `geometry` MUST exist.

#### E) Layer integrity per layer (JSON Canvas style)

Each loaded layer MUST contain:

- `nodes` array
- `edges` array

Each node:

- MUST be an object
- MUST have `id` as non-empty string
- node IDs MUST be unique within the layer

Each edge:

- MUST be an object
- MUST have `fromNode` and `toNode` as non-empty strings
- each endpoint MUST reference an existing node ID in that same layer

#### F) Cross-layer identity consistency (geometry-rooted)

If a `geometry` layer exists:

- every node `id` appearing in any non-geometry layer MUST also exist in geometry's node IDs

If no `geometry` layer exists:

- cross-layer identity checks are skipped (but dependency rules may still fail if other layers require geometry)

#### G) History validation (optional unless strict)

History validation behavior is aligned with current kernel:

- If `manifest.history` is **absent**:
  - in non-strict mode: OK
  - in `--strict` mode: ERROR (`manifest.history is required in --strict mode`)
- If `manifest.history` is present:
  - must be an object with non-empty string `file`
  - file must exist
  - file is NDJSON with per-line JSON object events
  - enforce hash chain:
    - first event `prev_hash` MUST equal 64 zeros
    - subsequent `prev_hash` MUST equal previous event `hash`
    - each event `hash` MUST equal SHA256(canonical_json(event_without_hash))

### 5.4 Success criteria

Validation succeeds iff no `error` issues exist.

Warnings do not fail validation unless explicitly stated (schema in strict mode).

### 5.5 Output and exit codes

- Exit code `0` on success
- Exit code `1` on failure
- Output must follow selected `--format`

## 6. `hd replay`

### 6.1 Syntax

```bash
tools/hd replay <manifest.json|project_dir>
```

### 6.2 Behavior

`replay` loads the bundle deterministically:

- `manifest` is loaded from `manifest.json`
- `layers` are loaded in manifest order into an object keyed by `layerId`
- `history` is loaded (if present and file exists) into an array preserving file order
  - if history file is missing, treat as empty history

It then computes:

- `digest = SHA256(canonical_json_bytes(bundle))`

Where `bundle` is:

```json
{
  "manifest": { ... },
  "layers": { "<layerId>": { ... }, ... },
  "history": [ { ... }, ... ]
}
```

### 6.3 Output and exit codes

- Print the 64-char hex digest to stdout
- Exit code `0` on success
- Exit code `1` on error (missing manifest, parse errors, etc.)

## 7. Compatibility wrapper: `tools/hd-validate`

### 7.1 Purpose

`tools/hd-validate` exists for compatibility with documentation and older tooling.

### 7.2 Behavior

It MUST forward:

```bash
tools/hd-validate <args...>
```

to:

```bash
tools/hd validate <args...>
```

and return the same exit code.

## 8. Inspector adapter server: `tools/hd-serve`

### 8.1 Purpose and trust boundary

`hd-serve` is a **local debugging server** for the inspector UI.

It MUST display a warning at startup:

- "local debugging only; do not expose to untrusted networks."

It MUST NOT claim to be hardened for internet exposure.

### 8.2 Syntax

```bash
tools/hd-serve [--host 127.0.0.1] [--port 8787] [--safe]
```

### 8.3 Safe mode

When `--safe` is enabled:

- `/api/bundle` and `/api/validate` MUST reject any target path not under the repo root (`ROOT`)
- Reject with HTTP 403 and an error message

Safe mode disables loading projects like `/tmp/...`.

### 8.4 Static viewer routing

The server MUST serve:

- `/` or `/viewer` or `/viewer/` -> `viewer/index.html`
- `/viewer/<path>` -> static file under `viewer/`

The server MUST include a path traversal guard so that `/viewer/../..` cannot escape the viewer directory.

### 8.5 Bundle endpoint

#### GET /api/bundle?project=<path>

- `project` defaults to `examples/infinity-cube` if omitted
- Resolve `target = (ROOT / project).resolve()`
- Require `target` exists and is a directory
- Load:
  - `target/manifest.json`
  - each layer file referenced by manifest
  - history file referenced by manifest (if present), as NDJSON

Return JSON:

```json
{
  "projectDir": "<absolute path>",
  "manifest": { ... },
  "layers": { "<layerId>": { ... }, ... },
  "history": [ ... ]
}
```

### 8.6 Validate endpoint

#### GET /api/validate?project=<path>&strict=<bool>

- `project` defaults to `examples/infinity-cube` if omitted
- `strict` is true if query value (after strip+lower) is in: `1,true,yes`
- Resolve `target = (ROOT / project).resolve()`
- In safe mode, enforce repo-root restriction
- Run the kernel validator as a subprocess:

```bash
python3 tools/hd validate <target> --format=json [--strict]
```

Return JSON:

```json
{
  "ok": true,
  "exitCode": 0,
  "issues": [],
  "stdout": "...",
  "stderr": "...",
  "strict": false
}
```

If stdout cannot be parsed as JSON, `issues` MUST be `null` and `stdout` MUST still be returned.

## 9. Viewer (Inspector UI): `viewer/index.html`

The viewer is considered a projection client and is not normative for kernel semantics. However, the reference UI provides a baseline behavior:

- Browse, Compare, Replay, Validate modes
- Compare performs deterministic node-level diff classification:
  - same / changed / missing-left / missing-right
- "Semantic-only" compare ignores layout fields (`x`, `y`, `width`, `height`)
- Validate mode uses `/api/validate` and does not reimplement kernel validation

The viewer MUST NOT claim canonical authority.

## 10. Demo Harness

`demos/run-all.sh` MUST run end-to-end without network dependencies and should conclude with success when the repo is healthy.

Reference demos include:

- init
- validate
- tamper history detection
- replay determinism

## 11. Conformance Guidance (for other implementations)

An implementation is **reference-compatible** if it matches:

- history hash canonicalization bytes and algorithm
- layer validation rules described above
- strict vs non-strict behavior re: history presence
- replay digest definition over the canonical bundle object

Recommended future work: publish "golden" test vectors for:

- canonical event hashing
- replay digest
- cross-layer identity failures
- edge reference failures
- dependency failures

## 12. Known intentional limitations

The reference implementation currently:

- treats layer payloads as JSON Canvas style objects only
- validates history only if present (unless strict)
- does not implement merge/branch/sync tooling yet (RFCs are forward-looking)
- does not attempt to sanitize `project` values except via `--safe` restriction

These are design choices for minimalism and determinism.
