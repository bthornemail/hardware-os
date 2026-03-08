RFC-0009: Hardware-OS Access Control Model
==========================================

Status: Draft  
Version: 1.0  
Depends on: RFC-0001, RFC-0006  
Last Updated: 2026-02-08

Abstract
--------

This RFC defines an access control model for Hardware-OS.

Access control governs who may append history.

It does not alter history semantics.

1. Authorization Model
----------------------

Authorization is evaluated before event acceptance.

Rejected events never enter history.

2. Identity
-----------

Actors MAY have cryptographic identities.

Signatures MAY accompany events.

3. Verification
---------------

Nodes MAY require signatures.

Unsigned events MAY be rejected.

4. Determinism Rule
-------------------

Authorization decisions MUST be deterministic
within a node policy.

5. Policy Scope
---------------

Access policy is local configuration.

It is not embedded in canonical history.

6. Sync Interaction
-------------------

Nodes MAY refuse to import unauthorized events.

Rejected events MUST NOT corrupt local history.

7. Conclusion
-------------

Access control filters writes.
It does not rewrite truth.

