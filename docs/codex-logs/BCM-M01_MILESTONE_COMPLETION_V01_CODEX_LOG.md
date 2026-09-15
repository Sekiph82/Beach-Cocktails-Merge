# BCM-M01 — Milestone Completion V01 Codex Log

This immutable Codex log records the M01 gameplay-contract recovery and playable-baseline verification work. It is builder evidence, not an acceptance verdict. Independent ChatGPT audit remains required.

## Scope and governance

- Milestone: M01 — Gameplay contract recovery and playable baseline verification.
- Active task: BCM-M01-001 — Recover and verify playable gameplay contract from synchronized v6.7 state.
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Godot target/runtime: `4.7.x`; installed executable resolved as Godot `4.7.2.stable.official.ed1daf0bf`.
- Authoritative prompt: `docs/prompts/BCM-M01_MILESTONE_COMPLETION_V01_PROMPT.md`.
- Required governance/audit sources read from the synchronized checkout: `AGENTS.md`, `TASKS.md`, `docs/audits/BCM-M00_MILESTONE_COMPLETION_V01_AUDIT.md`, and the M01 prompt.
- `TASKS.md` was not edited by Codex. It remains byte-for-byte unchanged during this M01 session.
- BCM-M02 and all V7 visual integration work were not started.
- BCM-M00-001/M00-002 accepted baseline was preserved; no M00 log or audit was rewritten.

## Sync-first preflight exact outputs

The mandatory preflight was run from the canonical local root before reading/acting on the synchronized M01 implementation.

OUTPUT BEGIN
```text
git status --short --branch
## main...origin/main
git remote -v
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
git fetch origin main
From https://github.com/Sekiph82/Beach-Cocktails-Merge
 * branch            main       -> FETCH_HEAD
   30ef9b3..75c10c3  main       -> origin/main
git rev-parse HEAD
30ef9b36694e56dd8e50302b9db4316191e11cf6
git rev-parse origin/main
75c10c3464d39deea798f330ff2cc1a2865bc9e5
git rev-list --left-right --count HEAD...origin/main
0 3
```
OUTPUT END

Remote-only commits were `d4c1446` (accepted M00 audit), `e792939` (M01 work order), and `75c10c3` (M00 closure/tracker advance). The local tree was clean and had no owner-local changes to reconcile. The remote was incorporated safely with:

```text
git merge --ff-only origin/main
Updating 30ef9b3..75c10c3
Fast-forward
```

Post-fast-forward synchronization:

OUTPUT BEGIN
```text
git status --short --branch
## main...origin/main
git rev-parse HEAD
75c10c3464d39deea798f330ff2cc1a2865bc9e5
git rev-parse origin/main
75c10c3464d39deea798f330ff2cc1a2865bc9e5
git rev-list --left-right --count HEAD...origin/main
0 0
```
OUTPUT END

No reset, force-push, automatic rebase, destructive checkout, or silent stash was used.

## Workspace and accepted-baseline evidence

The expected production root was confirmed:

OUTPUT BEGIN
```text
project.godot root=True
scenes directory=True
scripts directory=True
data directory=True
assets directory=True
```
OUTPUT END

The accepted M00 baseline critical-file comparison against `30ef9b36694e56dd8e50302b9db4316191e11cf6` produced no changed paths for `project.godot`, `scenes/main.tscn`, `data/drinks.json`, `scripts/drink.gd`, `scripts/merge_queue.gd`, and `scripts/shot_controller.gd`.

`project.godot` is directly at the workspace root and configures:

- main scene: `res://scenes/main.tscn`;
- logical viewport: `720 x 1280`;
- window override: `405 x 720`;
- stretch mode: `viewport`, aspect: `keep`;
- handheld orientation: portrait (`1`);
- renderer: GL Compatibility.

