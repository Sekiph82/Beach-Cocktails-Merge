# BCM-R10 V09 — Codex Execution Log

## Scope

- Work item: BCM-R10 V09 runtime visual-contact-hull recovery.
- Authoritative execution prompt: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V09.md`.
- Locked criteria: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V09.md`.
- Branch: `main`.
- Godot: Godot Engine v4.7.2.stable.official.
- Final handoff status: `AWAITING_AUDIT`.

## Sync-first preflight

The checkout was reconciled with `origin/main` using fetch plus fast-forward only. No reset, force-push, rebase, checkout overwrite, or stash was used.

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`
- Start HEAD after fast-forward reconciliation: `dfc72929e89077fe818ef8fdb5d32d0c0f5f34e9`
- Preflight divergence before fast-forward: `HEAD...origin/main = 0 5`
- Preflight branch: `main`
- Preflight remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`
- Owner-dirty files observed and preserved without staging or editing:
  - `project.godot`
  - `docs/evidence/m06_r07/canonical_720x1280.png`
  - `docs/evidence/m06_r07/canonical_720x1280_runtime_overlay.png`
  - `docs/evidence/m06_r07/shorter_wider_800x1280.png`
  - `docs/evidence/m06_r07/shorter_wider_800x1280_runtime_overlay.png`
  - `docs/evidence/m06_r07/taller_720x1440.png`
  - `docs/evidence/m06_r07/taller_720x1440_runtime_overlay.png`

`TASKS.md` was read but not edited. Canonical PNG assets were not modified. No M08+ work was started.

## Implementation

Implementation commit: `3bf550cb96a73ba9d1918757c4cba1932b07ff1b`.

Changed implementation/evidence files:

- `scripts/drink.gd`
  - Replaced the retired scalar table-edge clearance array with explicit L01-L12 visual contact hulls.
  - Each hull is authored in canonical texture source pixels from alpha-thresholded visible glass/container body geometry; garnish, straw, fruit, flowers, leaves, umbrellas, and transparent margins are excluded.
  - The active Sprite2D transform is applied at runtime to produce the local hull used by physics.
  - Existing CircleShape2D gameplay collider radii remain unchanged.
  - `_integrate_forces` uses the shared visual-hull projection solver.
- `scripts/game_manager.gd`
  - Exposes six left rail segments, six right rail segments, and one rear segment using the frozen V05 rail coordinates.
  - Builds inward-facing segment normals from an interior point.
  - Adds a three-pass half-plane visual-hull projection that corrects only actual penetration and removes only outward normal velocity while retaining tangent velocity.
  - Table walls are diagnostic/non-authoritative: layer 2 and mask 2. Drinks remain on layer 1 and mask 1.
  - Rear rail remains at `rear_table_y`; drink centers are not forced to a common rear Y.
- `scripts/merge_queue.gd`
  - Projects merge results through the same visual-hull solver, preserving merge Y and inherited momentum except for genuine boundary penetration/outward normal motion.
- `scripts/shot_controller.gd`
  - Uses the shared hull projection for held-drink movement.
- `docs/evidence/r10/v09_visual_contact_hulls.json`
  - Retains per-level hull point data, alpha threshold, dimensions, source hashes, and M05 body bounds for L01-L12.
- `tests/r10_v09_visual_hull_containment_probe.gd`
  - Focused V09 regression for frozen V05 rails, all 12 hulls, unchanged circle radii, rail normals, wall layers, scalar-model retirement, asymmetric side support, sloped side contact, rear hull-to-line contact, velocity projection, corner constraints, left/right merge projection, and center no-op merge.
- `tests/r10_v09_hull_overlay.gd`
  - Diagnostic overlay for accepted rails, inward normals, transformed visual hull, center, and circle collider comparison.
- `tests/r10_v09_gui_hull_capture.gd`
  - Normal display-mode 720x1280 capture using representative L01/L06/L12 contacts.

## Hull evidence

- Hull dataset: `docs/evidence/r10/v09_visual_contact_hulls.json`.
- Source alpha threshold: `32`.
- Hull count: 12, one for each L01-L12.
- Hull point count: 6-12 points per level, with all levels verified to have at least four points.
- Runtime transform: source-pixel hull points are centered by canonical texture dimensions and transformed by the active cocktail Sprite2D position/scale and visual-root scale.
- Rail segments: 6 left + 6 right + 1 rear = 13 finite segments.
- Normals: all verified as finite unit inward normals.
- Representative asymmetric support: `L01 left=393.130 right=126.170 delta=266.961`.
- Representative side contact:
  - `L01 left target_distance=0.234 center=(69.238,522.673)`.
  - `L06 right target_distance=0.525 center=(626.762,534.967)`.
- Rear contact: `L01 center_y=417.655 rear_table_y=398.333 rear_distance=0.502`; this is hull-to-line contact, not common center-Y stopping.
- Velocity projection: `normal_after=0.000 tangent_after=86.483`.
- Corner projection contacts: `["LeftRail_0", "RearRail"]`, corrected origin `(205.056,492.636)`.
- Center merge control: raw `(360.000,693.333)` equals corrected `(360.000,693.333)`.

