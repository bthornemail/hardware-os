# Logic Ladder and Metastructure Constitution

This maps the requested logic ladder and seven-invariant metastructure onto the current Hardware-OS codebase.

## Logic Ladder (Interpretive Frame)

Relevant logical strata for this ecosystem:

- propositional logic
- first-order logic
- second-order logic
- higher-order logic
- grammar-level rules
- concurrent constraint logic
- rule-engine style execution

In this project, these are not separate products. They are different descriptive levels over one deterministic pipeline.

## Seven-Invariant Metastructure

The seven invariants are a constitutional shell that logical orders inhabit.

1. type theory / axioms
2. boundaries / BICF / constraints
3. geometry
4. hypergraph structure
5. provenance
6. federation
7. projection surfaces

## Constitutional Basis

- type theory / axioms
  - manifested as strict data-shape and hash admissibility constraints
  - concrete anchors: `tools/hd`, `schemas/kernel/manifest-schema.json`
- boundaries / BICF
  - kernel truth vs projection boundary
  - concrete anchors: `tools/hd` vs `viewer/index.html`, `tools/hd-serve`

## Structural Basis

- geometry
  - geometry layer is identity namespace for cross-layer admissibility
  - concrete anchor: cross-layer node-id check in `tools/hd`
- hypergraph
  - layered node-edge graphs per canvas file
  - concrete anchors: `layers/*.canvas.json`, graph checks in `tools/hd`

## Historical / Distributed Basis

- provenance
  - append-only NDJSON with hash chain
  - concrete anchor: `validate_history` in `tools/hd`
- federation
  - currently minimal/local; compare mode and replay establish pre-federation semantics
  - concrete anchors: viewer compare/replay, RFC track in `dev-docs/03-rfcs`

## Observable Basis

- projection surfaces
  - browse/compare/replay/validate UI as non-authoritative observational layer
  - concrete anchors: `viewer/index.html`, `/api/bundle`, `/api/validate`

## Architectural Consequence

The seven invariants are not alternatives to logic systems.
They define admissible structure across logical levels, with determinism and provenance as system-wide constraints.

In short:

- logic determines expressibility
- invariants determine admissibility
- kernel determines authority
- projections determine observability
