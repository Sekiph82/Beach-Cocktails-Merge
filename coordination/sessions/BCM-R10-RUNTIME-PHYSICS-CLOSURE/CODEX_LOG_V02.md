# BCM-R10-RUNTIME-PHYSICS-CLOSURE — CODEX LOG V02

Status: IMPLEMENTATION_COMPLETE / AWAITING_INDEPENDENT_AUDIT

## Authority and sync

- Prompt: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V04.md`.
- Locked criteria: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V04.md`.
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`, branch `main`.
- Godot: `4.7.2.stable.official.ed1daf0bf`.
- Start HEAD after fast-forward: `7e9c0220d2c75b3c515366313657cbce6628246c`.
- Implementation SHA: `608bf1c8f7531c89d80e9a70d20bda17cfe75e02`.

All commands ran from `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.

Initial status was `## main...origin/main` with only these pre-existing owner-dirty paths: the six `docs/evidence/m06_r07/*.png` files and `project.godot`.

Remote was exactly:

```text
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
```

`git fetch origin main` completed. Pre-reconciliation `git rev-list --left-right --count HEAD...origin/main` was `0 13`; `git merge --ff-only origin/main` completed at `7e9c0220d2c75b3c515366313657cbce6628246c`. No reset, rebase, force-push, stash or destructive checkout was used.

The dirty `project.godot` was inspected before code edits. Its diff contains only Godot editor boilerplate comments and removal of `window/stretch/aspect="keep"`; it has no autoload, test startup path, alternate main scene or probe reference. It was preserved and excluded. The six dirty M06-R07 evidence files were also preserved and excluded.

## Implementation summary

### Rear physics

- `GameManager.get_rear_target_center_y()` now returns exactly `rear_table_y`; its compatibility argument is not used in the Y formula.
- `clamp_position_to_board()` uses exact common `rear_table_y` for rear Y; radius remains lateral-only.
- `Drink._integrate_forces()` applies the measured perspective side bounds during normal RigidBody2D motion and holds each moving drink at the exact common rear target. Zero-lateral-velocity rear arrival enters the normal settle path.
- `_build_walls()` no longer uses stale y=472 first rail samples for TopRail. Its span comes from `get_table_rail_bounds_at_y(rear_table_y)`; a small clearance prevents the rectangle nudging L12 off the exact solver target.
- No per-level rear target, sprite/body-height offset, garnish extent, width adjustment or radius addition was introduced into the rear target.

### HUD

- SCORE remains the accepted right-side anchor.
- BEST SCORE is moved by matching displayed canonical alpha-bottom to displayed SCORE alpha-bottom.
- NEXT is moved by matching displayed canonical alpha-center-X to SCORE alpha-center-X.
- Logo display width increases modestly from 190 to 210 px, preserving the canonical 1536:1024 aspect ratio. Logo X is solved from actual logo/BEST alpha bounds.
- `_visible_artwork_bounds()` uses `Image.get_used_rect()` and the same aspect-preserving scale as `_make_panel()`.
- Fixed score fonts remain 20 px and the seven-digit score contract remains unchanged. To-Go, held-drink/gold-oval, NEXT, progression, gameplay geometry and economy behavior remain otherwise unchanged.

Added `tests/r10_runtime_physics_closure_probe.gd`, `tests/r10_desktop_idle_smoke.gd` and three captures under `docs/evidence/r10/`. `tests/m02_physics_regression.gd` received only fixture isolation before its TopRail case; production behavior was not changed by that test correction.

## R10 graphical runtime evidence

Command: `$env:APPDATA='C:\Users\sekip\AppData\Local\Temp\BCM-R10-APPDATA'; godot_console.exe --path . --display-driver windows --rendering-method gl_compatibility --script tests/r10_runtime_physics_closure_probe.gd`.

Exit code: `0`; exact result: `R10_RUNTIME_PHYSICS_CLOSURE_RESULT=PASS`.

HUD measurements:

