# BCM-M34-R11 Mechanical Coverage — Codex Execution Log

## Work item and authority

- Work item: BCM-M34-R11-001 through BCM-M34-R11-005.
- Prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R11_MECHANICAL_COVERAGE_MASTER_PROMPT.md` (master prompt v1).
- Start date: 2026-10-15. Completion handoff marker: `AWAITING_GPT_M34_R11_INDEPENDENT_AUDIT`.
- Start HEAD: `102b83a4eb92ad5da22ef8c148170071f8fd4585`.
- Implementation/evidence end HEAD: `03cc4730d97ce61f1ab3a2b3f696431bb6c49ce4`.
- Branch: detached worktree HEAD based on `main`; no new branch was created.
- Remote: `origin` = `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Worktree reused: `C:\Users\sekip\.codex\worktrees\bcm-m34-r09-deferred-20261015`.

## Sync-first preflight and owner preservation

- Canonical Desktop checkout was at `afe9b94` before safe sync. `origin/main` was `102b83a`; local history was behind-only. The incoming diff did not touch any inventoried dirty owner path.
- Applied the authorized tracked-only preservation procedure using stash `owner-local-safe-sync-afe9b94-pre-M34R11`; no `-u` was used. Seven tracked owner diffs were hash-verified after restore; 15 untracked owner paths were hash-verified and left in place. Existing stashes were not applied or dropped.
- Fast-forwarded the canonical checkout to `102b83a`. The isolated worktree began clean at that synchronized HEAD.
- Implementation was committed as `03cc4730d97ce61f1ab3a2b3f696431bb6c49ce4` and pushed non-force to `origin/main`. At that publication check, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned that SHA; push was a fast-forward from `102b83a`.
- The separate builder-log commit is documentary and follows the implementation commit. Final parity is rechecked after the log commit is pushed.
- Root `TASKS.md` was not edited. `project.godot` has no worktree diff; its fresh-import autoload UID rewrite was restored to the pre-import form.

## Files changed

- `scripts/campaign/m17_seeded_validation_harness.gd` — optional profiling, legal geometry cache, stop-flag and per-frame wall-budget checks, plus deterministic cheap merge-center candidate. Existing call sites retain defaults.
- `tools/campaign/m34_r11_mechanical_coverage.gd` — bounded/restartable R11 runner, complete 1,000-level static checks, deterministic seeded profile/coverage phases, checkpoint rotation, STOP handling, and summary aggregation.
- `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R11/` — two checkpoint slots; static CSV and JSON; profile/coverage summaries; import/parse/probe outputs and exit-code index.
- This log is committed separately from implementation/evidence.

No gameplay rules, economy, level data, visual assets, or root tracker were changed. No Android/ADB, live ads, or IAP action was performed.

## Implementation and mechanical evidence

- The runner starts from all 18 R10 `UNVERIFIED` cases and adds L50 middle-stratum samples for each of 10 islands. The configuration pins island order, policy variants, one deterministic seed per island/level (`34110000 + island_index*1000 + level_id`), 5-second coverage trial cap, 0.65-second profile cap, 480-second aggregate sampling cap, and production ShotController usage. Checkpoints alternate A/B and resume by stable trial ID; STOP is checked between trials and physics frames.
- Every attempted action goes through production `ShotController`/`GameManager` launch and physics. The cheaper candidate uses a single deterministic same-level target pass or legal center fallback; cached lanes are calculated from the production legal geometry once per spawn level. No future-spawn, order, move-budget, VIP, collision, or physics bypass was added.
- The bounded static audit inspected all 1,000 levels: 10 islands; 2,156 normal order rows; normal T range 4–80; total T range 4–568; 167 VIP-enabled levels, counted as optional; zero 4T move-cap failures; zero star-threshold failures; zero save-identifier failures; zero timed levels; zero dynamic-resource failures. CSV has one row per level. Static results are not physical/path proof.
- Profiling ran 54 trials (18 cases × 3 variants). Aggregate observed wall time was 168.607 seconds. Mean observed decision time was 1,824.9 µs for uncached MERGE_AWARE, 1,805.5 µs for cached MERGE_AWARE, and 1,863.7 µs for CHEAP_MERGE_CENTER cached. Observed wall per frame was 20.731 ms, 20.720 ms, and 20.996 ms respectively; sample/probe work was 0.749–0.812 ms/frame, while waiting across the physics-frame boundary was about 15.0 ms/frame. This short run produced only one decision per profile trial and no merges, so it does not establish a meaningful gameplay-path or throughput advantage for the candidate. No built-in engine performance-monitor sum is used in the final aggregate.
- The original completed profile records predated separate shot-commit timing. The harness now records `shot_commit_wall_usec`, but that value is explicitly marked not captured for this persisted profile batch; do not infer a ShotController-only latency from it. Total trial wall and decision/sample/frame waits are available.
- Coverage attempted 33 trials across the 18 requested R10 levels. Recorded trial wall sums: 259.851 seconds coverage + 168.607 seconds profiles = 428.458 seconds. The longest individual samples were about 8.08 seconds; the original harness checked the wall cap between 60-frame action windows, so trials could exceed their nominal per-trial cap. A post-run code correction now checks each physics frame; that corrected check parsed successfully but was not used to rerun the mechanical batch.
- Coverage status among the 28 selected levels: 0 new `PROVED_PATH_WIN`, 17 `BUDGET_UNKNOWN`, 11 `NOT_RUN`. The two `PROVED_PATH_WIN` records are prior R10 Sunny Cove L1 and Tiki Island L1 evidence, kept separate from R11 selected-case counts. All 33 R11 coverage attempts were `BUDGET_UNKNOWN`; no trial was declared impossible. The 10 L50 middle samples were `NOT_RUN` after the aggregate sampling cutoff. Each attempted trial summary records island/level, seed, normal orders, VIP optional flag and theoretical T, legal `4T` bound, moves, policy, runtime, terminal reason, and win classification. Path sampling does not establish human fairness.
- The checkpoint’s cumulative wall clock ended at 846.7 seconds because its start timestamp spans runner restarts, task pauses, summary-only resumes, and the required follow-up probes. It stopped additional sampling at the configured 480-second budget on runner re-entry; the sum of recorded gameplay/profile trial runtimes is 428.458 seconds. Treat the checkpoint wall-clock field as elapsed session time, not active simulation time.
- No STOP file was present. No exhaustive proof was attempted or reported.

