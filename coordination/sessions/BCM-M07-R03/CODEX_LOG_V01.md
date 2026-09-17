# BCM-M07-R03 — Codex Execution Log V01

Status: AWAITING_AUDIT. This is builder evidence only; no independent acceptance verdict is assigned.

## Authority and scope

- Master prompt: `coordination/sessions/BCM-M04-M06-M07-R04/CHATGPT_EXECUTION_PROMPT_V02.md`.
- Locked criteria read before editing: `coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_CRITERIA_V01.md`.
- Start HEAD: `d204843` (the separately pushed M06-R04 commit).
- Scope: rebuild dynamic M07 HUD around the corrected owner PNG artwork.
- `TASKS.md`, prompts, criteria, policy files and all canonical PNG bytes were not edited.
- No `guide_line` was added; no M08+ work was started.

## HUD implementation

Production changes are in `scripts/game_manager.gd`:

- Best Score and Score use the exact landscape native ratios (`1671x941` and `1672x941`) and add only runtime numbers; baked crown/heading and star/heading remain in their PNGs.
- To-Go Orders uses the exact portrait ratio `1132x1389`; runtime adds only the current mapped target sprite, `Lx + name`, and live reward.
- NEXT uses the exact portrait ratio `1103x1426`; exactly one panel exists and runtime adds only the true next mapped cocktail.
- The progression artwork remains one `2170x725` aspect-preserving Sprite2D. Runtime creates twelve cocktail Sprite2D icons only; all runtime `Panel`/`StyleBoxFlat` cell frames were removed.
- Progression mapping is top L07-L12 and bottom L01-L06. All three HUD consumers continue to use the shared M05 `Drink.texture_for_level()` mapping; no duplicate L01-L12 path table was added.
- Launch halo and danger line remain world-space and unchanged relative to M06-R04 (`death_line_y` and `launch_y` from source y=1080 and y=1136).
- No permanent prototype instruction hint or legacy duplicate HUD labels are present.

## Independent asset measurements and final layout

`docs/evidence/m07/independent_inner_content_layout_v02.json` records independent content-window measurements. Native ratios and production display rectangles at 720 px width are:

| Element | Native size / ratio | Production display rectangle |
|---|---:|---:|
| Best Score | 1671x941 / 1.775 | x=16, y=145, w=205, h=115.443 |
| Score | 1672x941 / 1.777 | x=16, y=265, w=205, h=115.443 |
| To-Go Orders | 1132x1389 / 0.815 | centered, x=255, y=18, w=210, h=257.677 |
| NEXT | 1103x1426 / 0.774 | x=563, y=10, w=145, h=187.462 |
| Progression | 2170x725 / 2.993 | x=12, bottom margin=8, w=696, h=232.535 |

The progression slot interiors were measured directly from the new PNG using alpha/cream interior runs:

- source y ranges: top `[187,342]`, bottom `[380,536]`;
- source x ranges: `[499,658]`, `[701,860]`, `[902,1060]`, `[1102,1261]`, `[1303,1462]`, `[1506,1666]`;
- source centers used by production: x `[578.5,780.5,981.0,1181.5,1382.5,1586.0]`, y `[264.5,458.0]`.

The exact source-derived slot rectangles and panel content boxes are retained in the independent JSON dataset. Runtime alpha bounds for all twelve icons were within those slot interiors and had no material neighbor overlap.

## Commands and exact result markers

```text
godot_console.exe --path . --display-driver windows --rendering-driver opengl3 --rendering-method gl_compatibility --script res://tests/m07_hud_composition_probe.gd
M07_LAYOUT_DATASET PASS schema=BCM-M07-R03-independent-visible-content-layout-V01 overflow_tolerance=4.0 overlap_tolerance=2.0
M07_PROBE PASS: canonical progression has no runtime Panel/StyleBox cell frames
M07_PROBE PASS: canonical exactly one active To-Go panel/target/reward
M07_PROBE PASS: canonical exactly one Next panel shows true next texture
M07_PROBE PASS: canonical progression is intentional 2x6 order top L07-L12 / bottom L01-L06 with no L13
M07_PROBE PASS: canonical danger/launch remain at independent M06 coordinates
M07_PROBE PASS: canonical no guide-line or permanent prototype hint
M07_PROBE PASS: canonical cocktail HUD consumers use shared M05 level mapping
M07_PROBE PASS: canonical rapid launch keeps current held sprite and Next synchronized
M07_HUD_STATE label=canonical score=12650 best=24380 target=L6 reward=1000 next=L3 progression_slots=12 death_y=900.000 launch_y=946.667
M07_HUD_STATE label=taller_720x1440 score=12650 best=24380 target=L6 reward=1000 next=L1 progression_slots=12 death_y=1012.500 launch_y=1065.000
M07_HUD_STATE label=shorter_wider_800x1280 score=12650 best=24380 target=L6 reward=1000 next=L2 progression_slots=12 death_y=900.000 launch_y=946.667
M07_PROBE_RESULT=PASS
M07_R03_GODOT_EXIT_CODE=0
python tools/m07_evidence_sheet.py
M07_SHEET_RESULT=PASS
M07_R03_EVIDENCE_SHEET_EXIT_CODE=0
git diff --check
M07_R03_DIFF_CHECK_EXIT_CODE=0
```