```text
R10_HUD_BOUNDS label=canonical_720x1280 best_bottom_y=317.2205 score_bottom_y=317.2205 bottom_error=0.0000 score_center_x=605.4387 next_center_x=605.4387 score_next_x_error=0.0000 logo_center_x=118.5613 best_center_x=118.5613 logo_best_x_error=0.0000 logo_panel_width=210.0000
R10_HUD_BOUNDS label=taller_720x1440 best_bottom_y=317.2205 score_bottom_y=317.2205 bottom_error=0.0000 score_center_x=605.4387 next_center_x=605.4387 score_next_x_error=0.0000 logo_center_x=118.5613 best_center_x=118.5613 logo_best_x_error=0.0000 logo_panel_width=210.0000
R10_HUD_BOUNDS label=shorter_wider_800x1280 best_bottom_y=317.2205 score_bottom_y=317.2205 bottom_error=0.0000 score_center_x=685.4387 next_center_x=685.4387 score_next_x_error=0.0000 logo_center_x=118.5613 best_center_x=118.5613 logo_best_x_error=0.0000 logo_panel_width=210.0000
```

Capture results, each with `error=0`: `canonical_720x1280.png` (720x1280), `taller_720x1440.png` (720x1440), and `shorter_wider_800x1280.png` (800x1280).

Normal-physics rear results:

```text
R10_REAR_PHYSICAL_STATE rear_table_y=380.8333 table_top_y=380.8333 rear_bounds=(61.6667,658.3334)
R10_REAR_MOTION label=rear-center-L01 level=L01 start_x=360.0000 final=(360.0000,380.8333) rear_table_y=380.8333 target_error=0.0000 state=SETTLED velocity=(0.0000,0.0000)
R10_REAR_MOTION label=rear-center-L06 level=L06 start_x=360.0000 final=(360.0000,380.8333) rear_table_y=380.8333 target_error=0.0000 state=SETTLED velocity=(0.0000,0.0000)
R10_REAR_MOTION label=rear-center-L12 level=L12 start_x=360.0000 final=(360.0000,380.8333) rear_table_y=380.8333 target_error=0.0000 state=SETTLED velocity=(0.0000,0.0000)
R10_REAR_MOTION label=rear-left-L01 level=L01 start_x=44.5000 final=(141.9581,380.8333) rear_table_y=380.8333 target_error=0.0000 state=SETTLED velocity=(0.0000,0.0000)
R10_REAR_MOTION label=rear-right-L12 level=L12 start_x=605.5000 final=(495.2960,380.8333) rear_table_y=380.8333 target_error=0.0000 state=SETTLED velocity=(0.0000,0.0000)
```

## No-input evidence

Desktop Windows command exit code `0` produced:

```text
R10_DESKTOP_IDLE_OBSERVATION_SECONDS=10.0
R10_DESKTOP_IDLE_FINAL score=0 held=1 nonheld=0 total=1
R10_DESKTOP_IDLE_RESULT=PASS
```

The production-only 30.5-second command also returned exit code `0`:

```text
R09_NO_INPUT_OBSERVATION_SECONDS=30.5
R09_NO_INPUT_FINAL score=0 held=1 nonheld=0 total=1 merge_observed=false delivery_observed=false target_transition=false
R09_NO_INPUT_REGRESSION_RESULT=PASS
```

The production main scene therefore does not execute the synthetic L01–L12 drinks from `tests/m06_r08_rear_tangency_probe.gd`.

## Final active M01–M07 regression

Every listed process used a fresh temporary APPDATA directory and returned exit code `0`:

