# BCM-M07-R02 Codex Execution Log V01

Status: BUILDER EVIDENCE / AWAITING INDEPENDENT CHATGPT AUDIT

## Work item and authority

- Work item: BCM-M07-R02, final strict remediation sequence phase 4.
- Authority: `coordination/sessions/BCM-M04-M07-R03/CHATGPT_EXECUTION_PROMPT_V01.md`, Phase 4.
- Workspace: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Branch: `main`.
- Godot target/runtime: `4.7.2.stable.official.ed1daf0bf`, compatible with the governed Godot 4.7.x target.
- Start HEAD after M06-R03 push: `b1445fe1ea3d9b94a1e29d60ab7765db1ff1cc0e`.

## Sync-first preflight

Commands required by `AGENTS.md` were run from the repository root:

```text
git status --short --branch
## main...origin/main

git remote -v
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)

git fetch origin main
Already up to date.

git rev-list --left-right --count HEAD...origin/main
0 0
```

The M06-R03 commit was already pushed before M07 work began. No reset, rebase, force-push, or blind remote overwrite was used.

## Scope and implementation

The existing improved tropical M07 composition was retained. The only production layout adjustment was moving the To-Go target center from local panel y `0.41 * 220 = 90.20` to `0.39 * 220 = 85.80` so its measured imported-alpha silhouette clears the live level/name text by more than the material-overlap tolerance. No M06 table geometry, danger threshold, launch threshold, gameplay physics, scoring, economy, canonical PNG, or TASKS tracker was changed.

New evidence-only validation derives:

- label visible bounds from the active Godot font metrics, including the Best/Score shadow offsets;
- cocktail visible bounds from each imported texture's alpha `get_used_rect()` transformed by the live Sprite2D scale and pivot;
- independently authored inner boxes from `docs/evidence/m07/independent_inner_content_layout.json`;
- visible-bounds overlays from `tests/m07_hud_visible_bounds.gd`;
- strict containment and no-material-overlap checks in `tests/m07_hud_composition_probe.gd`.

The independent dataset is not imported by production code and does not obtain boxes from production assertions. It defines five panel scopes, seven dynamic content classes, twelve progression cell records, `overflow_tolerance_px = 4.0`, and `no_material_overlap_tolerance_px = 2.0`.

## Final outer HUD rectangles

Coordinates are viewport pixels. `ui_scale` is `1.0` for all three required viewports.

| viewport | Logo | Best Score | Score | To-Go Orders | NEXT | Progression strip |
|---|---|---|---|---|---|---|
| 720x1280 | (12,6,220,148) | (16,142,230,112) | (16,262,230,112) | (195,18,330,220) | (532,10,176,176) | (12,1012,696,260) |
| 720x1440 | (12,6,220,148) | (16,142,230,112) | (16,262,230,112) | (195,18,330,220) | (532,10,176,176) | (12,1172,696,260) |
| 800x1280 | (12,6,220,148) | (16,142,230,112) | (16,262,230,112) | (235,18,330,220) | (612,10,176,176) | (12,1012,776,260) |

The accepted M06 geometry remains: canonical danger/launch y `916.667 / 953.333`; taller portrait `1031.250 / 1072.500`; shorter/wider `916.667 / 953.333`.

## Independent authoritative inner boxes

These are local to each panel/strip and are retained in the dataset plus both overlay families.

```text
BestScorePanel.value = [44,34,142,70]
ScorePanel.value     = [44,34,142,70]
ToGoOrdersPanel.target = [82,18,166,126]
ToGoOrdersPanel.level  = [60,126,210,42]
ToGoOrdersPanel.reward = [70,165,190,48]
NextPanel.inset = [22,22,132,132]
ProgressionStrip cells: explicit 2x6 records; slot width 1/6 of the live strip,
top row y=.08 h=.34, bottom row y=.54 h=.34; 12 records total.
```

The progression ordering remains top `L07-L12`, bottom `L01-L06`; no `L13` slot or texture is introduced.

## Actual visible-bound measurements

The following are local panel/strip coordinates emitted by the live Godot probe. Bounds are visible alpha or font-metric bounds, not node centers. The canonical and taller 720-wide cases have the same local bounds. The shorter/wider case has the same non-strip bounds and a wider strip.

Canonical/taller dynamic bounds:

