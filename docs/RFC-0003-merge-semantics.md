RFC-0003: Hardware-OS Merge Semantics
=====================================

Status: Draft  
Version: 1.0  
Depends on: RFC-0001, RFC-0002  
Last Updated: 2026-02-08

Abstract
--------

This RFC defines deterministic merge semantics for Hardware-OS.

Merge combines two append-only histories into a single valid
history without violating kernel invariants.

The merge model guarantees:

- determinism
- replay stability
- no hidden state
- no silent data loss

Merges are structural operations over canonical logs.

Normative Language
------------------

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”,
“SHALL NOT”, “SHOULD”, “SHOULD NOT”, and “MAY” are to be
interpreted as described in RFC 2119.

1. Merge Model
--------------

A merge operates on two valid bundles:

    A = (manifestA, layersA, historyA)
    B = (manifestB, layersB, historyB)

Merge produces:

    M = merged bundle

Merge MUST preserve kernel validity per RFC-0001.

Merge MUST NOT mutate input histories.

Merge produces a new history extension.

2. Preconditions
----------------

Both bundles MUST:

- pass validation
- have valid hash chains
- share compatible schemaVersion
- share identity rules

Invalid inputs MUST abort merge.

3. Merge Strategy
-----------------

Hardware-OS merge is log-based.

Merge is defined as:

    union(historyA, historyB)
    -> deterministic ordering
    -> conflict resolution
    -> append reconciliation events

The merge result MUST itself form a valid hash chain.

4. Event Ordering
-----------------

Merged event ordering MUST be deterministic.

Ordering priority:

1. causal order (prev_hash chain)
2. timestamp `t`
3. lexical hash order

Implementations MUST apply a stable sort.

Different implementations MUST produce identical ordering.

5. Conflict Model
-----------------

A conflict occurs when two histories contain incompatible
operations over the same identity.

Conflicts are not silent.

They MUST be represented explicitly.

Conflict types include:

- concurrent modification of same node
- incompatible edge topology
- identity deletion vs mutation

6. Conflict Resolution
----------------------

Conflicts MUST NOT overwrite silently.

The merge engine MUST emit reconciliation events.

Example:

```
{
  "op": "conflict",
  "target": "node123",
  "left": <eventA>,
  "right": <eventB>
}
```

Conflict events become part of canonical history.

Inspectors MUST visualize conflicts.

7. Deterministic Merge Rule
---------------------------

Given the same inputs A and B:

All conforming implementations MUST produce identical M.

Merge MUST be a pure function:

    M = merge(A, B)

No randomness.
No hidden clocks.
No environment dependence.

8. Replay After Merge
---------------------

Merged history MUST replay deterministically.

Replay digest MUST be stable across implementations.

Conflict events MUST replay as structured state.

9. Layer Integrity
------------------

Merged layers MUST still satisfy:

- geometry identity rules
- dependency ordering
- edge integrity

If merge violates invariants:

-> merge fails

10. Inspector Behavior
----------------------

Inspectors MUST:

- highlight conflict events
- show both sides
- allow navigation
- never hide conflicts

Inspectors MUST NOT auto-resolve silently.

11. Non-Goals
-------------

This RFC does NOT define:

- automatic semantic resolution
- user preference merging
- CRDT behavior
- network consensus
- distributed locking

Merge is structural, not social.

12. Compatibility
-----------------

Merged bundles MUST remain valid RFC-0001 bundles.

Future RFCs MAY define higher-level merge strategies.

This RFC defines the minimal safe merge.

13. Extensibility
-----------------

Future extensions MAY include:

- semantic merge policies
- user-defined conflict resolvers
- merge visualization layers
- branch-aware histories

All extensions MUST preserve determinism.

14. Security Considerations
---------------------------

Merge MUST NOT hide conflicts.

Silent overwrite is forbidden.

Conflict visibility is required for auditability.

15. Conclusion
--------------

Merge in Hardware-OS is explicit, deterministic,
and conflict-preserving.

Truth is never rewritten.

Conflicts are first-class data.

