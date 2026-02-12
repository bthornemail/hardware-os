RFC-0008: Hardware-OS CRDT Extension Layer
==========================================

Status: Draft  
Version: 1.0  
Depends on: RFC-0001, RFC-0003, RFC-0005  
Last Updated: 2026-02-08

Abstract
--------

This RFC defines an optional CRDT extension layer.

CRDT behavior is projection logic,
not canonical kernel truth.

The kernel remains deterministic and append-only.

1. CRDT Layer Model
-------------------

CRDTs operate as interpreters over history.

They do not alter canonical events.

They derive emergent state.

2. CRDT State
-------------

CRDT state MUST be reconstructible from history.

No hidden state is allowed.

3. Conflict Compatibility
-------------------------

CRDTs MAY reduce visible conflicts,
but MUST NOT erase conflict events.

Conflicts remain in canonical history.

4. Replay Guarantee
-------------------

CRDT projection MUST be deterministic.

Given identical history:

All nodes MUST compute identical CRDT state.

5. Authority Boundary
---------------------

CRDT output is advisory.

Kernel truth remains unchanged.

6. Extensibility
----------------

Multiple CRDTs MAY coexist.

They are independent projections.

7. Conclusion
-------------

CRDTs are views.
History remains truth.

