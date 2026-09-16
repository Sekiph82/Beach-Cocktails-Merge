# BCM-M03 — Milestone Completion V01 Codex Log

This immutable Codex log records M03 builder evidence. It is not an acceptance verdict; independent ChatGPT audit remains required.

## Scope and governance

- Milestone/task: M03 / BCM-M03-001 — Scoring, combo, To-Go Orders, persistence, and game-over systems.
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Repository/branch: `https://github.com/Sekiph82/Beach-Cocktails-Merge` / `main`
- Godot: `4.7.2.stable.official.ed1daf0bf` (target 4.7.x).
- Read before work from synchronized checkout: `AGENTS.md`, `TASKS.md`, M02 audit, M02 Codex log, and M03 prompt.
- `TASKS.md` was not edited. M04 and V7 visual integration were not started.
- L6/L7 reward values were not invented or changed; owner decision remains required.

## Sync-first preflight

Exact mandatory preflight output:

OUTPUT BEGIN
```text
git status --short --branch
## main...origin/main
 M scripts/game_manager.gd
?? tests/m03_economy_regression.gd
git remote -v
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
git fetch origin main
From https://github.com/Sekiph82/Beach-Cocktails-Merge
   eef7bec..2233b1d  main       -> origin/main
git rev-parse HEAD
eef7becb9fbd3dc886421b53a6a123c29a953d1b
git rev-parse origin/main
2233b1d08da89cfaff1afea306103dee6ade3972
git rev-list --left-right --count HEAD...origin/main
0 3
```
OUTPUT END

Remote-only commits were the accepted M02 audit, M03 work order, and M02 closure/tracker advance. Read-only diff showed only `TASKS.md` and governance files remotely. Reconciliation used `git merge --ff-only origin/main`, producing `Updating eef7bec..2233b1d` / `Fast-forward`; local M03 edits were preserved. No reset, force-push, rebase, destructive checkout, or stash was used.

## Source/data evidence

Inspected `project.godot`, `scripts/game_manager.gd` (`_add_score`, `on_merged`, combo timer, target selection/collection, persistence, danger line, Game Over/restart), `scripts/drink.gd` (`merge_score`, `order_reward`), `scripts/merge_queue.gd`, `data/drinks.json`, `tests/m01_contract_probe.gd`, and `tests/m02_physics_regression.gd`.

Exact data extraction:

```text
MERGE_SCORES=L2=20,L3=50,L4=100,L5=200,L6=350,L7=600,L8=1000,L9=1600,L10=2500,L11=4000,L12=6500
ORDER_REWARDS=L6=0,L7=0,L8=3000,L9=5000,L10=8000,L11=12000,L12=18000
```

Relevant source locations/values:

```text
scripts/game_manager.gd:21  COMBO_WINDOW=1.5
scripts/game_manager.gd:22  MAX_COMBO=6
scripts/game_manager.gd:14  death_line_y=1040.0
scripts/game_manager.gd:15  death_tolerance=1.0
scripts/game_manager.gd:435-452 target_min=6, target_max=12, initial target=6, immediate-repeat avoidance
scripts/game_manager.gd:261-272 ConfigFile user://save.cfg, records/best
scripts/game_manager.gd:532-552 To-Go completion, one reward, next target
scripts/drink.gd:84-93 merge_score()/order_reward()
```

Accepted M01/M02 physics/launch behavior was preserved, including 700 px/s, 180 px/s², immediate next, simultaneous motion, forward-only response, merge momentum, L12 cap, and deferred merge requests.

## First M03 run and bounded repairs

The first economy run failed with the following retained evidence:

```text
M03_PROBE FAIL: combo expiration resets deterministically
ERROR: Error calling from signal 'finished' to callable: 'Node2D(game_manager.gd)::_finish_target_collection': Cannot convert argument 1 from Object to Object.
M03_PROBE FAIL: newly created matching drink fulfills active order
M03_PROBE FAIL: stored matching drink receives only the current To-Go reward
M03_PROBE FAIL: only one of multiple matching stored drinks is consumed
M03_PROBE FAIL: L12 remains stored when not ordered and fulfills a later L12 order
M03_PROBE_RESULT=FAIL
M03_PROBE_EXIT_CODE=1
```

Repairs were minimal and directly tied to those failures:

- combo expiration now sets `chain_timer = 0.0` when clearing `chain`;
- To-Go completion now stores the active `Drink` in `_target_drink` and connects a no-argument `_finish_target_collection()` callback, avoiding invalid typed/closure bound references;
- no score, combo percentage, reward, target, physics, visual, or asset values were retuned.

The probe waits 120 idle frames for the existing 0.34 s To-Go tween; this is test timing only and does not alter production tween duration.

## Final M03 deterministic economy probe

Added non-production `tests/m03_economy_regression.gd`. It uses the production main scene/classes and isolated APPDATA `C:\Users\sekip\AppData\Local\Temp\BCM-M03-economy-v6`; owner `user://` data was not touched.

Command: `godot --headless --path . --script res://tests/m03_economy_regression.gd`

Exact final output:

