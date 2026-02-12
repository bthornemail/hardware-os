# Architecture

Hardware-OS is a deterministic layered graph runtime.

It enforces a separation:

- Kernel (`tools/hd`) defines truth.
- UI (`viewer/`) projects truth.

## Pipeline

Normalize -> Hash -> Store -> Project -> Replay

- Normalize: canonical JSON representation plus structural rules.
- Hash: SHA256 over canonical bytes.
- Store: append-only NDJSON history chain.
- Project: layered JSON Canvas graphs.
- Replay: deterministic digest over the loaded bundle.

## Canonical Model

A project is rooted at `manifest.json`.

- `manifest.json` references layer files (JSON Canvas graphs) and an optional history file.
- Layers form a stack with dependencies (e.g. `geometry -> power -> signal -> runtime`).
- The geometry layer defines the identity namespace.
- History is an append-only hash chain and provides tamper detection.

## Replay

Replay is a pure function over inputs.

- Input: manifest + referenced layers + referenced history
- Output: deterministic digest (`tools/hd replay ...`)

No hidden state. Same input -> same digest.

## Inspector Philosophy

The Inspector renders projections of kernel state.

- It never defines truth.
- It never re-implements validator semantics.
- Validation shown in the UI is produced by invoking the kernel (`tools/hd validate`).