## Focused V09 probe

Command:

```text
godot_console.exe --headless --path . --script res://tests/r10_v09_visual_hull_containment_probe.gd
```

Result: `R10_V09_VISUAL_HULL_CONTAINMENT_RESULT=PASS`, exit code `0`.

The probe reported PASS for unchanged V05 left/right source rail coordinates, all 12 hulls and radii, all 13 rail segments and normals, non-drink wall layers, drink-only collision masks, scalar V08 model retirement, asymmetric side support, left/right/rear contacts, outward-normal removal with tangent preservation, corner constraints, left/right merge projection, and center no-op merge.

## Normal GUI evidence

Command:

```text
godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/r10_v09_gui_hull_capture.gd
```

Exact result:

```text
R10_V09_GUI_CAPTURE label=hull_rails_normals_circle_comparison dimensions=720x1280 error=0 path=res://docs/evidence/r10/v09_gui_hull_contacts_720x1280.png
R10_V09_GUI_CAPTURE_RESULT=PASS
R10_V09_GUI_CAPTURE_EXIT_CODE=0
```

Retained capture: `docs/evidence/r10/v09_gui_hull_contacts_720x1280.png` (720x1280, 1,758,330 bytes at capture time). This is builder evidence; independent owner visual acceptance was not performed by Codex.

## Active regression evidence

The active non-superseded suite was run serially with Godot 4.7.2. Exact result markers:

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
R10_V09_VISUAL_HULL_CONTAINMENT_RESULT=PASS
TEST_r10_v09_visual_hull_containment_probe.gd_EXIT_CODE=0
```

The no-input runtime specifically remained at `score=0`, `held=1`, `nonheld=0`, `total=1`, `merge_observed=false`, `delivery_observed=false`, and `target_transition=false` for 30.5 seconds. The desktop idle smoke remained at score zero with exactly one held preview and zero non-held drinks for 10.0 seconds.

M05 and M07 headless probes emitted known dummy-renderer `save_png`/null-texture diagnostics while their contract checks and required result markers remained PASS with exit code 0. The normal OpenGL GUI capture above is the retained runtime-render evidence.

## Superseded historical scalar-edge probes

The following historical probes were not treated as active V09 acceptance tests because they assert the retired scalar V06-V08 boundary model or removed scalar helper methods:

- `tests/m06_environment_geometry_probe.gd`
- `tests/m06_r06_full_tabletop_probe.gd`
- `tests/r10_v05_three_sided_envelope_probe.gd`
- `tests/r10_v06_edge_footprint_probe.gd`
- `tests/r10_v07_independent_edge_dataset_probe.gd`
- `tests/r10_v08_exact_edge_contact_probe.gd`
- `tests/r10_v07_gui_edge_capture.gd`
- `tests/r10_v08_gui_edge_capture.gd`

The M06 environment probe was invoked during this run and stopped at parse time because it still calls the removed `get_horizontal_bounds_at_y`; exact marker: `TEST_m06_environment_geometry_probe.gd_EXIT_CODE=1`. Its scalar radius/width assertions are incompatible with V09. The V09 replacement probe covers the current frozen rails, visual hull contacts, rear hull-to-line behavior, wall collision masks, velocity projection, corner handling, merge projection, and center no-op behavior. Historical files were not rewritten.

## Godot parse/import and hygiene

Commands and exact results:

```text
godot_console.exe --headless --path . --editor --quit
EDITOR_IMPORT_EXIT_CODE=0

res://scripts/drink.gd CHECK_ONLY_EXIT_CODE=0
res://scripts/game_manager.gd CHECK_ONLY_EXIT_CODE=0
res://scripts/merge_queue.gd CHECK_ONLY_EXIT_CODE=0
res://scripts/shot_controller.gd CHECK_ONLY_EXIT_CODE=0
res://tests/r10_v09_visual_hull_containment_probe.gd CHECK_ONLY_EXIT_CODE=0
res://tests/r10_v09_hull_overlay.gd CHECK_ONLY_EXIT_CODE=0
res://tests/r10_v09_gui_hull_capture.gd CHECK_ONLY_EXIT_CODE=0

GIT_DIFF_CHECK_EXIT_CODE=0
CACHED_DIFF_CHECK_EXIT_CODE=0
```

The editor emitted the known warning that `res://original_reference/project.godot` is ignored as a nested project. No parse/import failure occurred.

## Scope and limitations

- Only the V09 implementation, focused probe, hull dataset, overlay, and normal GUI capture were committed by this execution.
- Owner-dirty `project.godot` and prior M06 evidence were preserved and excluded from the commit.
- Canonical PNGs were not modified.
- No guide line was added.
- No M08+ work was started.
- Codex performed builder checks only; independent ChatGPT audit and owner visual acceptance remain pending.

## Publication and final equality

Implementation commit pushed to `main`:

```text
3bf550cb96a73ba9d1918757c4cba1932b07ff1b
```

This log is committed separately after the implementation commit. The final log-commit SHA and equality proof are recorded after the log commit is pushed.

`TASKS.md` was not modified.

Status: `AWAITING_AUDIT`.
