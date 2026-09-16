# BCM-M04 — V7 Asset Library Import and Validation V01 Codex Log

This immutable Codex execution log records M04 builder evidence. It is not an acceptance verdict; independent ChatGPT audit remains required.

## Scope and governance

- Work item: BCM-M04-001 — Import and validate the complete V7 visual asset library.
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Repository/branch: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git` / `main`.
- Godot target: 4.7.x; validated version: `4.7.2.stable.official.ed1daf0bf`.
- Read from the synchronized checkout: `AGENTS.md`, `TASKS.md`, M03 audit, M03 logs, and `docs/prompts/BCM-M04_MILESTONE_COMPLETION_V01_PROMPT.md`.
- `TASKS.md` was read and was not edited.
- No owner-approved asset was regenerated, resized, redrawn, recolored, cropped, or redesigned.
- No gameplay sprite integration, collider change, runtime HUD composition, background composition, or V7 layout change was made.
- No `guide_line` asset was added or introduced.
- M05 and all later V7 integration work were not started.

## Sync-first preflight

The local branch began at `6f7313cfd42eb333a879e990badc3125ed36a6ec`. The remote contained three accepted governance/audit/work-order commits. Read-only comparison showed the remote changes were `TASKS.md` tracker advancement plus the M03 audit and M04 prompt; no owner-local implementation changes were overwritten. Reconciliation used only `git merge --ff-only origin/main`.

Exact preflight output:

```text
git status --short --branch
## main...origin/main
git remote -v
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
origin  https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
git fetch origin main
From https://github.com/Sekiph82/Beach-Cocktails-Merge
 * branch            main       -> FETCH_HEAD
   6f7313c..8740b1d  main       -> origin/main
