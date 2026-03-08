# Development Documentation

This directory is the canonical development documentation set for Hardware-OS.

Historical chat transcripts are archived for provenance, but they are not normative.

## Reading Order

1. `01-foundations/`
2. `02-specification/`
3. `03-rfcs/`
4. `04-implementation/`
5. `05-governance-planning/`
6. `99-archive/`

## Categories

### 01 Foundations

- `01-foundations/ARCHITECTURE.md`: system boundaries and deterministic pipeline
- `01-foundations/KERNEL.md`: kernel behavior contract for `tools/hd`
- `01-foundations/INSPECTOR.md`: UI/projection contract and non-authority boundary
- `01-foundations/SECURITY.md`: trust boundaries and local-only assumptions

### 02 Specification

- `02-specification/SPECIFICATION.md`: canonical hashing and history-chain rules
- `02-specification/STATE_MACHINE_SPEC.md`: formal state-machine semantics

### 03 RFCs

- `RFC-0001` through `RFC-0010`: protocol evolution and extension model

### 04 Implementation

- `04-implementation/REFERENCE_IMPLEMENTATION.md`: normative behavior for current repo implementation
- `04-implementation/IMPLEMENTATION_GUIDE.md`: implementation blueprint for compatible kernels
- `04-implementation/DEMO_SUITE.md`: executable proof harness

### 05 Governance and Planning

- `05-governance-planning/MANIFESTO.md`: stabilized principles and intent
- `05-governance-planning/GOVERNANCE.md`: governance model and amendment flow
- `05-governance-planning/STABILIZATION_PLAN.md`: phased stabilization and launch sequencing
- `05-governance-planning/ROADMAP.md`: near/medium/long-term work

### 99 Archive

- `99-archive/chat_history.md`: raw development transcript archive (non-canonical)
- `99-archive/EXTRACTION_MAP.md`: provenance map from archive themes to canonical docs

## Canonicality Rules

- Normative behavior lives in this ordered doc set.
- Historical transcript files in `99-archive/` are source provenance only.
- If there is a conflict, structured docs in categories `01` through `05` win.
