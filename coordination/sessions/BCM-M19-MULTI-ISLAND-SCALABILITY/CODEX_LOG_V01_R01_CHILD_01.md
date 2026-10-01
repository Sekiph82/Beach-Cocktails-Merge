# CODEX Execution Log — BCM-M19-001 V01-R01

Status: `BUILDER_PASS`

- Start/evidence base: clean synchronized `main` at `7ac53546f78564a82a20f919fd4834a3e2481589` after the frozen selector harness setup gate.
- Harness: `tests/m19_r01_ordered_verification_probe.gd`, SHA-256 `19936ef82ff5299458449537f535968763daed1f`; invocation accepts exactly one selector.
- Exact command: `godot_console.exe --headless --path . --script res://tests/m19_r01_ordered_verification_probe.gd -- --child=1`.
- Exact result: exit `0`; `M19_R01_CHILD_01_RESULT=PASS`. Output contained no Child 02-06 result markers.
- Verified: multi-root load, single-root compatibility, duplicate/cross-island/count rejection, zero-level placeholder, one shared campaign/save/map/session architecture.
- Product freeze check from the setup head across `scripts/campaign/`, `data/campaign/`, M19 policy docs, and canonical island assets: no changed paths.
- `TASKS.md` SHA: `fcb6f4d8e284be936873c4af96b87c436e8a848b`; not modified.

This log is the only R01 evidence changed in the Child 01 publication.
