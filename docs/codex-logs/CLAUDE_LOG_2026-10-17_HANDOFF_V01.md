# Claude execution log — owner handoff, 2026-10-17

Actor: Claude (owner-designated coordinator and TASKS.md writer since 2026-10-17).
Start HEAD: `e0401dd` (after fast-forwarding 5 owner commits; incoming paths were disjoint from the 8 dirty owner paths, no stash needed).

## Root causes found

1. **M33-004 loop.** All R16–R24 `BUDGET_UNKNOWN` outcomes were a self-imposed 120 s real-time wall cap hitting at ~100 shots while levels allow 96–224 moves. Not game outcomes.
2. **Recurring project.godot / main.tscn drift, ~100 safe-sync stashes, World Map invalid UID warning.** `*.uid` was gitignored, so UIDs regenerated per checkout and the editor rewrote references.
3. **Godot import bloat.** Godot imported ~1.6 GB of evidence images under `coordination/`; `.godot/` was 1.4 GB.
4. **Most legacy probes failing.** The M32 first-play tutorial holds the result overlay until it finishes; probes written before M32 never saw a result screen.

## Work

- `4291ab9` commit `.uid` sidecars, unignore `*.uid`, fix `WorldMapScene.tscn` UID, adopt local UID refs in `project.godot`/`main.tscn`, add `.gdignore` to `coordination/` and `docs/`. Godot import cache for evidence purged (1.1 GB freed, regenerable).
- Difficulty removal (owner ruling): `ObjectiveCostModel` replaces `M17DifficultyModel`; `difficulty_tier` dropped from generator and the nine generated level files (no other field changed; validator PASS); difficulty analytics tools/tests deleted.
- M33-004: uncensored fixed-fps runner; 100/100 sampled levels won within 4T. See `coordination/sessions/BCM-M33-004-CLAUDE-V01/M33_004_CLAUDE_REPORT.md`.
- M34-005: 78 obsolete qualification/pilot tools/tests and the R18 qualification studio removed; 302 untracked harness residue files (24.9 MB) removed; 16 stale worktree registrations pruned; new `tests/run_regressions.py` replaces the per-remediation PowerShell suites. Inventory: `coordination/sessions/BCM-M34-005-CLAUDE-V01/cleanup_inventory.json`.
- Codex R21/R24 leftover evidence and `CODEX_LOG_M34_R24_V01.md` archived.

## Not done / not verifiable here

- M34-006 rewarded ads and M34-007 billing need owner-provided AdMob IDs, store product catalog, consent/age decisions, backend choice and device/emulator permission.
- No phone/device test, no human playtest, no native install/signing.
- 69 MB of art not referenced at runtime (masters, sources, planned screens) kept: ambiguity defaults to KEEP.
- ~1.58 GB tracked historical evidence and 100 owner safe-sync stashes kept pending owner decision.

TASKS.md updated by Claude after this evidence review.
