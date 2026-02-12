# Demo Suite

The demo suite is an executable proof harness.

Run:

```bash
demos/run-all.sh
```

## What It Proves

- Demo 01: deterministic project creation (`hd init` + `hd validate`)
- Demo 02: canonical example validates (`examples/infinity-cube`)
- Demo 03: history tamper detection (hash mismatch fails validation)
- Demo 04: replay determinism (stable `hd replay` digest)

Passing all demos indicates:

- core invariants are enforced
- history tampering is detectable
- replay digest is deterministic
