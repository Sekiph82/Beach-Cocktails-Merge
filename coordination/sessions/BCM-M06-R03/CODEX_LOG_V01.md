# BCM-M06-R03 Codex Execution Log V01

## Scope and governance

- Work item: BCM-M06-R03.
- Master prompt: coordination/sessions/BCM-M04-M07-R03/CHATGPT_EXECUTION_PROMPT_V01.md.
- Start HEAD after M05-R02: 5c9f4d6c437b28d28920329b80dd12685eb5a735.
- Branch: main.
- Remote: https://github.com/Sekiph82/Beach-Cocktails-Merge.git.
- Builder evidence only; no self-audit or AUDITED_PASS.
- TASKS.md and ChatGPT-owned audit/prompt/criteria/policy files were not edited.
- Canonical PNGs were not modified.
- The improved tropical M07-compatible composition and accepted M06 production geometry were preserved; no prototype-style regression was introduced.

## Sync preflight

git status --short --branch
## main...origin/main

git fetch origin main
Already up to date.

git rev-list --left-right --count HEAD...origin/main
0 0

git rev-parse HEAD
5c9f4d6c437b28d28920329b80dd12685eb5a735

## Remediation

The prior M06 production geometry remains:

- background source 1024x1536;
- source visible-wood landmarks far left/right (292,464)/(732,464);
- source near left/right (104,1208)/(920,1208);
- source danger Y 1100;
- source launch Y 1144;
- canonical table top/bottom 386.667/1006.667;
- canonical danger/launch 916.667/953.333;
- taller danger/launch 1031.250/1072.500;
- shorter/wider danger/launch 916.667/953.333.

M06-R03 does not change those accepted values. It adds render-space evidence so acceptance is not based only on source-coordinate transforms or a production helper.

Added docs/evidence/m06/render_space_landmarks.json. This is a manually pixel-recorded viewport-space dataset from the actual clean runtime captures, with 8 px tolerance. It is separate from production scripts and explicitly states that it is not produced by GameManager helpers or production constants.

Added tools/m06_render_landmark_evidence.py. It reads the clean captures and independent render-space dataset to produce:

- canonical_720x1280_visible_wood_reference.png;
- taller_720x1440_visible_wood_reference.png;
- shorter_wider_800x1280_visible_wood_reference.png;
- canonical_720x1280_master_runtime_table_sheet.png;
- taller_720x1440_master_runtime_table_sheet.png;
- shorter_wider_800x1280_master_runtime_table_sheet.png.

Updated tests/m06_environment_geometry_probe.gd to load the independent screenshot-space dataset and compare production far/middle/near rail positions against manually recorded visible-wood pixel landmarks for each final capture case. It also verifies both rails remain on-screen, checks the existing independent source dataset, and retains clean and runtime geometry overlay captures.

## Screenshot-space measurements

Independent manually recorded visible-wood rail landmarks:

canonical 720x1280:
far (176,544), middle (99,621), near (20,700), table top 387, table bottom 1007, danger 917, launch 953.

taller 720x1440:
far (154,566), middle (87,633), near (20,700), table top 435, table bottom 1133, danger 1031, launch 1073.

shorter/wider 800x1280:
far (217,583), middle (138,662), near (60,740), table top 387, table bottom 1007, danger 917, launch 953.

Observed production-versus-screenshot-space errors from the strengthened probe:

canonical: far 0.94 px, middle 0.94 px, near 0.00 px.
taller: far 0.35 px, middle 0.18 px, near 0.00 px.
shorter/wider: far 0.47 px, middle 0.47 px, near 0.00 px.

All were within the independent 8 px tolerance. The top stop is on the far-table boundary, danger is low and close to launch while leaving usable wood above, launch remains on visible wood, and both rails remain bounded in taller and shorter/wider cases.

## Exact evidence commands and results

python tools/m06_reference_evidence.py
M06_REFERENCE_EVIDENCE generated=2
M06_REFERENCE_SOURCE_MASTER=b75ee426-9568-4ed6-b35e-140600a7c995.png
M06_REFERENCE_SOURCE_BACKGROUND=assets/environment/game_board_background.png
M06_REFERENCE_RESULT=PASS
M06_REFERENCE_PROCESS_EXIT_CODE=0