The probe also verified dynamic score/Best Score/To-Go/NEXT updates, To-Go target L6 reward `+1000`, later dynamic target L7 reward `+1800`, on-screen panel bounds, visible text/alpha bounds, launch halo centering, canonical danger texture, and all 12 progression icons for all three required viewport sizes. The evidence-only overlays do not add production nodes or frames.

## Retained evidence

For each of `canonical_720x1280`, `taller_720x1440`, and `shorter_wider_800x1280`, the following final files were regenerated from the production scene:

- clean production screenshot: `<case>.png`;
- HUD content-box overlay: `<case>_hud_inner_boxes.png`;
- actual visible text/alpha bounds overlay: `<case>_visible_bounds.png`;
- progression close-up: `<case>_progression_closeup.png`;
- layout close-up: `<case>_layout_closeup.png`;
- visible-bounds close-up: `<case>_visible_bounds_closeup.png`;
- M07 owner/runtime comparison sheet: `<case>_master_side_by_side.png`.

`tools/m07_evidence_sheet.py` reported PASS for all three close-up sets. The screenshot files were created with dimensions `720x1280`, `720x1440`, and `800x1280` respectively.

## Files changed in this bounded phase

- `scripts/game_manager.gd`
- `tests/m07_hud_composition_probe.gd`
- `tests/m07_hud_inner_boxes.gd`
- `docs/evidence/m07/independent_inner_content_layout_v02.json`
- the regenerated final M07 screenshots, overlays, close-ups and comparison sheets under `docs/evidence/m07/`
- `coordination/sessions/BCM-M07-R03/CODEX_LOG_V01.md`

M01-M06 source behavior was not retuned. The full M01-M07 regression suite, Godot import/startup checks and final equality proof run after this bounded M07 commit.

## Handoff

Historical logs were not rewritten. ChatGPT-owned tracker/prompt/audit/criteria/policy files remain untouched. This log does not self-audit, assign `AUDITED_PASS`, or update `TASKS.md`.

## Final M01-M07 regression on candidate main

The final suite was run after the bounded M07-R03 commit (`8fddd0b`) against the candidate `main` checkout. All commands returned exit code `0`:

```text
res://tests/m01_contract_probe.gd                 M01_PROBE_RESULT=PASS        M01_FINAL_EXIT_CODE=0
res://tests/m02_physics_regression.gd             M02_PROBE_RESULT=PASS        M02_FINAL_EXIT_CODE=0
res://tests/m03_economy_regression.gd             M03_PROBE_RESULT=PASS        M03_FINAL_EXIT_CODE=0
res://tests/m04_asset_import_probe.gd             M04_GODOT_RESULT=PASS        M04_FINAL_EXIT_CODE=0
res://tests/m05_sprite_integration_probe.gd       M05_PROBE_RESULT=PASS        M05_FINAL_EXIT_CODE=0
res://tests/m06_environment_geometry_probe.gd     M06_PROBE_RESULT=PASS        M06_FINAL_EXIT_CODE=0
res://tests/m07_hud_composition_probe.gd          M07_PROBE_RESULT=PASS        M07_FINAL_EXIT_CODE=0
python tools/m04_asset_validation.py              M04_PYTHON_RESULT=PASS       M04_PYTHON_FINAL_EXIT_CODE=0
python tools/m05_independent_body_dataset.py     M05_INDEPENDENT_RESULT=PASS  M05_DATASET_FINAL_EXIT_CODE=0
godot --headless --editor --path . --quit       GODOT_IMPORT_FINAL_EXIT_CODE=0
godot --headless --path . --quit                 GODOT_STARTUP_FINAL_EXIT_CODE=0
git diff --check                                FINAL_DIFF_CHECK_EXIT_CODE=0
```

Final suite-specific markers included M01 700 px/s and 180 px/s² behavior, simultaneous motion/restart/Game Over persistence; M02 direct/glancing no-tunneling, single/chain merge, L12 cap, rapid launch and moving-body restart/Game Over; M03 exact score/economy and rewards `L6=1000`, `L7=1800`, `L8=3000`, `L9=5000`, `L10=8000`, `L11=12000`, `L12=18000`; M04 corrected owner hashes and 25-PNG inventory; M05 canonical mapped sprites and visible-body collider envelopes; M06 corrected-background rail/danger/launch geometry for all three viewports; and M07 baked-slot-only HUD, dynamic content, shared mapping, visible bounds, and rapid-launch synchronization.

The final suite regenerated only evidence captures; no source PNG or tracker file changed. The final local HEAD, `origin/main`, and remote `main` equality proof is recorded after the final evidence commit/push.