`scenes/main.tscn` is the minimal `Node2D` root `Main` with `res://scripts/game_manager.gd`. Runtime `GameManager._ready()` builds `Main/World`, `Main/MergeQueue`, `Main/UI`/HUD, `Main/UI/GameOver`, `Main/MergeTarget`, and `Main/ShotController`. The world contains `LeftRail`, `RightRail`, `TopRail`, and `BottomRail` static bodies plus runtime `Drink` bodies.

## Recovered gameplay contract

The synchronized v6.7 implementation uses a top-left logical coordinate system: +X is right, +Y is toward the player/bottom, and -Y is forward/up-table. The table is a perspective trapezoid used for geometry/presentation while physics remains genuine 2D.

Geometry and boundaries recovered from `scripts/game_manager.gd`:

- `table_top_y = 205.0`.
- Far/top table edge: x inset `76.0`; near/bottom edge: x inset `24.0`.
- `wall_thickness = 24.0`.
- Left/right rails run from `(76,205)` / `(644,205)` to `(24,1300.8)` / `(696,1300.8)` for the configured `720 x 1280` viewport; top and bottom rails close the playfield.
- `death_line_y = 1040.0`; a settled drink whose `position.y + radius` exceeds that line remains dangerous for `death_tolerance = 1.0` second before Game Over.
- Launch spawn is `Vector2(board_width * 0.5, board_height - 92.0)`, then clamped to the table bounds. With the configured viewport this is nominally `(360,1188)` before radius/boundary clamping.
- `get_horizontal_bounds_at_y()` derives lane limits from the interpolated table inset plus half wall thickness, drink radius, and 3 px clearance.
- Rails and drinks use collision layer `1` and collision mask `1`; held/target-captured/merging drinks use layer/mask `0` while non-physical.

Input and shot flow recovered from `scripts/shot_controller.gd`:

- `InputEventMouseButton` left-button press begins drag, mouse motion moves the held drink horizontally, and release fires.
- `InputEventScreenTouch` press/release and `InputEventScreenDrag` provide the mobile touch route.
- `_launch()` detaches the current drink, starts it at `Vector2(0,-launch_speed)`, and immediately calls `_spawn_next()`; it does not wait for settling or merging.
- `_spawn_next()` assigns the next preview level, spawns a new held drink immediately, and stores it as `_current_drink`.

Physics/merge flow recovered from `scripts/drink.gd` and `scripts/merge_queue.gd`:

- `Drink` is `RigidBody2D`; held drinks are frozen and non-colliding until release.
- Sliding drinks are dynamic/collidable, decelerated in `_integrate_forces()`, and become settled after the bounded low-speed delay.
- A settled drink is not permanently static: an impact velocity over 8 wakes it and changes it to `SLIDING`.
- `_forward_only()` removes positive Y velocity, so collision resolution cannot intentionally rebound a drink toward the player.
- `MergeQueue.request_merge()` defers replacement outside the physics callback, computes mass-weighted position/velocity, retains meaningful driver momentum, and caps the result at `Drink.max_level()` (12).
- The resulting drink is started sliding when an input was meaningfully moving; its velocity is kept forward/lateral and is not frozen at the merge point.

Game-flow/persistence flow recovered from `scripts/game_manager.gd`:

- `GameManager._update_death_line()` calls `_game_over()` after the danger tolerance.
- `_game_over()` sets `game_over`, clears merge requests, stops shooting, freezes drinks, persists `best_score`, and shows the GameOver overlay.
- `_restart_game()` calls `get_tree().reload_current_scene()`.
- `_load_best_score()` and `_save_best_score()` use `ConfigFile` at `user://save.cfg`, section `records`, key `best`.
- During recovery, a direct defect was found: `_add_score()` updates `best_score` live, so the former `_game_over()` condition `score > best_score` could never save a new record. The bounded M01 fix makes `_game_over()` persist the current best unconditionally at the terminal state. No tuning, scoring value, layout, art, or To-Go rule was changed.

## Accepted gameplay constants and data evidence

Exact source locations/symbols and values:

