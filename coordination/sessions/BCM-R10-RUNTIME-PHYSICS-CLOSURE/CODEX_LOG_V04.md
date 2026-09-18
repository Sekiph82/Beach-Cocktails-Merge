# BCM-R10-RUNTIME-PHYSICS-CLOSURE — V06 Codex Log V04

Status: `IMPLEMENTATION_COMPLETE / AWAITING_AUDIT`

## Work item and authority

- Work item: R10 V06 2D edge-contact experiment.
- Execution prompt: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V06.md`.
- Audit criteria: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V06.md`.
- Start HEAD: `3a9ec604eab160391b91a2ee661b853dce224648`.
- Implementation HEAD: `225014e039f4ad5136db3bdf91b3feddff329bf1`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

## Mandatory preflight and preservation

The synchronized checkout was verified at `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.

- `git fetch origin main` completed.
- Initial divergence was `HEAD...origin/main = 0 5`; `git merge --ff-only origin/main` advanced the checkout to `3a9ec604eab160391b91a2ee661b853dce224648`.
- Existing owner-dirty paths were not reset, stashed, overwritten, or staged:
  - `project.godot`
  - `docs/evidence/m06_r07/canonical_720x1280.png`
  - `docs/evidence/m06_r07/canonical_720x1280_runtime_overlay.png`
  - `docs/evidence/m06_r07/shorter_wider_800x1280.png`
  - `docs/evidence/m06_r07/shorter_wider_800x1280_runtime_overlay.png`
  - `docs/evidence/m06_r07/taller_720x1440.png`
  - `docs/evidence/m06_r07/taller_720x1440_runtime_overlay.png`
- `TASKS.md` was not edited.
- Canonical PNGs under `assets/` were not edited.
- No ChatGPT-owned prompt, criteria, policy, or historical log was edited.
- No `guide_line` or M08+ work was introduced.

## Implementation summary

The V05 three-sided envelope is frozen. The production rail source data remains:

- rear source Y `478.0`;
- left points `[(199,478),(149,587),(124,644),(85,734),(60,800),(20,1000),(8,1186)]`;
- right points `[(833,478),(880,587),(905,644),(942,734),(964,800),(1002,1000),(1016,1186)]`.

V06 adds a separate 2D table-edge contact half-width derived from the measured visible glass/container body. The runtime uses:

`edge_contact_half_width = visible_body_width_px * visual_scale_for_level(level) * 0.5 * visual_body_depth_scale_for_y(y)`

The existing 2D presentation scale is used; no 3D depth dimension is introduced. Garnish, straw, fruit, flowers, leaves, umbrellas, and transparent margins are excluded. Drink-to-drink collider radii remain unchanged. Rear contact remains exact: `rear_target_y == rear_table_y` with no radius or body extent added.

The V05 post-merge X correction remains in place and now uses the new edge-contact bounds. It is X-only, preserves merge Y and inherited momentum, and is a no-op for an already-valid center merge. Side-wall collision shapes are shifted outward by the maximum collider-versus-visible-body clearance needed across L01-L12, while the logical per-level side limits continue to use the exact level-specific visible-body footprint. This prevents full-radius physics from solver-ejecting a drink that is valid under the V06 side-contact model.

`Drink.create()` continues to use `RigidBody2D.CCD_MODE_CAST_SHAPE` for moving drinks.

## Files changed in the implementation commit

- `scripts/drink.gd`
- `scripts/game_manager.gd`
- `scripts/merge_queue.gd`
- `tests/m06_r06_full_tabletop_probe.gd`
- `tests/r10_v05_three_sided_envelope_probe.gd`
- `tests/r10_v06_edge_footprint_probe.gd`
- `docs/evidence/r10/v06_edge_contact_measurements.json`

## Focused V06 evidence

`tests/r10_v06_edge_footprint_probe.gd` completed with exit code `0` and:

`R10_V06_EDGE_FOOTPRINT_RESULT=PASS`

The probe covered all L01-L12 and printed the following representative measurements at sample Y `620.0`:

| Level | Collider radius | Edge half-width | CCD |
| --- | ---: | ---: | --- |
| L01 | 20.000 | 19.587 | CAST_SHAPE |
| L06 | 42.000 | 41.134 | CAST_SHAPE |
| L12 | 90.000 | 88.144 | CAST_SHAPE |

The full level records are retained in `docs/evidence/r10/v06_edge_contact_measurements.json`. The probe also verified:

- all collider radii stayed equal to the existing M05 dataset;
- all levels used the exact common rear target;
- V05 rear/left/right coordinates remained unchanged;
- representative L01/L06/L12 left and right side contacts used the smaller edge footprint;
- representative moving edge contacts stayed inside their footprint limits;
- left-wall merge raw X `21.098`, footprint `22.526`, valid range `(24.036,696.974)`, corrected X `24.036`;
- right-wall merge raw X `699.912`, footprint `22.526`, valid range `(24.036,696.974)`, corrected X `696.974`;
- center merge raw X and corrected X were both `360.505`, delta `-0.000`;
- representative CCD value was `2`, Godot `CAST_SHAPE`.

`tests/r10_v05_three_sided_envelope_probe.gd` completed with exit code `0` and `R10_V05_THREE_SIDED_ENVELOPE_RESULT=PASS`. The updated wall-merge checks remained tangent using the V06 edge-contact limits.

`tests/r10_runtime_physics_closure_probe.gd` completed with exit code `0` and `R10_RUNTIME_PHYSICS_CLOSURE_RESULT=PASS`. The representative rear-right L12 case reached `(469.1982,398.3333)` with `rear_table_y=398.3333` and target error `0.0000` after the physical side-wall clearance correction.

## Regression evidence

The final active suite was run on implementation commit `225014e`:

| Probe | Result | Exit |
| --- | --- | ---: |
| `m01_contract_probe.gd` | `M01_PROBE_RESULT=PASS` | 0 |
| `m02_physics_regression.gd` | `M02_PROBE_RESULT=PASS` | 0 |
| `m03_economy_regression.gd` | `M03_PROBE_RESULT=PASS` | 0 |
| `m04_asset_import_probe.gd` | `M04_GODOT_RESULT=PASS` | 0 |
| `m05_sprite_integration_probe.gd` | `M05_PROBE_RESULT=PASS` | 0 |
| `m06_r06_full_tabletop_probe.gd` | `M06_R07_PROBE_RESULT=PASS` | 0 |
| `m07_hud_composition_probe.gd` | `M07_PROBE_RESULT=PASS` | 0 |
| `m07_r06_owner_layout_probe.gd` | `M07_R06_PROBE_RESULT=PASS` | 0 |
| `r09_no_input_runtime_regression.gd` | `R09_NO_INPUT_REGRESSION_RESULT=PASS` | 0 |
| `r10_desktop_idle_smoke.gd` | `R10_DESKTOP_IDLE_RESULT=PASS` | 0 |
| `r10_runtime_physics_closure_probe.gd` | `R10_RUNTIME_PHYSICS_CLOSURE_RESULT=PASS` | 0 |
| `r10_v05_three_sided_envelope_probe.gd` | `R10_V05_THREE_SIDED_ENVELOPE_RESULT=PASS` | 0 |
| `r10_v06_edge_footprint_probe.gd` | `R10_V06_EDGE_FOOTPRINT_RESULT=PASS` | 0 |

No-input runtime evidence was `30.5` seconds with `score=0`, `held=1`, `nonheld=0`, `total=1`, `merge_observed=false`, and `delivery_observed=false`. Desktop idle evidence was `10.0` seconds with `score=0`, `held=1`, `nonheld=0`, and `total=1`.

The older `tests/r09_rear_boundary_probe.gd` was also run as a historical focused check and returned exit code `1`. It still expects the superseded independent background-pixel source Y `457.0`, while the locked V06 criteria explicitly freeze the owner-approved V05 playable rear source Y `478.0` and require `rear_target_y == rear_table_y`. It was not modified or used as a reason to move the accepted V05 envelope.

The older `tests/m06_r08_rear_tangency_probe.gd` has the same superseded source-Y assumption and was not part of the active V06 suite. It was not modified.

## Godot and hygiene checks

- `godot_console.exe --headless --path . --editor --quit`: exit `0`.
- Godot version: `4.7.2.stable.official.ed1daf0bf`.
- Godot emitted only the existing warning that `res://original_reference` contains another `project.godot` and is ignored.
- `--check-only --script` exit `0` for `drink.gd`, `game_manager.gd`, `merge_queue.gd`, `m06_r06_full_tabletop_probe.gd`, `r10_v05_three_sided_envelope_probe.gd`, and `r10_v06_edge_footprint_probe.gd`.
- `git diff --check`: exit `0` before implementation commit and again before log creation.
- Headless dummy rendering cannot provide PNG image pixels for the M06/M07/R10 capture helpers; those helpers report `renderer_has_no_image`/`headless_renderer_no_image` and do not treat that as a runtime visual capture. Normal GUI/F5 visual owner verification was not performed in this session.

## Publication and final state

Implementation commit:

`225014e039f4ad5136db3bdf91b3feddff329bf1`

The implementation commit was pushed to `origin/main` before this log was created. This log is a separate immutable evidence commit. `TASKS.md` remains byte-for-byte untouched. Builder evidence is not an independent acceptance audit.

Final handoff: `AWAITING_AUDIT`.
