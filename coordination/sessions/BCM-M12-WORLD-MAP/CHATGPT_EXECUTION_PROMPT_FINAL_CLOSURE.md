# BCM-M12 Final Closure Preparation

Repo:
https://github.com/Sekiph82/Beach-Cocktails-Merge

Work on current main only.

Task:
BCM-M12 FINAL CLOSURE PREPARATION

This is NOT an image-generation task.
This is NOT a visual redesign task.
This is NOT M13 implementation.

Do not modify any canonical PNG asset.

Goal:
Verify the final current M12 World Map + visual asset state and prepare it for independent ChatGPT closure audit.

## 1. Final visual library validation

Validate the CURRENT canonical asset library.

Check:
- all 398 manifest target paths exist
- PNGs decode
- declared dimensions are correct
- required alpha/transparency is valid
- no unintended empty/corrupt production asset exists

Scan ALL canonical manifest assets by final SHA/blob identity.

Report every duplicate group.

Classify duplicates as:
- intentional semantic reuse
- invalid semantic reuse

PASS requirement:
invalid semantic duplicate groups = 0

Do NOT regenerate anything.

## 2. V2 table validation

The old V1 table mask is NOT current authority.

Read:
- docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md
- docs/ui-assets/TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md
- assets/ui_assets/tables/table_geometry_v2.json

Validate all 10 island table families against current V2 rules.

For every island verify:
- gameplay_table.png = 720x1280 RGBA
- same V2/R11 structural geometry
- rear/tabletop position preserved
- front tabletop transition ~= y 988.333
- exactly two visible legs
- progression corridor remains unobstructed
- table_edge_overlay matches its own final gameplay_table
- gameplay_table_shadow matches the fixed V2 shadow master/recipe

Do NOT use the legacy V1 silhouette mask as acceptance authority.
Do NOT modify table assets.

## 3. Brand state

The owner selected:
assets/ui_assets/brand/logo_concept_v02.png

The six CURRENT canonical brand files derived from V02 are now the accepted brand state:
- assets/ui_assets/brand/app_icon.png
- assets/ui_assets/brand/brand_badge_small.png
- assets/ui_assets/brand/brand_wordmark_small.png
- assets/ui_assets/brand/legal_logo_mark.png
- assets/ui_assets/brand/logo_beach_cocktails_merge.png
- assets/ui_assets/brand/splash_logo.png

Do NOT restore the old protected owner-logo bytes.
Do NOT regenerate brand assets.

Update visual-task documentation only where necessary so future runs understand V02 is now canonical.

## 4. Global UI task state

The following assets were already regenerated individually and must now be marked complete in:
coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md

VA-348
VA-349
VA-350
VA-351
VA-352
VA-358
VA-359
VA-360
VA-362
VA-367
VA-370
VA-371
VA-372
VA-373
VA-374
VA-375

Do not regenerate them.

## 5. Contact sheets

Rebuild these seven evidence-only contact sheets from the CURRENT canonical assets:
- VA-176 assets/ui_assets/CONTACT_SHEET_GLOBAL.png
- VA-177 assets/ui_assets/CONTACT_SHEET_ISLANDS.png
- VA-178 assets/ui_assets/CONTACT_SHEET_MAJOR_SCREENS.png
- VA-179 assets/ui_assets/CONTACT_SHEET_SCREENS.png
- VA-180 assets/ui_assets/CONTACT_SHEET_SEMANTIC_ICONS.png
- VA-181 assets/ui_assets/CONTACT_SHEET_STATEFUL_UI.png
- VA-182 assets/ui_assets/CONTACT_SHEET_TABLES.png

These are technical composites only.

NO image generation.
NO new art.
NO AI redraw.

Use current canonical assets as source pixels.

Mark VA-176–VA-182 complete after successful generation.

## 6. World Map M12 regression

Run the existing focused M12 World Map tests.

Verify at minimum:
- data-driven WorldMapScene
- island state rendering
- OPEN / LOCKED / CURRENT / COMPLETE behavior
- sequential island lock enforcement
- navigation boundaries
- mobile-safe layout
- save reload/state restoration

Do not change runtime behavior unless a test exposes an actual M12 regression.

If a regression exists:
STOP and report it.
Do not silently remediate unrelated code.

## 7. Visual task tracker cleanup

Update:
coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md

using CURRENT project truth.

Mark completion-gate items complete only when directly proven by this run.

Remove/supersede obsolete assumptions such as:
- old canonical logo must remain byte-for-byte unchanged
- V1 table silhouette is current table authority

V02 brand state and V2 table contract are current authority.

For:
ui-assets-tasks.md

do NOT attempt to complete all historical branch tasks.

Add only a concise top-level note that this document is historical/superseded by the current main visual production state and CODEX_VISUAL_ASSET_TASKS.md.

## 8. Governance

DO NOT EDIT:
TASKS.md

Codex is not allowed to close M12 itself.

Independent ChatGPT audit will decide closure.

Do not create M13 code.
Do not start IslandMapScene work.

## 9. Output

Write:
coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_FINAL_CLOSURE.md

Keep it concise.

Include:
- start HEAD
- changed files
- manifest validation result
- invalid duplicate groups before/after
- 10-table V2 validation result
- brand V02 canonical-state confirmation
- contact-sheet result
- M12 regression result
- visual task tracker result
- final commit SHA
- final main HEAD

Commit and push only:
- rebuilt contact sheets
- necessary visual task/documentation updates
- final closure log

Do not modify canonical production PNGs.

Final response must be:
- implementation SHA
- final main HEAD
- invalid semantic duplicate count
- V2 table validation result
- M12 regression result
- AWAITING_M12_FINAL_AUDIT

Then STOP.