```text
scripts/shot_controller.gd:7   @export var launch_speed: float = 700.0
scripts/drink.gd:26            var slide_deceleration: float = 180.0
scripts/drink.gd:209-220       set_held(); freeze=true; collision_layer=0; collision_mask=0
scripts/drink.gd:227-243       start_sliding(); forward-only velocity; layer/mask=1; freeze=false
scripts/drink.gd:321-360       physics deceleration and settle handling
scripts/drink.gd:398-410       _forward_only() and enforcement of non-positive Y
scripts/merge_queue.gd:26-45   momentum calculation and no-backward clamp
scripts/merge_queue.gd:91-113  max-level check and moving merge result
scripts/game_manager.gd:435-450 target range mini(6,max_level)..mini(12,max_level)
scripts/game_manager.gd:256-271 user://save.cfg load/save path
```

`data/drinks.json` was parsed during verification:

OUTPUT BEGIN
```text
DRINK_LEVEL_COUNT=12
LEVEL_IDS=1,2,3,4,5,6,7,8,9,10,11,12
TARGET_LEVELS=6..12
TARGET_DATA=L6:order_reward=0;L7:order_reward=0;L8:order_reward=3000;L9:order_reward=5000;L10:order_reward=8000;L11:order_reward=12000;L12:order_reward=18000
```
OUTPUT END

There is one non-blocking documentation finding for independent audit: `README.txt` says “the first target is L8”, while the synchronized source comments and `_choose_next_target(initial=true)` select L6 and then rotate through L6-L12. The M01 prompt requires the range L6-L12, which the source satisfies. Codex did not silently redefine this contract or alter the README in M01; the discrepancy is recorded for audit.

## Godot 4.7.x validation exact outputs

Executable: `C:\Users\sekip\AppData\Local\Microsoft\WinGet\Links\godot.exe`.

Version:

OUTPUT BEGIN
```text
4.7.2.stable.official.ed1daf0bf
VERSION_EXIT_CODE=0
```
OUTPUT END

Import/parse:

OUTPUT BEGIN
```text
WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
   at: _should_skip_directory (editor/file_system/editor_file_system.cpp:3497)
IMPORT_EXIT_CODE=0
```
OUTPUT END

The nested-project warning is expected from retained reference material and is non-fatal. It is isolated by `original_reference/.gdignore`; no production reference is redirected to that folder.

Configured main-scene startup:

OUTPUT BEGIN
```text
STARTUP_EXIT_CODE=0
```
OUTPUT END

Command forms used:

```text
godot --headless --quiet --path . --editor --import --quit
godot --headless --quiet --path . --quit-after 3
```

## Deterministic focused runtime probe

Added non-production support file `tests/m01_contract_probe.gd`. It is a bounded SceneTree probe and does not alter production scene wiring. It exercises the actual main scene, source input handlers, physics bodies, merge queue, Game Over, persistence, and reload path.

The probe was run with APPDATA redirected to an isolated temporary directory so the owner’s normal Godot `user://` data could not be touched:

```text
Start-Process godot --headless --path . --script res://tests/m01_contract_probe.gd
ISOLATED_APPDATA=C:\Users\sekip\AppData\Local\Temp\BCM-M01-isolated-appdata-v2
```

Exact focused output:

