# BCM-R10 V10 — Codex Execution Log

## Scope

- Work item: BCM-R10 V10 runtime physics/boundary recovery.
- Authoritative prompt: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V10.md`.
- Locked criteria: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V10.md`.
- Branch: `main`.
- Godot: Godot Engine v4.7.2.stable.official.
- Final handoff: `AWAITING_AUDIT`.

## Sync-first preflight

Preflight was run from `C:\Users\sekip\Desktop\Beach Cocktails - Merge`:

```text
git status --short --branch
## main...origin/main
 M docs/evidence/m06_r07/canonical_720x1280.png
 M docs/evidence/m06_r07/canonical_720x1280_runtime_overlay.png
 M docs/evidence/m06_r07/shorter_wider_800x1280.png
 M docs/evidence/m06_r07/shorter_wider_800x1280_runtime_overlay.png
 M docs/evidence/m06_r07/taller_720x1440.png
 M docs/evidence/m06_r07/taller_720x1440_runtime_overlay.png
 M project.godot

git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)

git fetch origin main
exit code 0

git rev-list --left-right --count HEAD...origin/main
0 7
```

The checkout was fast-forwarded with `git merge --ff-only origin/main` from `1344b0f05535ea6fc98ebdc10a384361045623bf` to start HEAD `d6c80598d5ec22116e4ea0a7908df8a663426849`. No reset, force-push, rebase, destructive checkout, or stash was used.

Owner-dirty `project.godot` and the six prior M06 evidence PNGs were preserved and never staged. The remote fast-forward included the V10 prompt, locked criteria, audit, and the remote tracker update; Codex did not edit `TASKS.md`.

## Mandatory pre-fix reproduction

Before production implementation changes, `tests/r10_v10_v09_failure_repro.gd` was added and run through the real production `GameManager`, real spawned `Drink` bodies, and normal physics frames. The first version measured the actual rendered Sprite2D alpha footprint for side escape and the production glass-body contact hull for rear clearance. It intentionally failed against V09.

Commands/results:

```text
godot_console.exe --headless --path . --check-only --script res://tests/r10_v10_v09_failure_repro.gd
REPRO_CHECK_EXIT_CODE=0

R10_V10_PREFIX_SIDE side=left level=L01 center=(80.85713,497.2568) rendered_edge_distance=-22.022
R10_V10_PREFIX_SIDE side=right level=L06 center=(601.8839,477.3946) rendered_edge_distance=-40.230
R10_V10_PREFIX_REAR fraction=0.08 level=L12 center=(309.5668,491.2217) body_distance=0.504 visible_distance=-85.889
R10_V10_PREFIX_REAR fraction=0.20 level=L12 center=(240.4023,491.3524) body_distance=0.635 visible_distance=-85.759
R10_V10_PREFIX_REAR fraction=0.50 level=L12 center=(363.3333,490.8521) body_distance=0.135 visible_distance=-86.257
R10_V10_PREFIX_REAR fraction=0.80 level=L12 center=(521.8333,490.8521) body_distance=0.135 visible_distance=-86.257
R10_V10_PREFIX_REAR fraction=0.92 level=L12 center=(390.318,491.2209) body_distance=0.503 visible_distance=-85.890
R10_V10_PREFIX_SIDE_ESCAPE=true
R10_V10_PREFIX_REAR_GAP=true
R10_V10_PREFIX_REPRODUCTION_RESULT=FAIL_CURRENT_V09
REPRO_RUN_EXIT_CODE=1
```

This is retained as the required pre-fix builder reproduction of the owner-observed V09 boundary failure. The full-alpha side measurement is diagnostic evidence only; production contact geometry remains the independently measured visible glass/container body hull and does not include garnish as a gameplay collider.

## V10 implementation

Implementation commit: `6f902737f21c2983dabae6f42f59ed9d1a771e4c`.

Changed files:

- `scripts/drink.gd`
  - Corrected `get_boundary_contact_hull_local()` to compose the exact rendered hierarchy transform:
    `Visual.transform * CocktailSprite.transform * source_point`.
  - No collider radius or canonical PNG was changed.
- `scripts/game_manager.gd`
  - Replaced the V09 projection pass with a bounded iterative projection over the frozen V05 perspective envelope.
  - The accepted rail vertices form the convex perspective envelope; therefore their supporting half-planes are mathematically valid polygon constraints rather than unrelated infinite extensions of arbitrary segments.
  - Adjacent side/rear constraints are applied in sequence for corners, preserving tangential motion and removing only outward normal velocity.
  - The same authoritative projection remains used by live motion, spawning, held movement and merge-time correction through the existing callers.
  - V05 rail source coordinates, rear line, CircleShape2D radii, collision layers, launch/deceleration, economy and HUD behavior were preserved.
