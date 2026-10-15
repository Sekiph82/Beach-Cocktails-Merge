# BCM-M34-R14 Hard Watchdog Solver — Codex Execution Log

## Authority and scope

- Work item: next bounded BCM-M33-004 increment, R14 hard-deadline solver and high-density fixed-FPS parity.
- Prompt: `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/CHATGPT_M34_R14_HARD_WATCHDOG_SOLVER_MASTER_PROMPT.md`.
- Start HEAD: `5c7f8546fadc3ce10673a9da97994c73e5358d9b`.
- Implementation/evidence commit: `3fccca058815b8aaa1086c4af68315dae6154b3d`.
- Checkout: reused existing non-Desktop worktree `C:\Users\sekip\.codex\worktrees\bcm-m34-r09-deferred-20261015`; it was clean, detached, and fast-forwarded from R12 commit `261ef53aeed42aa014b7bf1969b94ccb8f344e3b` to synchronized `origin/main` before R14 changes. No worktree was created.
- Remote: `origin` (`https://github.com/Sekiph82/Beach-Cocktails-Merge.git`), publication target `main`.
- Godot: `4.7.2.stable.official.ed1daf0bf`; PowerShell `7.6.5`.

## Canonical Desktop sync and owner-work preservation

- Canonical Desktop root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Initial Desktop state: `main` at `201c30220408b1eee4b326eeb02e1b7b03d1765b`, 0 ahead / 5 behind fetched `origin/main` at `5c7f8546fadc3ce10673a9da97994c73e5358d9b`.
- Inventoried 8 modified tracked files and 15 untracked owner paths. The full incoming diff had no overlap with those paths. Before-sync SHA-256 and file-length manifest: `C:\Users\sekip\.codex\preservation\BCM-M34-R14-safe-sync-20261015\pre_sync_manifest.json`.
- Applied the authorized tracked-only safe-sync procedure using the exact stash `owner-local-safe-sync-201c302` (stash commit `15ac3189329a6e7d347c614f4e32ca56578f333b`); left untracked files untouched, fast-forwarded Desktop to `5c7f854`, then applied the stash without dropping it.
- Post-sync verification: all 8 tracked-file hashes and all 15 untracked-file hashes matched the before-sync manifest; no staged owner paths; stash retained. Verification record: `C:\Users\sekip\.codex\preservation\BCM-M34-R14-safe-sync-20261015\post_sync_verification.json`.
- Desktop was not modified during implementation/publication. It remains owner-dirty with the same 8 tracked and 15 untracked paths and is behind the R14 publication; no post-task sync was attempted because the canonical checkout is not clean and R14 prohibits modifying its root.
- Root `TASKS.md` was read from synchronized `HEAD`, never edited. Its blob hash in the R14 test checkout is `f0dc9c6dffececdd57492ee1b78a833e8c406f85`; the isolated regression runner recorded identical before/after hashes.

## Implementation and evidence

- Added optional `max_physics_frames` to the seeded gameplay harness. A bounded trial now stops at its exact physics-frame ceiling and records `PHYSICS_FRAME_BUDGET`; existing callers retain the prior behavior through the default value of zero.
- Parameterized the production-physics parity probe for R14 island, level, seed, policy, shot ceiling, and physics-frame ceiling.
- Added `tools/campaign/m34_r14_process_watchdog.ps1`. It starts a specific child process, verifies its PID/path/creation identity, snapshots descendants by parent lineage, enforces an external wall deadline, terminates only the verified task-owned process tree, and atomically writes a JSON result with reason and any durable partial-progress marker.
- Added a synthetic hung child and watchdog test. The 2-second timeout returned `TIMEOUT_TERMINATED`/exit 124, recorded the launched PowerShell PID and its verified `conhost.exe` child as terminated, retained the `CASE_RUNNING`/`UNKNOWN_TIMEOUT` partial marker, and confirmed the unrelated sentinel PID remained alive. Result: `watchdog_synthetic_test.json` (`PASS`).
- Added a single-case exact-4T probe. It writes `CASE_RUNNING` progress before trial execution and records legal 4T shots, per-case 8-second internal wall ceiling, a 12-second process watchdog, physics ceiling (`4T shots × 60 + up to 90 settle frames`), terminal reason, action-log provenance, and bounded backtracking cap. The probe parsed successfully with Godot `--check-only`.
- Added parity orchestration and a gate-controlled solver runner. The solver runner records `SKIPPED_GATE_NOT_PROVEN` for all three selected cases if high-density parity is not proven; static expectations and budget exhaustion are never presented as reachability proof.
- Evidence is under `coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R14/` (54 files, approximately 693 KB before the final synthetic watchdog refresh). It includes paired raw trial records, per-process watchdog results, trace divergence details, test outputs, disk inventory, and the gate skip.

