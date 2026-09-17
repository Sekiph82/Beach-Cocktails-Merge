# BCM-M05-R02 Codex Execution Log V01

## Scope and governance

- Work item: BCM-M05-R02.
- Master prompt: coordination/sessions/BCM-M04-M07-R03/CHATGPT_EXECUTION_PROMPT_V01.md.
- Start HEAD after M04-R02: ae59e48b57e71109512427a15c14a5cef5337762.
- Branch: main.
- Remote: https://github.com/Sekiph82/Beach-Cocktails-Merge.git.
- Builder evidence only; no self-audit or AUDITED_PASS.
- TASKS.md and ChatGPT-owned files were not edited.
- Canonical cocktail PNG bytes were not modified.
- M06/M07 production implementation was not changed in this bounded phase.

## Sync preflight

git status --short --branch
## main...origin/main

git fetch origin main
Already up to date.

git rev-list --left-right --count HEAD...origin/main
0 0

git rev-parse HEAD
ae59e48b57e71109512427a15c14a5cef5337762

## Historical radius correction

The immutable prior M05 log was not rewritten. The historically corrected pre-M05 JSON radius series remains:

14,21,29,38,48,59,71,84,98,113,129,146

The current production compressed collider radii remain the M05 accepted values 20,23,27,31,36,42,49,56,64,72,80,90. The new independent dataset records these as manually reviewed target envelopes with explicit tolerances; it does not import or generate them from Drink constants.

## Independent dataset and implementation

Added tools/m05_independent_body_dataset.py and generated docs/evidence/m05/independent_body_measurements.json.

The generator contains an independently hand-recorded body dataset outside scripts/drink.gd. For each L01-L12 it records:

- source path, source SHA-256 and dimensions;
- selected visible glass/container body bbox;
- body width, height and visible-body center offset;
- independent target collider radius and diameter;
- radius, body-diameter and center tolerances;
- manual measurement method and scope.

The selected body regions exclude straw, fruit, leaves, flowers, shadows and garnish extremes. Shape review is retained for tumbler, martini, highball, goblet, coconut and pineapple. Contact-pair review records low L01/L02, mid L06/L07 and high L11/L12.

Strengthened tests/m05_sprite_integration_probe.gd:

- loads independent_body_measurements.json rather than importing Drink constants;
- compares observed live Sprite2D body diameter projection, center error and live CollisionShape2D radius against independent target envelopes;
- retains canonical mapping, invalid-level/L13, merge, rapid-launch, restart and Game Over checks;
- calculates and records visible-body gap/overlap for independent low/mid/high pairs using actual live Drink Sprite2D scales and independent body widths;
- retains actual runtime clean, collider/pivot overlay, touching-pair and merge-continuity captures.

The old M05 evidence generator and immutable historical log were not rewritten. Production M05 mapping and scale/collider values were not arbitrarily enlarged in this phase because the independent body projection already matches the manually selected diameter targets exactly.

## Independent measurements and runtime observations

For each level, observed body diameter = independent body width x actual runtime Sprite2D scale. The focused probe output was:

M05_PRESENTATION_TABLE:
L1 observed_body_diameter=40.00 target_diameter=40.00 center_error=0.00 observed_radius=20.0 target_radius=20.0
L2 observed_body_diameter=46.00 target_diameter=46.00 center_error=0.00 observed_radius=23.0 target_radius=23.0
L3 observed_body_diameter=54.00 target_diameter=54.00 center_error=0.00 observed_radius=27.0 target_radius=27.0
L4 observed_body_diameter=62.00 target_diameter=62.00 center_error=0.00 observed_radius=31.0 target_radius=31.0
L5 observed_body_diameter=72.00 target_diameter=72.00 center_error=0.00 observed_radius=36.0 target_radius=36.0
L6 observed_body_diameter=84.00 target_diameter=84.00 center_error=0.00 observed_radius=42.0 target_radius=42.0
L7 observed_body_diameter=98.00 target_diameter=98.00 center_error=0.00 observed_radius=49.0 target_radius=49.0
L8 observed_body_diameter=112.00 target_diameter=112.00 center_error=0.00 observed_radius=56.0 target_radius=56.0
L9 observed_body_diameter=128.00 target_diameter=128.00 center_error=0.00 observed_radius=64.0 target_radius=64.0
L10 observed_body_diameter=144.00 target_diameter=144.00 center_error=0.00 observed_radius=72.0 target_radius=72.0
L11 observed_body_diameter=160.00 target_diameter=160.00 center_error=0.00 observed_radius=80.0 target_radius=80.0
L12 observed_body_diameter=180.00 target_diameter=180.00 center_error=0.00 observed_radius=90.0 target_radius=90.0

M05_INDEPENDENT_CONTACT_PAIR label=low levels=L01/L02 center_distance=43.000 visible_gap=0.000 visible_overlap=0.000 tolerance=5.000
M05_INDEPENDENT_CONTACT_PAIR label=mid levels=L06/L07 center_distance=91.000 visible_gap=-0.000 visible_overlap=0.000 tolerance=5.000
M05_INDEPENDENT_CONTACT_PAIR label=high levels=L11/L12 center_distance=170.000 visible_gap=0.000 visible_overlap=0.000 tolerance=5.000

These are independent-style evidence comparisons against the recorded dataset, not production-helper self-comparisons.

## Focused M05 output

