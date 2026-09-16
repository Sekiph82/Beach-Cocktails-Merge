# BCM-M02 — Milestone Completion V01 Codex Log

This immutable Codex log records the M02 physics, collision, merge, and rapid-launch hardening work. It is builder evidence, not an acceptance verdict. Independent ChatGPT audit remains required.

## Scope and governance

- Milestone: M02 — Physics, collision, merge, and rapid-launch hardening.
- Active task: BCM-M02-001 — Formalize physics, collision, merge, and rapid-launch regression suite.
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Godot target/runtime: `4.7.x`; installed runtime: `4.7.2.stable.official.ed1daf0bf`.
- Authoritative prompt: `docs/prompts/BCM-M02_MILESTONE_COMPLETION_V01_PROMPT.md`.
- Mandatory sources read from the synchronized checkout: `AGENTS.md`, root `TASKS.md`, `docs/audits/BCM-M01_MILESTONE_COMPLETION_V01_AUDIT.md`, `docs/codex-logs/BCM-M01_MILESTONE_COMPLETION_V01_CODEX_LOG.md`, and the M02 prompt.
- `TASKS.md` was not edited by Codex and remains the owner/ChatGPT-controlled tracker.
- M03, M04, M05, and all V7 visual integration work were not started.

## Sync-first preflight exact outputs

The mandatory preflight was run from the canonical local root before implementation. The local tree was clean; `origin` already pointed to the canonical repository.

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
   0b4a18e..cc342e4  main       -> origin/main
