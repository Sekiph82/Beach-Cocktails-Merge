# BCM-M07-R06 — Codex Execution Log V01

Status: `IMPLEMENTATION_COMPLETE / AWAITING_AUDIT`

Builder evidence only; no independent acceptance verdict is assigned here.

## Authority and scope

- Work item: BCM-M07-R06.
- Master prompt: `coordination/sessions/BCM-M06-R06-M07-R06/CHATGPT_EXECUTION_PROMPT_V01.md`.
- Locked criteria: `coordination/sessions/BCM-M07-R06/CHATGPT_AUDIT_CRITERIA_V01.md`.
- Read before editing: `AGENTS.md`, `coordination/AUDIT_POLICY.md`, `TASKS.md`, BCM-M06-R05 and BCM-M07-R05 independent audits, and the locked M06-R06/M07-R06 criteria.
- Start HEAD for this phase: `c192e21fc2170306e8611eaa5be4980618294f73`.
- Branch: `main`.
- Remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

## Phase boundary

BCM-M06-R06 was completed and pushed before this phase (`ed2ac3b9d7f6fff96426238fa6fd921269db38ec` implementation, `c192e21fc2170306e8611eaa5be4980618294f73` log). This phase did not retune M06 geometry, gameplay physics, economy, merge, persistence or canonical PNGs.

The pre-existing owner change in `project.godot` was preserved and excluded from all commits.

## M07-R06 implementation

`scripts/game_manager.gd` changes are HUD-only:

- SCORE now uses the right-side panel rectangle (`x = viewport width - panel width - margin`, `y = 205`) below the upper-right NEXT panel. BEST SCORE remains under the logo on the left.
- BEST SCORE and SCORE retain fixed 20 px production font sizes and the seven-digit clamp through `9999999`.
- `_center_panel_value()` measures the active rendered font string and fixed shadow extents, then centers the rendered value bounds in the independently measured dark window. `_refresh_hud()` reapplies this position after every value change; it never changes font size.
- To-Go remains target cocktail plus reward digits only. The reward moved from the previous low position to the cream board lower-middle window at local `y = 0.73 * panel_height`; no level/name label or leading plus sign was added.
- To-Go ropes remain HUD siblings from viewport top (`y=0`) to the baked panel anchors and remain behind the panel.

`scripts/drink.gd` explicitly reapplies the M05 visible-glass-body horizontal offset while a drink is held. Together with the existing M07-R04 foot anchor, the glass/container body—not garnish or full alpha bounds—defines both held X centering and Y baseline.

The existing independent M07 content dataset was updated only for the superseded To-Go reward window (`[35,185,140,35]` instead of the retired low window). No canonical PNG was modified.

## Focused M07-R06 probe

Command:

```text
godot_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/m07_r06_owner_layout_probe.gd
```

Exact result markers:

```text
M07_R06_PROBE PASS: M07-R06 main scene loads
M07_R06_PROBE PASS: canonical_720x1280 BEST remains left and SCORE is right below NEXT
M07_R06_PROBE PASS: taller_720x1440 BEST remains left and SCORE is right below NEXT
M07_R06_PROBE PASS: shorter_wider_800x1280 BEST remains left and SCORE is right below NEXT
M07_R06_SCORE label=canonical_720x1280 value=0 ... best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=canonical_720x1280 value=321 ... best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=canonical_720x1280 value=24380 ... best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=canonical_720x1280 value=999999 ... best_center_delta=0.005 score_center_delta=0.005
M07_R06_SCORE label=canonical_720x1280 value=9999999 ... best_center_delta=0.005 score_center_delta=0.005
M07_R06_PROBE PASS: canonical_720x1280 fixed-size score glyphs center inside both recessed windows
M07_R06_PROBE PASS: taller_720x1440 fixed-size score glyphs center inside both recessed windows
M07_R06_PROBE PASS: shorter_wider_800x1280 fixed-size score glyphs center inside both recessed windows
M07_R06_PROBE PASS: all To-Go L6-L12 target+reward cases fit inside the cream board
M07_R06_PROBE PASS: all three viewport To-Go ropes remain attached to viewport top
M07_R06_PROBE PASS: all three viewport NEXT L01-L12 cases remain contained
M07_R06_PROBE PASS: all three viewport baked 2x6 progressions remain frame-free
M07_R06_PROBE PASS: all three viewport M06 danger/launch coordinates and no guide line remain
M07_R06_PROBE PASS: all three viewport held glass bodies center on halo X and share launch baseline Y
M07_R06_HELD_SUMMARY label=canonical_720x1280 max_x_delta=0.000 max_y_delta=0.000
M07_R06_HELD_SUMMARY label=taller_720x1440 max_x_delta=0.000 max_y_delta=0.000
M07_R06_HELD_SUMMARY label=shorter_wider_800x1280 max_x_delta=0.000 max_y_delta=0.000
M07_R06_PROBE RESULT=PASS
M07_R06_PROBE_RESULT=PASS
M07_R06_PROBE_EXIT_CODE=0
```