python tools/m05_independent_body_dataset.py
M05_INDEPENDENT_DATASET levels=12 output=docs/evidence/m05/independent_body_measurements.json
M05_INDEPENDENT_METHOD=MANUAL_INDEPENDENT_GLASS_BODY_MEASUREMENT
M05_INDEPENDENT_RADII=20.0,23.0,27.0,31.0,36.0,42.0,49.0,56.0,64.0,72.0,80.0,90.0
M05_INDEPENDENT_RESULT=PASS
M05_DATASET_PROCESS_EXIT_CODE=0

godot_console --headless --path . --script res://tests/m05_sprite_integration_probe.gd --rendering-method gl_compatibility --display-driver windows
M05_PROBE PASS: main scene loads as PackedScene
M05_PROBE PASS: runtime world and shot controller are ready
M05_PROBE PASS: independent body/collider dataset loads outside production scripts
M05_PROBE PASS: invalid levels fail safely without an L13 texture
M05_PROBE PASS: all L01-L12 table drinks use the canonical Sprite2D mapping
M05_PROBE PASS: independent body diameter/center/radius envelopes match runtime observations
M05_PROBE PASS: all L01-L12 visual/body scales stay bounded for the portrait playfield
M05_PROBE PASS: runtime collider/pivot/contact evidence captures saved
M05_PROBE PASS: independent visible-body contact gap/overlap is bounded for low/mid/high pairs
M05_PROBE PASS: held launch drink uses a canonical Sprite2D
M05_PROBE PASS: merge creates the correct next-level sprite atomically
M05_PROBE PASS: merge result preserves forward/lateral momentum without visual teleport
M05_PROBE PASS: L12 has no L13 texture/path and stays capped
M05_PROBE PASS: rapid launches preserve coherent current/next Sprite2D visuals
M05_PROBE PASS: restart leaves one playable held Sprite2D and no orphan visuals
M05_PROBE PASS: Game Over preserves visual/body ownership without orphan nodes
M05_PROBE PASS: restart after Game Over restores one canonical held visual
M05_PROBE_RESULT=PASS
M05_PROBE_PROCESS_EXIT_CODE=0

## Regression and Godot results

M01:
godot_console --headless --path . --script res://tests/m01_contract_probe.gd
M01_PROBE_RESULT=PASS
M01_EXIT_CODE=0

M02:
godot_console --headless --path . --script res://tests/m02_physics_regression.gd
M02_PROBE PASS: 700 px/s direct-hit has contact without tunneling
M02_PROBE PASS: 700 px/s glancing-hit has contact without tunneling
M02_PROBE PASS: moving multi-body chain merge produces stable L3
M02_PROBE PASS: six rapid launches preserve current/next integrity
M02_PROBE PASS: restart during multi-body motion produces clean playable scene
M02_PROBE PASS: Game Over with multiple moving drinks freezes all and stops shooting
M02_PROBE_RESULT=PASS
M02_EXIT_CODE=0

M03:
godot_console --headless --path . --script res://tests/m03_economy_regression.gd
M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
M03_PROBE_RESULT=PASS
M03_EXIT_CODE=0

M04-R02:
godot_console --headless --path . --script res://tests/m04_asset_import_probe.gd
M04_GODOT_ASSET_COUNT expected=25 observed=25 cocktails=12 environment=1 ui=8 effects=4
M04_GODOT_PROBE PASS: effects PNG directory exact set has four approved assets
M04_GODOT_RESULT=PASS
M04_EXIT_CODE=0

Godot:
godot_console --version
4.7.2.stable.official.ed1daf0bf
godot_console --headless --quiet --path . --editor --import --quit
M05_IMPORT_PROCESS_EXIT_CODE=0
godot_console --headless --quiet --path . --quit-after 3
M05_STARTUP_PROCESS_EXIT_CODE=0

git diff --check
M05_DIFF_CHECK_EXIT_CODE=0

## Retained evidence

The existing actual-runtime evidence was regenerated:

- docs/evidence/m05/all_levels_clean.png;
- docs/evidence/m05/all_levels_collider_overlay.png;
- docs/evidence/m05/touching_pairs.png;
- docs/evidence/m05/merge_continuity.png;
- docs/evidence/m05/independent_body_measurements.json;
- this log.

The overlay is generated from actual live Drink nodes, live Sprite2D scale/offset and live collider shapes. The independent dataset is used for non-circular body/center/radius comparisons. Manual visual fit, garnish exclusion, shape diversity and apparent contact remain subject to independent ChatGPT pixel inspection.

Canonical PNG source diff:
git diff --quiet -- assets/cocktails assets/environment assets/ui assets/effects
M05_SOURCE_ASSET_DIFF_EXIT_CODE=0

## Changed files

scripts/drink.gd was not changed in M05-R02; the accepted M05 production mapping remains intact. Changed files are:

tests/m05_sprite_integration_probe.gd
tools/m05_independent_body_dataset.py
docs/evidence/m05/independent_body_measurements.json
docs/evidence/m05/all_levels_clean.png
docs/evidence/m05/all_levels_collider_overlay.png
docs/evidence/m05/touching_pairs.png
docs/evidence/m05/merge_continuity.png
coordination/sessions/BCM-M05-R02/CODEX_LOG_V01.md

No source PNG, TASKS.md, ChatGPT-owned file, M06/M07 production file, or historical log was modified.

## Boundary

M05-R02 builder work is complete for independent audit. M06-R03 begins only after this bounded commit is pushed; this log does not assign any audit verdict.
