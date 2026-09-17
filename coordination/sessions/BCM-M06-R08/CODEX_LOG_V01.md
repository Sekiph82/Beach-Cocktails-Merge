# BCM-M06-R08 Codex Execution Log V01

## Status

`IMPLEMENTATION_COMPLETE / AWAITING_INDEPENDENT_AUDIT`

Builder evidence only; no acceptance verdict is assigned here.

## Authority and scope

- Work item: `BCM-M06-R08`
- Prompt: `coordination/sessions/BCM-M06-R08-M07-R08/CHATGPT_EXECUTION_PROMPT_V04.md`
- Locked criteria: `coordination/sessions/BCM-M06-R08/CHATGPT_AUDIT_CRITERIA_V03.md`
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`
- Branch: `main`
- Workspace: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`

## Sync preflight

```text
git status --short --branch
## main...origin/main
 M project.godot
git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
git fetch origin main
From https://github.com/Sekiph82/Beach-Cocktails-Merge
   1c85c12..8c34d30  main -> origin/main
git rev-list --left-right --count HEAD...origin/main
0 13
git merge --ff-only origin/main
Updating 1c85c12..8c34d30
Fast-forward
```

The pre-existing owner-created `project.godot` modification was preserved and was never staged by this phase.

## Implementation

The production tabletop solver now exposes one runtime `rear_table_y` and computes every rear center from the current body half-extent:

```text
get_rear_target_center_y(body_half_extent_y) = rear_table_y + body_half_extent_y
clamp_position_to_board upper rear bound = get_rear_target_center_y(radius) + TABLE_SOLVER_EPSILON
```

The active circular `CollisionShape2D` radius is the physical glass/container half-extent used by the current M05 visual footprint. Garnish, straw, fruit, flowers, leaves, umbrellas and transparent texture margins are not part of this extent. No per-level rear Y table and no per-level rear boundary were added. Level-dependent center values arise only from the current L01-L12 collider radius.

The piecewise visible tabletop rails and accepted danger/launch coordinates remain unchanged. No corner guidance force was added; the existing measured polyline boundary provides smooth segment-by-segment corner behavior without changing momentum, speed, collision, merge or rapid-launch contracts.

## Changed files in the implementation commit

```text
scripts/game_manager.gd
tests/m06_r08_rear_tangency_probe.gd
tests/m06_r08_tangency_overlay.gd
docs/evidence/m06_r08/canonical_720x1280.png
docs/evidence/m06_r08/canonical_720x1280_tangency_overlay.png
docs/evidence/m06_r08/taller_720x1440.png
docs/evidence/m06_r08/taller_720x1440_tangency_overlay.png
docs/evidence/m06_r08/shorter_wider_800x1280.png
docs/evidence/m06_r08/shorter_wider_800x1280_tangency_overlay.png
```

Implementation commit:

```text
5fcf641 BCM-M06-R08 enforce common rear body tangency
```

## M06-R08 probe evidence

Command:

```text
godot_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/m06_r08_rear_tangency_probe.gd
EXIT_CODE=0
M06_R08_PROBE_RESULT=PASS
```

The independent dataset uses source rear sample `y=472.0`. The probe recorded these common rear values:

```text
canonical_720x1280 rear_table_y=393.333
taller_720x1440 rear_table_y=442.500
shorter_wider_800x1280 rear_table_y=393.333
```

For every viewport, every L01-L12 record satisfied `visible_body_top_y == rear_table_y` with `tangency_error=0.000`. The independent collider-derived half-extents and target-center offsets were:

```text
L01 20.000
L02 23.000
L03 27.000
L04 31.000
L05 36.000
L06 42.000
L07 49.000
L08 56.000
L09 64.000
L10 72.000
L11 80.000
L12 90.000
```

Representative runtime results included rear-left L01 and rear-right L12 in all three required layouts, each with body-top tangency error `0.000`. The retained clean and `_tangency_overlay` captures are 720x1280, 720x1440 and 800x1280; overlays show the common rear line and representative small/mid/large body footprints.

## Preservation checks

- `DANGER_SOURCE_Y=1080.0` and `LAUNCH_SOURCE_Y=1136.0` were not changed.
- Launch speed `700 px/s`, deceleration `180 px/s²`, collision/momentum, merge, combo, economy, persistence, Game Over/restart and rapid launch logic were not retuned.
- Canonical PNGs were not modified.
- `guide_line` was not added.
- M07 work was not included in this bounded implementation commit.
- `TASKS.md`, ChatGPT-owned files and historical logs were not edited.
- M08+ work was not started.

## Checks performed

```text
git diff --check
GIT_DIFF_CHECK_EXIT_CODE=0
```

The Godot 4.7.2 parse/import/startup and the complete active M01-M07 suite are run after the subsequent M07 phase, as required by V04. This phase's focused M06 probe passed before handoff to Phase 2.

## Handoff

`AWAITING_AUDIT`

This log is immutable builder evidence. Independent ChatGPT audit remains required; no `AUDITED_PASS` was assigned and the tracker was not modified.