The focused probe also emitted To-Go reward bounds `[39.90,188.10,49.00,31.00]` for four-digit rewards and `[39.90,188.10,61.00,31.00]` for five-digit rewards, within local window `[35.00,185.00,140.00,35.00]`. It emitted held baselines of `988.667`, `1107.000` and `988.667` for the three required viewports, each with zero measured X/Y error.

## Retained production screenshots

- `docs/evidence/m07_r06/canonical_720x1280.png` — 720x1280.
- `docs/evidence/m07_r06/taller_720x1440.png` — 720x1440.
- `docs/evidence/m07_r06/shorter_wider_800x1280.png` — 800x1280.

These captures show the current production background, BEST left, SCORE right below NEXT, To-Go target/reward-only content, corrected reward placement, launch halo and current 2x6 progression.

## Final M01-M07 regression

The required active final suite was run serially on final candidate main with Godot 4.7.2 stable, Windows display driver and OpenGL compatibility renderer:

```text
FINAL_M01_EXIT_CODE=0
M01_PROBE_RESULT=PASS
M02_PROBE_RESULT=PASS
FINAL_M02_EXIT_CODE=0
M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
M03_PROBE_RESULT=PASS
M04_GODOT_RESULT=PASS
FINAL_M04_EXIT_CODE=0
M05_PROBE_RESULT=PASS
FINAL_M05_EXIT_CODE=0
M06_R06_PROBE_RESULT=PASS
FINAL_M06_R06_EXIT_CODE=0
M07_R04_PROBE_RESULT=PASS
M07_R04_REGRESSION_EXIT_CODE=0
M07_R06_PROBE_RESULT=PASS
FINAL_M07_R06_EXIT_CODE=0
FINAL_M01_M07_REGRESSION_RESULT=PASS
FINAL_M01_M07_REGRESSION_EXIT_CODE=0
```

M02 was rerun in isolation after one earlier wrapper run produced a transient previously-freed diagnostic; the isolated run completed with `M02_PROBE_RESULT=PASS` and process exit code `0`. No test assertion was weakened.

The retired `tests/m06_environment_geometry_probe.gd` was also inspected/run once and reports failure because its M06-R04 independent datasets still assert the superseded narrow two-endpoint geometry. It was not used as the active M06-R06 acceptance probe; the new independent five-sample M06-R06 probe above is the current geometry regression required by the issued prompt. Its generated historical M06 PNG outputs were restored and no historical log was rewritten.

## Godot and hygiene checks

```text
godot_console.exe --headless --editor --path . --quit
FINAL_GODOT_IMPORT_STARTUP_EXIT_CODE=0
git diff --check
FINAL_GIT_DIFF_CHECK_EXIT_CODE=0
```

The editor smoke check reported only the expected warning that `res://original_reference/project.godot` is ignored as a second project configuration. No canonical asset import error occurred.

## Files changed in this phase

- `scripts/game_manager.gd`
- `scripts/drink.gd`
- `tests/m07_r04_focused_probe.gd` (superseded To-Go window expectation only)
- `tests/m07_r06_owner_layout_probe.gd`
- `docs/evidence/m07/independent_inner_content_layout_v02.json` (superseded To-Go window expectation only)
- `docs/evidence/m07_r06/` three production screenshots
- `coordination/sessions/BCM-M07-R06/CODEX_LOG_V01.md`

`TASKS.md`, canonical PNGs, ChatGPT-owned prompts/audit criteria/policy files, historical logs, M06-R06 files and M08+ files were not edited. No `guide_line` was introduced. No self-audit or `AUDITED_PASS` verdict was assigned.

## Publication

M07-R06 implementation commit: `ba167b34d9b0f7e8121600d56acf43e7cce27c4e`.

The log is finalized in a separate documentation/evidence-only commit after the implementation push. Final phase equality is recorded after that commit.

```text
git status --short --branch
## main...origin/main
 M project.godot
```

This phase stops at `AWAITING_AUDIT` for independent ChatGPT review.