- `tests/r10_v10_v09_failure_repro.gd`
  - Post-fix form of the real-physics failure diagnostic; the pre-fix failing output is recorded above.
- `tests/r10_v10_visual_hull_containment_probe.gd`
  - Adds transform-equivalence, frozen-rail, unchanged-radius, side crowd, rear accumulation and left/right merge stress coverage.
- `tests/r10_v10_gui_hull_capture.gd`
  - Normal-display 720x1280 runtime capture using the existing rail/hull/circle overlay.
- `docs/evidence/r10/v10_gui_hull_contacts_720x1280.png`
  - Retained normal GUI evidence.

No canonical PNG, `TASKS.md`, ChatGPT-owned prompt/audit/criteria/policy file, M08+ file, or guide line was modified.

## Post-fix reproduction

The same real production runtime diagnostic was rerun after the fix:

```text
R10_V10_POST_SIDE side=left level=L01 center=(80.81613,497.238) glass_body_edge_distance=0.681
R10_V10_POST_SIDE side=right level=L06 center=(602.029,477.3755) glass_body_edge_distance=0.278
R10_V10_POST_REAR fraction=0.08 level=L12 center=(309.5153,490.3305) glass_body_rear_distance=0.509
R10_V10_POST_REAR fraction=0.20 level=L12 center=(240.3781,490.4566) glass_body_rear_distance=0.635
R10_V10_POST_REAR fraction=0.50 level=L12 center=(363.3333,490.3229) glass_body_rear_distance=0.502
R10_V10_POST_REAR fraction=0.80 level=L12 center=(521.8333,490.3229) glass_body_rear_distance=0.502
R10_V10_POST_REAR fraction=0.92 level=L12 center=(390.4979,490.3288) glass_body_rear_distance=0.507
R10_V10_POST_SIDE_ESCAPE=false
R10_V10_POST_REAR_GAP=false
R10_V10_POST_REPRODUCTION_RESULT=PASS_NO_V09_FAILURE
POST_REPRO_EXIT_CODE=0
```

## Focused V10 probe

Command:

```text
godot_console.exe --headless --path . --script res://tests/r10_v10_visual_hull_containment_probe.gd
```

Exact required evidence markers:

```text
R10_V10_PROBE PASS: V05 left rail source coordinates are frozen
R10_V10_PROBE PASS: V05 right rail source coordinates are frozen
R10_V10_PROBE PASS: 13 finite boundary segments remain exposed
R10_V10_PROBE PASS: all L01-L12 collider radii remain unchanged
R10_V10_PROBE PASS: production scalar V06-V08 boundary model stays retired
R10_V10_TRANSFORM level=L01 y=450.0 root_scale=0.974063 equivalent=true
R10_V10_TRANSFORM level=L06 y=800.0 root_scale=0.985000 equivalent=true
R10_V10_TRANSFORM level=L12 y=1100.0 root_scale=0.994375 equivalent=true
R10_V10_PROBE PASS: Visual->Sprite hull transform equals composed node transforms
R10_V10_SIDE_STRESS side=left level=L01 min_edge_distance=0.681 inside_all=true
R10_V10_PROBE PASS: left crowded glass bodies never escape accepted rails
R10_V10_SIDE_STRESS side=right level=L06 min_edge_distance=0.278 inside_all=true
R10_V10_PROBE PASS: right crowded glass bodies never escape accepted rails
R10_V10_REAR_STRESS fraction=0.08 center=(309.5153,490.3305) body_rear_distance=0.509
R10_V10_REAR_STRESS fraction=0.50 center=(363.3333,490.3229) body_rear_distance=0.502
R10_V10_REAR_STRESS fraction=0.92 center=(390.4979,490.3305) body_rear_distance=0.507
R10_V10_PROBE PASS: rear accumulation reaches the same rear rail without a body gap
R10_V10_MERGE_STRESS side=left valid=true position=(153.98,419.8278)
R10_V10_PROBE PASS: left merge result remains inside the same authoritative solver
R10_V10_MERGE_STRESS side=right valid=true position=(105.6938,538.623)
R10_V10_PROBE PASS: right merge result remains inside the same authoritative solver
R10_V10_VISUAL_HULL_CONTAINMENT_RESULT=PASS
V10_PROBE_EXIT_CODE=0
```

## GUI evidence

Command:

```text
godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/r10_v10_gui_hull_capture.gd
```

Exact result:

```text
R10_V10_GUI_CAPTURE label=composed_hull_frozen_rails_circle_comparison dimensions=720x1280 error=0 path=res://docs/evidence/r10/v10_gui_hull_contacts_720x1280.png
R10_V10_GUI_CAPTURE_RESULT=PASS
FINAL_V10_GUI_CAPTURE_EXIT_CODE=0
```