## Fixed-FPS parity gate

- Ran normal and `--fixed-fps 60` modes against the same production `ShotController`, 60 physics ticks/sec, full Godot physics, and deterministic action seeds.
- Three Azure Bay L1 cohorts (seeds `34112001`, `34112002`, `34112003`; six-shot cap) matched action logs, all sampled trace hashes, merge/contact counts, and terminal states.
- Late/high-density cohort: Final Island L100, seed `34112100`, `WEAK_V02`, action cap 20. Both modes reached peak 15 live drinks and produced the same 17-shot action log, 4 merges, 41 contacts, and `TABLE_DANGER` terminal result. Exact physics trace hashes diverged first at sample index 60 / physics frame 915. Eleven vertical position components differed; maximum absolute difference was approximately `0.007935 px` in the retained run.
- Gate result: `REFUSE_FAST_SOLVER_MODE_PARITY_NOT_PROVEN`. The exact trace mismatch remains a divergence even though action and terminal counters matched.
- Per R14 gate, no exact-4T solver trial was run. The three representative cases are recorded as `SKIPPED_GATE_NOT_PROVEN`, not as wins, impossible paths, or failures. M33-004 remains open.

## Regressions and focused checks

- Synthetic process watchdog + partial-progress test: PASS; unrelated sentinel remained alive.
- PowerShell parser: zero syntax errors for the watchdog, hung-child fixture, and three R14 test runners.
- Godot parse-only check of `m34_r14_bounded_path_probe.gd`: exit 0.
- Regression suite first attempt: Economy and Daily passed; Navigation exceeded its initial 60-second watchdog after seven progress checks. The exact task-owned process was terminated and the first isolated test profile was removed. Navigation’s bound was raised to 180 seconds for its 1,000-level traversal.
- Final isolated regression suite: `ALL_REQUESTED_REGRESSIONS_PASS`, 10/10. Economy 35/35, Daily Rewards 38/38, M33 Navigation 17/17, M14 66/66, M15 63/63, scene UID, production routes, slim content, optional VIP, and startup smoke all exited 0. Evidence includes per-test stdout/stderr and watchdog JSON.
- Tests ran with an isolated temporary `APPDATA`; the exact test-created directory was removed after the suite. It contained 115,010 logical bytes before cleanup; measured free-space change across cleanup was +188,416 bytes. No owner game saves were read or changed.
- `git diff --cached --check`: PASS. No gameplay, energy, stars, timer, Focus, graphics, level data, Android package, ads, IAP, or release code was changed.
- No physical-device test, owner gameplay acceptance, or human fairness qualification was performed.

## Read-only disk drilldown

- Inventory: `evidence/M34-R14/disk_inventory_read_only.json`. It measured file metadata and allocated sizes for BCM/BeachCocktails-named Local AppData directories and physical `.codex\worktrees` children; reparse files were skipped. Twelve older BCM worktree registrations point to missing physical paths; the existing R14 worktree is active.
- Largest scoped folders included `AppData\Local\BeachCocktails` (8.76 GiB, three tutorial owner-review/evidence profiles), the R14 worktree (2.797 GiB, including 1.199 GiB `.godot` cache and 1.290 GiB coordination evidence), Android SDK/download/JDK bundle (4.608 GiB), preserved R09 Gradle build cache (2.583 GiB), R07/R08 export artifacts (2.824 GiB combined), and an unclassified old safe worktree (2.789 GiB).
- These are review candidates only: owner evidence/user data, active cache, SDK/toolchain, explicitly preserved cache, possible unique exports, or unclassified worktree contents. None met the exact safe-deletion bar. No disk-inventory target was deleted; no GB-scale space reclamation is claimed.

## Publication and stop

- Implementation/evidence commit `3fccca058815b8aaa1086c4af68315dae6154b3d` was pushed normally to `origin/main` with no force and no new branch.
- At the implementation publication checkpoint, `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main` all returned `3fccca058815b8aaa1086c4af68315dae6154b3d`.
- `TASKS.md` was not modified. Codex does not assign the acceptance verdict. Builder stop marker: `AWAITING_GPT_M34_R14_INDEPENDENT_AUDIT`.
- Required audit focus: determine whether the frame-915 high-density physics drift is acceptable or requires a different parity model; do not authorize fast solver mode or resume exact-4T trials until the high-density gate is independently resolved.
