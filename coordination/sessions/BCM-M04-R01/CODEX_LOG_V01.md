# BCM-M04-R01 — Codex Remediation Log V01

## Scope and governance

- Work item: BCM-M04-R01, strict asset-validation remediation.
- Prompt/criteria: coordination/sessions/BCM-M04-R01/CHATGPT_REMEDIATION_PROMPT_V01.md and CHATGPT_AUDIT_CRITERIA_V01.md.
- Repository: https://github.com/Sekiph82/Beach-Cocktails-Merge.git
- Branch: main
- Workspace: C:\Users\sekip\Desktop\Beach Cocktails - Merge
- Start HEAD after mandatory sync: 3667ae9bc23a593e51fb59a3e0e12526131c49a7
- This log is builder evidence only; no independent audit or AUDITED_PASS was assigned.
- TASKS.md, coordination policy, and all ChatGPT-owned prompt/criteria/audit files were left unchanged.

## Sync-first and source preservation

Initial mandatory preflight:

    git status --short --branch
    ## main...origin/main
    git remote -v
    origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (fetch)
    origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git (push)
    git fetch origin main
    From https://github.com/Sekiph82/Beach-Cocktails-Merge
     * branch main -> origin/main
       fb42850..3667ae9 main -> origin/main
    git rev-list --left-right --count HEAD...origin/main
    0 12
    git merge --ff-only origin/main
    Updating fb42850..3667ae9
    Fast-forward

No reset, force push, automatic rebase, destructive checkout, or stash was used. The incoming remote commits were governance/tracker/audit artifacts and were fast-forwarded before implementation.

The source asset check was run before staging:

    git diff --quiet -- assets/cocktails assets/environment assets/ui assets/effects
    M04_SOURCE_ASSET_DIFF_EXIT_CODE=0

All 22 owner-approved canonical PNGs remained byte-for-byte unchanged. Current canonical SHA-256 values are retained in docs/evidence/m04/manifest.json. The owner master reference was copied non-destructively from b75ee426-9568-4ed6-b35e-140600a7c995.png; it was not used as a source for production art.

## Implementation

Changed M04 files:

    tools/m04_asset_validation.py
    tests/m04_asset_import_probe.gd
    docs/evidence/m04/manifest.json
    docs/evidence/m04/cocktails_contact_sheet.png
    docs/evidence/m04/ui_contact_sheet.png
    docs/evidence/m04/effects_contact_sheet.png
    docs/evidence/m04/environment_reference.png
    docs/evidence/m04/master_reference.png
    docs/evidence/m04/progression_strip_12_slots.png
    coordination/sessions/BCM-M04-R01/CODEX_LOG_V01.md

The Python validator now:
- compares actual PNG sets in cocktails, environment, and UI directories against the required exact sets;
- verifies each canonical file exists, is tracked by Git, is non-empty, and decodes;
- enforces transparent-required policy for L01-L12, UI and To-Go trail assets;
- allows the environment's opaque RGB policy explicitly;
- requires non-empty alpha bounds for transparent assets;
- reports source dimensions, color type, alpha statistics, bbox and SHA-256;
- reports the Best Score/Score source width delta;
- fails if guide_line appears under assets;
- generates the retained evidence package and machine-readable manifest.

The Godot M04 probe now obtains observed PNG counts from actual directories using DirAccess, rather than echoing CANONICAL.size() as both expected and observed. It loads every canonical texture and checks positive dimensions/image availability.

Semantic observations are classified as MANUAL_VISUAL_EVIDENCE in the manifest/log, not as machine PASS.

## Canonical path and metric evidence

    M04_PATH_SET required=22 cocktails=12 environment=1 ui=8 effects=1
    M04_REPO_PATH_SET cocktails=12/12 environment=1/1 ui=8/8
    M04_REPO_PATH_SET PASS scope=cocktails exact=true
    M04_REPO_PATH_SET PASS scope=environment exact=true
    M04_REPO_PATH_SET PASS scope=ui exact=true
    M04_GUIDE_LINE PASS present=false

All 22 assets reported tracked=true and alpha_result=PASS. Important exact metrics:

    cocktails L01-L12: alpha=present; non-empty alpha bbox for every level; transparent pixels 59.3824% to 79.2202%
    environment: 1024x1536, alpha=absent, opaque-allowed, bbox=[0,0,1024,1536]
    logo: 1536x1024, transparent=33.9717%, bbox=[0,17,1519,1024]
    Best Score: 1672x941, transparent=37.0860%, bbox=[28,13,1645,941]
    Score: 1670x941, transparent=40.0561%, bbox=[0,0,1660,905]
    To-Go: 1536x1024, transparent=27.5171%, bbox=[0,0,1529,999]
    Next: 1254x1254, transparent=25.2107%, bbox=[0,47,1253,1246]
    progression: 2170x725, transparent=56.0214%, bbox=[0,9,2170,699]
    launch zone: 1254x1254, transparent=71.2814%, bbox=[0,19,1254,1254]
    danger line: 2172x724, transparent=85.5886%, bbox=[9,35,2162,698]
    To-Go trail: 1774x887, transparent=73.9130%, bbox=[31,19,1754,877]

    M04_PANEL_DIMENSIONS best=1672x941 score=1670x941 match=False delta=[2,0]
    M04_VISUAL_EVIDENCE generated=7 progression_slots_annotated=12 classification=MANUAL_VISUAL_EVIDENCE
    M04_PYTHON_RESULT=PASS
    M04_PYTHON_PROCESS_EXIT_CODE=0

