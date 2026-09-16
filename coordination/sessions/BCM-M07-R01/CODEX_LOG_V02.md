# BCM-M07-R01 V02 Codex Execution Log

## Scope and boundaries

- Work item: BCM-M07-R01 V02 strict remediation.
- Authoritative sequence: coordination/sessions/BCM-M04-M07-R02/CHATGPT_EXECUTION_PROMPT_V01.md.
- M07 V02 remediation, re-audit, and locked criteria were read before editing.
- Start after M06-R02: c5a5e9b1ed1b9fbd5df3c131720b8ac8e1e428a7.
- Goal: complete owner-directed dynamic gameplay HUD composition while preserving the current tropical M07 visual direction and accepted M01-M06 gameplay/geometry.
- TASKS.md was read and was not edited.
- ChatGPT-owned audit, prompt, criteria, and policy files were not edited.
- Canonical PNG files were not modified.
- No guide_line was added.
- M08+ was not started.

## Git and sync preflight

git status --short --branch
## main...origin/main

git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)

git fetch origin main
Already up to date.

git rev-list --left-right --count HEAD...origin/main
0 0

## Implementation summary

Production changes are bounded to the existing HUD composition in scripts/game_manager.gd:

- Best Score and Score were moved higher, with normalized 230x112 panel footprints at base scale. The Score bottom remains above the M06 perspective table top on all required portrait cases.
- To-Go uses one canonical panel_to_go_orders.png artwork with a larger 330x220 outer panel and explicit downward inner regions for target cocktail, live level/name, and live reward.
- NEXT remains exactly one canonical panel_next.png panel, enlarged to 176x176 with one true next Sprite2D and a dedicated inner content envelope.
- Progression uses one canonical progression_strip.png frame and a deliberate runtime 2x6 composition: top row L07-L12, bottom row L01-L06. Twelve icons are created through Drink.texture_for_level; no raw cocktail texture paths were duplicated.
- Progression icon max dimension increased from 54 to 70 for V02 evidence capture while preserving the M05 texture mapping.
- Launch halo uses canonical launch_zone.png, remains centered on the held drink, and was increased to a 132 px runtime diameter. It stays below the held drink in z-order and does not alter physics.
- Existing canonical danger-line PNG and M06 source threshold remain in use: source danger Y 1100 and source launch Y 1144.
- HUD scale is capped at 1.0 for wider portrait screens so the score hierarchy remains above the table rather than enlarging into the playfield. M06 playfield scaling/geometry is unchanged.

Added builder evidence tooling:

- tests/m07_hud_composition_probe.gd validates outer bounds, dynamic values, inner envelopes, 2x6 ordering, larger icons, halo, danger/launch coordinates, shared mapping, legacy-label suppression, and rapid-launch synchronization; it saves clean and annotated runtime captures.
- tests/m07_hud_inner_boxes.gd draws outer/inner HUD boxes plus table/danger/launch reference lines over actual runtime frames.
- tools/m07_evidence_sheet.py creates master/runtime side-by-side sheets, progression close-ups, and layout close-ups without modifying canonical inputs.

## Layout measurements

Base 720x1280 layout values:

Logo: (12, 6, 220, 148)
Best Score: (16, 142, 230, 112)
Score: (16, 262, 230, 112)
To-Go outer: centered, y=18, 330x220
To-Go target: center=(165, 90), dynamic level box starts at y=136.4, dynamic reward box starts at y=173.8
NEXT outer: right margin 12, y=10, 176x176
Progression: margin 12, y=1012, 696x260
Progression rows: top y=20.8, bottom y=140.4, six columns
Launch halo: 132 px centered on held drink
M06 danger/launch canonical: y=916.667 / y=953.333

The score panels use the same normalized display size. For 800x1280 the panel scale is capped at 1.0, keeping the same safe hierarchy while the M06 background remains aspect-preserving. For 720x1440 the same HUD footprint leaves additional lower playfield height; no black bars or geometry retuning were introduced.

## M07 probe exact result

godot_console --headless --path . --script res://tests/m07_hud_composition_probe.gd --rendering-method gl_compatibility --display-driver windows
Godot Engine v4.7.2.stable.official

