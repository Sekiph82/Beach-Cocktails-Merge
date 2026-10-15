# BCM-M34-R12 Solver and Sync Forensics — Codex Execution Log

## Work item and authority

- Work item: BCM-M34-R12-001 through R12-005.
- Prompt version: `CHATGPT_M34_R12_SOLVER_BOTTLENECK_AND_SYNC_FORENSICS_MASTER_PROMPT.md` with owner resume `CHATGPT_M34_R12_OWNER_RESUME_GB_HYGIENE_V02.md`.
- Start implementation HEAD: `201c30220408b1eee4b326eeb02e1b7b03d1765b`.
- Implementation/evidence commit SHA: `20de250408973a1eb246bc4f11e8f02e7432a367`.
- Checkout: existing non-Desktop worktree `C:\Users\sekip\.codex\worktrees\bcm-m34-r09-deferred-20261015`, detached HEAD; no new worktree created.
- Remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`), target `main`.
- Godot: `4.7.2.stable.official.ed1daf0bf`.

## Sync and owner preservation

- At task start, canonical Desktop was at `620febc27675a88a723a4df20a75268a227b04af`, behind-only 0 ahead / 4 behind `origin/main` (`201c30220408b1eee4b326eeb02e1b7b03d1765b`). The eight dirty tracked paths and 15 untracked paths were inventoried. Incoming paths were disjoint from every owner path.
- The owner-authorized tracked-only safe-sync procedure created and retained stash `owner-local-safe-sync-620febc-pre-M34R12` (no `-u`), fast-forwarded Desktop, applied without dropping the stash, and verified the tracked and untracked owner data remained intact. No owner path was staged or committed by that sync.
- The selected existing isolated worktree was clean and behind-only before fast-forward; it was fast-forwarded to start HEAD `201c302`. No R12-time sync or copy-back was performed on canonical Desktop.
- Read-only Desktop collision capture at `evidence/M34-R12/desktop_collision_audit_read_only.json`: Desktop `HEAD = origin/main = 201c302`, ahead/behind `0/0`; eight tracked owner-edited paths have working-tree blobs different from HEAD, while their HEAD and `origin/main` blobs match. Fifteen untracked paths were inventoried by name only; their contents were not opened. There was no incoming commit diff at capture, hence no incoming hunks to collide. All owner paths remain preserved and unstaged.
- Root `TASKS.md` was not modified.

## Files changed

- Extended `scripts/campaign/m17_seeded_validation_harness.gd` with optional 15-physics-frame state traces for body position/velocity, merge/contact counters, spawn sequence, progress, VIP, and terminal state. Default callers do not enable the trace.
- Added `tests/m34_r12_fixed_fps_parity_probe.gd` and `tools/campaign/m34_r12_bounded_path_probe.gd` for reproducible production-physics parity and exact-4T bounded path diagnostics. The bounded probe treats canonical `vip: null` as disabled optional VIP.
- Added R12 machine-readable static difficulty, Desktop collision, allocated-size/APK inventory, parity, interrupted-search, and regression evidence under `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R12/`.
- No gameplay physics, scoring, campaign data, assets, Android build, ads, IAP, or release content was changed.

## Solver profiling and bounded diagnostics

- Fresh parity pair: Azure Bay L1, seed `34112001`, `CHEAP_MERGE_CENTER_V01`, production `ShotController`, 60 physics ticks/sec, `Engine.time_scale=1.0`, no timer, six actions, 450 physics frames, three merges.
- Normal wall time: `7,762,315 us`; `--fixed-fps 60`: `577,268 us`, measured `13.45x` for this sample. Both runs had identical action-log SHA-256 `788833C65326C7C9E47B836B94689754D8A8E3AE917505F8CBF04D0BD68321A6`, 30 matching physics-trace state hashes, identical gameplay telemetry and terminal shot-budget abort. Profiling timing fields differ because they measure wall time.
- Profile sample: normal physics-frame wait averaged `15,257 us/frame`, while fixed-FPS averaged `240 us/frame`; `MERGE_AWARE_V01` versus `CHEAP_MERGE_CENTER_V01` decision time differed by less than `1 us/action` in the same six-shot fixed-FPS cohort. This points to frame waiting as the measured bottleneck in this cohort, not policy-decision cost. It does not establish high-density throughput.
- The first 4T runner attempt used an incorrect L1-equivalent-to-T conversion and set Sunny Cove L50 to 576 moves (16T rather than 4T). It is invalid and recorded as `UNKNOWN_NO_RESULT`; the cap formula was corrected to `ceil(normal_objective_cost/4)` and `4*T`.
- The next attempt exposed canonical `vip:null` rows; that diagnostic read was made null-safe. The corrected 10-case exact-4T batch parsed, but its first Sunny Cove L50 trial (`normal_T=36`, legal cap 144) produced no summary in the observed 77 seconds despite a 45-second internal wall guard. The two exact task-owned Godot processes were stopped after command-line verification. The partial console output is not a path result. Classification remains `UNKNOWN_NO_RESULT`; no win, failed path, or impossibility is claimed. No further repetitive sampling was run.
- Next solver experiment should retain production physics, use a process-level watchdog that is independently verified, and first profile a deliberately capped high-density state before another completion search. M33-004 remains OPEN.

## Static campaign difficulty review

- Reviewed all 1,000 canonical level rows using the R11 mechanical-coverage CSV and canonical level JSON. Normal objective T has p50 `40`, p90 `56`, max `80`; the normal move cap is exactly `4*T`. VIP is optional and excluded from that normal denominator; 167 levels have optional VIP data.
- Ten levels have normal T >= 60. Highest order target is L9; all requested targets are within the model's L1-L12 campaign and above the highest L3 normal spawn only for a subset. Model planning uses expected spawn value `7/3` L1-equivalent and yields mean planning estimate `68.87` spawns per level; this is an expectation heuristic, not a deterministic path or physics-success estimate.
- Per-island T, target, and expected-spawn summaries plus all 1,000 rows are in `campaign_difficulty_static_review.json`. Flags are human-review candidates only; no gameplay rule was changed and no physical feasibility claim is made.

## Read-only disk inventory

- Inventory scope was restricted to directly named BCM/BeachCocktails AppData Local and Temp folders, the active R12 worktree, and the known old BCM safe-worktree. It used `GetCompressedFileSizeW`, skipped reparse points, read metadata/size only, and did not delete anything.
- Per-path allocated totals sum to `34.567 GiB`; this can double-count overlapping/hardlinked content and is not a unique reclaimable-space total. C: had `90.394 GiB` free at capture. Largest entries include `BeachCocktails` 8.97 GiB (contents/use not classified), the named Godot Android bundle 4.72 GiB, Android Studio setup 2.91 GiB, active R12 worktree 2.86 GiB, owner-dirty old worktree 2.86 GiB, and explicitly preserved Gradle cache 2.65 GiB.
- Seven APKs were found in scoped export/build directories. Their SHA-256 hashes are all distinct; no duplicate APK bytes were established. Old build usefulness and redundancy are not proven, and toolchains, owner data, active worktree, and explicit preserved backups are protected. No deletion was justified; bytes reclaimed `0`. The 15 deferred R13 profile files totaling 44,266 bytes were not retried or deleted.

## Import and regression evidence

All commands used the task-specific AppData profile `C:\Users\sekip\AppData\Local\BeachCocktailsM34R12-20261015`.

- Fresh editor import `--headless --editor --path . --quit`: exit 0. Godot rewrote only the GameFeelFlow autoload to a generated UID; that one import-only line was restored. `project.godot` returned to its pre-import SHA and has no worktree diff.
- `tests/m34_economy_closure_probe.gd`: exit 0, 35/35 PASS.
- `tests/m34_production_routes_probe.gd`: exit 0, PASS; production route and energy roundtrip evidence.
- `tests/m34_daily_rewards_probe.gd`: exit 0, 38/38 PASS.
- `tests/m33_campaign_navigation_probe.gd`: exit 0, 17/17 PASS.
- `tests/m34_r09_slim_export_content_probe.gd`: exit 0, PASS.
- `tests/m34_r10_scene_uid_probe.gd`: exit 0, PASS.
- `tests/m34_r10_vip_optional_rule_probe.gd`: exit 0, PASS.
- `tests/m14_gameplay_session_bridge_probe.gd`: exit 0, 66/66 PASS.
- `tests/m15_vip_boosters_economy_probe.gd`: exit 0, 63/63 PASS.
- Headless startup smoke `--headless --path . --quit-after 3`: exit 0.
- Both R12 diagnostic scripts parsed successfully. `git diff --cached --check` passed for the implementation/evidence commit.

## Limits and builder stop

- No Android device or export build, human-play acceptance, ad/IAP work, or store/release validation was performed.
- Short parity establishes only one six-shot cohort. The exact-4T representative batch produced no completed row; solver completion quality and M33-004 remain unresolved. Static difficulty estimates do not replace runtime validation.
- No large or small disk cleanup occurred; the R13 tiny-file cleanup remains owner-deferred.
- Final implementation/evidence commit SHA: `20de250408973a1eb246bc4f11e8f02e7432a367`. A documentation-only commit adds this immutable builder log. Publication parity is checked after both commits are pushed and recorded in the handoff.
- `TASKS.md` remains byte-for-byte unchanged by Codex.
- Builder stop marker: `AWAITING_GPT_M34_R12_INDEPENDENT_AUDIT`.