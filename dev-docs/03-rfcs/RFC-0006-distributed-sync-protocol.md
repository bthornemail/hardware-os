RFC-0006: Hardware-OS Distributed Sync Protocol
===============================================

Status: Draft  
Version: 1.0  
Depends on: RFC-0001, RFC-0003, RFC-0004, RFC-0005  
Last Updated: 2026-02-08

Abstract
--------

This RFC defines a deterministic synchronization protocol
for exchanging Hardware-OS timelines between nodes.

The protocol guarantees:

- no silent history rewrite
- deterministic merge results
- replay stability
- conflict visibility
- audit preservation

The sync protocol exchanges append-only logs and
timeline metadata. It does not define consensus,
authority, or trust policy.

Normative Language
------------------

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”,
“SHALL NOT”, “SHOULD”, “SHOULD NOT”, and “MAY” are to be
interpreted as described in RFC 2119.

1. Sync Model
-------------

Each node maintains a local timeline DAG.

Sync exchanges:

- branch heads
- ancestry metadata
- missing history segments

Sync never deletes history.

Nodes extend timelines; they do not rewrite them.

2. Node Identity
----------------

Each node SHOULD have a stable identifier:

```
nodeId: string
```

Node identity is advisory and not authoritative.

Sync correctness relies on hashes, not identity.

3. Advertisement Phase
----------------------

Nodes first exchange branch summaries:

```
{
  "branches": [
    { "branchId": "...", "head": hash }
  ]
}
```

This is called an advertisement.

Advertisements MUST be immutable snapshots.

4. Discovery Phase
------------------

Upon receiving advertisement:

- compare local heads vs remote heads
- compute missing ancestry
- request unknown segments

Sync MUST request by hash, not by index.

5. History Transfer
-------------------

History is transferred as a list of events:

```
{
  "events": [ event1, event2, ... ]
}
```

Events MUST include full hash chain.

Receiver MUST verify:

- hash correctness
- prev_hash linkage
- ancestry validity

Invalid events MUST abort sync.

6. Branch Import
----------------

Imported history creates or extends branches.

Existing branches MUST NOT be mutated.

New heads are appended.

Branch ancestry MUST remain acyclic.

7. Merge After Sync
-------------------

If two branches diverge:

Sync MUST NOT auto-merge silently.

Nodes MAY:

- keep branches separate
- trigger RFC-0003 merge
- expose conflicts

Merge is optional and explicit.

8. Deterministic Outcome Rule
-----------------------------

Given identical input histories:

All conforming nodes MUST converge to identical
timeline structure.

Ordering MUST follow RFC-0003 rules.

No implementation-defined randomness allowed.

9. Idempotency
--------------

Sync MUST be idempotent.

Receiving the same events twice MUST produce
identical state.

Duplicate events MUST be ignored safely.

10. Partial Sync
----------------

Nodes MAY sync partial timelines.

Partial sync MUST preserve integrity:

- no broken hash chain
- no orphaned events

11. Trust Model
---------------

Sync does not imply trust.

Nodes MUST validate all incoming data.

Invalid data MUST be rejected.

Sync is transport-neutral.

12. Transport Layer
-------------------

This RFC does not mandate transport.

Examples MAY include:

- HTTP
- WebRTC
- file exchange
- peer-to-peer messaging

Transport MUST preserve event bytes exactly.

13. Conflict Propagation
------------------------

Conflicts are synced as normal events.

Conflict visibility MUST propagate across nodes.

Resolution events MUST sync identically.

14. Security Considerations
---------------------------

Sync MUST assume hostile peers.

Attack resistance relies on:

- hash validation
- ancestry verification
- deterministic replay

Nodes MUST never accept unverifiable history.

15. Compatibility
-----------------

Older nodes MUST preserve unknown metadata.

Forward compatibility is required.

16. Extensibility
-----------------

Future extensions MAY include:

- compression
- snapshot sync
- incremental checkpoints
- bandwidth optimization
- authenticated identities
- permission layers

Extensions MUST preserve determinism.

17. Conclusion
--------------

Distributed sync extends timelines.

Truth is exchanged, not negotiated.

History remains append-only.

Conflict remains explicit.

Replay remains deterministic.

