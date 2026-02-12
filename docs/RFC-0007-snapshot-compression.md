RFC-0007: Hardware-OS Snapshot Compression
==========================================

Status: Draft  
Version: 1.0  
Depends on: RFC-0001, RFC-0004, RFC-0006  
Last Updated: 2026-02-08

Abstract
--------

This RFC defines snapshot compression for Hardware-OS timelines.

Snapshots accelerate replay by materializing a verified
state checkpoint while preserving append-only history.

Snapshots are optimization artifacts.
They do not replace canonical history.

Normative Language
------------------

The key words MUST, MUST NOT, REQUIRED, SHALL, SHOULD, MAY
are interpreted per RFC 2119.

1. Snapshot Model
-----------------

A snapshot represents:

    replay(history up to hash H)

It is a derived artifact, not truth.

History remains canonical.

2. Snapshot Structure
---------------------

```
{
  "snapshotHash": hash,
  "baseHash": hash,
  "state": object
}
```

Where:

- baseHash = last event included
- state = canonical replay state

3. Determinism Rule
-------------------

Replaying from snapshot MUST produce identical results
to replaying full history.

Snapshots MUST be verifiable by recomputing replay.

4. Compression Guarantee
------------------------

Snapshots MAY omit prior history only for transport.

Canonical archives MUST preserve full history.

5. Snapshot Validity
--------------------

If snapshot state hash != replay hash:

-> snapshot invalid

Kernel MUST reject invalid snapshots.

6. Sync Interaction
-------------------

Snapshots MAY be exchanged during RFC-0006 sync.

Receivers MUST verify before trusting.

Snapshots MUST NOT override history.

7. Storage Policy
-----------------

Implementations MAY prune old snapshots.

History MUST remain reconstructable.

8. Security Considerations
--------------------------

Snapshots are untrusted hints.

Verification is mandatory.

9. Conclusion
-------------

Snapshots accelerate replay.
They never redefine truth.