```text
BestScore value = [75.00,44.98,82.00,41.00]
Score value     = [72.00,43.48,88.00,44.00]
To-Go target alpha = [118.39,36.45,93.96,98.86]
To-Go level/name   = [116.50,137.90,98.00,24.00]
To-Go reward       = [130.50,173.80,70.00,35.00]
NEXT alpha         = [52.09,63.63,74.30,76.71]
```

Shorter/wider progression local alpha bounds:

```text
L07 [29.67,31.17,68.66,67.49]   L08 [161.29,31.28,66.59,68.72]
L09 [290.73,30.17,66.26,69.83]   L10 [423.08,31.06,62.85,66.37]
L11 [547.00,31.06,69.00,68.94]   L12 [679.85,32.62,64.25,63.47]
L01 [30.98,152.94,63.81,64.91]  L02 [162.41,150.77,65.37,67.49]
L03 [288.33,150.72,69.22,67.21]  L04 [417.67,150.10,66.99,69.50]
L05 [547.00,150.66,68.77,68.94]  L06 [679.96,151.39,63.25,66.54]
```

Canonical/taller progression local alpha bounds:

```text
L07 [23.00,31.17,68.66,67.49]   L08 [141.29,31.28,66.59,68.72]
L09 [257.40,30.17,66.26,69.83]   L10 [376.41,31.06,62.85,66.37]
L11 [487.00,31.06,69.00,68.94]   L12 [606.52,32.62,64.25,63.47]
L01 [24.31,152.94,63.81,64.91]  L02 [142.41,150.77,65.37,67.49]
L03 [255.00,150.72,69.22,67.21]  L04 [371.00,150.10,66.99,69.50]
L05 [487.00,150.66,68.77,68.94]  L06 [606.63,151.39,63.25,66.54]
```

All visible bounds passed the independent boxes. Target-vs-level/reward and level-vs-reward material overlap checks passed. Every progression alpha bound remained in its independent cell and did not materially overlap its neighbor. A 4 px containment tolerance and 2 px material-overlap tolerance are hard failures in the probe.

## Before/after evidence for the bounded layout adjustment

The existing M07 V02 captures were retained before regenerating the adjusted layout:

```text
canonical_720x1280_before_r02.png       D75C4E47E603FE32067E083822B2B1476FDA55439DB66760BFCF842417E1495C
taller_720x1440_before_r02.png          60A93C33A6FD8D2A3975987F08E47DA79A4808E5A679FDC21699286A29BA7E60
shorter_wider_800x1280_before_r02.png   B28D35A324FB2BDD642470ADF7FE40456151A59B1414C952791833D97F63168B
```

The regenerated clean captures retain the tropical full-screen/table direction and shifted target:

```text
canonical_720x1280.png                  F96D281E4E10CAF77425165E88E27CA0F60EE0D452A09391524E223484DA67BF
taller_720x1440.png                     852544C531F12AD3D8358BEF206C427D773C960E263BDB6254E6D4FC0736106B
shorter_wider_800x1280.png              4FF90445937CCC31483BCDACED4FF7E4A675FF36AF14052E46A70D9950B18C6B
```

## Responsive evidence inventory and hashes

Each required case has clean, HUD inner-box, visible-bounds, master/runtime, progression close-up, and layout close-up evidence. The M06 table/danger/launch overlays remain in the committed M06-R03 evidence set and were not blended into this M07 commit.

