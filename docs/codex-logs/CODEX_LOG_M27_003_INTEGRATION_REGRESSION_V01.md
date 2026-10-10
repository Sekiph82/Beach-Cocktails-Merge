# CODEX LOG — BCM-M27-003 — Integration and Full Regression

## Work item

- Work item: `BCM-M27-003`
- Prompt: `coordination/sessions/BCM-M27-MASTER-V01/CHATGPT_M27_MASTER_PROMPT_V01.md`
- Prompt version: `BCM-M27-MASTER-V01`
- Start HEAD: `622ab5d551a7cbf71859e98cb8eff6450d8f5d00`
- Implementation/evidence commit: `05377d29cafa0ae78d0ebc8afc2490760f9475f2`
- Branch target: `main` (worktree remained detached; no branch was created)
- Remote: `origin` — `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Publication: pushed as a fast-forward; local HEAD, `origin/main`, and `git ls-remote origin refs/heads/main` all reported `05377d29cafa0ae78d0ebc8afc2490760f9475f2` after push.

## Sync and preservation

- Before implementation, `git fetch origin main` and `git rev-list --left-right --count HEAD...origin/main` reported `0 0` at start HEAD `622ab5d551a7cbf71859e98cb8eff6450d8f5d00`.
- All Godot invocations used `tests/m27_isolated_godot_runner.ps1`, delegating PID tracking and cleanup to `tests/m26_001_r01_godot_runner.ps1`.
- Sandbox identity: `BCM-M27-MASTER-V01-20261010-Sandbox`; verified sandbox user-data path: `%APPDATA%\Godot\app_userdata\BCM-M27-MASTER-V01-20261010-Sandbox`.
- The runner checked the real owner user-data tree before and after every invocation: 229 files and 38 directories, byte hashes and directory parity preserved. Per-stage log backups matched the owner log files present at stage start. No task-owned Godot process remained after a completed invocation.
- Final protected-asset comparison checked all 832 baseline asset paths and SHA-256/length pairs: 832 checked, 0 missing, 0 changed (`evidence/M27-003/owner_asset_integrity_final.json`).
- Four old rotating diagnostic logs lost in the earlier isolation incident were not recreated. The remaining owner logs and incident evidence were preserved. The owner accepted that loss and authorized continuation in the session.
- `TASKS.md` was not modified. The sandbox-only `project.godot` identity/autoload changes were restored before handoff. One unrelated untracked M26 screenshot already present in this worktree was left untouched and excluded from the commit.

## Implementation and evidence

- Hardened `PresentationFeedbackBridge` trace serialization so delayed events with freed `Object` targets do not raise script errors while collecting presentation diagnostics. The bridge records freed references as an invalid-object marker and avoids unsafe `is Node` checks on freed instances.
- Corrected the M27 runner’s editor gate to read the successful M27-001 isolation probe and to verify owner-data parity after a nonzero Godot exit before reporting the failed invocation.
- Added M27-specific regression copies and probes for historical M01–M20 coverage, full 100-level campaign progression, 4T move limits, plugin fallback, M21 GL QA, and a 120-frame production main-scene boot.
- Added the final M01–M20 regression matrix and M21 screenshot-integrity review under `coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-003/`.

## Commands and results

- `git diff --cached --check`: passed before the implementation/evidence commit.
- M01–M20 inherited regression matrix: 30/30 rows PASS, including corrected reruns of the M07 and M08 capture probes. Matrix: `evidence/M27-003/m01_m20_regression_matrix.json`.
- M21 campaign progression: `M21_CHILD_03_RESULT=PASS completed=100 checkpoints=5`; all levels completed and restart/checkpoint persistence assertions passed. After the freed-target diagnostic fix, the final run had no script errors. Runner exit `0`, cleanup verified.
- M25 move-limit audit: PASS for 100 levels, including 25 VIP levels, inclusive To-Go/VIP `T`, `4T` boundaries, exhaustion, and retry reset. Report: `evidence/M27-003/m25_move_limit_audit.json`.
- Plugin fallback: PASS across BOTH, GFF_ONLY, SPARK_ONLY, NEITHER, and injected plugin failure. All scenarios retained score 6500, best score 6500, chain 1, and identical before/after physics snapshots; freed-target diagnostics also passed. Report: `evidence/M27-003/plugin_fallback_authority.json`.
- M22 effect policy from M27-002: PASS, 97 checks, 16 semantics × FULL/REDUCED (32 rows), no failures, authority hash unchanged. M20 accessibility/settings probe passed persistence, high contrast/reduced-motion state, safe defaults, and save isolation.
- M21 GL QA: two retained valid runs (`M21_QA_clean_run02` and `M21_QA_clean_run04`), each with 16 distinct captures and normal exit/cleanup. Both include 720×1280 and 720×1440 production-path scenarios with GL Compatibility. Earlier attempts with repeated stale frames remain preserved as excluded failure evidence. Captures are automated scenarios, not human gameplay.
- Main-scene boot: PASS after 120 process frames; `GameManager` and `PresentationFeedbackBridge` valid. Runner exit `0`, cleanup verified.
- Guarded clean editor import: runner PASS, exit `0`, cleanup verified. Godot emitted two invalid UID warnings for `WorldMapScene.tscn` and `main.tscn` and loaded those script references by their text paths; no error was reported.
- M27-002 real GL Island Map captures also cover 720×1280 and 720×1440 in `evidence/M27-002/M26-island-map/`.
- `git fetch origin main`, fast-forward push, and post-push SHA comparison passed.

## Files changed

- `scripts/presentation_feedback_bridge.gd`
- `tests/m27_isolated_godot_runner.ps1`
- `tests/m27_003_*.gd`
- `coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-003/**`

## Limitations and handoff

- The test-driven GL captures demonstrate production-path surfaces; no physical-device touch acceptance or human gameplay review was performed.
- Owner-native visual acceptance remains pending and must remain open. M27-002 per-category owner visual review is not claimed.
- The clean editor import emitted the two invalid-UID fallback warnings noted above.
- This is builder evidence, not an independent acceptance audit. No milestone verdict or tracker transition is claimed.

## Final repository state

- Implementation/evidence commit: `05377d29cafa0ae78d0ebc8afc2490760f9475f2`
- At the post-push verification point: `HEAD = origin/main = remote main = 05377d29cafa0ae78d0ebc8afc2490760f9475f2`.
- `TASKS.md` remained byte-for-byte unchanged.
- Required stop marker for the master handoff: `AWAITING_GPT_M27_MILESTONE_AUDIT`.
