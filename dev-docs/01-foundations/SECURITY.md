# Security Model

Hardware-OS focuses on deterministic integrity and tamper detection. It is not designed as an internet-facing service.

## Trust Boundaries

- Kernel (`tools/hd`) defines truth.
- UI (`viewer/`) is a projection surface.
- Server (`tools/hd-serve`) serves static UI and routes to kernel tooling.

## History Guarantees

- Append-only event stream.
- Tamper detection via hash chaining.

## Inspector Server

`hd-serve` is intended for local debugging only.

- Do not expose it to untrusted networks.
- `--safe` restricts `/api/bundle` and `/api/validate` targets to paths under the repo root.

## Non-goals

- authentication
- authorization
- multi-user safety
- sandboxing untrusted code
