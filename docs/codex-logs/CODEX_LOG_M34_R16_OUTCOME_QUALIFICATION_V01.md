# Codex Execution Log — BCM-M34-R16 Outcome-Based Level Qualification Pilot V01

## Scope and authority

- Work item: `BCM-M33-004`, executed under `CHATGPT_M34_R16_OUTCOME_BASED_LEVEL_QUALIFICATION_MASTER_PROMPT.md`.
- Active checkout: existing non-Desktop worktree `C:\Users\sekip\.codex\worktrees\bcm-m34-r09-deferred-20261015`.
- Start HEAD: `bc3f1f7805cf22a5f5d594afde56dae867c4f4ac`.
- Branch/ref: detached HEAD; publication target `origin/main`.
- Root `TASKS.md` is protected and will not be modified.

## Sync and owner-state preservation

- Canonical Desktop preflight: `main`, 0 ahead / 12 behind before safe sync; fetched `origin/main` at `bc3f1f7805cf22a5f5d594afde56dae867c4f4ac`.
- Eight tracked owner edits and fifteen untracked owner paths matched the R14 preservation manifest SHA-256 values; incoming changes were disjoint.
- Applied tracked-only stash `owner-local-safe-sync-27e38f9`, fast-forwarded Desktop, and reapplied the stash without dropping it. Final Desktop synchronization details will be recorded after publication.
- Reused R15 worktree fast-forwarded from `b60108df472dc1f8536432c893da5b9760d362bf` to the start HEAD; its untracked `r15_parse_probe.json` remains untouched.

## Implementation and evidence

- Added `tools/campaign/m34_r16_outcome_pilot.gd` and `tests/m34_r16_outcome_pilot.ps1` for bounded standard-FPS production-physics runs. The pilot selected six levels on Sunny Cove, Tiki Island, Coconut Beach, and Final Island, paired `WEAK_V02` and `MERGE_AWARE_V01` on one fixed seed per level, and used the canonical normal-objective `theoretical_shots_to_go * 4` cap with optional VIP excluded.
- Added optional incremental checkpointing to `scripts/campaign/m17_seeded_validation_harness.gd`. It records committed actions, progress transitions, merge events, the seed/policy and physics metadata into per-trial partial files. This test harness change does not alter gameplay/runtime mechanics.
- Added `tools/campaign/m34_r16_summarize_pilot.ps1` to generate the concise machine-readable report from watchdog/result/progress evidence, plus `tests/m34_r16_regression_suite.ps1` to isolate and capture the requested regressions.
- The report is `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R16/pilot_attempt03/outcome_qualification_report.json`; each base/replay has a compact watchdog record and a full action/progress trace file. The complete M34-R16 evidence folder is 645688 bytes.
- The six-level sample produced two `WIN_OBSERVED` base trials on Sunny Cove L1 (one per policy), each completing in 9 shots under the 16-shot normal 4T cap. Both same-seed action-log replays independently completed the normal objective, for two additional `WIN_OBSERVED` replay trials. The projected core action inputs match for both retries.
- The remaining nine planned base cases are `BUDGET_UNKNOWN`; one `MERGE_AWARE_V01` Tiki Island L30 process exited with code `-1` after 8 committed actions / 465 physics frames and is `ERROR`. There were zero `LOSS_OBSERVED` cases. Each unknown retains its partial action trace and objective/merge progress. No non-win is described as impossible.
- Each pilot process loaded `LevelDatabase` in `ValidationMode.FULL`, validating all 1,000 level records. The final six-level pilot used a 15-second external process watchdog; observed watchdog wall time ranged up to 20,131 ms including termination, below 25 seconds. The global sampling run was 214,470 ms. Across pilot/controller recovery attempts the recorded pilot tool wall time totals 362,169 ms, below 12 minutes.
- Calibration and controller recovery are separately disclosed in the machine report. An earlier 20-second calibration deadline measured 27,930 ms including termination and is excluded from the six-level sample; it recorded 19 actions and 6 merges without objective progress. The first two runner attempts and a report-rebuild attempt exposed PowerShell aggregation defects. The report was then regenerated read-only from per-trial evidence. That rebuild repeated four timed-out cases whose probes had only partial records; the current Tiki L30 merge-aware result is the recorded `ERROR`.
- A supplementary attempt02 Sunny Cove L1 weak-policy base run and same-seed replay also recorded `WIN_OBSERVED`; both are retained under `pilot_attempt02` but excluded from the final six-level sample counts. During report recovery, the first-pass partial snapshots for Sunny Cove L40 (both policies) and Tiki Island L30 (both policies) were overwritten by their bounded reruns. Their first classifications/times remain in the outer watchdog stdout, but those four earlier action traces were not retained. The final selected trial records point to the latest complete/partial traces; the report marks this evidence limitation explicitly.
- The sample does not distinguish the two policies: each won the same easiest level, and the rest were unknown/error under the short cap. The report recommends a bounded human-studio investigation of Sunny Cove L40, Tiki Island L30, and Final Island L100 before staged 1,000-level solver coverage. It estimates 8.88 hours for one seed across two policies at measured base-run wall cost, 17.76 hours for two seeds, and 9.80 hours for the one-seed paired-policy estimate if observed-rate win retries are included. These are lower-bound scheduling estimates; the censored unknowns do not support quality or reachability extrapolation. Human fairness/UX and owner-native/device acceptance remain unassessed/deferred.
- No production game mechanics, level content, energy/economy, UI, timer policy, star rules, ads/IAP, or root `TASKS.md` were edited.
- Godot import produced one `project.godot` autoload path-to-UID rewrite in the reused worktree. The before-import worktree status had no such diff; the exact one-line generated rewrite was restored to the tracked path after inspection and is excluded from the task commit.

