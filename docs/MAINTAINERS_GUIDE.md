# Maintainers Guide

## Compatibility Contract

The current compatibility anchor is the behavior of `tools/hd`.

Breaking changes include:

- canonical serialization changes
- hash-chain rule changes
- replay digest construction changes
- output/exit code contract changes for `validate`

Any such change requires:

1. explicit versioning/migration note
2. spec update in `dev-docs/02-specification`
3. reference behavior update in `dev-docs/04-implementation`

## Release Discipline

Before cut/tag:

1. validate reference project
2. verify replay digest determinism
3. verify history tamper detection
4. verify viewer validate mode still delegates to kernel
5. verify safe mode path restrictions

Suggested command set:

```bash
python3 tools/hd validate examples/infinity-cube
python3 tools/hd replay examples/infinity-cube
python3 tools/hd replay examples/infinity-cube
python3 tools/hd validate examples/infinity-cube --format json
python3 tools/hd validate examples/infinity-cube --format github
python3 tools/hd-serve --safe --port 8787
```

## Security Posture

- `hd-serve` is local-debug oriented.
- Do not expose it to untrusted networks.
- Preserve path traversal protections in `/viewer/*`.
- Preserve safe mode restrictions for API targets.

## Repo Health Gaps to Track

Current observed gap in this checkout:

- scripts in `tools/` and `demos/` lack executable bit, causing direct invocation failures.

If intended for CI/users, normalize file modes.

## Planned vs Implemented Hygiene

Maintain explicit separation:

- implemented now: `hd init/validate/replay`, `hd-serve`, viewer, example project
- planned/stubbed: `hd-compile`, `hd-merge`, `hd-sim`, wrapper `hd-replay`

Never document planned tools as production-ready without implementation landing.
