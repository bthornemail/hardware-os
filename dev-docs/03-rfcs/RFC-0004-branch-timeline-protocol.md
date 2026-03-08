RFC-0004: Hardware-OS Branch Timeline Protocol
==============================================

Status: Draft  
Version: 1.0  
Depends on: RFC-0001, RFC-0002, RFC-0003  
Last Updated: 2026-02-08

Abstract
--------

This RFC defines the Hardware-OS timeline model.

A timeline is a directed acyclic structure of append-only
history branches. Branches represent alternate evolutions
of state while preserving deterministic replay.

This protocol formalizes:

- branch identity
- ancestry rules
- timeline navigation
- replay windows
- merge lineage
- deterministic branch selection

Timelines extend history without rewriting it.

Normative Language
------------------

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”,
“SHALL NOT”, “SHOULD”, “SHOULD NOT”, and “MAY” are to be
interpreted as described in RFC 2119.

1. Timeline Model
-----------------

A Hardware-OS project history is not a single chain.

It is a set of branches forming a DAG:

    root -> branch -> branch -> ...

Each branch is an append-only log.

No branch rewrites its ancestors.

2. Branch Identity
------------------

Each branch MUST have:

```
{
  "branchId": string,
  "parent": hash | null,
  "head": hash
}
```

Where:

- branchId is globally unique
- parent references the parent branch head
- head is the latest event hash

The root branch MUST have parent = null.

3. Branch Creation
------------------

Creating a branch:

- copies ancestry
- begins a new append-only path
- does not mutate the parent

Branching is equivalent to:

    fork(history at hash H)

4. Ancestry Rules
-----------------

All branches MUST share a common ancestor.

Branches MUST NOT invent history.

Every branch event MUST reference a valid ancestor hash.

Invalid ancestry invalidates the branch.

5. Timeline DAG Constraints
---------------------------

The timeline graph MUST be acyclic.

Cycles invalidate the project.

Branches form a partial order, not a loop.

6. Replay Windows
-----------------

A replay window is defined as:

    replay(branchId, uptoHash)

Replay MUST include all ancestors in order.

Replay MUST be deterministic.

Different implementations MUST produce identical state.

7. Branch Merge Lineage
-----------------------

Merge does not erase branches.

Merge produces:

- a new branch
- with multiple parents

Example:

```
merge(A, B) -> C

C.parent = [A.head, B.head]
```

The merge branch preserves ancestry.

Inspectors MUST visualize merge lineage.

8. Deterministic Branch Selection
---------------------------------

If multiple heads exist, a deterministic selector MUST be used.

Default selector:

- lexicographically smallest head hash

Implementations MAY offer UI choice,
but canonical replay MUST specify a rule.

9. Timeline Navigation
----------------------

Inspectors MAY provide:

- branch switching
- ancestor stepping
- merge visualization
- time scrubbing

Navigation MUST NOT mutate history.

10. Branch Integrity
--------------------

Branch operations MUST preserve:

- hash chain correctness
- identity invariants
- layer validity
- replay determinism

Invalid branches MUST be rejected.

11. Conflict Interaction
------------------------

Conflicts are branch-local until merged.

Conflict visibility MUST survive across branches.

Merges MUST preserve conflict events.

12. Storage Model
-----------------

Branches MAY be stored:

- as separate logs
- as tagged heads
- as DAG metadata

Storage format is implementation-defined.

Replay semantics are normative.

13. Inspector Responsibilities
------------------------------

Inspectors MUST:

- display branch ancestry
- show merge points
- allow branch selection
- visualize lineage

Inspectors MUST NOT hide divergence.

14. Compatibility
-----------------

Branch timelines MUST remain valid RFC-0001 histories.

Older kernels MUST safely ignore branch metadata.

15. Extensibility
-----------------

Future extensions MAY include:

- branch labels
- permissions
- distributed sync
- branch pruning
- timeline compression

Extensions MUST preserve ancestry integrity.

16. Security Considerations
---------------------------

Branches MUST not rewrite history.

Branch spoofing MUST be detectable via hashes.

Timeline integrity relies on cryptographic chaining.

17. Conclusion
--------------

Hardware-OS timelines model alternate futures.

Truth is preserved.
Branches are explicit.
Merges are traceable.

History becomes a navigable space, not a single line.

