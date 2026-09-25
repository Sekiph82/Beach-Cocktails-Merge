# BCM-M12 World Map — Final Closure Execution Prompt V01

Read and obey first:

`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_FINAL_CLOSURE_V01.md`

Work on current `main` only.

This is M12 FINAL CLOSURE PREPARATION.

No image generation.
No visual redesign.
No canonical production PNG regeneration.
No M13 implementation.
Do not edit `TASKS.md`.

## Tasks

### 1. Final visual-library validation

Validate the current canonical manifest library:
- all 398 target paths exist;
- PNG decode/dimensions;
- required alpha/transparency;
- no empty/corrupt production asset.

Scan all canonical manifest assets by final SHA/blob identity.

Report every duplicate group and classify:
- intentional semantic reuse;
- invalid semantic reuse.

Required result for closure:
`invalid semantic duplicate groups = 0`.

Do not regenerate anything.

### 2. Validate all 10 V2 table families

Read:
- `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md`
- `docs/ui-assets/TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md`
- `assets/ui_assets/tables/table_geometry_v2.json`

V1 silhouette/mask is historical only.

For all 10 islands verify:
- `gameplay_table.png` = 720x1280 RGBA;
- common V2/R11 structure;
- rear/tabletop placement;
- front tabletop transition ~= y 988.333;
- exactly two visible front legs;
- L01-L12 progression corridor unobstructed;
- overlay aligns with/derives from its island final table;
- shadow matches fixed V2 shadow master/recipe;
- no island-specific geometry drift.

Do not modify table production assets.

### 3. Confirm V02 canonical brand state

Owner selected:
`assets/ui_assets/brand/logo_concept_v02.png`

Current six canonical brand files are accepted:
- `app_icon.png`
- `brand_badge_small.png`
- `brand_wordmark_small.png`
- `legal_logo_mark.png`
- `logo_beach_cocktails_merge.png`
- `splash_logo.png`

Do not restore the old logo.
Do not regenerate brand assets.

Update visual-task documentation only where needed so V02 is recorded as current authority.

### 4. Mark already completed global UI tasks

In:
`coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md`

mark complete:
VA-348, VA-349, VA-350, VA-351, VA-352,
VA-358, VA-359, VA-360, VA-362, VA-367,
VA-370, VA-371, VA-372, VA-373, VA-374, VA-375.

Do not regenerate them.

### 5. Rebuild seven evidence-only contact sheets

Rebuild from CURRENT canonical assets only:

- VA-176 `assets/ui_assets/CONTACT_SHEET_GLOBAL.png`
- VA-177 `assets/ui_assets/CONTACT_SHEET_ISLANDS.png`
- VA-178 `assets/ui_assets/CONTACT_SHEET_MAJOR_SCREENS.png`
- VA-179 `assets/ui_assets/CONTACT_SHEET_SCREENS.png`
- VA-180 `assets/ui_assets/CONTACT_SHEET_SEMANTIC_ICONS.png`
- VA-181 `assets/ui_assets/CONTACT_SHEET_STATEFUL_UI.png`
- VA-182 `assets/ui_assets/CONTACT_SHEET_TABLES.png`

Technical compositing only.
No AI/image-generation call.
No new art.

Mark VA-176 through VA-182 complete after successful rebuild.

### 6. Run focused M12 World Map regression

Verify existing tests for:
- data-driven WorldMapScene;
- OPEN / LOCKED / CURRENT / COMPLETE rendering;
- sequential island lock enforcement;
- navigation boundaries;
- mobile-safe layout;
- save reload/state restoration.

If a real M12 regression exists:
STOP and report it.
Do not broaden scope into unrelated remediation.

### 7. Clean active visual-task documentation

Update:
`coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md`

Use current project truth.

Supersede obsolete assumptions:
- old logo byte-for-byte preservation;
- V1 table silhouette as current authority.

For:
`ui-assets-tasks.md`

do not mass-complete historical branch tasks.
Add only a concise top-level note that it is historical/superseded by the current `main` visual production state and `CODEX_VISUAL_ASSET_TASKS.md`.

### 8. Builder log

Write:

`coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_FINAL_CLOSURE.md`

Keep concise. Include:
- start HEAD;
- changed files;
- manifest validation;
- duplicate scan before/after;
- V2 10-table result;
- V02 brand confirmation;
- contact-sheet result;
- M12 regression result;
- visual tracker result;
- implementation SHA;
- final main HEAD.

Commit/push only:
- seven rebuilt contact sheets;
- necessary visual-task/documentation updates;
- builder log.

Do not modify canonical production PNGs.
Do not edit `TASKS.md`.

Final response:
- implementation SHA
- final main HEAD
- invalid semantic duplicate count
- V2 table validation result
- M12 regression result
- `AWAITING_M12_FINAL_AUDIT`

Then STOP.
