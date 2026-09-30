# BCM-M19-004 — Canonical Island Sequence

Execute only after Child 03 PASS.

Validate and, only if needed, correct canonical island ordering and next-island chain to the locked 10-slot sequence. Preserve `final_island` as a placeholder with public name explicitly TBD; do not invent a final name.

Add a focused sequence probe covering order indices, next links, uniqueness and terminal final slot.

Log to `CODEX_LOG_V01_CHILD_04.md`. Stop on failure before Child 05.