The validator emitted one M04_ASSET PASS line per canonical asset with path, Git tracking, bytes, dimensions, alpha policy/result, transparent/non-transparent counts, bbox and SHA-256. The full machine-readable record is in docs/evidence/m04/manifest.json.

## Retained evidence inventory

Generated evidence hashes:

    cocktails_contact_sheet.png bytes=761290 sha256=094C609468F897FE2B8E6CC6EA29A9A832DCCCEDEA831C23C630C9E57A68DE6B
    ui_contact_sheet.png bytes=1301699 sha256=67C4EE1C653B788AB9968BF4F16B99D06C154ED60C67FAE32A030AC2850493F6
    effects_contact_sheet.png bytes=97261 sha256=E9F724C8EE93E54CD0DA0D459EEE57B0F6279E457DE887C4FB9C614569A2F6DE
    environment_reference.png bytes=2551649 sha256=479FCA4698D0D3F0E819EC878F20CDE1033CC011ED396E48792FDE3072B1D9DF
    master_reference.png bytes=2425782 sha256=04F05BFFE43EDB17097677F7E05FDD1D0A13C0845A3EA9ACADB6F1BD7488FBA3
    progression_strip_12_slots.png bytes=1152165 sha256=ED992360938D99FA1F46D1D33369A2F7CCE9213F9A98F993E2C5D6A65711C14F
    manifest.json bytes=21530 sha256=B5D83ECE06BE1180DF6B1C6CE39305FAB096E8FE18F6AAE347FDDB77BFB061BC

Manual visual inspection of the retained evidence:
- cocktails_contact_sheet.png shows labelled L01-L12 on checkerboard transparency, with distinct glass silhouettes, visible straws and preserved garnish progression;
- ui_contact_sheet.png shows logo, Best Score, Score, To-Go, Next, progression strip, launch zone and danger line; blank dynamic regions are visible in Best/Score/To-Go/Next;
- progression_strip_12_slots.png retains the source strip with twelve individually numbered/outlined visual slot regions;
- environment_reference.png is a direct non-destructive reference of the empty tropical long perspective table;
- effects_contact_sheet.png shows the transparent simplified gold To-Go trail;
- master_reference.png retains the owner master relationship for independent audit.

Cocktail semantic matrix, classified MANUAL_VISUAL_EVIDENCE:
- L01: small rounded yellow/orange citrus tumbler; blue/white straw; citrus slice.
- L02: red short tumbler; red/white straw; cherry.
- L03: tall green lime/mint highball; green/white straw; lime and mint garnish.
- L04: blue martini; striped straw; cherry/lime/leaf/hibiscus tropical garnish.
- L05: orange tropical goblet; straw; orange/pineapple/leaf/hibiscus garnish.
- L06: pink martini; straw and cherry; no added orange/hibiscus claim.
- L07: long orange-yellow highball; red/white straw; orange slice and green leaves.
- L08: blue rounded goblet; yellow/white straw; mint and ice.
- L09: coconut cocktail; blue/white straw; plumeria and leaves.
- L10: pink/magenta premium goblet; yellow/white straw; hibiscus/orange/leaves.
- L11: tall layered red-orange highball; red/white straw; cherry and apple/lime-side garnish.
- L12: pineapple-body cocktail; red/white straw; circular pineapple slice garnish.

The owner-master relationship is explicit: master logo maps to logo asset; left score stack maps to Best Score and Score panels; upper center order maps to To-Go; upper-right preview maps to Next; tabletop cocktails map to L01-L12; bottom progression maps to progression_strip; lower table threshold maps to danger_line; launch marker maps to launch_zone; delivery trail maps to To-Go trail. Master-only decorative signs/text and the historical dotted aiming line are not current separated-asset contract. Later owner direction explicitly forbids guide_line, so it remains absent.

The source dimensions mismatch is retained, not hidden: Best Score width 1672 vs Score width 1670, delta 2 pixels.

## Godot evidence

    godot_console --headless --path . --script res://tests/m04_asset_import_probe.gd
    Godot Engine v4.7.2.stable.official.ed1daf0bf
    M04_GODOT_ASSET_COUNT expected=22 observed=22 cocktails=12 environment=1 ui=8 effects_required=1
    M04_GODOT_PROBE PASS: repository PNG directory counts match canonical scopes
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

## Smoke and hygiene evidence

    godot_console --version
    4.7.2.stable.official.ed1daf0bf
    VERSION_PROCESS_EXIT_CODE=0

    godot_console --headless --quiet --path . --editor --import --quit
    WARNING: Detected another project.godot at res://original_reference. The folder will be ignored.
    IMPORT_PROCESS_EXIT_CODE=0

    godot_console --headless --quiet --path . --quit-after 3
    STARTUP_PROCESS_EXIT_CODE=0

    git diff --check
    M04_DIFF_CHECK_EXIT_CODE=0
    git status --short --branch
    ## main...origin/main
    M04_PRECOMMIT_STATUS shows only the listed M04 files and evidence directory.

No production gameplay, M05, M06 or M07 implementation was introduced in this bounded M04 phase. The original M07 implementation remains historical/current baseline and was not changed by this M04 commit.

## Limitations and audit boundary

- Semantic cocktail shape/garnish, panel blank-region, progression count, environment cleanliness, launch-ring and trail suitability are retained visual evidence classified MANUAL_VISUAL_EVIDENCE; the validator does not mislabel those as machine proof.
- This builder session did not issue the independent audit verdict.
- Owner-master pixel relationship remains subject to independent ChatGPT inspection.
- The import warning about pre-existing original_reference is non-fatal.

## Commit and push

This phase is committed separately before M05 starts. The commit SHA and final equality are recorded after push.


