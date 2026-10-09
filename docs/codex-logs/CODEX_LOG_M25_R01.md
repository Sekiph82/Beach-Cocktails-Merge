# Codex execution log — BCM-M25-R01

- Prompt: `coordination/sessions/BCM-M25-MASTER-V01/BCM-M25-R01_CRASH_AND_RESULTS_VALIDATION_PROMPT.md`
- Locked criteria: `coordination/sessions/BCM-M25-MASTER-V01/BCM-M25-R01_AUDIT_CRITERIA_V01.md`
- Start HEAD: `1f066825fddf18c5f8ccec01203fb7b16514cb35`
- Branch / remote: `main` / `origin`
- Sync preflight: canonical Desktop checkout was four commits behind and zero ahead. Seven modified tracked owner paths were inventoried; incoming paths (TASKS and current M25 prompt/audit files) were disjoint. A tracked-only stash named `owner-local-safe-sync-7c87899` was created and reapplied; untracked owner files were left in place. Fast-forward completed with local and origin at `1f066825fddf18c5f8ccec01203fb7b16514cb35` before work.
- Pre-probe save and owner-file snapshot: `coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-R01/pre_probe_integrity_snapshot.json`.

## Scope and changes

- Updated `tests/m21_mobile_qa_probe.gd` to allow an R01-only capture directory and to explicitly cancel presentation bridges, clear Spark, free the production shell, wait for queued frames, and synchronize the renderer before process exit.
- Added genuine gameplay InputEvent evidence runners and isolated R01 output under `coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-R01/`.
- Production gameplay, campaign, Results, presentation policy, assets, and root `TASKS.md` were not edited. M25-001/002/003 implementation was already integrated in the repository; no retroactive child commits were created.

## Crash and renderer evidence

- Prior run printed 16-capture PASS but exited `-1073741819` (`0xC0000005`). Windows Error Reporting identifies Godot 4.7.2 faulting in `igxelpicd64.dll` 31.0.101.3616 at offset `0x2e1ee1` on Intel Iris Xe; matching event evidence for Oct 6 and Oct 9 is in `evidence/M25-R01/crash/prior_wer_diagnostics.json`.
- Builder diagnosis: failure occurs during GL process teardown after capture, with an Intel GL driver fault recorded by WER. The runner now explicitly tears down effect bridges/Spark and waits for renderer synchronization before quit. This mitigation is repeatable; the exact driver-level root cause is not proven and no driver change was made.
- `clean_gl_run_01` and `clean_gl_run_02`: Godot 4.7.2, GL Compatibility, both canonical 720x1280 and tall 720x1440, 16 captures each, zero assertion failures, empty stderr, and process exit 0. Both logs record `bridges_canceled=true spark_cleared=true renderer_synced=true`.
- `--headless` on the screenshot-only M21 runner exits 1 because all 16 viewport captures are unavailable in a headless renderer. This is recorded as a renderer mismatch, not used as a gameplay or mobile QA result; the real GL runs above are the applicable evidence.

## Genuine Results route

- The R01 runner starts production Home, launches through PLAY, and sends automated mouse `InputEvent`s through `ShotController._unhandled_input`; real Drink physics/collisions/merges, score and campaign objectives resolve the terminal result. It does not call result presentation or inject a terminal result. `human_operated=false` is recorded explicitly.
- `full_win_03`: GL Compatibility FULL, natural Sunny Cove Level 1 WIN, score 775, 3 stars, first clear, reward record, 14 shots / 28 mouse events; before/event/settled screenshots and timestamps are recorded. Result title/body preserve production values. Automated pointer activation did not navigate the result action, so `action_route_ok=false` is retained in the report.
- `reduced_win_01`: GL Compatibility REDUCED, natural Level 1 WIN, score 1173, 3 stars, first clear, 16 shots / 32 mouse events; before/event/settled captures recorded.
- Natural LOSE was not achieved. The FULL LOSE attempt instead reached a real WIN after gameplay; it remains labeled `expected_outcome=LOSE`, `actual_outcome=WIN` in evidence. No fake LOSE claim is made. A genuine REDUCED LOSE and genuine 1-/2-star routes were also not obtained. Result Retry/action behavior is covered by the M25 presentation probe through the production button action signal, but real mouse navigation after a gameplay terminal is unverified.
- `full_win_01`, `full_lose_02`, and `full_win_02` are retained as earlier R01 attempts. `full_win_02` reused an R01 test profile and began at an advanced frontier; subsequent scenario runs use separate fresh APPDATA roots. The owner save files were never used as test profiles.

## M25 source-to-criterion traceability

