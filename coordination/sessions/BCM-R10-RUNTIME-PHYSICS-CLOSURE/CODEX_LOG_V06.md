# BCM-R10 V08 Codex Execution Log

## Scope and authority

- Work item: `BCM-R10-RUNTIME-PHYSICS-CLOSURE` V08.
- Authoritative prompt: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V08.md`.
- Locked criteria: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V08.md`.
- Read before editing: `AGENTS.md`, `TASKS.md`, `coordination/AUDIT_POLICY.md`, `CHATGPT_AUDIT_V05.md`, and V08 criteria.
- Status: `AWAITING_AUDIT`.
- Codex did not self-audit, did not update `TASKS.md`, did not modify ChatGPT-owned files, did not modify canonical PNGs, and did not start M08+.

## Synchronization preflight

- Workspace: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Branch: `main`.
- Remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Initial session preflight:
  - `git status --short --branch` — `main...origin/main` with the pre-existing owner-dirty `project.godot` and six M06-R07 evidence PNGs.
  - `git remote -v` — canonical repository confirmed.
  - `git fetch origin main` — completed successfully.
  - `git rev-list --left-right --count HEAD...origin/main` — `0 5` before reconciliation.
  - `git merge --ff-only origin/main` — completed successfully to synchronized start HEAD `92df408f0b4e6a0992ef40db13a3fe0b4e88886c`.
- The fast-forward changed only the remote-issued `TASKS.md`, V08 prompt, V08 criteria, and V07 audit artifacts. `TASKS.md` was not edited by Codex.
- Owner-dirty files were preserved and never staged:
  - `project.godot`
  - `docs/evidence/m06_r07/canonical_720x1280.png`
  - `docs/evidence/m06_r07/canonical_720x1280_runtime_overlay.png`
  - `docs/evidence/m06_r07/shorter_wider_800x1280.png`
  - `docs/evidence/m06_r07/shorter_wider_800x1280_runtime_overlay.png`
  - `docs/evidence/m06_r07/taller_720x1440.png`
  - `docs/evidence/m06_r07/taller_720x1440_runtime_overlay.png`

## Implementation

Implementation commit: `0c6f66c4380fc41fb9163cf806dd2daff62b368f`.

Changed and committed only the V08 implementation/evidence files:

- `scripts/drink.gd`
- `scripts/game_manager.gd`
- `tests/r10_v08_exact_edge_contact_probe.gd`
- `tests/r10_v08_gui_edge_capture.gd`
- `docs/evidence/r10/v08_gui_edge_contacts_720x1280.png`

Production changes:

- Replaced the V07 dataset with the exact V08 literal runtime-pixel array:

```text
L01..L12 = [9.0, 10.5, 13.0, 10.0, 14.5, 16.0, 18.0, 22.5, 22.0, 31.0, 32.0, 34.0]
```

- `Drink.table_edge_contact_half_width_for_level()` returns the literal array value directly. It does not calculate from `COLLIDER_RADII`, `VISIBLE_BODY_WIDTH_PX`, `visual_scale_for_level()`, texture dimensions, source widths, or Y scaling.
- `GameManager.get_horizontal_edge_contact_bounds_at_y()` uses the exact V08 rail-plus-edge-footprint model.
- `GameManager.clamp_position_to_board()` keeps the exact common `rear_table_y` and routes known levels through the V08 edge-contact bounds.
- `_max_side_wall_clearance()` keeps full collider radii outside the logical rails using the V08 footprint, preventing physics solver ejection from the accepted logical envelope.
- `scripts/merge_queue.gd` retains V05 Solution 1: the merged result is clamped by the level-specific horizontal edge bounds, with merge Y and inherited momentum preserved.
- V05 rail coordinates, `rear_target_y = rear_table_y`, collider radii, CAST_SHAPE CCD, launch speed, deceleration, HUD, economy, persistence, Game Over/restart, and rapid-launch behavior were preserved.

## V08 focused probe

Probe: `tests/r10_v08_exact_edge_contact_probe.gd`.

The probe uses an independent literal expected array and verifies the production helper source does not contain forbidden collider/scale/texture/source derivation references. It checks all twelve collider radii, frozen V05 left/right/rear coordinates, exact rear targeting, L01/L06/L12 left and right moving contacts, both wall merges using V08 L02 `10.5`, and center merge no-op behavior.

Exact final markers:

```text
R10_V08_PROBE PASS: V05 rear source coordinate remains frozen
R10_V08_PROBE PASS: V05 left envelope coordinates remain frozen
R10_V08_PROBE PASS: V05 right envelope coordinates remain frozen
R10_V08_PROBE PASS: production values match literal V08 array
R10_V08_PROBE PASS: V08 production helper has no forbidden derivation
R10_V08_PROBE PASS: L01/L06/L12 left and right moving contacts remain inside V08 limit
R10_V08_PROBE PASS: left-wall merge uses V08 L02=10.5 edge range
R10_V08_PROBE PASS: right-wall merge uses V08 L02=10.5 edge range
R10_V08_PROBE PASS: center merge clamp is a no-op
R10_V08_EXACT_EDGE_CONTACT_RESULT=PASS
R10_V08_PROBE_EXIT_CODE=0
```

Representative wall evidence:

```text
R10_V08_WALL_MERGE side=left raw_merge_x=10.510 edge_half_width=10.5 valid_range=(12.010,709.000) corrected_x=12.010 contained=true corrected=true
R10_V08_WALL_MERGE side=right raw_merge_x=710.500 edge_half_width=10.5 valid_range=(12.010,709.000) corrected_x=709.000 contained=true corrected=true
R10_V08_CENTER_NOOP raw_merge_x=360.505 corrected_x=360.505 delta=0.000
```