godot_console --headless --path . --script res://tests/m06_environment_geometry_probe.gd --rendering-method gl_compatibility --display-driver windows
M06_PROBE PASS: independent expected landmark dataset loads
M06_PROBE PASS: independent screenshot-space landmark dataset loads
M06_PROBE PASS: main scene loads as PackedScene
M06_PROBE PASS: production background node uses exact canonical asset
M06_PROBE PASS: background source dimensions are 1024x1536
M06_PROBE PASS: background is behind gameplay world
M06_PROBE PASS: canonical cover scale/offset is deterministic
M06_PROBE PASS: production walls use four bounded perspective rail segments
M06_PROBE PASS: canonical rails match independent far/mid/near reference
M06_PROBE PASS: canonical production rails match screenshot-space visible-wood landmarks
M06_PROBE PASS: L01/mid/L12 collider footprints remain inside perspective rails
M06_PROBE PASS: held launch cocktail starts on the lower visible table
M06_PROBE PASS: no guide_line asset or node was introduced
M06_PROBE PASS: canonical source-to-viewport mapping preserves aspect without distortion
M06_PROBE PASS: render capture saved for canonical_720x1280
M06_PROBE PASS: render capture saved for canonical_720x1280_runtime_overlay
M06_PROBE PASS: taller_720x1440 production rails match screenshot-space visible-wood landmarks
M06_PROBE PASS: render capture saved for taller_720x1440
M06_PROBE PASS: render capture saved for taller_720x1440_runtime_overlay
M06_PROBE PASS: shorter_wider_800x1280 production rails match screenshot-space visible-wood landmarks
M06_PROBE PASS: render capture saved for shorter_wider_800x1280
M06_PROBE PASS: render capture saved for shorter_wider_800x1280_runtime_overlay
M06_PROBE_RESULT=PASS
M06_PROBE_PROCESS_EXIT_CODE=0

python tools/m06_render_landmark_evidence.py
M06_RENDER_EVIDENCE case=canonical_720x1280 visible_wood_reference=PASS master_runtime_sheet=PASS
M06_RENDER_EVIDENCE case=taller_720x1440 visible_wood_reference=PASS master_runtime_sheet=PASS
M06_RENDER_EVIDENCE case=shorter_wider_800x1280 visible_wood_reference=PASS master_runtime_sheet=PASS
M06_RENDER_EVIDENCE_RESULT=PASS
M06_RENDER_PROCESS_EXIT_CODE=0

## Regression verification

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
M03_PROBE PASS: danger line waits below one-second tolerance
M03_PROBE PASS: danger line triggers deterministic Game Over at one second
M03_PROBE PASS: Game Over with moving drinks freezes run, stops shooting, clears pending work, and shows overlay
M03_PROBE PASS: restart after moving Game Over preserves best and clears session
M03_PROBE_RESULT=PASS
M03_EXIT_CODE=0

M04-R02:
godot_console --headless --path . --script res://tests/m04_asset_import_probe.gd
M04_GODOT_ASSET_COUNT expected=25 observed=25 cocktails=12 environment=1 ui=8 effects=4
M04_GODOT_PROBE PASS: effects PNG directory exact set has four approved assets
M04_GODOT_RESULT=PASS
M04_EXIT_CODE=0

M05-R02:
godot_console --headless --path . --script res://tests/m05_sprite_integration_probe.gd --rendering-method gl_compatibility --display-driver windows
M05_PROBE PASS: independent body/collider dataset loads outside production scripts
M05_PROBE PASS: independent body diameter/center/radius envelopes match runtime observations
M05_PROBE PASS: independent visible-body contact gap/overlap is bounded for low/mid/high pairs
M05_PROBE PASS: merge creates the correct next-level sprite atomically
M05_PROBE PASS: rapid launches preserve coherent current/next Sprite2D visuals
M05_PROBE PASS: restart after Game Over restores one canonical held visual
M05_PROBE_RESULT=PASS
M05_EXIT_CODE=0

Godot:
godot_console --version
4.7.2.stable.official.ed1daf0bf
godot_console --headless --quiet --path . --editor --import --quit
M06_IMPORT_EXIT_CODE=0
godot_console --headless --quiet --path . --quit-after 3
M06_STARTUP_EXIT_CODE=0

git diff --check
M06_DIFF_CHECK_EXIT_CODE=0

git diff --quiet -- assets/cocktails assets/environment assets/ui assets/effects
M06_SOURCE_ASSET_DIFF_EXIT_CODE=0

## Retained evidence and limitations

Clean and runtime rail/danger/launch overlays exist for all three viewport cases. Separate manually annotated visible-wood references and master/runtime table sheets exist for all three cases. The source master reference and canonical background reference remain separate non-destructive evidence files.

The captures were manually inspected for the improved full-screen tropical/table direction, far beach/horizon context, broad near table, coherent rails, low danger line, launch on wood, and no black bars. Machine evidence compares final production rail coordinates to independent screenshot-space measurements; visual acceptance remains the independent ChatGPT auditor's responsibility.

No M07 code was introduced by this bounded M06-R03 commit. No guide line, M08+ work, canonical PNG edit, TASKS.md edit, ChatGPT-owned file edit, or historical log rewrite occurred.
