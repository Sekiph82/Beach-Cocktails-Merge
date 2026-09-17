# BCM-M06-R05 Codex Execution Log V01

Status: `IMPLEMENTATION_COMPLETE / AWAITING_AUDIT`

Builder evidence only; no independent acceptance verdict is assigned here.

## Authority and preflight

- Work item: BCM-M06-R05.
- Master prompt: `coordination/sessions/BCM-M07-R04-THEN-M06-R05-M07-R05/CHATGPT_EXECUTION_PROMPT_V01.md`.
- Locked criteria: `coordination/sessions/BCM-M06-R05/CHATGPT_AUDIT_CRITERIA_V01.md`.
- Read before editing: `AGENTS.md`, `coordination/AUDIT_POLICY.md`, `TASKS.md`, the locked M06-R05 criteria, the locked M07-R05 criteria, and the completed M07-R04 Codex log.
- Start HEAD: `fac71a724f3bd480ae4e25fea592cbd1374f2ed8`.
- Branch: `main`.
- Remote: `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.

Sync-first preflight from `C:\Users\sekip\Desktop\Beach Cocktails - Merge`:

```text
git status --short --branch
## main...origin/main
git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
git fetch origin main
M06_R05_PREFLIGHT_FETCH_EXIT_CODE=0
git rev-list --left-right --count HEAD...origin/main
0 0
```

## Implementation summary

`scripts/game_manager.gd` now uses one coherent visible-edge boundary model:

- `get_table_rail_bounds_at_y()` remains the perspective-aware visible tabletop edge.
- `get_horizontal_bounds_at_y()` removes the prior duplicated half-wall-width clearance and returns `visible edge ± physical collider radius ± 0.5 px solver epsilon`.
- `clamp_position_to_board()` uses the same radius-plus-epsilon model for vertical center safety.
- `_build_walls()` offsets left/right wall bodies outward by half wall thickness so their inward collision faces align with the visible edges; top/bottom bodies are likewise offset outward.
- HUD nodes and rectangles are not referenced by the bounds functions.
- M06 accepted danger y and launch y source coordinates remain unchanged (`1080` and `1136`).
- M01-M05 gameplay, physics, economy, merge, persistence, Game Over and M07-R04 HUD behavior were not retuned.
- M05 collider radii were not changed.
- No canonical PNG was modified and no `guide_line` was added.

## Focused M06-R05 probe

Command:

```text
godot_v4.7.2-stable_win64_console.exe --headless --path . --display-driver windows --rendering-method gl_compatibility --rendering-driver opengl3 --script res://tests/m06_r05_full_tabletop_probe.gd
```

Exact result markers:

```text
M06_R05_PROBE PASS: M06-R05 main scene loads
M06_R05_PROBE PASS: canonical_720x1280 HUD is not consulted by horizontal bounds
M06_R05_PROBE PASS: canonical_720x1280 L01/L06/L12 reach both visible tabletop edges at far/middle/near depths
M06_R05_PROBE PASS: canonical_720x1280 wide bounds use radius plus only epsilon
M06_R05_PROBE PASS: canonical_720x1280 static wall inward-face model is outward-offset
M06_R05_PROBE PASS: canonical_720x1280 accepted danger/launch Y remain unchanged
M06_R05_PROBE PASS: taller_720x1440 HUD is not consulted by horizontal bounds
M06_R05_PROBE PASS: taller_720x1440 L01/L06/L12 reach both visible tabletop edges at far/middle/near depths
M06_R05_PROBE PASS: taller_720x1440 wide bounds use radius plus only epsilon
M06_R05_PROBE PASS: taller_720x1440 static wall inward-face model is outward-offset
M06_R05_PROBE PASS: taller_720x1440 accepted danger/launch Y remain unchanged
M06_R05_PROBE PASS: shorter_wider_800x1280 HUD is not consulted by horizontal bounds
M06_R05_PROBE PASS: shorter_wider_800x1280 L01/L06/L12 reach both visible tabletop edges at far/middle/near depths
M06_R05_PROBE PASS: shorter_wider_800x1280 wide bounds use radius plus only epsilon
M06_R05_PROBE PASS: shorter_wider_800x1280 static wall inward-face model is outward-offset
M06_R05_PROBE PASS: shorter_wider_800x1280 accepted danger/launch Y remain unchanged
M06_R05_PROBE RESULT=PASS
M06_R05_PROBE_EXIT_CODE=0
```

Representative exact contact evidence:

```text
M06_R05_CONTACT label=canonical_720x1280 depth=far level=L1 rails=(55.833,664.167) radius=20.000 left_center=76.333 right_center=643.667 left_body=56.333 right_body=663.667 left_ok=true right_ok=true
M06_R05_CONTACT label=canonical_720x1280 depth=middle level=L6 rails=(40.833,679.167) radius=42.000 left_center=83.333 right_center=636.667 left_body=41.333 right_body=678.667 left_ok=true right_ok=true
M06_R05_CONTACT label=canonical_720x1280 depth=near level=L12 rails=(26.667,693.333) radius=90.000 left_center=117.167 right_center=602.833 left_body=27.167 right_body=692.833 left_ok=true right_ok=true
M06_R05_CONTACT label=taller_720x1440 depth=far level=L1 rails=(23.763,696.237) radius=20.000 left_center=44.263 right_center=675.737 left_body=24.263 right_body=695.737 left_ok=true right_ok=true
M06_R05_CONTACT label=taller_720x1440 depth=middle level=L6 rails=(22.188,697.813) radius=42.000 left_center=64.688 right_center=655.313 left_body=22.688 right_body=697.313 left_ok=true right_ok=true
M06_R05_CONTACT label=taller_720x1440 depth=near level=L12 rails=(20.700,699.300) radius=90.000 left_center=111.200 right_center=608.800 left_body=21.200 right_body=698.800 left_ok=true right_ok=true
M06_R05_CONTACT label=shorter_wider_800x1280 depth=far level=L1 rails=(90.233,709.767) radius=20.000 left_center=110.733 right_center=689.267 left_body=90.733 right_body=709.267 left_ok=true right_ok=true
M06_R05_CONTACT label=shorter_wider_800x1280 depth=middle level=L6 rails=(60.833,739.167) radius=42.000 left_center=103.333 right_center=696.667 left_body=61.333 right_body=738.667 left_ok=true right_ok=true
M06_R05_CONTACT label=shorter_wider_800x1280 depth=near level=L12 rails=(33.067,766.933) radius=90.000 left_center=123.567 right_center=676.433 left_body=33.567 right_body=766.433 left_ok=true right_ok=true
```

For each contact, the body edges are within 0.5 px of the measured visible rail and remain inside the tabletop. All L01/L06/L12 combinations at all three depths and both sides passed the same check.

## Retained runtime evidence

The probe saved clean and geometry-overlay screenshots for all required viewports:

- `docs/evidence/m06_r05/canonical_720x1280.png`
- `docs/evidence/m06_r05/canonical_720x1280_geometry_overlay.png`
- `docs/evidence/m06_r05/taller_720x1440.png`
- `docs/evidence/m06_r05/taller_720x1440_geometry_overlay.png`
- `docs/evidence/m06_r05/shorter_wider_800x1280.png`
- `docs/evidence/m06_r05/shorter_wider_800x1280_geometry_overlay.png`

Exact capture markers:

```text
M06_R05_CAPTURE label=canonical_720x1280 clean=res://docs/evidence/m06_r05/canonical_720x1280.png overlay=res://docs/evidence/m06_r05/canonical_720x1280_geometry_overlay.png dimensions=720x1280 clean_error=0 overlay_error=0
M06_R05_CAPTURE label=taller_720x1440 clean=res://docs/evidence/m06_r05/taller_720x1440.png overlay=res://docs/evidence/m06_r05/taller_720x1440_geometry_overlay.png dimensions=720x1440 clean_error=0 overlay_error=0
M06_R05_CAPTURE label=shorter_wider_800x1280 clean=res://docs/evidence/m06_r05/shorter_wider_800x1280.png overlay=res://docs/evidence/m06_r05/shorter_wider_800x1280_geometry_overlay.png dimensions=800x1280 clean_error=0 overlay_error=0
```

The overlay marks visible perspective edges, wall inward-face lines, danger/launch references, and computed left/right tangent centers for L01/L06/L12. The bound check explicitly scans the production function source for HUD dependencies and found none.

## Files changed

- `scripts/game_manager.gd`
- `tests/m06_r05_full_tabletop_probe.gd`
- `tests/m06_r05_geometry_overlay.gd`
- `docs/evidence/m06_r05/` six required runtime captures
- `coordination/sessions/BCM-M06-R05/CODEX_LOG_V01.md`

`TASKS.md`, ChatGPT-owned prompts/audit criteria/policy files, historical logs, and canonical PNGs were not edited. No M07-R05 or M08+ implementation was started in this phase.

## Checks

```text
git diff --check
M06_R05_DIFF_CHECK_EXIT_CODE=0
```

The existing M01-M05 probes and M07-R04 probe are rerun in the final candidate regression after M07-R05, as required by the master prompt.

## Publication

Final commit SHA and local/origin/remote equality are recorded after this phase's push in the final section below.

This phase stops at `AWAITING_AUDIT` only after the separate M07-R05 phase and final regression are complete, per the sequential master prompt.
