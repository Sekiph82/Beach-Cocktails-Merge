# BCM-M12 World Map — Final Closure Audit Criteria

Status: LOCKED BEFORE EXECUTION
Milestone: M12
Audit authority: ChatGPT independent audit after Codex execution
Repository: https://github.com/Sekiph82/Beach-Cocktails-Merge
Branch: main

## Purpose

Close M12 only if the current World Map implementation and the final visual-asset library satisfy the current project truth.

This is a closure audit. It is not an image-generation pass and not an M13 implementation pass.

## Locked acceptance criteria

### A. Canonical visual library

1. All 398 manifest target paths exist.
2. Declared PNG assets decode successfully.
3. Declared dimensions match the manifest/task metadata.
4. Required transparent assets contain usable alpha.
5. No canonical production asset is empty/corrupt.
6. All canonical manifest assets are scanned for duplicate final SHA/blob identity.
7. Every duplicate group is classified as either intentional semantic reuse or invalid semantic reuse.
8. PASS requires invalid semantic duplicate count = 0.

### B. V2 table family

Current table authority:
- docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md
- docs/ui-assets/TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md
- assets/ui_assets/tables/table_geometry_v2.json

The legacy V1 silhouette/mask is historical only and must not be used as current acceptance authority.

For all 10 island table families verify:
1. gameplay_table.png is 720x1280 RGBA.
2. V2/R11 structural geometry is preserved.
3. Rear tabletop position remains near y=398.333.
4. Front tabletop art transition remains near y=988.333.
5. Perspective centerline remains x=360.
6. Exactly two visible front legs/supports exist.
7. The L01-L12 progression corridor remains unobstructed.
8. table_edge_overlay.png is consistent with the final table geometry/source pixels.
9. gameplay_table_shadow.png matches the fixed V2 shadow recipe/master.
10. No runtime physics was altered to accommodate artwork.

### C. Current brand authority

Owner selected:
assets/ui_assets/brand/logo_concept_v02.png

The current six canonical brand outputs are accepted as the new brand family subject to this audit:
- assets/ui_assets/brand/app_icon.png
- assets/ui_assets/brand/brand_badge_small.png
- assets/ui_assets/brand/brand_wordmark_small.png
- assets/ui_assets/brand/legal_logo_mark.png
- assets/ui_assets/brand/logo_beach_cocktails_merge.png
- assets/ui_assets/brand/splash_logo.png

The historical requirement that the previous owner logo remain byte-for-byte unchanged is superseded.

### D. Global UI completion state

The following items must be represented as completed in the active visual tracker if their final files validate:
VA-348, VA-349, VA-350, VA-351, VA-352,
VA-358, VA-359, VA-360, VA-362, VA-367,
VA-370, VA-371, VA-372, VA-373, VA-374, VA-375.

### E. Contact sheets

Rebuild from CURRENT canonical assets only:
- VA-176 CONTACT_SHEET_GLOBAL.png
- VA-177 CONTACT_SHEET_ISLANDS.png
- VA-178 CONTACT_SHEET_MAJOR_SCREENS.png
- VA-179 CONTACT_SHEET_SCREENS.png
- VA-180 CONTACT_SHEET_SEMANTIC_ICONS.png
- VA-181 CONTACT_SHEET_STATEFUL_UI.png
- VA-182 CONTACT_SHEET_TABLES.png

These are evidence composites only. No AI image generation is allowed for them.

### F. M12 World Map regression

Existing M12 focused tests must pass for:
1. data-driven WorldMapScene;
2. island OPEN / LOCKED / CURRENT / COMPLETE rendering;
3. sequential island lock enforcement;
4. navigation boundaries;
5. mobile-safe layout;
6. save reload/state restoration.

A newly exposed M12 regression blocks closure.

### G. Tracker/documentation truth

1. coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md must reflect current proven visual state.
2. Obsolete V1 table-authority and old-logo-preservation assumptions must not remain as active completion requirements.
3. ui-assets-tasks.md may be marked historical/superseded, but Codex must not rewrite its entire historical plan.
4. TASKS.md must NOT be edited by Codex.
5. TASKS.md will be updated by ChatGPT only after independent audit.

## Scope restrictions

Codex must not:
- generate or redesign canonical visual assets;
- modify canonical production PNGs;
- modify TASKS.md;
- begin M13;
- change accepted core gameplay/physics;
- self-declare M12 closed.

## Audit verdicts

AUDITED_PASS:
All locked criteria pass. ChatGPT may then update TASKS.md, close M12, and advance project state to M13.

CHANGES_REQUIRED:
Any locked blocker remains. ChatGPT records the blocker and TASKS.md stays on M12.
