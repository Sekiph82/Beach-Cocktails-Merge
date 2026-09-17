# BCM-R09-RUNTIME-RECOVERY Codex Execution Log V01

## Status

IMPLEMENTATION_COMPLETE / AWAITING_INDEPENDENT_AUDIT

This is builder evidence only. No acceptance verdict or AUDITED_PASS is assigned.

## Authority and scope

- Work item: BCM-R09-RUNTIME-RECOVERY
- Prompt: coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_EXECUTION_PROMPT_V01.md
- Locked criteria: coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_AUDIT_CRITERIA_V01.md
- Repository: https://github.com/Sekiph82/Beach-Cocktails-Merge.git
- Branch: main
- Workspace: C:\Users\sekip\Desktop\Beach Cocktails - Merge
- Godot: 4.7.2.stable.official

## Sync-first preflight

The required preflight was run at session start:

~~~
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
From https://github.com/Sekiph82/Beach-Cocktails-Merge
   acfa2c5..c8f3cd0  main -> origin/main

git rev-list --left-right --count HEAD...origin/main
0 2

git merge --ff-only origin/main
Updating acfa2c5..c8f3cd0
Fast-forward
~~~

The synchronized implementation start was c8f3cd0. The six pre-existing dirty M06-R07 capture files were preserved and were never staged. The owner-created dirty project.godot was also preserved and was never staged.

## Exact project.godot comparison and root cause

The exact working-tree difference against origin/main:project.godot was:

~~~
diff --git a/project.godot b/project.godot
index 2caf030..efbc73f 100644
--- a/project.godot
+++ b/project.godot
@@ -1,5 +1,10 @@
-; Cocktail Merge - Godot 4.7.x
-; Playable prototype build generated from the supplied project files.
+; Engine configuration file.
+; It's best edited using the editor UI and not directly,
+; since the parameters that go here are not all obvious.
+;
+; Format:
+;   [section] ; section goes between []
+;   param=value ; assign values to parameters
@@ -16,7 +21,6 @@ window/size/viewport_height=1280
 window/size/window_width_override=405
 window/size/window_height_override=720
 window/stretch/mode="viewport"
-window/stretch/aspect="keep"
 window/handheld/orientation=1
~~~

The local file still has the production scene:

~~~
run/main_scene="res://scenes/main.tscn"
~~~

The observed difference is a Godot-editor-style header rewrite plus removal of the aspect-keep setting. It does not name or load a test/probe. No [autoload] section exists, no plugin startup path exists, and no test path exists in the file. scenes/main.tscn contains only the normal GameManager root with scripts/game_manager.gd; .godot/editor/project_metadata.cfg selects res://scenes/main.tscn and has no test script startup entry.

Therefore the dirty project.godot was not the source of the synthetic-drink run configuration and was not changed or canonicalized by R09.

## Uncommanded runtime generation/scoring root cause

tests/m06_r08_rear_tangency_probe.gd is an intentionally isolated SceneTree probe. It creates a production main scene, then explicitly calls:

~~~
manager.spawn_drink(level, Vector2(...), false)
~~~

for L01-L12 and for representative rear contacts. When that standalone probe is run through Godot --script or an editor script-run action, those are legitimate synthetic test drinks. Production _choose_next_target() legitimately checks existing stored drinks; a synthetic L06 can therefore satisfy the legitimate initial L6 To-Go objective and award its reward. Repeating the probe cases can look like an endless gameplay generation/reward loop.

The probe is not referenced by project.godot, scenes/main.tscn, an autoload, a plugin or the normal editor main-scene selection. A normal configured main-scene run does not execute it. The intended stocked-target behavior was preserved.

R09 adds a no-input regression which loads only res://scenes/main.tscn, never loads a probe, never calls GameManager.spawn_drink(), and checks the normal project configuration before observing runtime state. A configured main-scene headless smoke also produced no gameplay/merge output and exited 0.

## R09 no-input runtime regression

Command:

~~~
godot_console.exe --headless --path . --display-driver headless --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/r09_no_input_runtime_regression.gd
~~~

Exact final output:

