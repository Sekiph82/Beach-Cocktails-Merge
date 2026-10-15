# BCM-M34-R15 Numerical Parity and Bounded Solver — Codex Execution Log

## Scope and authority

- Work item: bounded BCM-M33-004 investigation under R15.
- Prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R15_NUMERICAL_PARITY_SOLVER_MASTER_PROMPT.md`.
- R14 audit and evidence reviewed: `CHATGPT_M34_R14_INDEPENDENT_AUDIT_V01.md` and `evidence/M34-R14/`.
- Start HEAD after safe synchronization: `27e38f93e7ef048c51bbd0d34967fc33d73a6988`.
- Checkout used: existing detached R14 worktree `C:\Users\sekip\.codex\worktrees\bcm-m34-r09-deferred-20261015`; it was clean at `5aced928ebb97234525289d2572feff9fd41e153`, three commits behind, and fast-forwarded to `origin/main`. No worktree or branch was created.
- Remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`), publication target `main`.
- Godot: `4.7.2.stable.official.ed1daf0bf`; PowerShell 7.
- Root `TASKS.md` was read only. Its SHA-1 stayed `e68c079308626733d2b2759260c4ea75712a6547` before and after the R15 regression suite.

## Canonical Desktop synchronization and preservation

- Desktop began on `main` at `5c7f8546fadc3ce10673a9da97994c73e5358d9b`, 0 ahead / 5 behind fetched `origin/main` at `27e38f93e7ef048c51bbd0d34967fc33d73a6988`.
- Eight modified tracked files and fifteen untracked owner paths matched the prior R14 preservation manifest, including every SHA-256. Incoming paths were disjoint from all 23 owner paths.
- Applied the authorized tracked-only stash `owner-local-safe-sync-5c7f854`; untracked paths remained in place. Fast-forwarded Desktop and restored the stash without dropping it.
- After sync: Desktop `HEAD = origin/main = remote main = 27e38f93e7ef048c51bbd0d34967fc33d73a6988`, ahead/behind `0/0`; all 23 owner path hashes matched; the new stash and older preservation stash remain retained; no owner path was staged.
- Desktop was not modified by R15 implementation. It remains dirty with the same 8 tracked and 15 untracked owner paths. Post-publication Desktop fast-forward is intentionally not attempted while this owner work remains dirty.

## Pre-registration and implementation

- Before controlled physics runs, committed `evidence/M34-R15/NUMERICAL_PARITY_GATE_PREREGISTRATION_V01.json` in `c849f78e2929a590555bc948cbecd30d2820e290`.
- The pre-registered strict gate requires exact per-frame state hashes, stable identity pairing, ordered contacts/merges, objectives, terminal state, and actions/branches. Strict failure remains failure and does not enable fast solver mode.
- The exploratory gate caps per-entity per-frame position delta at 0.02 px, velocity delta at 0.05 px/s, and cumulative aligned position-delta sum at 0.25 px per entity. Identity, motion/sleep state, event identity/order/frame, objectives, terminal, and branch/action differences fail it. Candidate classification is not authority.
- Extended only the seeded validation harness and diagnostic/test scripts. Traces now use deterministic harness-assigned drink IDs, capture every physics frame, awake/sleep and motion state, position/velocity, all ordered `body_entered` observations, ordered merge events, per-frame objective/terminal/action state, and process/physics settings. No production gameplay physics, campaign rules, energy, timer, star policy, Focus, level data, UI, or monetization code changed.
- The first R15 instrumentation attempt exposed that post-merge bodies could fall back to process-specific Godot instance IDs. The harness was corrected to assign IDs at each physics sample; the affected early comparison output was regenerated. Subsequent event signatures canonicalize generated node names while retaining stable drink IDs and event order.
- The final pre-log code/evidence base is `bd5d5051214635cafc4852396ab22f6124eeaf76`; the immutable builder log is committed with the publication change set.

## Numerical drift findings