## Commands and results

Godot was `4.7.2.stable.official.ed1daf0bf`; commands ran headless in the isolated worktree, with task-specific `APPDATA` for the regression probes.

- Fresh import: `godot_console.exe --headless --editor --path <worktree> --quit` — exit 0; stdout/stderr captured in `fresh_editor_import.*.txt`.
- Runner parser: `godot_console.exe --headless --path . --check-only --script res://tools/campaign/m34_r11_mechanical_coverage.gd` — final exit 0. One later summary-aggregation parse error was corrected before this final parse.
- Static and resumable mechanical runner: `godot_console.exe --headless --path . --script res://tools/campaign/m34_r11_mechanical_coverage.gd` — final summary-only resume exit 0; 1,000 static records, 54 profiles; status `STOPPED_AT_GLOBAL_WALL_BUDGET`.
- Daily Rewards: `godot_console.exe --headless --path . --script res://tests/m34_daily_rewards_probe.gd` — exit 0, 38/38 assertions.
- Economy: `godot_console.exe --headless --path . --script res://tests/m34_economy_closure_probe.gd` — exit 0, 24/24 assertions.
- M33 navigation: `godot_console.exe --headless --path . --script res://tests/m33_campaign_navigation_probe.gd` — exit 0, 17/17 assertions.
- Slim content: `godot_console.exe --headless --path . --script res://tests/m34_r09_slim_export_content_probe.gd` — exit 0.
- Scene UID: `godot_console.exe --headless --path . --script res://tests/m34_r10_scene_uid_probe.gd` — exit 0.
- VIP optional rule: `godot_console.exe --headless --path . --script res://tests/m34_r10_vip_optional_rule_probe.gd` — exit 0.
- Startup smoke: `godot_console.exe --headless --path . --quit-after 3` — exit 0.
- `git diff --cached --check` before implementation commit — exit 0.

Two runner attempts emitted recoverable harness errors while resuming: an output-field name mismatch and then a JSON array type conversion. Both were corrected; stable trial IDs/checkpoints prevented duplicate persisted results. Their stdout/stderr are retained as `mechanical_coverage_attempt01.*` and `mechanical_coverage_attempt02.*`. These were runner defects, not gameplay failures.

## Manual checks and limitations

- Manual owner visual/gameplay acceptance was not performed. No device, Android, physical play, usability fairness, or campaign-completion acceptance is claimed.
- The sample is deliberately finite and seed-bound. `BUDGET_UNKNOWN` and `NOT_RUN` remain unresolved; a found path (including prior R10 evidence) is not a fairness result.
- Per-frame wall-cap correction was parse-checked but not used for another mechanical batch; its runtime boundary remains unverified in this run.
- The implementation commit was published to `origin/main` by fast-forward. The canonical Desktop checkout still requires the governed post-task safe synchronization after the separate log commit; owner-local 7 tracked and 15 untracked paths and their preservation stash remain protected.

## Final repository truth

- Implementation/evidence commit: `03cc4730d97ce61f1ab3a2b3f696431bb6c49ce4`.
- No root `TASKS.md` edit.
- Implementation push parity was verified against `origin/main` and `git ls-remote`; final post-log parity and canonical Desktop safe sync are performed after this log is committed and pushed.
- Required handoff: `AWAITING_GPT_M34_R11_INDEPENDENT_AUDIT`.