M07_PROBE PASS: main scene loads as PackedScene
M07_PROBE PASS: canonical has one HUD root
M07_PROBE PASS: canonical canonical logo/panels exist
M07_PROBE PASS: canonical score panels share normalized display size
M07_PROBE PASS: canonical top-left logo then Best Score then Score hierarchy
M07_PROBE PASS: canonical score stack stays above the perspective table
M07_PROBE PASS: canonical upper-center To-Go panel and upper-right Next panel do not overlap
M07_PROBE PASS: canonical outer HUD panels remain on-screen
M07_PROBE PASS: canonical live score values are dynamic
M07_PROBE PASS: canonical exactly one active To-Go panel/target/reward
M07_PROBE PASS: canonical exactly one Next panel shows true next texture
M07_PROBE PASS: canonical To-Go target, level and reward fit independent downward inner boxes
M07_PROBE PASS: canonical Next cocktail fits the dedicated inner content box
M07_PROBE PASS: canonical progression is intentional 2x6 order top L07-L12 / bottom L01-L06 with no L13
M07_PROBE PASS: canonical progression icons use larger M05-mapped visual bounds
M07_PROBE PASS: canonical held cocktail is above canonical launch zone
M07_PROBE PASS: canonical launch halo is centered below the held cocktail and visibly larger
M07_PROBE PASS: canonical canonical danger PNG tracks accepted M06 threshold
M07_PROBE PASS: canonical danger/launch remain at independent M06 coordinates
M07_PROBE PASS: canonical no guide-line or permanent prototype hint
M07_PROBE PASS: canonical no legacy duplicate labels
M07_PROBE PASS: canonical cocktail HUD consumers use shared M05 level mapping
M07_PROBE PASS: canonical live score/To-Go/Next state updates without duplicate mapping
M07_PROBE PASS: canonical rapid launch keeps current held sprite and Next synchronized
M07_PROBE PASS: taller_720x1440 has one HUD root
M07_PROBE PASS: taller_720x1440 score stack stays above the perspective table
M07_PROBE PASS: taller_720x1440 outer HUD panels remain on-screen
M07_PROBE PASS: taller_720x1440 To-Go target, level and reward fit independent downward inner boxes
M07_PROBE PASS: taller_720x1440 Next cocktail fits the dedicated inner content box
M07_PROBE PASS: taller_720x1440 progression is intentional 2x6 order top L07-L12 / bottom L01-L06 with no L13
M07_PROBE PASS: taller_720x1440 launch halo is centered below the held cocktail and visibly larger
M07_PROBE PASS: taller_720x1440 danger/launch remain at independent M06 coordinates
M07_PROBE PASS: taller_720x1440 live score/To-Go/Next state updates without duplicate mapping
M07_PROBE PASS: taller_720x1440 rapid launch keeps current held sprite and Next synchronized
M07_PROBE PASS: shorter_wider_800x1280 has one HUD root
M07_PROBE PASS: shorter_wider_800x1280 score stack stays above the perspective table
M07_PROBE PASS: shorter_wider_800x1280 outer HUD panels remain on-screen
M07_PROBE PASS: shorter_wider_800x1280 To-Go target, level and reward fit independent downward inner boxes
M07_PROBE PASS: shorter_wider_800x1280 Next cocktail fits the dedicated inner content box
M07_PROBE PASS: shorter_wider_800x1280 progression is intentional 2x6 order top L07-L12 / bottom L01-L06 with no L13
M07_PROBE PASS: shorter_wider_800x1280 launch halo is centered below the held cocktail and visibly larger
M07_PROBE PASS: shorter_wider_800x1280 danger/launch remain at independent M06 coordinates
M07_PROBE PASS: shorter_wider_800x1280 live score/To-Go/Next state updates without duplicate mapping
M07_PROBE PASS: shorter_wider_800x1280 rapid launch keeps current held sprite and Next synchronized
M07_PROBE_RESULT=PASS
process exit code: 0

Dynamic-state probe coverage also changed score, best score, To-Go target/reward, and NEXT through production APIs, then verified the restored capture state. It launched three drinks rapidly and verified that the held Sprite2D and true next level remained synchronized.

## M07 retained render evidence

Clean production captures:
M07_CAPTURE name=canonical_720x1280 dimensions=720x1280 error=0
M07_CAPTURE name=taller_720x1440 dimensions=720x1440 error=0
M07_CAPTURE name=shorter_wider_800x1280 dimensions=800x1280 error=0