OUTPUT BEGIN
```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
M01_PROBE user_save_path=C:/Users/sekip/AppData/Local/Temp/BCM-M01-isolated-appdata-v2/Godot/app_userdata/CocktailMerge/save.cfg
M01_PROBE PASS: main scene loads as PackedScene
M01_PROBE PASS: runtime world is created
M01_PROBE PASS: runtime ShotController is created
M01_PROBE PASS: runtime MergeQueue is created
M01_PROBE PASS: initial held drink exists
M01_PROBE PASS: initial drink is HELD
M01_PROBE PASS: held drink is frozen
M01_PROBE PASS: held drink has no collision layer/mask
M01_PROBE PASS: mouse release launches current drink
M01_PROBE PASS: launched drink uses 700 px/s initial velocity
M01_PROBE PASS: launched drink is collidable
M01_PROBE PASS: next held drink appears immediately after mouse launch
M01_PROBE PASS: next drink is HELD
M01_PROBE PASS: touch release launches current drink
M01_PROBE PASS: touch route provides another immediate held drink
M01_PROBE PASS: multiple drinks can move simultaneously
M01_PROBE PASS: sliding deceleration is 180 px/s^2
M01_PROBE PASS: forward-only motion removes +Y rebound
M01_PROBE PASS: settled drink wakes and is physically movable on impact
MERGE L2 +20  COMBO x1 +0  (toplam: 20)
M01_PROBE PASS: merge creates capped next level
M01_PROBE PASS: merge result preserves forward/lateral momentum
M01_PROBE PASS: L12 is the cap and L13 is unavailable
OYUN BITTI - Skor: 123
M01_PROBE PASS: Game Over freezes the run and shows overlay
M01_PROBE PASS: best score is persisted through user://
M01_PROBE PASS: restart reloads a playable scene
M01_PROBE PASS: best score survives restart
M01_PROBE_RESULT=PASS
PROBE_EXIT_CODE=0
```
OUTPUT END

The probe’s persistence assertion loaded the isolated `user://save.cfg`, checked `records/best == 123`, confirmed the file exists, reloaded the current scene, and confirmed the new GameManager restored `best_score == 123`.

## Verified, source-inferred, and unverified matrix

Verified by deterministic runtime probe and/or Godot startup:

- project import/parse and configured main-scene startup;
- runtime Main/World/MergeQueue/ShotController creation;
- initial held non-physical drink;
- desktop mouse release route;
- mobile touch press/drag/release route;
- immediate next-held availability after launch;
- second launch while earlier drinks remain active;
- multiple simultaneous moving drinks;
- 700 px/s initial launch and 180 px/s² deceleration;
- stopped drink waking and moving after a physical impact;
- merge result momentum and forward-only post-collision behavior;
- L12 cap / no L13 data progression;
- Game Over freeze/overlay/stop-shooting behavior;
- isolated `user://` persistence and restart restoration.

Source-inferred from inspected production symbols/configuration, not claimed as a native device acceptance test:

- exact trapezoid/rail geometry and collision layer/mask wiring;
- no artificial cruise/minimum-speed assist (the only slide speed change is deceleration in `_integrate_forces()`);
- To-Go target range and non-repeat rotation logic;
- deferred merge replacement and stock-delivery code path.

UNVERIFIED:

- native touchscreen hardware behavior and device safe-area interaction;
- exported Android/iOS builds and device performance;
- long-duration manual play feel across dense collision clusters;
- owner-native visual acceptance.

No fake interactive or device evidence was recorded.

## Files changed in M01

```text
scripts/game_manager.gd
tests/m01_contract_probe.gd
docs/codex-logs/BCM-M01_MILESTONE_COMPLETION_V01_CODEX_LOG.md
```

`scripts/game_manager.gd` contains only the bounded persistence repair described above. `tests/m01_contract_probe.gd` is deterministic/non-production support. No `TASKS.md`, V7 asset, visual integration, M02 file, or gameplay tuning file was changed.

## Final pre-commit checks

Before staging this log, the working-tree checks returned:

OUTPUT BEGIN
```text
git diff --check
DIFF_CHECK_EXIT_CODE=0
git diff -- TASKS.md
TASKS_DIFF_EXIT_CODE=0
```
OUTPUT END

The only intended pre-log paths were the bounded source fix and the new test. Generated `.godot`/import data remained ignored.

## Completion and stop condition

- The intended M01 source/support/log changes were committed and pushed to `main` after this evidence was written.
- The final pushed commit SHA and the post-push `HEAD`/`origin/main`/remote-main equality outputs are supplied in the completion response because a commit cannot contain its own hash without changing that hash.
- `TASKS.md` was not edited.
- BCM-M02 was not started.
- V7 visual integration was not started.
- Codex assigns no M01 acceptance verdict; execution stops here for independent ChatGPT audit.
