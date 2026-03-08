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

- `docs/README.md`: contributor and maintainer implementation docs (actual functionality)
- `dev-docs/README.md`: canonical dev-docs index and reading order
- `dev-docs/01-foundations/`: architecture, kernel, inspector, security
- `dev-docs/02-specification/`: semantic and formal specifications
- `dev-docs/03-rfcs/`: RFC series (`RFC-0001` through `RFC-0010`)
- `dev-docs/04-implementation/`: implementation and reference behavior docs
- `dev-docs/05-governance-planning/`: manifesto, governance, roadmap/plans
- `dev-docs/99-archive/`: historical transcript archive (non-canonical)

## Also In This Repo

- `src/Desktop/CanvasEDSL.hs`: Haskell EDSL for emitting JSON Canvas nodes/edges.