git rev-parse HEAD
0b4a18e7638eb6f58eb1524db34530f8d0f8e38c
git rev-parse origin/main
cc342e4917e017e09f42fb307decb8be410fb18e
git rev-list --left-right --count HEAD...origin/main
0 3
```
OUTPUT END

Remote-only commits were the accepted M01 audit, consolidated M02 work order, and M01 closure/tracker advance. They were incorporated with:

```text
git merge --ff-only origin/main
Updating 0b4a18e..cc342e4
Fast-forward
```

After reconciliation, `HEAD` and `origin/main` were both `cc342e4917e017e09f42fb307decb8be410fb18e`, with divergence `0 0`. No reset, force-push, automatic rebase, destructive checkout, or silent stash was used.

## M01 baseline and documentation cleanup

The accepted M01 baseline was inspected before changes. `project.godot`, `scenes/main.tscn`, `data/drinks.json`, `scripts/shot_controller.gd`, and the existing M01 probe remained the starting implementation. M02 did not change launch tuning, scoring tables, combo economy, To-Go rewards/selection, UI composition, or V7 assets.

The explicitly required documentation cleanup was made:

```text
README.txt before: To-Go Orders targets remain L6-L12; the first target is L8 and immediate repeats are avoided.
README.txt after:  To-Go Orders targets remain L6-L12; the first target is L6 and immediate repeats are avoided.
```

Production target behavior remains source-defined as L6 initially, then L6-L12 with immediate-repeat avoidance.

## Production files and symbols inspected

- `project.godot`: main scene, 720x1280 logical viewport, 405x720 override, viewport stretch/aspect keep, portrait orientation, GL Compatibility.
- `scenes/main.tscn`: `Main` Node2D with `GameManager` script.
- `scripts/game_manager.gd`: table geometry, rail creation, danger line, world hierarchy, spawning, Game Over/restart, To-Go target range.
- `scripts/shot_controller.gd`: launch speed, current/next state, mouse/touch routes, immediate `_spawn_next()`.
- `scripts/drink.gd`: `RigidBody2D` state machine, collider, mass, damping/material, CCD, wake/settle, forward-only contact handling, merge signal dispatch.
- `scripts/merge_queue.gd`: deferred replacement queue, duplicate-pair guard, mass-weighted merge position/velocity, L12 validation, momentum preservation.
- `data/drinks.json`: all 12 level radii, design masses, merge scores, and To-Go reward data.
- `tests/m01_contract_probe.gd`: reused M01 scene/runtime regression probe.
- `tests/m02_physics_regression.gd`: deterministic M02-focused production-class regression probe.

Runtime physics configuration recovered from source:

- Runtime mass is intentionally compressed as `1.0 + (level - 1) * 0.30`; JSON design mass remains the original doubling progression. The source comment explains why literal 1..2048 mass would make high-level drinks concrete-like.
- `gravity_scale=0.0`, `linear_damp=0.0`, `angular_damp=3.0`, rotation locked.
- `continuous_cd=CCD_MODE_CAST_SHAPE`, `freeze_mode=FREEZE_MODE_STATIC`.
- Drink material: friction `0.08`, bounce `0.0`; rails: friction `0.10`, bounce `0.0`.
- Held: `freeze=true`, layer/mask `0`; sliding/settled: dynamic and layer/mask `1`; merging/target-captured: layer/mask `0`.
- Settled bodies wake when impact velocity exceeds `8.0`; sliding decelerates at `180 px/s²`; no cruise/minimum-speed assist.
- `_forward_only()` removes positive Y velocity, preventing intentional return toward the player.

Exact source symbol locations include `ShotController.launch_speed`, `Drink.slide_deceleration`, `Drink.set_held()`, `Drink.start_sliding()`, `Drink._integrate_forces()`, `Drink._forward_only()`, `Drink._on_body_entered()`, `MergeQueue.request_merge()`, `MergeQueue._do_merge()`, `GameManager._build_walls()`, `GameManager._update_death_line()`, and `GameManager._choose_next_target()`.

## Mass/radius table exact runtime output

OUTPUT BEGIN
```text
M02_MASS_RADIUS_TABLE L1 radius=14.0 mass=1.0 json_mass=1.0; L2 radius=21.0 mass=1.29999995231628 json_mass=2.0; L3 radius=29.0 mass=1.60000002384186 json_mass=4.0; L4 radius=38.0 mass=1.89999997615814 json_mass=8.0; L5 radius=48.0 mass=2.20000004768372 json_mass=16.0; L6 radius=59.0 mass=2.5 json_mass=32.0; L7 radius=71.0 mass=2.79999995231628 json_mass=64.0; L8 radius=84.0 mass=3.09999990463257 json_mass=128.0; L9 radius=98.0 mass=3.40000009536743 json_mass=256.0; L10 radius=113.0 mass=3.70000004768372 json_mass=512.0; L11 radius=129.0 mass=4.0 json_mass=1024.0; L12 radius=146.0 mass=4.30000019073486 json_mass=2048.0
```
OUTPUT END

All 12 current colliders are positive and runtime mass is monotonic. Final collider-to-visible-sprite footprint alignment is explicitly `DEFERRED TO M05`; V7 sprites were not integrated in M02.

## Defect found and bounded repair

The first M02 run exposed a direct M02.02 defect: `body_entered` synchronously emitted `merged`, which called `MergeQueue.request_merge()` and `begin_merge()` while Godot was flushing physics queries.

Exact failure excerpt:

OUTPUT BEGIN
```text
ERROR: Can't change this state while flushing queries. Use call_deferred() or set_deferred() to change monitoring state instead.
   at: body_set_mode (modules/godot_physics_2d/godot_physics_server_2d.cpp:569)
   [0] begin_merge (res://scripts/drink.gd:278)
   [1] request_merge (res://scripts/merge_queue.gd:46)
   [2] _on_body_entered (res://scripts/drink.gd:395)
```
OUTPUT END

Minimal repair: `Drink._on_body_entered()` now defers `_emit_merge_request(other, level + 1)`. The helper revalidates instance/state/level/cap conditions, then emits the existing signal outside the physics callback. `MergeQueue` remains the resolver; no tuning or economy changes were made.

The M01 support probe also had a measurement-only issue: random initial level selection could make it count the initial held level-2 drink as the merged result. It now excludes `MotionState.HELD` for that result lookup. This was not a production behavior change.

## Godot version/import/startup exact outputs

```text
GODOT_PATH=C:\Users\sekip\AppData\Local\Microsoft\WinGet\Links\godot.exe
4.7.2.stable.official.ed1daf0bf
VERSION_EXIT_CODE=0
```

Import command:

```text
godot --headless --quiet --path . --editor --import --quit
WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
   at: _should_skip_directory (editor/file_system/editor_file_system.cpp:3497)
IMPORT_EXIT_CODE=0
```

Main-scene startup command:

```text
godot --headless --quiet --path . --quit-after 3
STARTUP_EXIT_CODE=0
```

The nested-project warning is expected retained reference material and is non-fatal.

## M01 regression after production repair

Command: `godot --headless --path . --script res://tests/m01_contract_probe.gd` with isolated APPDATA `C:\Users\sekip\AppData\Local\Temp\BCM-M02-m01-regression-final`.

OUTPUT BEGIN
```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
M01_PROBE user_save_path=C:/Users/sekip/AppData/Local/Temp/BCM-M02-m01-regression-final/Godot/app_userdata/CocktailMerge/save.cfg
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
M01_PROBE PASS: Game Over freezes run and shows overlay
M01_PROBE PASS: best score is persisted through user://
M01_PROBE PASS: restart reloads a playable scene
M01_PROBE PASS: best score survives restart
M01_PROBE_RESULT=PASS
M01_PROBE_EXIT_CODE=0
```
OUTPUT END

## M02 focused regression exact output

Command: `godot --headless --path . --script res://tests/m02_physics_regression.gd` with isolated APPDATA `C:\Users\sekip\AppData\Local\Temp\BCM-M02-focused-final`.

OUTPUT BEGIN
```text
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
M02_PROBE user_save_path=C:/Users/sekip/AppData/Local/Temp/BCM-M02-focused-final/Godot/app_userdata/CocktailMerge/save.cfg
M02_PROBE PASS: main scene loads as PackedScene
M02_PROBE PASS: runtime GameManager/World is ready
M02_PROBE PASS: runtime world has four named rails
M02_BODY_CONFIG level=6 mass=2.5 radius=59.0 freeze_mode=0 ccd=2 linear_damp=0.0 angular_damp=3.0 friction=0.07999999821186 bounce=0.0
M02_PROBE PASS: RigidBody2D body and zero-bounce physics configuration
M02_PROBE PASS: settled body starts dynamic, sleeping, and collidable
M02_MASS_RADIUS_TABLE L1 radius=14.0 mass=1.0 json_mass=1.0; L2 radius=21.0 mass=1.29999995231628 json_mass=2.0; L3 radius=29.0 mass=1.60000002384186 json_mass=4.0; L4 radius=38.0 mass=1.89999997615814 json_mass=8.0; L5 radius=48.0 mass=2.20000004768372 json_mass=16.0; L6 radius=59.0 mass=2.5 json_mass=32.0; L7 radius=71.0 mass=2.79999995231628 json_mass=64.0; L8 radius=84.0 mass=3.09999990463257 json_mass=128.0; L9 radius=98.0 mass=3.40000009536743 json_mass=256.0; L10 radius=113.0 mass=3.70000004768372 json_mass=512.0; L11 radius=129.0 mass=4.0 json_mass=1024.0; L12 radius=146.0 mass=4.30000019073486 json_mass=2048.0
M02_PROBE PASS: all 12 collider radii are positive and runtime mass is monotonic
M02_PROBE PASS: held state is frozen and non-physical before release
M02_PROBE PASS: held-to-sliding transition enables dynamic collision
M02_TOP_CONTACT final_position=(360.0, 230.465) motion_state=2 velocity=(0.0, 0.0)
M02_PROBE PASS: top boundary contact settles without +Y rebound
M02_DIRECT_HIT contacts=1 target_position=(150.0, 635.8008) target_state=1
M02_PROBE PASS: 700 px/s direct-hit has contact without tunneling
M02_GLANCING_HIT contacts=1 target_position=(567.1415, 675.0937) target_state=1
M02_PROBE PASS: 700 px/s glancing-hit has contact without tunneling
M02_PROBE PASS: collision response remains forward-only
MERGE L2 +20  COMBO x1 +0  (toplam: 20)
M02_SINGLE_MERGE score_delta=20 level2_bodies=1 pending=0
M02_PROBE PASS: one pair resolves once with one score and one result body
MERGE L2 +20  COMBO x2 +5  (toplam: 45)
MERGE L3 +50  COMBO x3 +25  (toplam: 120)
M02_CHAIN_STRESS l3_bodies=2 moving_stress=true pending=0
M02_PROBE PASS: moving multi-body chain merge produces stable L3
M02_PROBE PASS: chain merge consumes only the intended chain inputs
M02_PROBE PASS: L12 plus L12 remains two L12 bodies with no L13
M02_PROBE PASS: L12 remains a hard cap
M02_RAPID_STEP index=1 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=2 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=3 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=4 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=5 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_STEP index=6 pre_ok=true post_ok=true fired_state=1 next_state=0
M02_RAPID_LAUNCH launches=6 world_drinks=7 simulated_previous=6 current_valid=true current_state=0
M02_PROBE PASS: six rapid launches preserve current/next integrity
M02_PROBE PASS: earlier rapid-launch drinks continue physical simulation
M02_PROBE PASS: restart during multi-body motion produces clean playable scene
OYUN BITTI - Skor: 0
M02_PROBE PASS: Game Over with multiple moving drinks freezes all and stops shooting
M02_PROBE PASS: post-Game-Over restart has no stale moving-body references
M02_PROBE_RESULT=PASS
M02_PROBE_EXIT_CODE=0
```
OUTPUT END

`M02_SINGLE_MERGE` requested the same pair twice and got one result, one score delta, and zero pending requests. `M02_CHAIN_STRESS` reports two L3 bodies because one is the generated chain result and one is the intentionally moving L3 stress body; the intended chain inputs were consumed once. Direct and glancing tests counted actual contacts and target movement at accepted speed with CCD enabled, proving no practical tunneling in those representative cases.

## Verified / source-inferred / deferred matrix

Verified by deterministic Godot runtime and/or source:

- RigidBody2D state transitions, mass/radius table, sleep/wake/settle, friction/damping/zero-bounce/CCD: PASS.
- Held non-collision to released collision transition: PASS.
- Four named rails, top boundary, forward-only response, settled-body impact wake/momentum transfer: PASS.
- Direct/glancing 700 px/s contact/no-practical-tunneling: PASS.
- Deferred merge replacement, single-pair single-resolution/single-score, next-level merge, L12 cap, L12+L12 retention, momentum, moving chain/stress: PASS.
- Six rapid launches, current/next integrity, earlier moving bodies, restart with moving bodies, Game Over with moving bodies, stale-reference cleanup: PASS.
- M01 regression after production repair: PASS.
- README first target: corrected to L6.

Source-inferred or engine-event-level only: exact geometry/layer wiring, no cruise assist, target-range source logic, native touch hardware behavior, and exhaustive dense-table coverage.

UNVERIFIED/deferred: device/export behavior, long-duration manual play feel, owner-native visual acceptance, and final sprite-footprint alignment (`DEFERRED TO M05`).

## Files changed in M02

```text
README.txt
scripts/drink.gd
tests/m01_contract_probe.gd
tests/m02_physics_regression.gd
docs/codex-logs/BCM-M02_MILESTONE_COMPLETION_V01_CODEX_LOG.md
```

No `TASKS.md`, M03, V7, asset, visual, scoring, To-Go, audio, export, or unrelated file was changed.

## Final pre-commit evidence and stop condition

Before staging, the exact final scope check was:

OUTPUT BEGIN
```text
=== FINAL PRE-COMMIT DIFF/SCOPE ===
WORKTREE_DIFF_CHECK_EXIT_CODE=0
M README.txt
M scripts/drink.gd
M tests/m01_contract_probe.gd
=== TASKS PROTECTION ===
TASKS_DIFF_EXIT_CODE=0
=== STATUS ===
## main...origin/main
M README.txt
M scripts/drink.gd
M tests/m01_contract_probe.gd
?? docs/codex-logs/BCM-M02_MILESTONE_COMPLETION_V01_CODEX_LOG.md
?? tests/m02_physics_regression.gd
=== README TARGET ===
27:- To-Go Orders targets remain L6-L12; the first target is L6 and immediate repeats are avoided.
```
OUTPUT END

Staged checks returned `STAGED_DIFF_CHECK_EXIT_CODE=0` and `STAGED_TASKS_DIFF_EXIT_CODE=0`.

The intended files were committed and pushed to `main`. The final commit SHA and post-push equality proof are supplied in the completion response after commit creation; a commit cannot contain its own hash without changing that hash. `TASKS.md` was not edited. M03 and V7 integration were not started. Codex assigns no M02 acceptance verdict and stops for independent ChatGPT audit.