Annotated outer/inner-box captures:
M07_CAPTURE name=canonical_720x1280_hud_inner_boxes dimensions=720x1280 error=0
M07_CAPTURE name=taller_720x1440_hud_inner_boxes dimensions=720x1440 error=0
M07_CAPTURE name=shorter_wider_800x1280_hud_inner_boxes dimensions=800x1280 error=0

Evidence sheets:
python tools/m07_evidence_sheet.py
M07_SHEET case=canonical_720x1280 side_by_side=PASS progression_closeup=PASS layout_closeup=PASS
M07_SHEET case=taller_720x1440 side_by_side=PASS progression_closeup=PASS layout_closeup=PASS
M07_SHEET case=shorter_wider_800x1280 side_by_side=PASS progression_closeup=PASS layout_closeup=PASS
M07_SHEET_RESULT=PASS
process exit code: 0

## Godot and regression evidence

Godot:
godot_console --version
4.7.2.stable.official.ed1daf0bf
godot_console --headless --quiet --path . --editor --import --quit
WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
IMPORT_EXIT_CODE=0
godot_console --headless --quiet --path . --quit-after 3
MAIN_SCENE_SMOKE_EXIT_CODE=0

M01 after M07 changes:
godot_console --headless --path . --script res://tests/m01_contract_probe.gd
M01_PROBE_RESULT=PASS
process exit code: 0

M02 after M07 changes:
godot_console --headless --path . --script res://tests/m02_physics_regression.gd
M02_PROBE PASS: 700 px/s direct-hit has contact without tunneling
M02_PROBE PASS: 700 px/s glancing-hit has contact without tunneling
M02_PROBE PASS: moving multi-body chain merge produces stable L3
M02_PROBE PASS: six rapid launches preserve current/next integrity
M02_PROBE PASS: restart during multi-body motion produces clean playable scene
M02_PROBE PASS: Game Over with multiple moving drinks freezes all and stops shooting
M02_PROBE_RESULT=PASS
process exit code: 0

M03 after M07 changes:
godot_console --headless --path . --script res://tests/m03_economy_regression.gd
M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
M03_PROBE PASS: danger line waits below one-second tolerance
M03_PROBE PASS: danger line triggers deterministic Game Over at one second
M03_PROBE PASS: Game Over with moving drinks freezes run, stops shooting, clears pending work, and shows overlay
M03_PROBE PASS: restart after moving Game Over preserves best and clears session
M03_PROBE_RESULT=PASS
process exit code: 0

M04 after M07 changes:
godot_console --headless --path . --script res://tests/m04_asset_import_probe.gd
M04_GODOT_ASSET_COUNT expected=22 observed=22 cocktails=12 ui=8 effects_required=1
M04_GODOT_PROBE PASS: repository PNG directory counts match canonical scopes
M04_GODOT_RESULT=PASS
process exit code: 0

M05 after M07 changes:
godot_console --headless --path . --script res://tests/m05_sprite_integration_probe.gd --rendering-method gl_compatibility --display-driver windows
M05_PROBE PASS: all L01-L12 table drinks use the canonical Sprite2D mapping
M05_PROBE PASS: runtime collider/pivot/contact evidence captures saved
M05_PROBE PASS: merge creates the correct next-level sprite atomically
M05_PROBE PASS: merge result preserves forward/lateral momentum without visual teleport
M05_PROBE PASS: rapid launches preserve coherent current/next Sprite2D visuals
M05_PROBE PASS: restart after Game Over restores one canonical held visual
M05_PROBE_RESULT=PASS
process exit code: 0

M06-R02 was completed and passed immediately before this M07 implementation. M07 then independently rechecked M06 danger/launch values for all three viewports: canonical 916.667/953.333, taller 1031.250/1072.500, and shorter/wider 916.667/953.333. No M06 geometry or physics code was changed by the M07 remediation.

## Files changed in this remediation

scripts/game_manager.gd
tests/m07_hud_composition_probe.gd
tests/m07_hud_inner_boxes.gd
tools/m07_evidence_sheet.py
docs/evidence/m07 canonical captures and evidence sheets
coordination/sessions/BCM-M07-R01/CODEX_LOG_V02.md

No canonical PNG under assets/ was changed. No TASKS.md or ChatGPT-owned coordination file was changed.

## Final boundary

This log records builder commands and retained evidence for independent ChatGPT audit. It does not self-audit, assign an acceptance verdict, or transition the tracker. Final commit SHA and equality proof are appended after the bounded commit and push.

