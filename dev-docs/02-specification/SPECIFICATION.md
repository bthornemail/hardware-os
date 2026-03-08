# Hardware-OS (Working Notes)

The canonical development documentation for this repository lives in the structured `dev-docs/` set, indexed in `dev-docs/README.md`.

This repository implements a minimal, dependency-light subset:
- A manifest (`manifest.json`) referencing layer files (`*.canvas.json`) and optional history (`*.ndjson`)
- JSON Canvas style layers: `{"nodes":[...], "edges":[...]}`
- Validation of:
  - layer dependency presence (`geometry` -> `power` -> `signal` -> `runtime`)
  - node/edge integrity per layer
  - cross-layer node-id consistency (all non-geometry node IDs must exist in geometry)
  - NDJSON history hash chaining (`hash`, `prev_hash`)

See `tools/hd` for the source-of-truth behavior.

## Canonical Documentation Source

Rule: docs in `dev-docs/01-foundations` through `dev-docs/05-governance-planning` are canonical. Historical transcripts in `dev-docs/99-archive` are non-canonical provenance only.

## Event Hash Canonicalization (History)

History is an append-only NDJSON stream, one JSON object per line.

Given an event object `E`:
1. Remove the field `"hash"` (if present).
2. JSON-serialize with:
   - sorted keys
   - separators `(",", ":")` (no extra whitespace)
   - ASCII/`utf-8` bytes (`ensure_ascii=true`)
3. Compute `SHA256` over those bytes.
4. Encode as lowercase hex to produce the 64-char `"hash"` string.

Chain rule:
- For the first event, `"prev_hash"` MUST be 64 zeros (`"000...000"`).
- For every subsequent event, `"prev_hash"` MUST equal the previous event's `"hash"`.
