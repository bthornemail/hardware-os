# Contributors Guide

## Development Baseline

Primary implementation surfaces:

- kernel logic: `tools/hd`
- local API adapter: `tools/hd-serve`
- UI projection: `viewer/index.html`
- reference sample: `examples/infinity-cube/`

## How to Run Locally

Use explicit interpreters in this checkout:

```bash
python3 tools/hd validate examples/infinity-cube
python3 tools/hd replay examples/infinity-cube
python3 tools/hd init /tmp/hd-scratch
python3 tools/hd-serve --port 8787 --safe
```

Open:

- `http://127.0.0.1:8787/viewer/`

## Contribution Rules

1. Keep kernel deterministic.
2. Do not move validator semantics into the UI.
3. Preserve canonical JSON hashing behavior.
4. Keep cross-layer identity rule stable unless explicitly versioned.
5. Document behavior changes in `dev-docs/` and update this folder's implementation notes.

## Adding Validator Rules

When adding a new rule in `tools/hd`:

1. place it in the existing validation pipeline order
2. make error messages deterministic and stable
3. ensure JSON/text/github formats still align
4. add or update demo/test fixture behavior

## Adding API Endpoints

When changing `tools/hd-serve`:

1. enforce root-bound path checks where relevant
2. keep safe-mode semantics strict
3. keep response shape explicit and version-stable
4. avoid duplicate kernel logic; invoke kernel command when possible

## Viewer Changes

UI may add projection features, but it must not:

- redefine validity
- write canonical project state
- bypass kernel for authoritative validation

## Pull Request Checklist

- behavior change summarized with before/after examples
- no nondeterministic ordering introduced
- docs updated in `docs/` and `dev-docs/` as needed
- manual run commands included
