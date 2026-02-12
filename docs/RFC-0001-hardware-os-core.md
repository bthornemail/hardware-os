RFC-0001: Hardware-OS Core Specification
========================================

Status: Draft  
Version: 1.0  
Author: Hardware-OS Contributors  
Last Updated: 2026-02-08

Abstract
--------

This document specifies the core protocol for Hardware-OS:
a deterministic layered graph runtime with an append-only,
cryptographically verifiable history log.

The specification defines canonical data formats,
validation rules, replay semantics, and trust boundaries.

This RFC is implementation-neutral and applies to all
conforming Hardware-OS kernels.

Normative Language
------------------

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”,
“SHALL NOT”, “SHOULD”, “SHOULD NOT”, and “MAY” in this
document are to be interpreted as described in RFC 2119.

1. System Model
---------------

Hardware-OS defines a pipeline:

    Normalize -> Hash -> Store -> Project -> Replay

Where:

- Normalize produces canonical JSON representations
- Hash produces cryptographic identifiers
- Store records an append-only event log
- Project renders layered graph structures
- Replay deterministically materializes state

The kernel is the canonical truth engine.
User interfaces are projections and MUST NOT redefine truth.

2. Manifest
-----------

Each Hardware-OS project MUST contain a manifest:

    manifest.json

The manifest is the root object of the project.

### 2.1 Required fields

```
{
  "hdVersion": string,
  "schemaVersion": string,
  "layers": array
}
```

Implementations MUST reject manifests missing required fields.

The manifest MAY include a `history` object (see Section 5).

### 2.2 Layers entry

Each element of `layers` MUST contain:

```
{
  "layerId": string,
  "file": string
}
```

The file path is relative to the project root.

3. Layer Format
---------------

Each layer MUST be a JSON object:

```
{
  "nodes": array,
  "edges": array
}
```

### 3.1 Nodes

Each node MUST contain:

- `id`: non-empty string

Node IDs MUST be unique within a layer.

### 3.2 Edges

Edges MUST reference existing node IDs:

```
{
  "fromNode": string,
  "toNode": string
}
```

Invalid references MUST cause validation failure.

### 3.3 Layer dependency ordering

Layers MUST respect the following dependency chain when those layers are present:

    geometry -> power -> signal -> runtime

A layer MUST NOT exist unless its dependency exists.

4. Identity Model
-----------------

The geometry layer defines canonical identity.

All nodes in non-geometry layers MUST reference IDs
that exist in the geometry layer.

Violation of this rule invalidates the project.

5. History Log
--------------

History is stored as NDJSON.

Each line is a JSON event object.

If the manifest includes a `history` object, it MUST include:

```
{
  "file": string
}
```

The file path is relative to the project root.

### 5.1 Event structure

```
{
  "t": number,
  "prev_hash": string,
  "op": string,
  "target": string,
  "hash": string
}
```

Additional fields MAY exist.

### 5.2 Canonical hash algorithm

To compute `hash`:

1. Remove the `"hash"` field
2. Serialize JSON with:
   - sorted keys
   - ASCII encoding
   - no extra whitespace
3. SHA256 over the bytes
4. lowercase hex encoding

### 5.3 Chain rule

The first event MUST use:

    prev_hash = "000...000" (64 zeros)

Each subsequent event MUST use:

    prev_hash == previous event hash

Mismatch invalidates history.

6. Validation
-------------

A conforming validator MUST check:

- manifest schema correctness
- layer file existence
- node ID uniqueness
- edge reference integrity
- dependency ordering
- geometry identity enforcement

If the manifest includes `history`, the validator MUST also check:

- history hash chain correctness

Validation failure MUST produce a non-zero exit code.

7. Replay
---------

Replay is defined as a pure function:

    state = replay(manifest + layers + history)

Replay MUST be deterministic.

Two conforming implementations given identical input
MUST produce identical replay digests.

The replay digest MUST be SHA256 over canonical JSON
of the fully materialized bundle:

```
{
  "manifest": ...,
  "layers": { ... },
  "history": [ ... ]
}
```

8. Determinism Requirements
---------------------------

Implementations MUST:

- use canonical JSON serialization
- avoid random ordering
- avoid nondeterministic timestamps
- produce stable digests across platforms

9. Trust Model
--------------

The kernel defines truth.

User interfaces:

- MAY display projections
- MUST NOT redefine validation rules
- MUST defer to kernel validation

10. Security Considerations
---------------------------

Hardware-OS guarantees tamper detection via hash chaining.

Hardware-OS does NOT provide:

- authentication
- encryption
- access control
- sandboxing

Network exposure of debugging servers is out of scope.

Implementations SHOULD warn users about unsafe deployment.

11. Compatibility
-----------------

Future versions MUST preserve replay determinism.

Schema evolution MUST NOT break existing valid projects.

12. Reference Implementation
----------------------------

The canonical reference implementation in this repository is:

    tools/hd

Other implementations MUST conform to this RFC.

13. Conclusion
--------------

Hardware-OS defines a minimal deterministic runtime.

Truth is defined by canonical structure and replay.

All projections are derived, not authoritative.

