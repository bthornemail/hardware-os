# Hardware-OS Implementation Guide

Status: Draft  
Version: 1.0  
Audience: Engineers implementing a compatible Hardware-OS kernel or inspector  
Depends on: `../03-rfcs/RFC-0001-hardware-os-core.md` through `../03-rfcs/RFC-0006-distributed-sync-protocol.md`, `REFERENCE_IMPLEMENTATION.md`

This document explains how to implement a compatible Hardware-OS system from scratch.

It is not a user guide. It is an engineering blueprint.

The goal:

> independent implementations must replay identically

If two implementations ingest the same project, they must produce the same replay digest.

## 1. Mental Model

Hardware-OS has three layers:

1. Kernel
   - deterministic truth engine
   - manifest + layers + history
   - replay + validation
2. Inspector
   - read-only projection of kernel state
   - never defines truth
3. Sync layer (future)
   - exchange histories
   - preserve append-only guarantees

If your implementation preserves this separation, you are on the correct path.

## 2. Minimum Compatible Kernel

To be compatible you only need:

- canonical JSON serialization
- history hash chain
- layer validation
- deterministic replay digest

Everything else is optional.

## 3. Canonical JSON Rules

This is the most important rule.

All hashes derive from canonical JSON bytes.

Reference behavior:

```python
json.dumps(
  obj,
  sort_keys=True,
  separators=(",", ":"),
  ensure_ascii=True
).encode("utf-8")
```

Rules:

- keys sorted lexicographically
- no whitespace except required separators
- UTF-8 encoding
- ASCII-safe escaping

You MUST match this exactly.

If your canonicalization differs, you are incompatible.

## 4. Event Hash Algorithm

Given event `E`:

1. Remove `"hash"` field if present
2. Canonical serialize
3. SHA256 digest
4. lowercase hex string

```text
hash = sha256(canonical(E_without_hash))
```

Chain rule:

```text
E0.prev_hash = "000...000"
Ei.prev_hash = hash(Ei-1)
```

This makes history tamper-evident.

## 5. History Storage

History is NDJSON:

```text
{event1}
{event2}
{event3}
```

One JSON object per line.

Order is canonical. No reordering allowed.

## 6. Manifest Resolution

A project is resolved as:

```text
project/
  manifest.json
  layers/
  build/history.ndjson
```

If target is directory -> append `manifest.json`.
If target is file -> treat as manifest.

Implementations MUST support both.

## 7. Layer Model

Each layer is a JSON object:

```json
{
  "nodes": [],
  "edges": []
}
```

Rules:

- `node.id` must be unique per layer
- edges reference existing node IDs
- no dangling references

Optional but recommended:

- geometry layer anchors cross-layer identity

## 8. Cross-Layer Identity

If a geometry layer exists:

All non-geometry node IDs must exist in geometry.

If geometry absent: skip cross-layer check.

This preserves the identity root.

## 9. Dependency Enforcement

Minimal dependency graph:

```text
power -> geometry
signal -> power
runtime -> signal
```

Rule:

Dependencies apply only if the dependent layer exists.

Do not require missing layers to exist. Only enforce consistency when present.

## 10. Validation Strategy

A compliant validator should:

1. Parse manifest
2. Load layers
3. Check structure
4. Check dependencies
5. Check node/edge integrity
6. Validate history (if present)
7. Return structured issues

Strict mode MAY require history presence.

Non-strict mode MAY allow no history.

## 11. Replay Digest

Replay loads:

```text
bundle = {
  manifest,
  layers,
  history
}
```

Digest:

```text
SHA256(canonical(bundle))
```

This digest is the canonical state fingerprint.

All compatible implementations MUST produce the same digest.

## 12. Error Handling Philosophy

Validation should:

- accumulate errors
- not stop at first failure
- produce deterministic ordering of diagnostics

Do not emit nondeterministic error lists.

Sort errors if needed.

## 13. Inspector Implementation

Inspector requirements:

- read-only
- deterministic projection
- no mutation authority
- no hidden state

Inspector may:

- diff nodes
- highlight changes
- scrub history
- visualize graph

Inspector must never rewrite history.

## 14. Security Model

Assume hostile input.

Always verify:

- JSON structure
- hash chain
- references
- canonical serialization

Never trust external bundles.

## 15. Performance Guidance

Replay is O(n) in history length.

Implementations MAY add:

- snapshot caching
- incremental replay
- memory pooling

But optimization must not change digest results.

## 16. Compatibility Testing

Before claiming compatibility:

- run replay twice -> identical digest
- modify one byte -> validation fails
- reorder history -> validation fails
- tamper `prev_hash` -> validation fails

These are baseline invariants.

## 17. Common Implementation Mistakes

- Using non-canonical JSON serializer
- Pretty-printing JSON before hashing
- Ignoring UTF-8 normalization
- Reordering history events
- Floating point inconsistencies
- Non-deterministic map iteration
- Auto-merging conflicts silently

Avoid all of these.

## 18. Recommended Architecture

Clean separation:

```text
kernel/
  canonical.py
  history.py
  validate.py
  replay.py

inspector/
  ui/
  api-adapter/
```

Kernel must not import inspector.

Inspector depends on kernel.

Never reverse.

## 19. Future Extensions

Your implementation can add:

- merge engines
- sync protocols
- CRDT projections
- access control
- compression

But kernel invariants must remain frozen.

## 20. Final Principle

Hardware-OS is not a UI framework.

It is a deterministic truth machine.

Everything else is projection.

If your implementation preserves:

- append-only history
- canonical hashing
- deterministic replay

then you are compatible.

Everything else is optional.