```text
TEST=m01_contract_probe.gd EXIT=0 / M01_PROBE_RESULT=PASS
TEST=m02_physics_regression.gd EXIT=0 / M02_PROBE_RESULT=PASS
TEST=m03_economy_regression.gd EXIT=0 / M03_PROBE_RESULT=PASS
TEST=m04_asset_import_probe.gd EXIT=0 / M04_GODOT_RESULT=PASS
TEST=m05_sprite_integration_probe.gd EXIT=0 / M05_PROBE_RESULT=PASS
TEST=m06_environment_geometry_probe.gd EXIT=0 / M06_PROBE_RESULT=PASS
TEST=m07_hud_composition_probe.gd EXIT=0 / M07_PROBE_RESULT=PASS
TEST=m07_r04_focused_probe.gd EXIT=0 / M07_R04_PROBE_RESULT=PASS
TEST=m07_r06_owner_layout_probe.gd EXIT=0 / M07_R06_PROBE_RESULT=PASS
TEST=r09_no_input_runtime_regression.gd EXIT=0 / R09_NO_INPUT_REGRESSION_RESULT=PASS
TEST=r10_runtime_physics_closure_probe.gd EXIT=0 / R10_RUNTIME_PHYSICS_CLOSURE_RESULT=PASS
TEST=r10_desktop_idle_smoke.gd EXIT=0 / R10_DESKTOP_IDLE_RESULT=PASS
```

The older M05/M06/M07 evidence probes also exited `0`; the dummy headless renderer emits `Parameter "t" is null` while those older probes attempt viewport screenshot writes. The real Windows OpenGL R10 run saved all final captures with `error=0`. Historical probes with superseded assertions were not changed: `m06_r08_rear_tangency_probe.gd` expects the old radius-added target and `m07_r05_hud_adaptation_probe.gd` expects the old upward score stack.

## Godot, parse and hygiene

`godot_console.exe --headless --path . --editor --quit --check-only` returned `0`; `godot_console.exe --headless --path . --editor --quit` returned `0`; `git diff --check` returned `0`. Godot completed filesystem scan, global classes, plugin initialization, asset reimport and editor startup. The only warning was the existing ignored nested `original_reference/project.godot`.

## Canonical asset preservation

No canonical asset path appears in the implementation diff. Observed final SHA-256 values:

```text
E65D7EEDCC60AEDD7522D6415411E39B3ED2798EEDF06318D321BD43DE63B3C9  assets/ui/logo_beach_cocktails_merge.png
94CE6AEAC7847834E91273DC6D32CB9BFD4A273CA459ED387C91624905F71157  assets/ui/panel_best_score.png
3E20ED0266C65B75FC0724D3D7C239ADEF113E0F9D4F0A693EB64ADC8B7104E2  assets/ui/panel_score.png
36396F70B14C58A543BCFE79F2B7BDF3DA4E18F31767ACF3D8260B23580DA56D  assets/ui/panel_next.png
EF9D395A2E2D9CFD0B9A3E998EF5874ACEC0C9210CBE05633A04934FBDDC4400  assets/ui/panel_to_go_orders.png
6354B44CF1D4152C952802FB0F26D03E387B70F37001C75DBB1D886B6EAC611C  assets/ui/progression_strip.png
EA8506F0AE3F5F633F47C3AA6E7CE8BD64CA2CC055D076C4F65B4FCA17CCC72C  assets/ui/launch_zone.png
90ED7E9757EF64AC7C13DCD6F1D1366460F8B69D8623495070F91AB1DA11C5FA  assets/ui/danger_line.png
BF9EF25BFE27B78805C487410601A9FEF16B36F83C97B9BC6F3BF70670DFD17A  assets/environment/game_board_background.png
```

`TASKS.md`, `AGENTS.md`, `coordination/AUDIT_POLICY.md`, all ChatGPT-owned prompt/audit/criteria files, canonical PNGs and historical logs were not modified. No M08+ work and no `guide_line` was added.

## Final repository state

Before the log commit, local HEAD, `origin/main` and remote `main` all equaled `608bf1c8f7531c89d80e9a70d20bda17cfe75e02`. The log commit adds only this file; equality is rechecked after its push. The seven pre-existing owner-dirty paths remain intentionally uncommitted. Independent ChatGPT visual/acceptance audit remains pending. Handoff: `AWAITING_AUDIT`.
