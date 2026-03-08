# Hardware-OS Manifesto

Hardware is not assembled. It is compiled.

Hardware-OS treats a system as a deterministic graph across four projections:

- physical artifact
- virtual model
- runtime behavior
- historical event log

These projections must remain isomorphic or the system is invalid.

## Core Commitments

- Kernel truth is deterministic and append-only.
- History is authoritative for temporal integrity.
- Projection tools (UI, simulators, compilers) must not redefine kernel truth.
- Extensions are optional and must preserve core invariants.

## Language Model

Hardware-OS models systems as layered graphs:

- geometry (identity namespace)
- power
- signal
- runtime
- optional extension layers

Each layer introduces additional constraints while preserving cross-layer identity.

## Build Chain

1. Source graphs (`*.canvas.json`)
2. History (`*.ndjson`)
3. Deterministic validation and replay
4. Materialized artifacts and runtime projections

## Governance Commitment

Normative semantics are defined in structured docs under `dev-docs/`, not in archived transcripts.