```text
canonical_720x1280_hud_inner_boxes.png  AF3949A0828F9BB6B21C6C63F3C1AC73EED396D9E0620641598D2ABD60C12B4B
canonical_720x1280_visible_bounds.png   E43C69E8B86A524894377F366A4E443FA1A238F20D2155D1C3AAE357F7EFB1F3
canonical_720x1280_master_side_by_side.png CCBF2894ABFF4379622B0C77F42CBB82B127032B6F221357258959416B11471A
canonical_720x1280_progression_closeup.png E93EC53EB54F10CDE7BC497BA10DF8491717EF6E6E94093DB9E4C43EBBC2CE17
canonical_720x1280_layout_closeup.png  514CE1DB01956F5502DCBC8418A611B8BA996BD3464301852ED8DE256B4221D6

taller_720x1440_hud_inner_boxes.png     0364C6A5ACFC093C3A5EB92EB563A1838C19D97B615171075CB17C53AEDE3B07
taller_720x1440_visible_bounds.png       71BAA978028B1A40D134E5B3988C62DC27511F88648A248B573E6663B709237E
taller_720x1440_master_side_by_side.png  651264165712BDDEF93BD647D18CB1A53DB701E2E434BE629CC61C33842FD2E7
taller_720x1440_progression_closeup.png  1D2509C6BBF995B547D696AAE2380C7B9DB089CA2DA463FD16FAEE9BA199C081
taller_720x1440_layout_closeup.png       7CCC7414BEF4389C5EEB82DFF5D96B4D64D1487CEA3FAC6433619F64F5517FF6

shorter_wider_800x1280_hud_inner_boxes.png 24D8206460B2A56543AF4DC8BDA9C8E9539C5CB6B5660E805D86CE981399E553
shorter_wider_800x1280_visible_bounds.png  8D8A398AF19FF63FF978CAB71E5A85320370D204417D5F8AE274F575D0299D16
shorter_wider_800x1280_master_side_by_side.png 14BCD1FED85F7C79784D103982C8F6D136D21994E9ECE528619336E103BAFD7D
shorter_wider_800x1280_progression_closeup.png D6C7FE84567D5CB078269F0C28D172F985FEDACE0435120B0309CA4E29661F9E
shorter_wider_800x1280_layout_closeup.png C0EE1988B1C2848ACFE5AE081A434344A6B4B5A75B67032043A662197EA1A65

canonical_720x1280_visible_bounds_closeup.png 13F1CD0409D0A7E0B7FC34D8EE0FDB35C6319A769391BBCCCFA23624FA853F01
taller_720x1440_visible_bounds_closeup.png F491635B711050A52A5A9ACCCC2DF1BB86BDBA5576A66C2E0B38B395CE9C0224
shorter_wider_800x1280_visible_bounds_closeup.png B294992F6394CBEA43D71D06F2B7C0DBCCE48EC592FBE00D6C60DE0D3D5B5A2D
```

`tools/m07_evidence_sheet.py` was extended to require visible-bounds inputs and emit `*_visible_bounds_closeup.png`. The final sheet output was:

```text
M07_SHEET case=canonical_720x1280 side_by_side=PASS progression_closeup=PASS layout_closeup=PASS visible_bounds_closeup=PASS
M07_SHEET case=taller_720x1440 side_by_side=PASS progression_closeup=PASS layout_closeup=PASS visible_bounds_closeup=PASS
M07_SHEET case=shorter_wider_800x1280 side_by_side=PASS progression_closeup=PASS layout_closeup=PASS visible_bounds_closeup=PASS
M07_SHEET_RESULT=PASS
M07_SHEET_PROCESS_EXIT_CODE=0
```

## Exact M07 probe output markers

Godot render capture used the desktop Windows/OpenGL3 compatibility driver because `--headless` selects the dummy driver and cannot expose a render texture. The headless run was not used as render evidence; the final render run was:

```text
godot_console.exe --display-driver windows --rendering-driver opengl3 --rendering-method gl_compatibility --path . --script tests/m07_hud_composition_probe.gd
M07_LAYOUT_DATASET PASS schema=BCM-M07-R02-independent-visible-content-layout-V01 overflow_tolerance=4.0 overlap_tolerance=2.0
M07_CAPTURE name=canonical_720x1280 dimensions=720x1280 error=0
M07_CAPTURE name=canonical_720x1280_visible_bounds dimensions=720x1280 error=0
M07_CAPTURE name=taller_720x1440 dimensions=720x1440 error=0
M07_CAPTURE name=taller_720x1440_visible_bounds dimensions=720x1440 error=0
M07_CAPTURE name=shorter_wider_800x1280 dimensions=800x1280 error=0
M07_CAPTURE name=shorter_wider_800x1280_visible_bounds dimensions=800x1280 error=0
M07_PROBE PASS: canonical all 12 progression alpha bounds stay inside independent cells without neighbor overlap
M07_PROBE PASS: taller_720x1440 all 12 progression alpha bounds stay inside independent cells without neighbor overlap
M07_PROBE PASS: shorter_wider_800x1280 all 12 progression alpha bounds stay inside independent cells without neighbor overlap
M07_PROBE_RESULT=PASS
M07_WINDOW_PROBE_EXIT_CODE=0
```

## Regression evidence

The complete candidate-suite rerun produced these exact result markers and exit codes. The one standalone M02 rerun was used after a sequential process emitted a transient freed-object probe error; the standalone governed probe completed cleanly and is the retained M02 result.

