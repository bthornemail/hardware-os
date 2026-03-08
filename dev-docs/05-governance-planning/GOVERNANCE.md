# Hardware-OS Governance

Status: Draft  
Version: 1.0

## Structure

- Kernel Council: maintains kernel invariants and semantic contracts.
- Reference Validator Team: maintains conformance behavior and test vectors.
- Extension Registry Maintainers: curate optional extension proposals.

## Decision Scope

- Kernel semantics changes require explicit RFC updates and migration notes.
- Reference behavior changes require test updates and release notes.
- Extension additions must not alter core kernel truth rules.

## Amendment Process

1. Open an RFC with motivation, normative deltas, and compatibility impact.
2. Publish implementation and conformance-test implications.
3. Approve by maintainer consensus with explicit effective version.
4. Update canonical docs under `dev-docs/` in the same change set.

## Emergency Rule

Emergency amendments are permitted only for correctness, integrity, or security defects and must include a follow-up full RFC ratification.

## Canonicality Rule

Governance decisions are canonical only after they are merged into structured docs in `dev-docs`.
