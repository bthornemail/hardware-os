# Hardware-OS Documentation (Contributors + Maintainers)

This folder documents the **actual implemented behavior** in this repository for contributors and maintainers.

## Start Here

- `PROJECT_ACTUAL_FUNCTIONALITY.md`: what the code does today, and what is still stubbed.
- `CONTRIBUTORS_GUIDE.md`: how to add/change behavior safely.
- `MAINTAINERS_GUIDE.md`: release discipline, compatibility boundaries, and operational checks.
- `LOGIC_LADDER_AND_CONSTITUTION.md`: logic-ladder and seven-invariant metastructure mapped to this codebase.

## Scope

This folder is implementation-facing. Normative dev spec documents remain under `dev-docs/`.

## Current Runtime Note

In this checkout, `tools/hd`, `tools/hd-serve`, and demo scripts are not executable (`chmod +x` not set).
Use:

- `python3 tools/hd ...`
- `python3 tools/hd-serve ...`
- `bash demos/run-all.sh` (still fails if it calls non-executable tools directly)