Retained capture: `docs/evidence/r10/v10_gui_hull_contacts_720x1280.png`, 720x1280, 1,752,754 bytes at final capture. It is builder evidence; owner visual acceptance remains pending.

## Full active regression

The active M01-M07/R09/R10 sequence was run serially after the implementation. Exact result markers:

```text
M01_PROBE_RESULT=PASS
TEST_m01_contract_probe.gd_EXIT_CODE=0
M02_PROBE_RESULT=PASS
TEST_m02_physics_regression.gd_EXIT_CODE=0
M03_PROBE_RESULT=PASS
TEST_m03_economy_regression.gd_EXIT_CODE=0
M04_GODOT_RESULT=PASS
TEST_m04_asset_import_probe.gd_EXIT_CODE=0
M05_PROBE_RESULT=PASS
TEST_m05_sprite_integration_probe.gd_EXIT_CODE=0
M07_PROBE_RESULT=PASS
TEST_m07_hud_composition_probe.gd_EXIT_CODE=0
M07_R06_PROBE_RESULT=PASS
TEST_m07_r06_owner_layout_probe.gd_EXIT_CODE=0
R09_NO_INPUT_REGRESSION_RESULT=PASS
R09_NO_INPUT_OBSERVATION_SECONDS=30.5
TEST_r09_no_input_runtime_regression.gd_EXIT_CODE=0
R10_DESKTOP_IDLE_RESULT=PASS
R10_DESKTOP_IDLE_OBSERVATION_SECONDS=10.0
TEST_r10_desktop_idle_smoke.gd_EXIT_CODE=0
R10_V10_POST_REPRODUCTION_RESULT=PASS_NO_V09_FAILURE
TEST_r10_v10_v09_failure_repro.gd_EXIT_CODE=0
R10_V10_VISUAL_HULL_CONTAINMENT_RESULT=PASS
TEST_r10_v10_visual_hull_containment_probe.gd_EXIT_CODE=0
```

The 30.5-second no-input regression remained at score 0, exactly one held preview, zero non-held drinks, no merge, no delivery and no target transition. The desktop idle smoke remained at score 0 with exactly one held preview and zero non-held drinks.

Known dummy-renderer warnings from M05/M07 screenshot helper paths were emitted, but their contract result markers and process exit codes remained PASS. Normal OpenGL GUI evidence was captured separately above.

## Superseded M06 scalar probe

`tests/m06_environment_geometry_probe.gd` remains a historical scalar-boundary probe and was not counted as active V10 evidence. It was invoked after the implementation and still fails at parse time because it calls removed `get_horizontal_bounds_at_y`; exact result:

```text
SCRIPT ERROR: Parse Error: Cannot infer the type of "launch_bounds" variable because the value doesn't have a set type.
SCRIPT ERROR: Parse Error: Cannot infer the type of "launch_ok" variable because the value doesn't have a set type.
SUPERSEDED_M06_ENVIRONMENT_PROBE_EXIT_CODE=1
```

Its obsolete scalar/radius assertions are replaced by the V10 transform, frozen-rail, side/rear stress and merge probe. Historical files were not rewritten.

## Godot and hygiene checks

```text
EDITOR_IMPORT_EXIT_CODE=0
scripts/drink.gd CHECK_ONLY_EXIT_CODE=0
scripts/game_manager.gd CHECK_ONLY_EXIT_CODE=0
tests/r10_v10_v09_failure_repro.gd CHECK_ONLY_EXIT_CODE=0
tests/r10_v10_visual_hull_containment_probe.gd CHECK_ONLY_EXIT_CODE=0
tests/r10_v10_gui_hull_capture.gd CHECK_ONLY_EXIT_CODE=0
GIT_DIFF_CHECK_EXIT_CODE=0
IMPLEMENTATION_CACHED_DIFF_CHECK_EXIT_CODE=0
```

Godot emitted only the known nested `res://original_reference/project.godot` ignored-project warning. No canonical asset was reimported or modified.

## Scope limitations and handoff

- Implementation SHA: `6f902737f21c2983dabae6f42f59ed9d1a771e4c`.
- Owner-dirty `project.godot` and prior M06 evidence were preserved and excluded.
- No launch speed, deceleration, collider radius, collision/momentum, merge/economy, persistence, Game Over/restart, HUD, NEXT, progression or held-alignment contract was retuned.
- No canonical PNG, guide line, `TASKS.md`, ChatGPT-owned file or M08+ work was changed.
- Codex builder evidence is not independent acceptance. Owner must still run normal Godot GUI and confirm the rear visual gap is gone/natural, side escape is absent, and no transition popping/jitter is introduced.
- Final log commit SHA and the local/origin/live-remote equality proof are recorded after this log is pushed.

Status: `AWAITING_AUDIT`.