Representative moving-contact evidence:

```text
R10_V08_EDGE_CONTACT level=L01 side=left edge_half_width=9.0 collider_radius=20.0 final_x=10.692 range=(10.692,710.500) inside=true
R10_V08_EDGE_CONTACT level=L01 side=right edge_half_width=9.0 collider_radius=20.0 final_x=710.500 range=(10.748,710.500) inside=true
R10_V08_EDGE_CONTACT level=L06 side=left edge_half_width=16.0 collider_radius=42.0 final_x=17.692 range=(17.692,703.500) inside=true
R10_V08_EDGE_CONTACT level=L06 side=right edge_half_width=16.0 collider_radius=42.0 final_x=703.500 range=(17.748,703.500) inside=true
R10_V08_EDGE_CONTACT level=L12 side=left edge_half_width=34.0 collider_radius=90.0 final_x=36.450 range=(35.266,685.500) inside=true
R10_V08_EDGE_CONTACT level=L12 side=right edge_half_width=34.0 collider_radius=90.0 final_x=684.880 range=(35.383,685.500) inside=true
```

## Full active regression

The final active suite was run after the V08 implementation. Every listed script exited `0` and emitted its PASS marker:

```text
tests/m01_contract_probe.gd EXIT_CODE=0 — M01_PROBE_RESULT=PASS
tests/m02_physics_regression.gd EXIT_CODE=0 — M02_PROBE_RESULT=PASS
tests/m03_economy_regression.gd EXIT_CODE=0 — M03_PROBE_RESULT=PASS
tests/m04_asset_import_probe.gd EXIT_CODE=0 — M04_GODOT_RESULT=PASS
tests/m05_sprite_integration_probe.gd EXIT_CODE=0 — M05_PROBE_RESULT=PASS
tests/m06_r06_full_tabletop_probe.gd EXIT_CODE=0 — M06_R07_PROBE_RESULT=PASS
tests/m07_hud_composition_probe.gd EXIT_CODE=0 — M07_PROBE_RESULT=PASS
tests/m07_r06_owner_layout_probe.gd EXIT_CODE=0 — M07_R06_PROBE_RESULT=PASS
tests/r09_no_input_runtime_regression.gd EXIT_CODE=0 — R09_NO_INPUT_REGRESSION_RESULT=PASS
tests/r10_desktop_idle_smoke.gd EXIT_CODE=0 — R10_DESKTOP_IDLE_RESULT=PASS
tests/r10_runtime_physics_closure_probe.gd EXIT_CODE=0 — R10_RUNTIME_PHYSICS_CLOSURE_RESULT=PASS
tests/r10_v05_three_sided_envelope_probe.gd EXIT_CODE=0 — R10_V05_THREE_SIDED_ENVELOPE_RESULT=PASS
tests/r10_v08_exact_edge_contact_probe.gd EXIT_CODE=0 — R10_V08_EXACT_EDGE_CONTACT_RESULT=PASS
ACTIVE_M01_M07_R09_R10_REGRESSION=PASS
```

Focused idle evidence:

```text
R09_NO_INPUT_OBSERVATION_SECONDS=30.5
R09_NO_INPUT_FINAL score=0 held=1 nonheld=0 total=1 merge_observed=false delivery_observed=false target_transition=false
R09_NO_INPUT_REGRESSION_RESULT=PASS
R10_DESKTOP_IDLE_OBSERVATION_SECONDS=10.0
R10_DESKTOP_IDLE_FINAL score=0 held=1 nonheld=0 total=1
R10_DESKTOP_IDLE_RESULT=PASS
```

## Godot, GUI, and hygiene evidence

Godot 4.7.2 was used. Import/startup and check-only results:

```text
godot_console.exe --headless --path . --editor --quit: EDITOR_IMPORT_EXIT_CODE=0
res://scripts/drink.gd CHECK_ONLY_EXIT_CODE=0
res://scripts/game_manager.gd CHECK_ONLY_EXIT_CODE=0
res://scripts/merge_queue.gd CHECK_ONLY_EXIT_CODE=0
res://tests/r10_v08_exact_edge_contact_probe.gd CHECK_ONLY_EXIT_CODE=0
res://tests/r10_v08_gui_edge_capture.gd CHECK_ONLY_EXIT_CODE=0
GIT_DIFF_CHECK_EXIT_CODE=0
```

The headless renderer emitted the existing null-texture/leaked-RID warnings while evidence-capture probes reported their captures unavailable, but those probes completed with exit code `0`. A normal non-headless OpenGL production capture was retained separately:

```text
R10_V08_GUI_CAPTURE label=edge_contacts dimensions=720x1280 error=0 path=res://docs/evidence/r10/v08_gui_edge_contacts_720x1280.png
R10_V08_GUI_CAPTURE_RESULT=PASS
R10_V08_GUI_CAPTURE_EXIT_CODE=0
```

The normal-display capture is builder evidence for owner verification. Codex did not assign owner visual acceptance or an audit verdict.

## Final publication and equality

- Implementation commit `0c6f66c4380fc41fb9163cf806dd2daff62b368f` was pushed to `origin/main` before this log commit.
- This V08 log is committed and pushed separately after implementation.
- Final post-log equality was checked with `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main`; all three values matched.
- `git diff --name-only -- TASKS.md` returned no output.
- Final worktree retains only the pre-existing owner-dirty files listed in the synchronization section; no V08 file is left unstaged.
- Final handoff: `AWAITING_AUDIT`.
