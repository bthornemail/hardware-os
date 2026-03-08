# Inspector UI

The Inspector is a local projection UI over kernel state.

- Kernel (`tools/hd`) defines truth.
- UI (`viewer/`) displays projections of that truth.

The Inspector does not implement its own validator semantics.

## Running

```bash
tools/hd-serve --port 8787
```

Open:

- `http://127.0.0.1:8787/viewer/`

Optional hardening:

```bash
tools/hd-serve --safe
```

## Modes

- Browse: explore one project (layers, nodes, edges).
- Compare: node-level diff of two projects.
- Replay: scrub history (left project only).
- Validate: run kernel validation and display output.

## Compare Semantics

Node diff categories:

- same
- changed
- missing in right
- missing in left

Semantic-only compare ignores layout keys: `x`, `y`, `width`, `height`.

## Safety

`hd-serve` is intended for local debugging.

- Do not expose to untrusted networks.
- Use `--safe` to restrict loaded paths to the repo root.
