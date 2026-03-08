# Kernel Specification

This document describes the kernel contract implemented by `tools/hd`.

`tools/hd` is the source of truth for:

- manifest structure
- layer integrity rules
- cross-layer identity rules
- NDJSON hash chain verification
- deterministic replay digest

## Manifest

A project is rooted at `manifest.json`.

Minimal shape:

```json
{
  "hdVersion": "1",
  "schemaVersion": "1.0.0",
  "project": "name",
  "layers": [
    {"layerId": "geometry", "file": "layers/geometry.canvas.json"}
  ],
  "history": {"file": "build/history.ndjson"}
}
```

Rules:

- `layers` MUST be a non-empty array.
- Each `layers[]` entry MUST have `layerId` and `file`.

## Layers

Layer files are JSON Canvas style graphs:

```json
{
  "nodes": [ ... ],
  "edges": [ ... ]
}
```

Kernel rules:

- Nodes in a layer MUST have unique non-empty string `id`.
- Edges MUST reference existing nodes via `fromNode` and `toNode`.

Cross-layer identity:

- If `geometry` exists, all node ids referenced in non-geometry layers MUST exist as node ids in `geometry`.

Layer dependencies (minimal kernel set):

- `geometry`
- `power` depends on `geometry`
- `signal` depends on `power`
- `runtime` depends on `signal`
- `history` is treated as special (temporal spine)

## History

History is NDJSON: one JSON object per line.

Required fields per event (as validated today):

- `hash`: 64-char lowercase hex string
- `prev_hash`: 64-char lowercase hex string

The kernel verifies:

- `prev_hash` equals the previous event's `hash`.
- `hash` equals SHA256 of a canonical JSON encoding of the event with the `hash` field removed.

The canonicalization rules are frozen in `../02-specification/SPECIFICATION.md`.

## Commands

### `hd init <dir>`

Creates a minimal valid project at `<dir>`.

### `hd validate <manifest.json|project_dir>`

Validates:

- manifest structure
- layer dependency presence
- per-layer node/edge integrity
- cross-layer identity
- history hash chain (if configured)

Flags:

- `--strict`: treat optional checks as errors (e.g. missing history)
- `--format=text|json|github`: output formatting

Exit codes:

- `0` valid
- `1` invalid

### `hd replay <manifest.json|project_dir>`

Loads the manifest, referenced layers, and referenced history and prints a deterministic SHA256 digest over the loaded bundle.

This is a "replay digest" (not a simulation).

Exit codes:

- `0` success
- `1` manifest missing
