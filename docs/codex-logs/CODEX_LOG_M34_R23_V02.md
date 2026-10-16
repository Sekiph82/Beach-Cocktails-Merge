# Codex Execution Log — BCM-M34-R23 V02

## Active scope and synchronization

- Work item: `BCM-M33-004` / `BCM-M34-R23`, owner-updated prompt `CHATGPT_M34_R23_SCREENING_PROVENANCE_MASTER_PROMPT.md`.
- Active owner rule: a fixed, reproducible random selection of 10 unique levels per island (100 total), executed in interleaved rounds; each session is capped at 35 minutes and 250 MB new retained evidence. The remaining 900 levels are not authorized.
- The owner updated `origin/main` during the first R23 execution. The update changed only `TASKS.md` and the R23 prompt. Those changes were integrated without conflict in merge commit `2077036`; the current `TASKS.md` blob matches `origin/main` (`a4912c8a9db9ff1c64ea34f6b316bda2a1caec4c`). Codex did not author or edit the tracker.
- Updated-scope starting HEAD: `2077036595dacb62fe999bfaa808d072784f162c`.
- Branch / remote: `main` / `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge`).
- Owner-local pre-existing path inventory: 205 paths; final SHA-256 and byte-length comparison found 0 changed or missing paths.
- Safe-sync stash `owner-local-safe-sync-04ca364` remains intact and was not dropped.

## Superseded pre-update evidence

Before the owner update reached the working checkout, the previous prompt version ran a 22-trial, 30-case screening plan. It is retained as immutable historical builder evidence only and is excluded from the owner-updated random sample. Its manifest elapsed time exceeded the former 35-minute ceiling by 110 seconds because the prior runner timer reset on resume. It is not reported as progress toward the 100 selected levels.

## Frozen selection manifest

- File: `qualification/r23_random_selection_seed_20261016_v01.json`.
- Seed: `20261016`.
- SHA-256: `ef21d5a3023ae7328424da4e459b667c6d6b0dbd567e7a2106cc9b9161d66eb2`.
- Selection: exactly 100 unique `(island, level, global_level_id)` records, 10 per island, without replacement; rounds are interleaved across all 10 islands.
- RNG: deterministic SHA-256 stream with unbiased uint32 rejection sampling and Fisher-Yates shuffle. The manifest was written and validated before new trials.
- Case seed and canonical VIP flag are recorded for each selected level. A separate fail-closed VIP mismatch probe returned exit code 3 with `ERROR/VIP_PROVENANCE_MISMATCH` before gameplay.

## Owner-updated bounded session

Session evidence root: `evidence/M34-R23/sessions/random_sample_v01_session_01/`.

- Main attempt: `20261016T160131517Z_7ec7f46f76f64c5bb387cac3c0d56b8f`.
- Result: `PILOT_PARTIAL`, 22 of 100 selected trials completed. Outcomes: 9 `WIN_OBSERVED`, 13 `BUDGET_UNKNOWN`, 0 losses, 0 errors. The 9 winning levels span 7 islands.
- Every island received its first-round sample before second-round samples began. Trials ran sequentially; each stayed within the 120-second watchdog limit.
- Manifest wall time: 2,067,000 ms; runner stopwatch: 2,068,091 ms. Both are under the 2,100,000 ms session ceiling. Stop reason: `GLOBAL_BUDGET_RESERVE_REACHED`.
- 22/22 trial starts have unique matching finishes and immutable case/trace hashes. There are no duplicate event IDs, trial IDs, levels, or final trace paths; lane parity mismatches: 0; VIP mismatches: 0.
- Trace audit status: `TRACE_AND_MANIFEST_INTEGRITY_PASS_PARTIAL_SESSION`. This is a partial sample and not a campaign qualification verdict.
- The session tree measured 77,887,864 bytes (152 files) at final integrity capture. Total R23 retained evidence measured about 150.6 MB, under the 262,144,000-byte cap.
- The pilot reported a C: free-space delta of -372,023,296 bytes. The final regression rerun reported -1,376,256 bytes. At final capture, C: total size was 1,022,767,394,816 bytes with 77,675,200,512 bytes free.

## Resume safety and regressions

- A plan-only resume probe validated the prior closed session against the same selection-manifest SHA. It carried forward 22 completed unique levels and produced exactly 78 remaining selected levels without launching gameplay or drawing a new sample.
- The resume probe reused the existing isolated APPDATA/LOCALAPPDATA directories. A deliberate seed mismatch also verified fail-closed attempt closure: one `ATTEMPT_STARTED`, one `ATTEMPT_FINISHED`, zero trials, status `PREFLIGHT_ERROR`.
- Final regression suite: `ALL_REQUESTED_REGRESSIONS_PASS`, 10/10: fresh editor import, economy, daily rewards, campaign navigation, M14 bridge, M15 VIP economy, production routes, scene UID, slim content, VIP optionality, and startup smoke. It reused the existing isolated AppData cache.
- Godot 4.7.2 emitted the existing `WorldMapScene.tscn` invalid UID warning (`uid://kf3xtrckwhbr`) and fell back to the text path. The probes exited successfully; the warning remains recorded.
- PowerShell parser checks: 0 parse errors in the R23 runner, audit, selection generator, and regression harness. The intentional invalid-seed probe confirmed the runner writes a closed `PREFLIGHT_ERROR` attempt instead of leaving an open manifest start.
- Manual GUI or phone acceptance was not performed.

## Files changed by this updated-scope continuation

- `tools/campaign/m34_r23_screening_pilot.ps1`
- `tools/campaign/m34_r23_audit_pilot.ps1`
- `tools/campaign/m34_r23_generate_selection.ps1`
- `tests/m34_r23_regression_suite.ps1`
- `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R23/`
- `docs/codex-logs/CODEX_LOG_M34_R23_V02.md`

All older R19-R22 evidence and owner-local files were preserved. The only `TASKS.md` change came from the owner-authored remote commits synchronized during this task; its local blob equals `origin/main`.

## Publication and stop status

- Updated-scope implementation/evidence commit SHA: `a3762d1d3305672fe40453b1c267e4486b5e85be`.\n- Payload publication verification: local `HEAD` = `origin/main` = remote `refs/heads/main` = `a3762d1d3305672fe40453b1c267e4486b5e85be`.
- This V02 execution log is a subsequent log-only commit. The final local/origin/remote refs were verified again after publishing that log commit; see the final handoff.
- The 78 remaining selected levels are not run in this execution. The owner-updated prompt requires a later expressly authorized execution to continue with the same seed, manifest, completed-trial records, and reused isolated AppData.
- Required stop marker: `AWAITING_GPT_M34_R23_INDEPENDENT_AUDIT`.

`TASKS.md` was not edited by Codex.
