# BCM-M06-R02 Codex Execution Log

## Scope

- Work item: BCM-M06-R02 strict remediation.
- Prompt: \`coordination/sessions/BCM-M04-M07-R02/CHATGPT_EXECUTION_PROMPT_V01.md\` and the locked M06-R02 remediation/criteria files.
- Goal: correct environment/background perspective-table geometry and responsive playfield evidence while preserving accepted M01-M05 gameplay contracts.
- \`TASKS.md\` was read and was not edited.
- No M07 implementation was introduced by this bounded commit; M08+ and later V7 integration were not started.

## Git and sync preflight

Start checkout was synchronized at \`3667ae9bc23a593e51fb59a3e0e12526131c49a7\`.

\`\`\`text
git status --short --branch
## main...origin/main

git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)

git fetch origin main
3667ae9 main -> origin/main

git rev-list --left-right --count HEAD...origin/main
0 0
\`\`\`

The M04-R01 and M05-R01 commits were already present on \`main\`; no reset, force-push, destructive checkout, automatic rebase, or stash was used.

## Implementation

Changed production geometry in \`scripts/game_manager.gd\`:

- Danger source threshold: \`1048.0\` -> \`1100.0\`.
- Canonical 720x1280 danger line: \`873.333\` -> \`916.667\`.
- Launch source threshold remained \`1144.0\`; canonical launch remained \`953.333\`.
- The bottom gameplay rail is clamped to visible portrait bounds. At taller portrait ratios the previous raw source-cover near rail could be off-screen; gameplay now uses bounded \`table_bottom_inset\` values and interpolates the visible trapezoid consistently.
- Physics walls use the same bounded table rail coordinates used by the reference checks.

Added independent evidence tooling:

- \`docs/evidence/m06/expected_landmarks.json\` records source landmarks and independently calculated canonical, taller, and shorter/wider viewport envelopes.
- \`tools/m06_reference_evidence.py\` creates non-destructive annotated source/background references.
- \`tests/m06_geometry_overlay.gd\` draws runtime rails, stops, danger threshold, and launch position over the actual scene.
- \`tests/m06_environment_geometry_probe.gd\` validates the independent dataset, exact canonical asset use, bounded rails, collider footprints, launch/danger placement, no \`guide_line\`, aspect-preserving mapping, and clean/overlay captures for all three viewports.

## Geometry evidence

Independent source: \`assets/environment/game_board_background.png\`, 1024x1536.

Source landmarks: far rails \`(292,464)\` / \`(732,464)\`, near rails \`(104,1208)\` / \`(920,1208)\`, danger Y \`1100\`, launch Y \`1144\`.

\`\`\`text
case                    table top   table bottom   danger     launch     far rails          middle rails       near rails
canonical 720x1280     386.667     1006.667       916.667    953.333    (176.667,543.333)  (98.333,621.667)  (20.000,700.000)
taller 720x1440        435.000     1132.500      1031.250   1072.500    (153.750,566.250)  (86.875,633.125)  (20.000,700.000)
shorter/wider 800x1280 386.667     1006.667       916.667    953.333    (216.667,583.333)  (138.333,661.667) (60.000,740.000)
\`\`\`

Before/after threshold evidence:

\`\`\`text
canonical danger: 873.333 -> 916.667; launch: 953.333 -> 953.333
taller danger:    982.500 -> 1031.250; launch: 1072.500 -> 1072.500
shorter danger:   873.333 -> 916.667; launch: 953.333 -> 953.333
\`\`\`

The independent probe reported exact far/middle/near matches within 3 px, all rails on-screen, monotonic widening with depth, and L1/L6/L12 collider footprints inside independent rail envelopes.

## Commands and exact results

Reference evidence:

\`\`\`text
python tools/m06_reference_evidence.py
M06_REFERENCE_EVIDENCE generated=2
M06_REFERENCE_SOURCE_MASTER=b75ee426-9568-4ed6-b35e-140600a7c995.png
M06_REFERENCE_SOURCE_BACKGROUND=assets/environment/game_board_background.png
M06_REFERENCE_RESULT=PASS
process exit code: 0
\`\`\`

M06 geometry probe:

\`\`\`text
godot_console --headless --path . --script res://tests/m06_environment_geometry_probe.gd --rendering-method gl_compatibility --display-driver windows
M06_PROBE PASS: independent expected landmark dataset loads
M06_PROBE PASS: main scene loads as PackedScene
M06_PROBE PASS: production background node uses exact canonical asset
M06_PROBE PASS: background source dimensions are 1024x1536
M06_PROBE PASS: background is behind gameplay world
M06_PROBE PASS: canonical cover scale/offset is deterministic
M06_PROBE PASS: production walls use four bounded perspective rail segments
M06_PROBE PASS: canonical rails match independent far/mid/near reference
M06_PROBE PASS: canonical launch/danger occupy lower visible wood
M06_PROBE PASS: L01/mid/L12 collider footprints remain inside perspective rails
M06_PROBE PASS: held launch cocktail starts on the lower visible table
M06_PROBE PASS: no guide_line asset or node was introduced
M06_PROBE PASS: canonical source-to-viewport mapping preserves aspect without distortion
M06_PROBE PASS: render capture saved for canonical_720x1280
M06_PROBE PASS: render capture saved for canonical_720x1280_runtime_overlay
M06_PROBE PASS: taller_720x1440 rails match independent far/mid/near reference
M06_PROBE PASS: render capture saved for taller_720x1440
M06_PROBE PASS: render capture saved for taller_720x1440_runtime_overlay
M06_PROBE PASS: shorter_wider_800x1280 rails match independent far/mid/near reference
M06_PROBE PASS: render capture saved for shorter_wider_800x1280
M06_PROBE PASS: render capture saved for shorter_wider_800x1280_runtime_overlay
M06_NOTE direct/glancing collision, rapid launch, merge, restart, Game Over and To-Go contracts are covered by the rerun M01-M05 probes recorded with this run.
M06_PROBE_RESULT=PASS
process exit code: 0
\`\`\`

Godot smoke:

\`\`\`text
godot_console --version
4.7.2.stable.official
godot_console --headless --quiet --path . --editor --import --quit
process exit code: 0
godot_console --headless --quiet --path . --quit-after 3
process exit code: 0
\`\`\`

M01 regression:

\`\`\`text
godot_console --headless --path . --script res://tests/m01_contract_probe.gd
M01_PROBE_RESULT=PASS
process exit code: 0
\`\`\`

M02 regression:

\`\`\`text
godot_console --headless --path . --script res://tests/m02_physics_regression.gd
M02_PROBE PASS: 700 px/s direct-hit has contact without tunneling
M02_PROBE PASS: 700 px/s glancing-hit has contact without tunneling
M02_PROBE PASS: moving multi-body chain merge produces stable L3
M02_PROBE PASS: six rapid launches preserve current/next integrity
M02_PROBE PASS: restart during multi-body motion produces clean playable scene
M02_PROBE PASS: Game Over with multiple moving drinks freezes all and stops shooting
M02_PROBE_RESULT=PASS
process exit code: 0
\`\`\`

M03 regression:

\`\`\`text
godot_console --headless --path . --script res://tests/m03_economy_regression.gd
M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
M03_PROBE PASS: danger line waits below one-second tolerance
M03_PROBE PASS: danger line triggers deterministic Game Over at one second
M03_PROBE PASS: Game Over with moving drinks freezes run, stops shooting, clears pending work, and shows overlay
M03_PROBE PASS: restart after moving Game Over preserves best and clears session
M03_PROBE_RESULT=PASS
process exit code: 0
\`\`\`

M04 asset/import regression:

\`\`\`text
godot_console --headless --path . --script res://tests/m04_asset_import_probe.gd
M04_GODOT_ASSET_COUNT expected=22 observed=22 cocktails=12 environment=1 ui=8 effects_required=1
M04_GODOT_PROBE PASS: repository PNG directory counts match canonical scopes
M04_GODOT_RESULT=PASS
process exit code: 0
\`\`\`

M05 sprite regression:

\`\`\`text
godot_console --headless --path . --script res://tests/m05_sprite_integration_probe.gd --rendering-method gl_compatibility --display-driver windows
M05_PROBE PASS: all L01-L12 table drinks use the canonical Sprite2D mapping
M05_PROBE PASS: runtime collider/pivot/contact evidence captures saved
M05_PROBE PASS: merge creates the correct next-level sprite atomically
M05_PROBE PASS: merge result preserves forward/lateral momentum without visual teleport
M05_PROBE PASS: rapid launches preserve coherent current/next Sprite2D visuals
M05_PROBE PASS: restart after Game Over restores one canonical held visual
M05_PROBE_RESULT=PASS
process exit code: 0
\`\`\`

## Retained evidence and boundaries

Retained M06 evidence includes clean and runtime-overlay captures for 720x1280, 720x1440, and 800x1280, plus source/background landmark references and the independent JSON dataset. Captures were manually inspected for the tropical background, perspective rails, lower danger line, centered launch zone, bounded taller-portrait rails, and absence of black bars.

Canonical PNGs were not modified. \`guide_line\` was not added. \`TASKS.md\` and ChatGPT-owned audit/prompt/criteria files were not modified. The existing current M07 visual direction remains the starting point for the next bounded M07-R01 V02 remediation; this M06 commit does not regress it to the old prototype appearance.

Limitations: this is builder evidence for independent ChatGPT audit; this log does not assign an acceptance verdict.

## Commit and final equality

The M06 remediation is committed separately from M04-R01 and M05-R01. The final SHA, push result, and equality output are appended only after commit/push.
