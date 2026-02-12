RFC-0002: Hardware-OS Inspector Protocol
========================================

Status: Draft  
Version: 1.0  
Depends on: RFC-0001  
Last Updated: 2026-02-08

Abstract
--------

This RFC defines the Inspector Protocol: a projection interface
for interacting with Hardware-OS kernels.

The inspector is a read-only projection surface over canonical
kernel state. It provides visualization, comparison, replay
navigation, and validation display.

The inspector MUST NOT redefine kernel truth.

This RFC defines:

- inspector API contracts
- projection semantics
- compare semantics
- replay navigation rules
- validation integration
- trust boundaries
- conformance requirements

Normative Language
------------------

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”,
“SHALL NOT”, “SHOULD”, “SHOULD NOT”, and “MAY” are to be
interpreted as described in RFC 2119.

1. Inspector Model
------------------

The inspector is a client of a Hardware-OS kernel.

It is not a kernel implementation.

The inspector MUST treat kernel outputs as authoritative.

The inspector MAY:

- visualize
- annotate
- filter
- compare
- navigate history

The inspector MUST NOT:

- modify canonical data
- redefine validation rules
- invent replay semantics

2. Inspector API Surface
------------------------

The inspector communicates with a kernel adapter via HTTP.

This RFC defines a minimal API surface.

### 2.1 Bundle endpoint

GET /api/bundle?project=<path>

Returns:

```
{
  "projectDir": string,
  "manifest": object,
  "layers": object,
  "history": array
}
```

The inspector MUST treat this bundle as immutable.

The inspector MUST NOT mutate bundle contents.

### 2.2 Validation endpoint

GET /api/validate?project=<path>&strict=<bool>

Returns:

```
{
  "ok": boolean,
  "exitCode": number,
  "issues": array | null,
  "stdout": string,
  "stderr": string,
  "strict": boolean
}
```

The inspector MUST display validation results without
reinterpreting them.

Validation authority remains with the kernel.

3. Projection Semantics
-----------------------

Projection is a pure visualization of bundle state.

The inspector MUST NOT:

- reorder history
- mutate layer data
- normalize structures differently than the kernel

Projection MUST be read-only.

Any edits MUST be treated as proposals, not canonical changes.

4. Compare Mode
---------------

Compare mode visualizes differences between two bundles:

    left bundle vs right bundle

The inspector MUST compute diffs without modifying either bundle.

### 4.1 Node diff categories

Nodes MUST be categorized as:

- same
- changed
- missing-in-right
- missing-in-left

Diff classification MUST be deterministic.

### 4.2 Semantic-only comparison

Inspectors MAY offer a semantic comparison mode.

Semantic comparison SHOULD ignore layout fields:

- x
- y
- width
- height

Other fields MAY be ignored if documented.

5. Replay Navigation
--------------------

Replay navigation is a visualization of history traversal.

The inspector MUST treat history as append-only.

Scrubbing history MUST NOT modify the underlying log.

Inspectors MAY highlight event targets.

Replay visualization MUST remain deterministic.

6. Geometry Overlay
-------------------

The inspector MAY render geometry as a base identity layer.

If overlay is enabled:

- geometry MUST be drawn read-only
- other layers MUST reference geometry IDs

Overlay is visualization only.

7. Inspector State
------------------

Inspector UI state (camera, selection, filters) is ephemeral.

Inspector state MUST NOT be written into canonical project files.

Inspector persistence MAY be local-only.

8. Trust Model
--------------

The inspector is untrusted relative to the kernel.

Truth flows:

    kernel -> inspector

Never:

    inspector -> kernel

Inspectors MUST defer validation and replay authority
to the kernel.

9. Security Considerations
--------------------------

Inspector servers are local debugging tools.

Inspectors SHOULD warn users when exposed to networks.

Inspectors MAY implement safe path restrictions.

Inspector APIs MUST assume untrusted user input.

10. Conformance
---------------

An implementation conforms to RFC-0002 if:

- it does not redefine kernel semantics
- it treats bundle data as immutable
- it defers validation authority
- it implements deterministic compare classification
- it preserves replay ordering

11. Compatibility
-----------------

Inspectors MUST remain forward-compatible with RFC-0001.

Inspectors MUST NOT break valid kernel bundles.

12. Extensibility
-----------------

Future extensions MAY include:

- edge diff semantics
- branch timelines
- merge visualization
- multi-bundle comparison
- replay animation
- distributed inspectors

Extensions MUST preserve kernel authority.

13. Conclusion
--------------

The inspector is a projection surface.

The kernel remains the source of truth.

Separation preserves determinism and prevents UI drift.

