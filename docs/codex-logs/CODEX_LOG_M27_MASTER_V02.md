# CODEX MASTER LOG — BCM-M27-MASTER-V01 — V02

Status: `BUILDER_SEQUENCE_COMPLETE; INDEPENDENT_MILESTONE_AUDIT_PENDING`.

## Master work item

- Master: `BCM-M27-MASTER-V01`, prompt V01 at `coordination/sessions/BCM-M27-MASTER-V01/CHATGPT_M27_MASTER_PROMPT_V01.md`.
- Start HEAD after synchronized safe preflight: `9667a1c0ad51cb7f93dcc870e276949006bae205`.
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`, target branch `main`.
- Worktree: `C:\Users\sekip\.codex\worktrees\bcm-m27-master-v01-sandbox` (detached; no branch created).
- Builder implementation commits:
  - M27-001 lifecycle: `d64c63d73f3adaec2f5032f13377406fec3387e1`.
  - M27-002 reduced-motion/presentation: `ec36174a339bc90ec1e2532a8433c6521e27036c`.
  - M27-003 integration/regression: `05377d29cafa0ae78d0ebc8afc2490760f9475f2`.
- Child-log commits:
  - M27-001 log: `95074183d1494e8c87bb21168265e145aa5401e7`.
  - M27-002 log: `622ab5d551a7cbf71859e98cb8eff6450d8f5d00`.
  - M27-003 log: `8e8f74ac1faefad98c2c2c50560aa2666ef033f5`.
- Supporting logs: `CODEX_LOG_M27_001_LIFECYCLE_STRESS_V01.md`, `CODEX_LOG_M27_002_REDUCED_MOTION_V01.md`, and `CODEX_LOG_M27_003_INTEGRATION_REGRESSION_V01.md` under `docs/codex-logs/`.
- Original M27 incident log `CODEX_LOG_M27_MASTER_V01.md` is retained unchanged; this V02 closes the builder sequence without rewriting the incident record.

## Sync, owner preservation, and isolation

- Canonical Desktop was safely synchronized to `9667a1c0ad51cb7f93dcc870e276949006bae205` at task start, preserving owner-local tracked and untracked work.
- Subsequent implementation ran in the managed non-Desktop worktree. Before each work stage, `git fetch origin main` and `git rev-list --left-right --count HEAD...origin/main` confirmed the worktree was synchronized.
- All Godot commands used `tests/m27_isolated_godot_runner.ps1` and the M26 PID-tracking runner. The unique Godot project/user-data identity was `BCM-M27-MASTER-V01-20261010-Sandbox`.
- Across guarded invocations the real owner `CocktailMerge` data remained 229 files and 38 directories with byte-hash and directory parity; the per-stage backups of the remaining owner logs verified. No task-owned Godot process remained after completed invocations.
- Final protected-asset hash audit: 832 baseline assets checked, zero missing and zero changed. Evidence: `coordination/sessions/BCM-M27-MASTER-V01/evidence/M27-003/owner_asset_integrity_final.json`.
- Four rotated owner diagnostic logs lost during the earlier incident were not reconstructed. The owner explicitly accepted their loss and authorized continuation. Remaining owner logs and incident evidence were preserved.
- `TASKS.md` was not modified in any child. Only ChatGPT, after independent audit, may update the tracker.

## Child sequence and evidence summary

### M27-001 — presentation lifecycle stress

- Isolated lifecycle probe: `PASS checks=64 failures=0 dispatches=18 active_particles=40 captures=0`.
- Exercised rapid merge/To-Go/VIP bursts, <=48 live-particle limit, dispatch backpressure, listener reconfiguration, cancellation/color restoration, and 12 terminal-world cleanup cycles.
- Gameplay session bridge regression passed Retry, Island Map return, and single-gameplay-instance assertions.
- Full evidence and limitations are recorded in the M27-001 child log and `evidence/M27-001/`.

### M27-002 — FULL/REDUCED effect policy and accessibility

- M22-003 effect policy: 97 checks, zero failures; 16 semantic kinds with 32 FULL/REDUCED policy rows, unchanged authority hash, and forbidden physics/time/camera effects excluded.
- M20 settings persistence/accessibility regression passed. M23–M26 focused functional regressions passed after correcting the hidden Island Map completion-presentation order and stale M23 test fake behavior.
- Global active-particle cap remained 48.
- Paired owner visual review remains open. The M27-002 child log records a preliminary windowed run that saved captures but exited abnormally during shutdown; those captures are not treated as a clean renderer pass.

### M27-003 — plugin fallback, full regression, boot, and GL scenarios

- M01–M20 historical regression matrix: 30/30 PASS, including final M07 and M08 capture-probe reruns.
- Plugin fallback probe passed BOTH, GFF_ONLY, SPARK_ONLY, NEITHER, and injected plugin-failure scenarios. All retained score 6500, best score 6500, chain 1, and matching before/after physics snapshots. Delayed freed-target diagnostic serialization passed.
- M25 move-limit audit passed all 100 levels, including 25 VIP levels, inclusive To-Go/VIP denominator, `4T` move budget, exhaustion, and Retry reset.
- M21 campaign progression completed all 100 levels with five checkpoints and restart persistence: `M21_CHILD_03_RESULT=PASS completed=100 checkpoints=5`. A reproduced freed-object diagnostic error was fixed in `PresentationFeedbackBridge` and the complete progression rerun passed without script errors.
- Two valid M21 GL QA sets (`M21_QA_clean_run02` and `M21_QA_clean_run04`) each contain 16 distinct production-path captures, cover 720×1280 and 720×1440, and exited normally with process cleanup verified. Earlier repeated-frame attempts are retained and explicitly excluded in `M21_capture_integrity_review.json`.
- A focused main-scene run passed 120 process frames with valid `GameManager` and `PresentationFeedbackBridge` instances.
- Guarded clean editor import exited 0 with cleanup verified. Godot still printed invalid UID fallback warnings for `main.tscn` and `WorldMapScene.tscn`, resolving both scripts by text paths.
- Existing M27-002 windowed Island Map evidence includes valid 720×1280 and 720×1440 captures under `evidence/M27-002/M26-island-map/`.

## Safety and repository validation

- `git diff --cached --check` passed for M27-003 implementation/evidence and log commits.
- All M27-003 evidence JSON files parsed successfully; no malformed report was found.
- No `TASKS.md` path was staged or committed.
- Worktree-local `project.godot` sandbox identity/import changes were restored before handoff. One unrelated untracked M26 screenshot in this worktree was preserved and excluded.
- Each child and child log was pushed in order as a fast-forward to `main`; no force push, branch creation, rebase, or reset was used.

## Open audit and acceptance items

- Owner-native visual acceptance is still pending; no builder result substitutes for it.
- Test-driven captures are not human gameplay or physical-device touch acceptance.
- M27-002 category-by-category paired visual acceptance remains for independent review.
- The two invalid UID fallback warnings from clean editor import remain for audit disposition.
- This log and all child logs are builder claims/evidence indexes. They do not issue the milestone verdict or authorize a tracker transition.

## Final builder handoff

- Required marker: `AWAITING_GPT_M27_MILESTONE_AUDIT`.
- Do not start M28 or edit `TASKS.md` before the independent audit.
- At final publication verification, local HEAD, `origin/main`, and remote `main` will be recorded as the same SHA. The master-log commit is documentation-only and its SHA is recorded by Git history and the post-push verification.