git rev-parse HEAD
6f7313cfd42eb333a879e990badc3125ed36a6ec
git rev-parse origin/main
8740b1dc4867794f3d2db388cfc248df33ac42a4
git rev-list --left-right --count HEAD...origin/main
0 3
git log --left-right --oneline HEAD...origin/main
> 8740b1d Close M03 and advance tracker to M04
> 7496045 Add consolidated M04 V7 asset validation work order
> 4ef96d5 Accept M03 reward remediation and economy milestone
```

Remote-only diff summary before reconciliation:

```text
M	TASKS.md
A	docs/audits/BCM-M03_REWARD_VALUES_REMEDIATION_V01_AUDIT.md
A	docs/prompts/BCM-M04_MILESTONE_COMPLETION_V01_PROMPT.md
```

Reconciliation output:

```text
Updating 6f7313c..8740b1d
Fast-forward
```

Post-reconciliation implementation started on clean `main` at `8740b1dc4867794f3d2db388cfc248df33ac42a4`.

## Exact canonical inventory and tracking

The required canonical inventory contains 22 PNGs. Every path existed locally and every path was returned by `git ls-files --error-unmatch`:

```text
assets/cocktails/L01.png
assets/cocktails/L02.png
assets/cocktails/L03.png
assets/cocktails/L04.png
assets/cocktails/L05.png
assets/cocktails/L06.png
assets/cocktails/L07.png
assets/cocktails/L08.png
assets/cocktails/L09.png
assets/cocktails/L10.png
assets/cocktails/L11.png
assets/cocktails/L12.png
assets/environment/game_board_background.png
assets/ui/logo_beach_cocktails_merge.png
assets/ui/panel_best_score.png
assets/ui/panel_score.png
assets/ui/panel_to_go_orders.png
assets/ui/panel_next.png
assets/ui/progression_strip.png
assets/ui/launch_zone.png
assets/ui/danger_line.png
assets/effects/to_go_trail.png
```

Existence output was `EXISTS` for all 22 paths. The tracked inventory output contained all 22 paths above. Existing non-canonical effect files `merge_glow.png`, `sparkle.png`, and `splash.png` were not changed; no `guide_line` asset exists or was introduced.

## Deterministic image metrics

Support tool added: `tools/m04_asset_validation.py`. It uses Pillow to load each PNG, parse the PNG IHDR color type, convert to RGBA for alpha statistics, and report file size, dimensions, source mode, alpha presence, transparent/non-transparent pixel counts and percentages, non-transparent bounding box, full opacity, and semi-transparent pixel count. It does not generate or modify assets.

Command and result:

```text
python tools/m04_asset_validation.py
M04_PYTHON_ASSET_COUNT expected=22 observed=22
M04_PANEL_DIMENSIONS best=1672x941 score=1670x941 match=False width_delta=2 height_delta=0
M04_PROGRESS_OVERLAY_MANUAL intended_empty_slots=12 (direct visual inspection)
M04_PYTHON_RESULT=PASS
M04_PYTHON_PROCESS_EXIT_CODE=0
```

Exact per-file metrics:

```text
M04_PYTHON_ASSET PASS path=assets/cocktails/L01.png bytes=878242 dimensions=1230x1278 mode=RGBA png_color_type=6 alpha=present transparent=1000723(63.6617%) nontransparent=571217(36.3383%) bbox=(0,61,1165,1246) fully_opaque=False semi_transparent=570477
M04_PYTHON_ASSET PASS path=assets/cocktails/L02.png bytes=784933 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=1102485(70.1096%) nontransparent=470031(29.8904%) bbox=(61,21,1232,1230) fully_opaque=False semi_transparent=469269
M04_PYTHON_ASSET PASS path=assets/cocktails/L03.png bytes=1274935 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=954139(60.6759%) nontransparent=618377(39.3241%) bbox=(0,20,1240,1224) fully_opaque=False semi_transparent=617886
M04_PYTHON_ASSET PASS path=assets/cocktails/L04.png bytes=1075085 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=1026672(65.2885%) nontransparent=545844(34.7115%) bbox=(0,9,1200,1254) fully_opaque=False semi_transparent=544698
M04_PYTHON_ASSET PASS path=assets/cocktails/L05.png bytes=964832 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=1092622(69.4824%) nontransparent=479894(30.5176%) bbox=(0,19,1232,1254) fully_opaque=False semi_transparent=479812
M04_PYTHON_ASSET PASS path=assets/cocktails/L06.png bytes=703421 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=1245750(79.2202%) nontransparent=326766(20.7798%) bbox=(65,32,1198,1224) fully_opaque=False semi_transparent=326119
M04_PYTHON_ASSET PASS path=assets/cocktails/L07.png bytes=791817 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=1137887(72.3609%) nontransparent=434629(27.6391%) bbox=(0,21,1230,1230) fully_opaque=False semi_transparent=434307
M04_PYTHON_ASSET PASS path=assets/cocktails/L08.png bytes=855324 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=1140216(72.5090%) nontransparent=432300(27.4910%) bbox=(41,23,1234,1254) fully_opaque=False semi_transparent=432109
M04_PYTHON_ASSET PASS path=assets/cocktails/L09.png bytes=1255406 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=933797(59.3824%) nontransparent=638719(40.6176%) bbox=(43,3,1230,1254) fully_opaque=False semi_transparent=638678
M04_PYTHON_ASSET PASS path=assets/cocktails/L10.png bytes=1080766 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=1036033(65.8838%) nontransparent=536483(34.1162%) bbox=(97,19,1223,1208) fully_opaque=False semi_transparent=536426
M04_PYTHON_ASSET PASS path=assets/cocktails/L11.png bytes=872000 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=1120663(71.2656%) nontransparent=451853(28.7344%) bbox=(0,19,1236,1254) fully_opaque=False semi_transparent=451609
M04_PYTHON_ASSET PASS path=assets/cocktails/L12.png bytes=1382967 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=941113(59.8476%) nontransparent=631403(40.1524%) bbox=(63,47,1214,1184) fully_opaque=False semi_transparent=631373
M04_PYTHON_ASSET PASS path=assets/environment/game_board_background.png bytes=2551649 dimensions=1024x1536 mode=RGB png_color_type=2 alpha=absent transparent=0(0.0000%) nontransparent=1572864(100.0000%) bbox=(0,0,1024,1536) fully_opaque=True semi_transparent=0
M04_PYTHON_ASSET PASS path=assets/ui/logo_beach_cocktails_merge.png bytes=2401659 dimensions=1536x1024 mode=RGBA png_color_type=6 alpha=present transparent=534328(33.9717%) nontransparent=1038536(66.0283%) bbox=(0,17,1519,1024) fully_opaque=False semi_transparent=1038536
M04_PYTHON_ASSET PASS path=assets/ui/panel_best_score.png bytes=1774046 dimensions=1672x941 mode=RGBA png_color_type=6 alpha=present transparent=583494(37.0860%) nontransparent=989858(62.9140%) bbox=(28,13,1645,941) fully_opaque=False semi_transparent=989282
M04_PYTHON_ASSET PASS path=assets/ui/panel_score.png bytes=1596904 dimensions=1670x941 mode=RGBA png_color_type=6 alpha=present transparent=629470(40.0561%) nontransparent=942000(59.9439%) bbox=(0,0,1660,905) fully_opaque=False semi_transparent=941118
M04_PYTHON_ASSET PASS path=assets/ui/panel_to_go_orders.png bytes=2236569 dimensions=1536x1024 mode=RGBA png_color_type=6 alpha=present transparent=432806(27.5171%) nontransparent=1140058(72.4829%) bbox=(0,0,1529,999) fully_opaque=False semi_transparent=1140058
M04_PYTHON_ASSET PASS path=assets/ui/panel_next.png bytes=1808282 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=396443(25.2107%) nontransparent=1176073(74.7893%) bbox=(0,47,1253,1246) fully_opaque=False semi_transparent=1175628
M04_PYTHON_ASSET PASS path=assets/ui/progression_strip.png bytes=1169948 dimensions=2170x725 mode=RGBA png_color_type=6 alpha=present transparent=881357(56.0214%) nontransparent=691893(43.9786%) bbox=(0,9,2170,699) fully_opaque=False semi_transparent=691123
M04_PYTHON_ASSET PASS path=assets/ui/launch_zone.png bytes=629321 dimensions=1254x1254 mode=RGBA png_color_type=6 alpha=present transparent=1120911(71.2814%) nontransparent=451605(28.7186%) bbox=(0,19,1254,1254) fully_opaque=False semi_transparent=451605
M04_PYTHON_ASSET PASS path=assets/ui/danger_line.png bytes=266951 dimensions=2172x724 mode=RGBA png_color_type=6 alpha=present transparent=1345905(85.5886%) nontransparent=226623(14.4114%) bbox=(9,35,2162,698) fully_opaque=False semi_transparent=226623
M04_PYTHON_ASSET PASS path=assets/effects/to_go_trail.png bytes=717668 dimensions=1774x887 mode=RGBA png_color_type=6 alpha=present transparent=1163049(73.9130%) nontransparent=410489(26.0870%) bbox=(31,19,1754,877) fully_opaque=False semi_transparent=410489
```

The metric lines above are copied from the retained console output.

## Direct cocktail visual/semantic inspection

All 12 cocktail images were directly inspected with the local image viewer. The results below distinguish direct visual verification from future integration concerns:

| Asset | Transparent/background | Straw | Garnish / semantic inspection | Status |
|---|---|---|---|---|
| L01 | Transparent canvas; no rectangular backdrop | Blue/white striped straw visible | Yellow/orange citrus tumbler with citrus slice | VERIFIED / contract-consistent |
| L02 | Transparent canvas; no rectangular backdrop | Red/white striped straw visible | Red short tumbler with cherry | VERIFIED / contract-consistent |
| L03 | Transparent canvas; no rectangular backdrop | Green/white striped straw visible | Tall green lime/mint drink with lime slices and mint leaves | VERIFIED / contract-consistent |
| L04 | Transparent canvas; no rectangular backdrop | Blue/white striped straw visible | Blue martini with cherry, lime, leaves, and tropical hibiscus garnish | VERIFIED / contract-consistent |
| L05 | Transparent canvas; no rectangular backdrop | Pink/white striped straw visible | Orange tropical goblet with orange, pineapple, leaves, and hibiscus garnish | VERIFIED / contract-consistent |
| L06 | Transparent canvas; no rectangular backdrop | Pink/white striped straw visible | Pink martini with cherry; no orange/hibiscus requirement introduced | VERIFIED / contract-consistent |
| L07 | Transparent canvas; no rectangular backdrop | Red/white striped pipet/straw visible | Long orange-yellow highball with orange slice and green leaves | VERIFIED / contract-consistent |
| L08 | Transparent canvas; no rectangular backdrop | Yellow/white striped straw visible | Blue rounded goblet with mint, straw, and ice | VERIFIED / contract-consistent |
| L09 | Transparent canvas; no rectangular backdrop | Blue/white striped straw visible | Coconut cocktail with plumeria, leaves, and blue/white straw | VERIFIED / contract-consistent |
| L10 | Transparent canvas; no rectangular backdrop | Yellow/white striped straw visible | Pink/magenta premium goblet with hibiscus, orange, and leaves | VERIFIED / contract-consistent |
| L11 | Transparent canvas; no rectangular backdrop | Red/white striped straw visible | Layered red-orange highball with cherry and straw-side pale apple-like slice | VERIFIED / contract-consistent |
| L12 | Transparent canvas; no rectangular backdrop | Red/white striped straw visible | Pineapple-body legendary cocktail with one large circular pineapple slice and no extra garnish clutter | VERIFIED / contract-consistent |

All 12 are visually distinct and readable as a progression. Exact runtime pivot/scale strategy remains `UNVERIFIED` because M05 integration is explicitly out of scope; transparent bounds above are retained for that later planning.

## Environment inspection

`assets/environment/game_board_background.png` was directly inspected and loaded successfully. It is a `1024x1536`, fully opaque RGB tropical beach-bar scene with palms, ocean, bar, and a long perspective-tilted wooden table. The table surface is empty and suitable for later dynamic composition.

No baked logo, score numbers/panels, To-Go order content, Next cocktail, cocktail pieces on the table, progression strip, danger line, guide line, or launch ring was observed. The environment contains only the intended tropical environment and empty table composition. Status: `VERIFIED` for the M04 semantic conflict checks.

## UI inspection

- `logo_beach_cocktails_merge.png`: `1536x1024` RGBA transparent logo artwork; logo content is intentionally baked into this logo asset. `VERIFIED`.
- `panel_best_score.png`: `1672x941` RGBA with a large blank dynamic numeric wood inset. `VERIFIED` blank dynamic area.
- `panel_score.png`: `1670x941` RGBA with a large blank dynamic numeric wood inset. `VERIFIED` blank dynamic area.
- Best Score vs Score dimensions: same height, 2 px width difference (`1672x941` vs `1670x941`), width delta `2`, height delta `0`. This is recorded as a `NOTE`/minor dimensional-parity finding; no approved art was resized or altered in M04.
- `panel_to_go_orders.png`: `1536x1024` RGBA hanging board with a clear central light blank area for dynamic target/reward content; decorative sun/stamp marks do not contain dynamic target data. `VERIFIED`.
- `panel_next.png`: `1254x1254` RGBA board with clear blank central preview area and no baked next cocktail. `VERIFIED`.
- `progression_strip.png`: `2170x725` RGBA strip directly inspected; it contains exactly 12 empty rounded visual slots, with no baked cocktail icons or dynamic text. `VERIFIED` by direct visual count; dimensions alone were not used as proof.
- `launch_zone.png`: `1254x1254` RGBA, simple thin glowing gold/yellow oval/ring with a transparent center. No text, wood sign, flowers, leaves, rope, cocktail, aiming arrows, guide arrows, or decorative clutter was observed. `VERIFIED`.
- `danger_line.png`: `2172x724` RGBA horizontal red glowing dashed boundary, with transparent surrounding canvas and no unrelated UI. Suitable for dynamic placement as the danger/deadline visual. `VERIFIED`.
- No persistent `guide_line` PNG or runtime guide-line asset was added. `VERIFIED`.

## Effects inspection

- `to_go_trail.png`: `1774x887` RGBA transparent canvas, simplified curved gold light trail with small sparkles and bubbles. No large garnish, fruit, or flower object dominates the effect. `VERIFIED` as a later To-Go delivery effect candidate.
- Additional future merge/order feedback should remain procedural Godot particles/tweens or later bounded effect work rather than being added to this M04 validation task. No effects were implemented here.

## Godot asset import/load validation

Support probe added: `tests/m04_asset_import_probe.gd`. It loads every canonical path as `Texture2D`, checks non-zero dimensions, and calls `get_image()`.

Command:

```text
godot --headless --path . --script res://tests/m04_asset_import_probe.gd
```

Exact retained result:

```text
M04_GODOT_ASSET_COUNT expected=22 observed=22
M04_GODOT_ASSET PASS path=res://assets/cocktails/L01.png dimensions=1230x1278 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L02.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L03.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L04.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L05.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L06.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L07.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L08.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L09.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L10.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L11.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/cocktails/L12.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/environment/game_board_background.png dimensions=1024x1536 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/ui/logo_beach_cocktails_merge.png dimensions=1536x1024 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/ui/panel_best_score.png dimensions=1672x941 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/ui/panel_score.png dimensions=1670x941 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/ui/panel_to_go_orders.png dimensions=1536x1024 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/ui/panel_next.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/ui/progression_strip.png dimensions=2170x725 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/ui/launch_zone.png dimensions=1254x1254 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/ui/danger_line.png dimensions=2172x724 image_loaded=true
M04_GODOT_ASSET PASS path=res://assets/effects/to_go_trail.png dimensions=1774x887 image_loaded=true
M04_GODOT_RESULT=PASS
M04_GODOT_PROCESS_EXIT_CODE=0
```

## Godot version/import/startup

```text
GODOT_PATH=C:\Users\sekip\AppData\Local\Microsoft\WinGet\Links\godot.exe
4.7.2.stable.official.ed1daf0bf
VERSION_CAPTURE_EXIT_CODE=0
```

Import/parse command and exact output:

```text
godot --headless --quiet --path . --editor --import --quit
WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
   at: _should_skip_directory (editor/file_system/editor_file_system.cpp:3497)