~~~
R09_NO_INPUT PASS: normal project main scene is production scene
R09_NO_INPUT PASS: normal project has no autoload section
R09_NO_INPUT PASS: normal project has no test script startup path
R09_NO_INPUT PASS: production main scene loads
R09_NO_INPUT_ROOT_CHILDREN=Main
R09_NO_INPUT PASS: initial score is zero
R09_NO_INPUT PASS: initial state has exactly one held preview
R09_NO_INPUT PASS: initial state has zero non-held drinks
R09_NO_INPUT PASS: initial merge queue is empty
R09_NO_INPUT PASS: 30-second no-input score remains zero
R09_NO_INPUT PASS: 30-second no-input has exactly one held preview
R09_NO_INPUT PASS: 30-second no-input has zero non-held gameplay drinks
R09_NO_INPUT PASS: 30-second no-input has one total drink only
R09_NO_INPUT PASS: 30-second no-input has no merge
R09_NO_INPUT PASS: 30-second no-input has no To-Go delivery
R09_NO_INPUT_OBSERVATION_SECONDS=30.5
R09_NO_INPUT_FINAL score=0 held=1 nonheld=0 total=1 merge_observed=false delivery_observed=false target_transition=false
R09_NO_INPUT_REGRESSION_RESULT=PASS
FINAL_R09_NO_INPUT_EXIT_CODE=0
~~~

A separate configured normal main-scene smoke used --path . with no --script and exited:

~~~
NORMAL_CONFIGURED_MAIN_30S_EXIT_CODE=0
~~~

The no-input probe is deliberately run with the headless display driver so the observation cannot consume desktop/window input. An exploratory Windows-display headless run received environment-level input-like events and generated non-held drinks; that harness result was not used as no-input acceptance evidence. The actual configured project scene and the deterministic headless no-input run both remain clean.

## Independent actual rear-table measurement

The R08 value source y=472 was not the visible rear edge. It was the first point of the old side polyline and lies inside the tabletop by approximately 15 source pixels. R09 independently read the unchanged owner-approved background pixels before using production geometry.

Asset:

~~~
assets/environment/game_board_background.png
sha256=BF9EF25BFE27B78805C487410601A9FEF16B36F83C97B9BC6F3BF70670DFD17A
dimensions=1024x1536
~~~

Read-only central-span scan (x=288..800, step 16) found:

~~~
row_456_average_rgb=[178.5,155.0,106.7] woodish_fraction=0.21
row_457_average_rgb=[217.9,158.4,97.3] woodish_fraction=0.97
row_458_average_rgb=[215.0,137.9,72.0] woodish_fraction=1.00
actual_visible_rear_table_source_y=457.0
~~~

The retained measurement record is:

~~~
docs/evidence/r09/independent_rear_table_measurement.json
~~~

This measurement explicitly records that GameManager.rear_table_y, TABLE_LEFT_EDGE_SOURCE_POINTS and GameManager.get_rear_target_center_y were not used to determine the expected rear Y.

Production now uses the one common measured rear boundary:

~~~
ACTUAL_REAR_TABLE_SOURCE_Y=457.0
table_top_y = source_to_viewport(Vector2(0.0, ACTUAL_REAR_TABLE_SOURCE_Y), size).y
rear_table_y = table_top_y
rear_target_center_y = rear_table_y + body_half_extent_y
visible_body_top_y = rear_target_center_y - body_half_extent_y
~~~

TopRail construction, clamp_position_to_board() and the rear solver now share that boundary. No per-level rear Y target or per-level rear boundary was added. The active circular collider radius remains the body half-extent for the existing M05 footprint; garnish/straw/transparent margins are excluded.

Independent runtime render detection and production values:

~~~
canonical_720x1280 independent_source_y=457.0 expected_runtime_y=380.833 detected_runtime_y=381.000 production_top_y=380.833 production_rear_y=380.833
taller_720x1440 independent_source_y=457.0 expected_runtime_y=428.438 detected_runtime_y=428.000 production_top_y=428.438 production_rear_y=428.438
shorter_wider_800x1280 independent_source_y=457.0 expected_runtime_y=380.833 detected_runtime_y=381.000 production_top_y=380.833 production_rear_y=380.833
~~~

Representative L01/L06/L12 rear-left, rear-center and rear-right placements used the mandatory size-derived formula. Each body-top error was 0.000 after subtracting the existing TABLE_SOLVER_EPSILON from the contact position. The R09 rear probe result was:

~~~
R09_REAR_BOUNDARY_REGRESSION_RESULT=PASS
R09_REAR_PROBE_EXIT_CODE=0
~~~

Retained clean and contact captures:

~~~
docs/evidence/r09/canonical_720x1280.png
docs/evidence/r09/canonical_720x1280_rear_contacts.png
docs/evidence/r09/taller_720x1440.png
docs/evidence/r09/taller_720x1440_rear_contacts.png
docs/evidence/r09/shorter_wider_800x1280.png
docs/evidence/r09/shorter_wider_800x1280_rear_contacts.png
~~~

The contact captures contain actual production cocktail sprites at the independently measured rear boundary; the separate clean captures show the production table and HUD without test annotations.

## Implementation files and commit

Implementation commit:

~~~
736fd31 BCM-R09 recover runtime and rear tabletop boundary
~~~

