RFC-0005: Hardware-OS Conflict Resolution Policies
==================================================

Status: Draft  
Version: 1.0  
Depends on: RFC-0001, RFC-0003, RFC-0004  
Last Updated: 2026-02-08

Abstract
--------

This RFC defines formal policies for resolving merge conflicts
in Hardware-OS.

Conflicts are first-class events (RFC-0003). They MUST be
represented explicitly and never silently overwritten.

This RFC defines:

- conflict taxonomy
- resolution event structure
- deterministic policy classes
- human-assisted resolution
- replay guarantees
- audit preservation

Resolution is additive. History is never erased.

Normative Language
------------------

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”,
“SHALL NOT”, “SHOULD”, “SHOULD NOT”, and “MAY” are to be
interpreted as described in RFC 2119.

1. Conflict Philosophy
----------------------

Hardware-OS forbids silent overwrite.

Every conflict MUST be visible.

Resolution is modeled as new history, not mutation of past.

Truth is extended, not rewritten.

2. Conflict Taxonomy
--------------------

Implementations MUST classify conflicts into categories.

Minimum required taxonomy:

### 2.1 Identity conflict

Two branches mutate the same node identity.

### 2.2 Topology conflict

Edges or relationships become incompatible.

### 2.3 Deletion conflict

One branch deletes an identity another modifies.

### 2.4 Semantic conflict

Application-level incompatible meaning.

Additional categories MAY be defined.

3. Conflict Event Structure
---------------------------

A conflict event MUST exist in history:

```
{
  "op": "conflict",
  "type": "...",
  "target": "...",
  "left": <event>,
  "right": <event>,
  "hash": "...",
  "prev_hash": \"...\"
}
```

Conflict events are canonical data.

They MUST replay deterministically.

4. Resolution Events
--------------------

A resolution is an explicit follow-up event:

```
{
  "op": "resolve",
  "conflict": hash,
  "policy": \"...\",
  "decision": \"...\",
  "hash": \"...\",
  "prev_hash\": \"...\"
}
```

Resolution does not erase the conflict.

It references it.

5. Resolution Policy Classes
----------------------------

Policies MUST be deterministic.

Allowed baseline classes:

### 5.1 Left-wins

Select left branch state.

### 5.2 Right-wins

Select right branch state.

### 5.3 Merge

Combine fields deterministically.

### 5.4 Reject

Mark identity invalid.

### 5.5 Human-resolved

Explicit external decision encoded as data.

Implementations MAY add policies,
but MUST document semantics.

6. Determinism Rule
-------------------

Given:

    conflict + resolution event

Replay MUST produce identical state
across conforming implementations.

Policy interpretation MUST be deterministic.

7. Human Resolution
-------------------

Human decisions MUST be encoded as data.

No implicit UI state is allowed.

Example:

```
\"policy\": \"human\",
\"decision\": {
  \"chosen\": \"left\",
  \"note\": \"approved by reviewer\"
}
```

Human resolution is still machine-verifiable.

8. Audit Guarantees
-------------------

Resolution MUST preserve:

- original conflicting events
- classification
- decision record
- lineage

Nothing is hidden.

Auditors MUST reconstruct full history.

9. Inspector Responsibilities
-----------------------------

Inspectors MUST:

- show unresolved conflicts
- show resolution events
- link conflict -> resolution
- never hide unresolved conflicts

Inspectors MAY assist human resolution.

Inspectors MUST NOT invent resolutions.

10. Resolution Scope
--------------------

Resolutions apply only to the referenced conflict.

They MUST NOT implicitly resolve unrelated conflicts.

Each conflict is independent.

11. Invalid Resolution
----------------------

If a resolution references a nonexistent conflict:

-> project invalid

If policy is undefined:

-> project invalid

12. Compatibility
-----------------

Older kernels MUST preserve unknown policy events.

Forward compatibility is required.

13. Extensibility
-----------------

Future extensions MAY include:

- multi-party resolution
- voting systems
- weighted merge policies
- domain-specific resolvers
- automated arbitration

Extensions MUST preserve auditability.

14. Security Considerations
---------------------------

Conflict resolution is security-sensitive.

Silent resolution is forbidden.

All decisions MUST be explicit.

Tampering MUST invalidate the hash chain.

15. Conclusion
--------------

Conflicts are data.

Resolution is data.

Nothing disappears.

History remains transparent and replayable.

