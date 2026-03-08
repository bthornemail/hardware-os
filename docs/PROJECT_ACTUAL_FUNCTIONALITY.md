# Project Actual Functionality

This document is strictly about what is implemented in code now.

## Implemented Components

## 1. Kernel CLI (`tools/hd`)

Commands implemented:

- `init <dir> [--project <name>]`
- `validate <manifest.json|project_dir> [--strict] [--format text|json|github]`
- `replay <manifest.json|project_dir>`

### `init`

Creates:

- `manifest.json`
- `layers/geometry.canvas.json`
- `layers/power.canvas.json`
- `build/history.ndjson`

Behavior:

- geometry and power contain node `id = edge0`
- history is a deterministic two-event hash chain
- prints manifest path on success

### `validate`

Validation pipeline:

1. manifest parse and structure checks
2. optional JSON Schema validation (`schemas/kernel/manifest-schema.json`) only if `jsonschema` is importable
3. layer file existence and JSON object checks
4. conditional layer dependencies:
   - `power -> geometry`
   - `signal -> power`
   - `runtime -> signal`
5. per-layer graph checks:
   - `nodes` and `edges` arrays
   - node `id` non-empty + unique
   - `edges[].fromNode` and `toNode` reference existing node ids
6. cross-layer identity check:
   - all non-geometry node ids must exist in geometry
7. history hash-chain validation (if `manifest.history` exists):
   - `prev_hash` linkage
   - `hash = sha256(canonical_json(event_without_hash))`

`--strict` effect:

- fails if history section is missing
- schema failures become errors (otherwise warnings)

Output modes:

- `text`: human-readable issues or `ISOMORPHIC ✓`
- `json`: machine-readable issue array
- `github`: Actions annotations

### `replay`

Builds deterministic bundle:

- manifest object
- all listed layers
- all history events (if file exists)

Then prints:

- `sha256(canonical_json(bundle))`

## 2. Inspector Server (`tools/hd-serve`)

HTTP server over local files.

Static/UI routes:

- `/`, `/viewer`, `/viewer/` -> `viewer/index.html`
- `/viewer/*` static assets (with path traversal guard)

API routes:

- `/api/bundle?project=<path>`
  - default project: `examples/infinity-cube`
  - returns manifest + layers + history
- `/api/validate?project=<path>&strict=1`
  - shells out to `tools/hd validate --format=json`
  - returns `{ok, exitCode, issues, stdout, stderr, strict}`

Safety mode:

- `--safe` restricts API target paths to under repo root.

## 3. Viewer (`viewer/index.html`)

Modes:

- Browse: inspect one project/layer
- Compare: diff node sets across two projects
- Replay: scrub history and jump by event target
- Validate: run kernel validator through API

Viewer details:

- semantic-only compare can ignore layout fields (`x,y,width,height`)
- compare categories: same / changed / missing-right / missing-left
- search by node id or text
- renders geometry base overlay optionally
- does not implement validator semantics itself

## 4. Demo Harness (`demos/`)

Intended checks:

- demo 01: `init` then `validate`
- demo 02: validate example project
- demo 03: tamper history and expect validation failure
- demo 04: replay digest determinism (same digest twice)

Current caveat:

- scripts call `tools/hd` directly, but file mode in this checkout is not executable.

## 5. Haskell EDSL (`src/Desktop/CanvasEDSL.hs`)

Provides typed JSON Canvas/NDJSON builders:

- canvas node/edge types
- directional edge combinators (`fifoTop`, `fifoBottom`, `portLeft`, `portRight`)
- NDJSON event encoding (`EvAddNode`, `EvAddEdge`, `EvSnapshot`)

Status:

- library module only; no integrated build pipeline in this repo currently uses it.

## Not Implemented (Stubbed)

These commands exist as wrappers but currently return "not implemented yet":

- `tools/hd-compile`
- `tools/hd-merge`
- `tools/hd-replay` (wrapper script; distinct from `hd replay` subcommand)
- `tools/hd-sim`

The implemented replay behavior is via:

- `python3 tools/hd replay ...`