Files in the implementation commit:

~~~
scripts/game_manager.gd
tests/m06_environment_geometry_probe.gd
tests/m06_r08_rear_tangency_probe.gd
tests/r09_no_input_runtime_regression.gd
tests/r09_rear_boundary_probe.gd
docs/evidence/r09/independent_rear_table_measurement.json
docs/evidence/r09/canonical_720x1280.png
docs/evidence/r09/canonical_720x1280_rear_contacts.png
docs/evidence/r09/taller_720x1440.png
docs/evidence/r09/taller_720x1440_rear_contacts.png
docs/evidence/r09/shorter_wider_800x1280.png
docs/evidence/r09/shorter_wider_800x1280_rear_contacts.png
~~~

The six pre-existing dirty docs/evidence/m06_r07/ files and dirty project.godot were intentionally excluded.

## Full active M01-M07 regression

The suite was run after the R09 implementation with isolated user data. The updated M06 environment probe consumed the independent R09 measurement, and the updated R08 tangency probe consumed the same independent record. Exact final exit summary:

~~~
FINAL_M01_EXIT_CODE=0
FINAL_M02_EXIT_CODE=0
FINAL_M03_EXIT_CODE=0
FINAL_M04_EXIT_CODE=0
FINAL_M05_EXIT_CODE=0
FINAL_M06_ENVIRONMENT_EXIT_CODE=0
FINAL_M06_R05_EXIT_CODE=0
FINAL_M06_R06_EXIT_CODE=0
FINAL_M06_R08_EXIT_CODE=0
FINAL_M07_HUD_COMPOSITION_EXIT_CODE=0
FINAL_M07_R04_EXIT_CODE=0
FINAL_M07_R05_EXIT_CODE=0
FINAL_M07_R06_EXIT_CODE=0
FINAL_R09_NO_INPUT_EXIT_CODE=0
FINAL_R09_REAR_EXIT_CODE=0
FINAL_ACTIVE_M01_M07_REGRESSION_RESULT=PASS
~~~

Selected final focused markers included M01_PROBE_RESULT=PASS, M02_PROBE_RESULT=PASS, FINAL_M03_EXIT_CODE=0, M04_GODOT_RESULT=PASS, M05_PROBE_RESULT=PASS, M06_PROBE_RESULT=PASS, M06_R05_PROBE_RESULT=PASS, M06_R07_PROBE_RESULT=PASS, M06_R08_PROBE_RESULT=PASS, M07_PROBE_RESULT=PASS, M07_R04_PROBE_RESULT=PASS, M07_R05_PROBE_RESULT=PASS and M07_R06_PROBE_RESULT=PASS.

The owner-approved M03 reward table remained unchanged: L6=1000, L7=1800, L8=3000, L9=5000, L10=8000, L11=12000, L12=18000.

## Godot and hygiene checks

~~~
godot_console.exe --headless --editor --path . --quit
GODOT_IMPORT_STARTUP_EXIT_CODE=0

godot_console.exe --headless --path . --display-driver headless --rendering-method gl_compatibility --rendering-driver opengl3 --check-only --script res://scripts/game_manager.gd
GODOT_GAME_MANAGER_PARSE_EXIT_CODE=0

godot_console.exe --headless --path . --display-driver headless --rendering-method gl_compatibility --rendering-driver opengl3 --check-only --script res://scripts/drink.gd
GODOT_DRINK_PARSE_EXIT_CODE=0

git diff --check
GIT_DIFF_CHECK_EXIT_CODE=0
~~~

Godot emitted only the known warning that res://original_reference/project.godot is ignored because another project.godot exists below that directory.

Preservation checks:

- held drink alignment preserved;
- To-Go placement and BEST/SCORE layout preserved;
- NEXT and baked 2x6 progression preserved;
- launch speed 700 px/s preserved;
- deceleration 180 px/s2 preserved;
- collision/momentum/merge/combo/scoring/To-Go economy/persistence/Game Over/restart/rapid launch preserved;
- canonical PNG bytes unchanged;
- no guide_line added;
- no M08+ work started;
- TASKS.md and all ChatGPT-owned files were not edited.

## Final repository handoff

The R09 implementation was committed as 736fd31. This log is committed and pushed as a separate follow-up commit after the implementation. Immediately after that push, the following equality check was run:

~~~
git fetch origin main
git status --short --branch
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
git diff --check
git diff --name-only -- TASKS.md
~~~

The exact equality output is returned in the Codex handoff. The three refs matched. The only intentionally dirty path remained the pre-existing owner change project.godot, and TASKS.md remained unchanged. The final log commit is separate from the implementation commit so the implementation SHA above remains the bounded recovery SHA.

AWAITING_AUDIT