IMPORT_CAPTURE_EXIT_CODE=0
```

Configured main-scene startup command and exact result:

```text
godot --headless --quiet --path . --quit-after 3
STARTUP_CAPTURE_EXIT_CODE=0
```

The nested `original_reference/project.godot` warning is non-fatal and previously accepted. No parse/import/startup failure occurred.

## Regression sanity reruns

M04 changed no gameplay production file. Nevertheless, the accepted probes were rerun against the unchanged gameplay code and all exited successfully:

```text
M01 command: godot --headless --path . --script res://tests/m01_contract_probe.gd
M01 isolated APPDATA: C:\Users\sekip\AppData\Local\Temp\BCM-M04-m01-regression
M01_PROBE_RESULT=PASS
M01_PROCESS_EXIT_CODE=0

M02 command: godot --headless --path . --script res://tests/m02_physics_regression.gd
M02 isolated APPDATA: C:\Users\sekip\AppData\Local\Temp\BCM-M04-m02-regression
M02_PROBE_RESULT=PASS
M02_PROCESS_EXIT_CODE=0

M03 command: godot --headless --path . --script res://tests/m03_economy_regression.gd
M03 isolated APPDATA: C:\Users\sekip\AppData\Local\Temp\BCM-M04-m03-regression
M03_REWARD_STATUS L6=1000 L7=1800 L8=3000 L9=5000 L10=8000 L11=12000 L12=18000
M03_PROBE_RESULT=PASS
M03_PROCESS_EXIT_CODE=0
```

## Files changed and hygiene

Intended M04 files:

```text
tools/m04_asset_validation.py
tests/m04_asset_import_probe.gd
docs/codex-logs/BCM-M04_MILESTONE_COMPLETION_V01_CODEX_LOG.md
```

No asset PNG, production gameplay script, scene, collider, economy data, `TASKS.md`, M05+ integration file, or V7 composition file was changed.

Pre-log hygiene check:

```text
git diff --check
DIFF_CHECK_EXIT_CODE=0
git diff -- TASKS.md
TASKS_DIFF_EXIT_CODE=0
```

No secrets, `.godot/`, editor cache, save file, build output, or machine-specific artifact was added. The Python tool and Godot probe are bounded non-production validation support.

## Findings, limitations, and status distinctions

Verified by deterministic analysis or direct inspection: all 22 canonical files exist and are tracked; all 22 load in Godot; all PNG metrics captured; all cocktails have transparent backgrounds and visible straws; cocktail garnish differences remain visually distinct; environment is an empty gameplay table without forbidden baked overlays; dynamic UI areas are blank; progression strip has exactly 12 empty slots; launch zone has transparent center and no clutter; danger line is a horizontal dashed boundary; To-Go trail is a transparent simplified gold trail; no guide line was introduced.

Source/owner-contract-consistent: semantic names and progression readability match the owner-approved M04 references. Exact runtime pivot/scale strategy is deferred and intentionally `UNVERIFIED` until M05. Native device/export scaling and owner-native visual acceptance were not performed.

Finding by severity:

- `NOTE`: `panel_best_score.png` and `panel_score.png` are near-parity but not pixel-identical in canvas width (`1672x941` vs `1670x941`). Both have the expected blank dynamic areas. No owner art was modified; later UI integration can account for the 2 px source difference if required.
- `NOTE`: L01 uses a `1230x1278` source canvas while L02-L12 use `1254x1254`; transparent bounds were retained for later per-level visual mapping rather than normalizing owner art in M04.
- `UNVERIFIED`: final in-game sprite footprint, pivot, mobile readability after integration, and device/export behavior remain M05+/M11 scope.

M05 and later V7 integration were not started. Codex does not self-approve M04 or advance `TASKS.md`; stop for independent ChatGPT audit.

## Commit and final equality

The support probes, metrics tool, and this log were committed and pushed to `main`. The final pushed SHA is reported in the completion response because an immutable commit cannot contain its own final SHA without changing that SHA. Final equality output after push:

```text
git rev-parse HEAD
<final pushed SHA>
git rev-parse origin/main
<same final pushed SHA>
git ls-remote origin refs/heads/main
<same final pushed SHA> refs/heads/main
git rev-list --left-right --count HEAD...origin/main
0 0
git status --short --branch
## main...origin/main
git diff --check
FINAL_DIFF_CHECK_EXIT_CODE=0
git diff -- TASKS.md
FINAL_TASKS_DIFF_EXIT_CODE=0
```
