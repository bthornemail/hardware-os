# Hardware-OS

Hardware-OS is a deterministic layered graph runtime with a cryptographic history log and a local inspector UI.

Core separation:

- Kernel defines truth.
- UI projects truth.

## Kernel CLI

```bash
tools/hd init <dir>
tools/hd validate <manifest.json|project_dir>
tools/hd replay <manifest.json|project_dir>
```

These commands are the canonical truth engine. The inspector UI never replaces them.

## Demo Suite

```bash
demos/run-all.sh
```

This proves deterministic init, validation, tamper detection, and replay determinism.

## Inspector UI

```bash
tools/hd-serve --port 8787
# open http://127.0.0.1:8787/viewer/
```

Note: `hd-serve` is intended for local debugging only. Do not expose it to untrusted networks.

Optional hardening:
```bash
tools/hd-serve --safe
```
`--safe` restricts `/api/bundle` and `/api/validate` targets to paths under the repo root (disables loading `/tmp/...`).

## Docs

- `ARCHITECTURE.md`: system model and boundaries
- `KERNEL.md`: kernel contract for `tools/hd`
- `INSPECTOR.md`: inspector behavior and semantics
- `DEMO_SUITE.md`: demo harness and what it proves
- `SECURITY.md`: trust boundaries and non-goals
- `ROADMAP.md`: next work
- `SPECIFICATION.md`: frozen hash canonicalization rules and notes
- `chat_history.md`: canonical captured source material for the spec

## Also In This Repo

- `src/Desktop/CanvasEDSL.hs`: Haskell EDSL for emitting JSON Canvas nodes/edges.