OUTPUT BEGIN
```text
ISOLATED_APPDATA=C:\Users\sekip\AppData\Local\Temp\BCM-M03-economy-v6
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
M03_PROBE user_save_path=C:/Users/sekip/AppData/Local/Temp/BCM-M03-economy-v6/Godot/app_userdata/CocktailMerge/save.cfg
M03_PROBE PASS: main scene loads as PackedScene
M03_PROBE PASS: runtime economy objects are ready
M03_SCORE_TABLE L2 expected=20 observed=20; L3 expected=50 observed=50; L4 expected=100 observed=100; L5 expected=200 observed=200; L6 expected=350 observed=350; L7 expected=600 observed=600; L8 expected=1000 observed=1000; L9 expected=1600 observed=1600; L10 expected=2500 observed=2500; L11 expected=4000 observed=4000; L12 expected=6500 observed=6500
M03_PROBE PASS: every resulting merge level L2-L12 pays the exact score once
M03_COMBO observed_deltas=[20, 25, 30, 35, 40, 45, 45] chain=6 timer=1.5
M03_PROBE PASS: combo x1 through x6+ uses 0/25/50/75/100/125 percent cap
M03_PROBE PASS: combo expiration resets deterministically
M03_PROBE PASS: post-window merge restarts at x1
M03_PROBE PASS: initial active To-Go target starts at L6
M03_PROBE PASS: To-Go target stays in L6-L12 and avoids immediate repeat
TO-GO ORDER L8 +3000  (toplam: 4000)
M03_PROBE PASS: newly created matching drink fulfills active order
TO-GO ORDER L9 +5000  (toplam: 5000)
M03_PROBE PASS: stored matching drink receives only the current To-Go reward
TO-GO ORDER L10 +8000  (toplam: 8000)
M03_PROBE PASS: only one of multiple matching stored drinks is consumed
TO-GO ORDER L12 +18000  (toplam: 18000)
M03_PROBE PASS: L12 remains stored when not ordered and fulfills a later L12 order
M03_PROBE PASS: duplicate merge request cannot double-pay
M03_PROBE PASS: missing save loads safe best-score default
M03_PROBE PASS: corrupt save loads safe best-score default without crash
M03_PROBE PASS: danger line waits below one-second tolerance
M03_PROBE PASS: danger line triggers deterministic Game Over at one second
M03_PROBE PASS: restart clears session score/state and restores playable scene
M03_PROBE PASS: Game Over with moving drinks freezes run, stops shooting, clears pending work, and shows overlay
M03_PROBE PASS: Game Over persists best score without corrupting save
M03_PROBE PASS: restart after moving Game Over preserves best and clears session
M03_REWARD_STATUS L6=0 L7=0 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
OWNER DECISION REQUIRED FOR FINAL L6/L7 REWARD VALUES
M03_PROBE_RESULT=PASS
M03_PROBE_EXIT_CODE=0
```
OUTPUT END

The probe resets combo for each score-table case, observes every resulting-level score, checks x1-x6+ and timeout, tests immediate/stored/multiple/L12 order fulfillment and no duplicate payout, tests missing/corrupt save defaults, checks 0.50 s vs 1.00 s danger tolerance, and verifies moving Game Over/restart persistence/state reset.

## Godot validation

```text
GODOT_PATH=C:\Users\sekip\AppData\Local\Microsoft\WinGet\Links\godot.exe
4.7.2.stable.official.ed1daf0bf
VERSION_EXIT_CODE=0
```

Import/parse: `godot --headless --quiet --path . --editor --import --quit`

```text
WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
IMPORT_EXIT_CODE=0
```

Main-scene startup: `godot --headless --quiet --path . --quit-after 3`

```text
STARTUP_EXIT_CODE=0
```

The nested reference-project warning is expected and non-fatal.

## M01/M02 regression after M03 repairs

M01 command: `godot --headless --path . --script res://tests/m01_contract_probe.gd`; isolated APPDATA `C:\Users\sekip\AppData\Local\Temp\BCM-M03-m01-final`.

```text
M01_PROBE_RESULT=PASS
M01_PROBE_EXIT_CODE=0
```

M02 command: `godot --headless --path . --script res://tests/m02_physics_regression.gd`; isolated APPDATA `C:\Users\sekip\AppData\Local\Temp\BCM-M03-m02-final`.

```text
M02_PROBE_RESULT=PASS
M02_PROBE_EXIT_CODE=0
```

The rerun outputs also retained PASS evidence for M01 launch/current/next, persistence, and Game Over; and M02 body config, collision, tunneling, single merge, chain stress, L12 cap, rapid launch, moving restart, and moving Game Over.

## Verification matrix

PASS by deterministic runtime/source evidence: L2-L12 exact score table; x1-x6+ combo cap and timeout; L6-L12 target range with initial L6 and repeat avoidance; immediate/stored/multiple/L12 delivery; no duplicate order/merge payout; approved L8-L12 rewards; missing/corrupt save defaults; best-score persistence; danger-line timing; Game Over/restart integrity; M01/M02 regressions; Godot import/parse/startup.

SOURCE-INFERRED or limited: exact HUD wiring and native device interaction. Device/export behavior, long-duration manual play feel, and owner-native visual acceptance were not claimed.

OWNER DECISION REQUIRED FOR FINAL L6/L7 REWARD VALUES: current values remain `L6=0`, `L7=0`; no values were invented or changed.

DEFERRED: M04 asset work, all V7 integration, final sprite-footprint alignment, and future save schema/migration work.

## Files changed

```text
scripts/game_manager.gd
tests/m03_economy_regression.gd
docs/codex-logs/BCM-M03_MILESTONE_COMPLETION_V01_CODEX_LOG.md
```

No `TASKS.md`, `data/drinks.json`, physics-tuning, visual/asset, M04, M03-future, or V7 file was changed.

## Final pre-commit and completion

`git diff --check` returned `0`; worktree and staged `TASKS.md` diffs returned no output with exit code `0`; staged scope contained only the three paths above. The intended M03 files and this log were committed and pushed to `main`. Final SHA and post-push equality proof are reported in the completion response after commit creation because a commit cannot contain its own hash without changing that hash. Codex assigns no M03 acceptance verdict, does not edit `TASKS.md`, does not start M04/V7, and stops for independent ChatGPT audit.