```text
M01_PROBE_RESULT=PASS
M01_PROBE_PROCESS_EXIT_CODE=0
M02_PROBE_RESULT=PASS
M02_STANDALONE_EXIT_CODE=0
M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
M03_PROBE_RESULT=PASS
M03_PROBE_PROCESS_EXIT_CODE=0
M04_PYTHON_RESULT=PASS
M04_PYTHON_PROCESS_EXIT_CODE=0
M04_GODOT_ASSET_COUNT expected=25 observed=25 cocktails=12 environment=1 ui=8 effects=4
M04_GODOT_RESULT=PASS
M04_GODOT_PROCESS_EXIT_CODE=0
M05_INDEPENDENT_RESULT=PASS
M05_DATASET_PROCESS_EXIT_CODE=0
M05_PROBE_RESULT=PASS
M05_PROBE_PROCESS_EXIT_CODE=0
M05_INDEPENDENT_CONTACT_PAIR label=low levels=L01/L02 center_distance=43.000 visible_gap=0.000 visible_overlap=0.000 tolerance=5.000
M05_INDEPENDENT_CONTACT_PAIR label=mid levels=L06/L07 center_distance=91.000 visible_gap=-0.000 visible_overlap=0.000 tolerance=5.000
M05_INDEPENDENT_CONTACT_PAIR label=high levels=L11/L12 center_distance=170.000 visible_gap=0.000 visible_overlap=0.000 tolerance=5.000
M06_RENDER_EVIDENCE_RESULT=PASS
M06_RENDER_PROCESS_EXIT_CODE=0
M06_PROBE_RESULT=PASS
M06_PROBE_PROCESS_EXIT_CODE=0
M07_SHEET_RESULT=PASS
M07_SHEET_PROCESS_EXIT_CODE=0
M07_PROBE_RESULT=PASS
M07_WINDOW_PROBE_EXIT_CODE=0
```

Detailed regression contracts observed in the retained outputs include M01 launch speed `700`, deceleration `180`, immediate held-next, simultaneous motion, forward-only contact, restart/Game Over and persistence; M02 direct/glancing contact, CCD/tunneling, one-pair and chain merge, L12 cap, six rapid launches and moving-body restart/Game Over; M03 score/combo, corrected L6/L7 rewards, stored delivery, L12 persistence, danger timing, moving-body Game Over and restart. No gameplay constant was changed by M07.

## Godot import/parse/startup and hygiene

```text
godot_console.exe --version
4.7.2.stable.official.ed1daf0bf

godot_console.exe --headless --editor --quit
GODOT_IMPORT_RESULT=PASS
GODOT_IMPORT_PROCESS_EXIT_CODE=0

godot_console.exe --headless --path . --quit
GODOT_STARTUP_RESULT=PASS
GODOT_STARTUP_PROCESS_EXIT_CODE=0

git diff --check
M07_DIFF_CHECK_EXIT_CODE=0
```

No canonical source PNG changed:

```text
git diff --name-only -- assets/
(empty)
M07_CANONICAL_ASSET_DIFF_EXIT_CODE=0
```

## Changed files

```text
scripts/game_manager.gd
tests/m07_hud_composition_probe.gd
tests/m07_hud_visible_bounds.gd
tools/m07_evidence_sheet.py
docs/evidence/m07/independent_inner_content_layout.json
docs/evidence/m07/*_before_r02.png
docs/evidence/m07/*_visible_bounds.png
docs/evidence/m07/*_visible_bounds_closeup.png
docs/evidence/m07 regenerated clean/inner-box/master-runtime/progression/layout evidence
coordination/sessions/BCM-M07-R02/CODEX_LOG_V01.md
```

The M06 evidence files were not included in this bounded M07 commit. No historical log was rewritten.

## Governance and handoff

- `TASKS.md` was not edited; `git diff -- TASKS.md` is empty.
- ChatGPT-owned audit, prompt, criteria, and policy files were not edited.
- No M08+ work was started.
- No `guide_line` asset, node, or production reference was added.
- Canonical PNG files were not modified or regenerated.
- M07 remains builder evidence only and is explicitly `AWAITING_AUDIT`; no `AUDITED_PASS` was assigned.
- The final commit SHA and local/origin/remote equality are verified at push time and reported in the handoff response.