- M25-001 Results entrance / immutable data / actions: `scripts/campaign/campaign_feedback_overlay.gd` `show_result` and `scripts/presentation_feedback_bridge.gd` `_result_presentation_plan`; production terminal signal routing is `scripts/campaign/campaign_navigation_controller.gd` `_on_session_terminal` / `_present_pending_terminal_result`. Focused checks: `tests/m25_result_presentation_probe.gd` (22 checks, PASS), M24-001/002/003 evidence, and M21 production routing probes. No separate intermediate M25-001 build/commit exists.
- M25-002 WIN tiers, replay/deduplication, particle ceiling, reduced motion: `scripts/presentation_feedback_bridge.gd` result token guard and `_result_presentation_plan` (48-live-particle clamp); focused probe checks ordinary WIN, mastery, first-clear, reward priority, duplicate suppression, REDUCED zero Spark, immutable score/reward, and actual live pool bounds (22/22 PASS). M22-001/002/003 and M23-003 regressions also pass. Integrated source was already delivered as one commit; no fabricated child commit history was added.
- M25-003 LOSE policy and retry/map action shape: same result planner’s `game_fail` branch and `CampaignFeedbackOverlay.show_result`; focused probe confirms zero Spark, duration caps, unchanged LOSE copy, Retry/Island Map actions, stable hitbox, and one Retry action emission. This is synthetic result-policy/action evidence; it does not substitute for missing genuine gameplay LOSE evidence.
- Additional criterion-by-criterion source map and artifact references: `coordination/sessions/BCM-M25-MASTER-V01/evidence/M25-R01/source_traceability.md`.

## Regression and integrity results

- M02 physics: `M02_PROBE_RESULT=PASS`.
- M09 audio/haptics and merge cleanup: `M09_AUDIO_HAPTICS_RESULT=PASS`.
- M15 VIP/economy: `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS`.
- M21 100-level progression and persistence: `M21_CHILD_03_RESULT=PASS completed=100 checkpoints=5`; release persistence PASS; M21 GL mobile QA PASS twice, 16 captures per run.
- M22 plugin contract / semantic bridge / effect policy: PASS, 21 / 27 / 97 checks; absence-of-both-plugins safely no-ops. M23 color restoration PASS, 13 checks across seven scenarios with exact Color equality.
- M23-001/002/003: PASS, 28 / 30 / 30 checks; recorded active particle peak 40 in M23-002. M24-001/002/003 each exit 0 and write reports with empty failure lists.
- M25 result presentation: `M25_RESULT_PRESENTATION_PROBE_RESULT=PASS checks=22 failures=0`.
- Godot 4.7.2 `--headless --editor --path <repo> --quit`: exit 0. `--headless --path <repo> --quit-after 120`: exit 0. `git diff --check`: exit 0 (line-ending warnings only).
- Pre/post owner integrity: `evidence/M25-R01/post_probe_integrity_report.json` records 35/35 protected owner saves/blobs/tree files matching their pre-probe SHA-256. Campaign save, backup, save.cfg and settings hashes match the initial snapshot. Godot editor import temporarily rewrote owner-local `project.godot`; it was restored byte-for-byte from the preserved exact stash blob and verified against its pre-probe hash. The historical M23 mobile_qa images accidentally written during the first malformed launch were restored to their original HEAD bytes and independently hash-checked; no M23 history remains modified by that incident.
- Stashes were not dropped. Owner-local paths and supplied Home PNGs remain unstaged and uncommitted.

## Files, status, and limitations

- Intended publication: this execution log, `tests/m21_mobile_qa_probe.gd`, and the new M25-R01 evidence directory only.
- `TASKS.md` was not modified. M26 was not started.
- Manual physical-device checks were not performed. Automated mouse InputEvents are not claimed as human-operated input. Real result-button pointer routing, genuine FULL/REDUCED LOSE, and genuine one-/two-star terminal runs remain unverified. The R01 acceptance chain therefore remains for independent audit; no acceptance verdict is claimed.
- Owner-local `project.godot`, M21/M22 evidence and owner Home PNGs are preserved outside the staged publication set.
- Implementation/evidence commit SHA: `2efa9413844b0b163a2a855ac8069508dd4fb2d7` (pushed to `origin/main`). At post-push verification, local HEAD, `origin/main`, and `git ls-remote origin refs/heads/main` all returned `2efa9413844b0b163a2a855ac8069508dd4fb2d7`; ahead/behind was `0/0`.
- The log-only publication finalization is a subsequent commit; its full SHA is recorded in Git history. Local pre-existing owner modifications and untracked owner files remain unstaged and preserved; no M25-owned path is left unpublished.
- Required stop marker: `AWAITING_GPT_M25_R01_REAUDIT`.
