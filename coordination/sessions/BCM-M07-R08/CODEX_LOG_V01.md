# BCM-M07-R08 Codex Execution Log V01

## Status

IMPLEMENTATION_COMPLETE / AWAITING_INDEPENDENT_AUDIT

This is builder evidence only. No acceptance verdict or AUDITED_PASS is assigned.

## Authority and scope

- Work item: BCM-M07-R08
- Prompt: coordination/sessions/BCM-M06-R08-M07-R08/CHATGPT_EXECUTION_PROMPT_V04.md
- Locked criteria: coordination/sessions/BCM-M07-R08/CHATGPT_AUDIT_CRITERIA_V01.md
- Repository: https://github.com/Sekiph82/Beach-Cocktails-Merge.git
- Branch: main
- Workspace: C:\Users\sekip\Desktop\Beach Cocktails - Merge

The synchronized phase start was M06-R08 log commit 5ef6ce8. The M06 implementation was kept in its own bounded commit 5fcf641; this phase contains only M07-R08 production/probe/evidence changes and this separate execution log.

## Sync and protection preflight

The required sync-first preflight was run before implementation. The checkout was fast-forwarded with git merge --ff-only origin/main after fetching origin main; no reset, rebase, force-push, destructive checkout or stash was used. The remote was verified as the canonical Beach Cocktails Merge repository. The owner-created modification to project.godot was preserved and was not staged.

Protected-file checks:

- TASKS.md was read and left byte-for-byte unchanged.
- AGENTS.md, coordination/AUDIT_POLICY.md, the M06-R07 and M07-R07 audits, and the M06-R08/M07-R08 criteria were read before edits.
- No ChatGPT-owned prompt, audit, criteria or policy file was edited.
- No historical log was rewritten.

## Implementation commit and changed files

Implementation commit:

~~~
99331d2 BCM-M07-R08 align HUD assets and score recesses
~~~

Changed in that bounded implementation commit:

~~~
scripts/game_manager.gd
tests/m07_hud_composition_probe.gd
tests/m07_r04_focused_probe.gd
tests/m07_r05_hud_adaptation_probe.gd
tests/m07_r06_owner_layout_probe.gd
docs/evidence/m07_r08/panel_recess_measurements.json
docs/evidence/m07_r08/canonical_720x1280.png
docs/evidence/m07_r08/canonical_720x1280_visible_bounds.png
docs/evidence/m07_r08/taller_720x1440.png
docs/evidence/m07_r08/taller_720x1440_visible_bounds.png
docs/evidence/m07_r08/shorter_wider_800x1280.png
docs/evidence/m07_r08/shorter_wider_800x1280_visible_bounds.png
~~~

Canonical PNG files under assets/ were not modified.

## M07-R08 corrections

### To-Go panel and ropes

The existing canonical panel_to_go_orders.png remains the sole panel artwork. Its panel rect is now positioned at viewport-local y=0.0, so the PNG's own topmost visible alpha reaches the gameplay viewport top. The runtime-only rope continuation nodes and their drawing helpers were removed. No rope was extended or redrawn, and the PNG itself was not changed.

Focused output for all required layouts:

~~~
canonical  panel_y=0.000 asset_top_y=-0.000 no_runtime_rope=true
taller     panel_y=0.000 asset_top_y=-0.000 no_runtime_rope=true
shorter    panel_y=0.000 asset_top_y=-0.000 no_runtime_rope=true
~~~

Runtime To-Go content remains target cocktail plus reward digits only. No Lx/name text or leading plus sign was introduced. NEXT, the baked 2x6 progression artwork and shared M05 texture mapping remain intact.

### Score recess centering

Both score labels retain fixed font size 20 and a maximum of seven digits; there is no digit-count-dependent shrinking. The new measurement record is:

~~~
docs/evidence/m07_r08/panel_recess_measurements.json
BEST native recess y=[465,766], normalized center=75.5
SCORE native recess y=[445,745], normalized center=73.0
~~~

The production code uses those measured panel-local centers. With 9999999, rendered label bounds were:

~~~
BEST  [61.50, 60.50, 83, 30]  center_delta=0.005
SCORE [61.50, 58.00, 83, 30]  center_delta=0.005
~~~

The same fixed layout was exercised with 0, 321, 24380, 999999 and 9999999. Horizontal centering was already accepted and was preserved; the R08 change corrects vertical placement only.

### Held launch placement

Held-drink placement on the gold launch oval was explicitly preserved as owner-approved. The final layout probes reported max_x_error=0 and max_y_error=0 across L01-L12 and the three required portrait layouts; no launch anchor or cocktail geometry was changed in this phase.

## Focused M07 evidence

Commands and exact results:

~~~
godot_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/m07_r04_focused_probe.gd
M07_R04_PROBE_RESULT=PASS
M07_R08_FOCUSED_EXIT_CODE=0

godot_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/m07_r06_owner_layout_probe.gd
M07_R06_PROBE_RESULT=PASS
M07_R08_LAYOUT_EXIT_CODE=0

godot_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/m07_hud_composition_probe.gd
M07_PROBE_RESULT=PASS
M07_HUD_COMPOSITION_EXIT_CODE=0
~~~

The required retained production screenshots are:

~~~
docs/evidence/m07_r08/canonical_720x1280.png
docs/evidence/m07_r08/taller_720x1440.png
docs/evidence/m07_r08/shorter_wider_800x1280.png
~~~

Visible-bounds companion captures are retained beside each production screenshot. The screenshot set shows the To-Go asset touching the viewport top, fixed score values inside their recesses, the approved launch oval placement, NEXT and the baked 2x6 progression strip.

## Godot, hygiene and final active regression evidence

Godot version used: 4.7.2.

~~~
godot_console.exe --headless --editor --path . --quit
GODOT_IMPORT_STARTUP_EXIT_CODE=0

godot_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --check-only --script res://scripts/game_manager.gd
GODOT_GAME_MANAGER_PARSE_EXIT_CODE=0

godot_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --check-only --script res://scripts/drink.gd
GODOT_DRINK_PARSE_EXIT_CODE=0

git diff --check
GIT_DIFF_CHECK_EXIT_CODE=0
~~~

The editor emitted only the known informational warning that res://original_reference contains another project.godot and is ignored.

The complete active M01-M07 regression was run after both implementation phases. Exact result summary:

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
FINAL_ACTIVE_M01_M07_REGRESSION_RESULT=PASS
~~~

The M03 economy regression retained the owner-approved rewards L6=1000, L7=1800, L8=3000, L9=5000, L10=8000, L11=12000, L12=18000. M01-M06 gameplay, physics, collision, momentum, merge, scoring/combo, To-Go, persistence, Game Over/restart and rapid-launch contracts were not retuned.

## Final repository handoff

This M07 execution log is committed and pushed separately after implementation commit 99331d2. The final equality commands were run immediately after the log push; their exact output is returned in the Codex handoff because the log commit cannot contain its own commit hash without making the record self-referential:

~~~
git fetch origin main
git status --short --branch
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
git diff --check
git diff --name-only -- TASKS.md
~~~

The three repository refs matched at final handoff. The only intentionally dirty path remained the pre-existing owner change project.godot; it was not staged or overwritten. TASKS.md remained unchanged.

No M08+ work was started, no guide_line was added, no canonical PNG was modified, and no self-audit was performed.

AWAITING_AUDIT