## Validation, outcomes, and limits

- Final fresh editor import: `godot_console.exe --headless --editor --path <worktree> --quit`, Godot 4.7.2, watchdog `EXITED`, exit 0, 34,917 ms, empty stderr.
- Focused/regression suite: Economy 35, Daily Rewards 38, Navigation 17, M14 bridge, M15 VIP/economy, scene UID, production routes, slim content, optional VIP, and startup smoke all `EXITED` with exit 0 (`10/10`). Navigation 17 took 72,701 ms; all other probes also exited under their watchdog budgets.
- Command wrappers: `tests/m34_r16_outcome_pilot.ps1` ran under `tools/campaign/m34_r14_process_watchdog.ps1` with a 600-second external global deadline; the driver used 15-second external per-case watchdogs. `tests/m34_r16_regression_suite.ps1` ran under the same process-identity watchdog, with individual limits of 60 seconds (Navigation 17: 180 seconds). `tools/campaign/m34_r16_summarize_pilot.ps1` rebuilt the report from existing JSON after the driver aggregation defects; it launches no game processes.
- The regression summary confirms `TASKS.md` SHA-256 unchanged: `60f4eb47b37ebe3b20ac2efe1eab42e1b5764ab3` before and after.
- Disk inventory was read-only. The reused worktree contains `.godot/imported` at 1,286,453,057 bytes, `.godot/editor` at 868,519 bytes, and `.godot/exported` at 49,812 bytes. User Roaming Godot data measured 569,366,214 bytes and Local Godot cache 139,434,356 bytes. These were retained. Six task-owned AppData temp directories total 133,613 bytes; the earlier command bundling import with recursive temp removal was rejected before execution, so no deletion retry was made. Regression free-space delta was -3,137,536 bytes; no reclaimed-space claim is made. Final C: free space at inventory was 118,227,390,464 bytes.
- No physical-device, owner-native gameplay, human fairness, campaign-wide physical reachability, or 1,000-level outcome acceptance was performed. Non-win outcomes remain unknown; the one child exit is retained as an error, not reclassified.

## Publication

- Start HEAD in the reused implementation worktree was `bc3f1f7805cf22a5f5d594afde56dae867c4f4ac`; after fetching, `HEAD` and `origin/main` matched with 0 ahead / 0 behind before commit.
- Implementation and complete R16 pilot/regression evidence were committed as `16fffac801510b708d72b29717c2b545b117e245` (`Add R16 outcome-based level qualification pilot`) and pushed normally with `git push origin HEAD:main`.
- Immediately after that push, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `16fffac801510b708d72b29717c2b545b117e245`; ahead / behind was 0 / 0.
- The immutable execution log is being committed separately. `TASKS.md`, `project.godot`, and the untracked `r15_parse_probe.json` were excluded from the implementation commit. No files were staged or published from the retained Desktop owner-local work.
- Root `TASKS.md` SHA-256 is `60f4eb47b37ebe3b20ac2efe1eab42e1b5764ab3` and remains unchanged. The implementation commit changes only R16 harness/tool/test/evidence paths listed by its Git tree.
- Stop marker: `AWAITING_GPT_M34_R16_INDEPENDENT_AUDIT`. BCM-M33-004 remains OPEN; Codex assigns no acceptance verdict.