- Seven bounded Godot runs completed normally: two normal-mode repeats for Final Island L100 seed `34112100`, normal and `--fixed-fps 60` pairs for seeds `34112100`, `34112101`, and `34112102`. Each process had a 30-second normal or 15-second fixed-FPS external watchdog. All reached at least 14 live drinks (registered high-density minimum: 8).
- Every pair failed strict parity. No pair passed the tolerant candidate gate. The final classification was `structural_divergence` for all four comparisons: numeric ceilings were exceeded in three; seed `34112102` also had a terminal-frame difference and trace-length mismatch.
- The normal repeat of seed `34112100` had identical 17-action, 41-contact, 4-merge, `TABLE_DANGER` results and identical ordered contact/merge/action traces. Its first state mismatch was frame 125, stable drink ID 6 (L4): Y was `372.648742675781` versus `371.733856201172`, a 0.914886 px delta. Both bodies were awake (`sleeping=false`), `SLIDING` (`motion_state=1`), and reported zero velocity on that frame. They nearly reconverged on the following frame. Position cap 0.02 px and cumulative cap 0.25 px were exceeded. This is not a wake/sleep transition and not a branch/action/event-order difference.
- Seed `34112100` normal versus fixed-FPS had the same action/event order and final outcome. Maximum position delta was 0.914886 px at frame 125, ID 6; maximum velocity delta was 0.148035 px/s at frame 964, ID 39; the trace lengths differed by one physics frame.
- Seed `34112101` normal versus fixed-FPS had identical branch, contact, merge, objective, and terminal traces. Maximum position delta was 1.148804 px at frame 1021, ID 40; cumulative position-delta sum was 1.186402 px. The velocity ceiling was not exceeded.
- Seed `34112102` had zero observed position delta and a maximum velocity residual of `3.39e-11` px/s, but the normal and fixed runs recorded terminal state at different physics frames and ended with trace lengths 1233 versus 1226. This is a terminal-timing difference, not a win/fail outcome disagreement.
- All compared configurations recorded 60 physics ticks/sec, `physics/2d/run_on_separate_thread=false`, 16 processors, and no `max_fps` cap. Repeated normal-mode divergence shows `--fixed-fps` is not the sole trigger. The awake frame-125 difference and the exact event/action agreement rule out sleep transition, branch changes, and JSON serialization as the sole explanation. The trace supports nondeterministic rigid-body contact/integration state; it does not isolate the exact internal solver operation or OS CPU scheduling as the cause. Godot 4.7 documents that physics is not deterministic for seemingly identical situations, and documents that `--fixed-fps` disables real-time synchronization; those facts are consistent with these observations, not a project-specific proof of the internal cause.
- Evidence: `evidence/M34-R15/controlled_parity_summary.json` and the seven paired per-frame records and watchdog reports in that directory. The summary records each frame's maximum position/velocity delta, paired identities, contact/merge event cursors, and equality of action, objective, and terminal traces.
- The adversarial comparator test passed: a numeric-only perturbation within tolerance was classified `tolerant_candidate_only`; an injected branch-lane mutation and collision-target identity mutation each failed as `structural_divergence`.
- Fast/high-speed authoritative solver mode remains prohibited. No tolerance has been accepted as parity authority.

## Bounded standard-speed 4T diagnostic

- Ran one Final Island L100 seed `34113100` exact-4T candidate through the production `ShotController` and full production physics, at standard speed with no `--fixed-fps` flag. Internal wall budget: 8 seconds; external synthetic-validated process watchdog: 12 seconds; one case only; no backtracking.
- Watchdog exited normally before its deadline. The trial stopped with `PER_LEVEL_WALL_BUDGET` after 9 actions / 489 physics frames and was classified `LEGAL_PATH_NOT_FOUND_WITHIN_BUDGET`. It is not an impossibility proof or reachability verdict. No win was proven.
- The watchdog implementation's synthetic hung-child test remains available as committed R14 evidence: `evidence/M34-R14/watchdog_synthetic_test.json` (`PASS`, verified task-owned process termination, unrelated sentinel preserved, partial UNKNOWN record preserved).
- R15 trial evidence: `standard_fps_authoritative_4t_summary.json`, `final_island_l100_standard_fps_4t_seed_34113100.json`, `.progress.json`, and `.watchdog.json`.

## Regressions and focused validation

- R15 adversarial gate self-test: PASS (`branch=structural_divergence`, `collision=structural_divergence`, numeric-only control=`tolerant_candidate_only`).
- Controlled numerical cohort: 7/7 Godot processes exited under their watchdogs; all cases met the high-density threshold. Strict result: 0/4 pairs; tolerant candidate result: 0/4 pairs.
- Standard-speed exact-4T diagnostic: 1 bounded case, watchdog `EXITED`, result `LEGAL_PATH_NOT_FOUND_WITHIN_BUDGET`; no impossibility inference.
- Integration regression suite: 10/10 passed: Economy 35, Daily Rewards 38, Navigation 17, M14 bridge, M15 VIP/economy, scene UID, production routes, slim content, optional VIP, startup smoke. Each child exited 0. Full stdout/stderr and watchdog reports are under `evidence/M34-R15/`.
- Tests ran with a unique task-owned temporary AppData location. Its measured size before cleanup was 115,012 bytes; the exact directory was removed. Measured free-space change across the run was **-4,890,624 bytes**; no reclaimed-space claim is made. No owner save, SDK, cache, backup, or Desktop path was cleaned. No fresh disk inventory was run for R15; the R14 inventory found no proven GB-scale disposable target.
- `git diff --check` passed before the R15 commits. `TASKS.md` was not staged or edited. No physical-device, owner-native gameplay, human fairness, or full 1,000-level reachability acceptance was performed.

## Publication and stop

- All R15 code, tests, per-frame traces, watchdog records, regression evidence, preregistration, and this log are to be published normally to `origin/main`; no force push or new branch is used.
- Code/evidence base immediately before the log commit: `bd5d5051214635cafc4852396ab22f6124eeaf76`.
- Final publication verification must confirm `git rev-parse HEAD = git rev-parse origin/main = git ls-remote origin refs/heads/main`, with ahead/behind `0/0`.
- Explicit confirmation: root `TASKS.md` was not modified; BCM-M33-004 remains OPEN; Codex assigns no acceptance verdict.
- Builder stop marker: `AWAITING_GPT_M34_R15_INDEPENDENT_AUDIT`.
