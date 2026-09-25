# BCM-M12 World Map — Final Closure Preparation Execution Prompt

Use the locked criteria:
coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_CRITERIA_FINAL_CLOSURE.md

Repository:
https://github.com/Sekiph82/Beach-Cocktails-Merge

Branch:
main

## Task

Prepare M12 for independent final audit.

This is NOT image generation.
This is NOT visual redesign.
This is NOT M13 implementation.

Do not modify canonical production PNG assets.
Do not edit TASKS.md.

## Execute

1. Validate all 398 current manifest target assets:
   - existence
   - decode
   - dimensions
   - alpha/transparency where required
   - non-empty/corrupt status

2. Scan the whole canonical manifest by final SHA/blob identity.
   - report every duplicate group
   - classify intentional semantic reuse vs invalid semantic reuse
   - PASS requires invalid semantic duplicate count = 0
   - do not regenerate assets

3. Validate all 10 table families against CURRENT V2 authority only:
   - docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md
   - docs/ui-assets/TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md
   - assets/ui_assets/tables/table_geometry_v2.json
   - 720x1280 RGBA
   - same V2/R11 geometry
   - rear y ~= 398.333
   - front transition y ~= 988.333
   - center x=360
   - exactly two visible legs
   - progression corridor unobstructed
   - overlay consistent with final gameplay_table
   - shadow consistent with fixed V2 recipe/master
   - legacy V1 mask is NOT acceptance authority

4. Confirm current V02 brand authority:
   selected source = assets/ui_assets/brand/logo_concept_v02.png
   canonical six current brand outputs are the active brand family.
   Do not restore the old logo.
   Do not regenerate brand assets.

5. In coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md:
   mark proven complete:
   VA-348, VA-349, VA-350, VA-351, VA-352,
   VA-358, VA-359, VA-360, VA-362, VA-367,
   VA-370, VA-371, VA-372, VA-373, VA-374, VA-375.

6. Rebuild these seven evidence-only contact sheets from CURRENT canonical source pixels:
   - VA-176 assets/ui_assets/CONTACT_SHEET_GLOBAL.png
   - VA-177 assets/ui_assets/CONTACT_SHEET_ISLANDS.png
   - VA-178 assets/ui_assets/CONTACT_SHEET_MAJOR_SCREENS.png
   - VA-179 assets/ui_assets/CONTACT_SHEET_SCREENS.png
   - VA-180 assets/ui_assets/CONTACT_SHEET_SEMANTIC_ICONS.png
   - VA-181 assets/ui_assets/CONTACT_SHEET_STATEFUL_UI.png
   - VA-182 assets/ui_assets/CONTACT_SHEET_TABLES.png

   Technical composition only.
   No image generation.
   Mark VA-176..VA-182 complete after successful rebuild.

7. Run existing focused M12 World Map regression tests:
   - data-driven WorldMapScene
   - island state rendering
   - OPEN/LOCKED/CURRENT/COMPLETE
   - sequential lock enforcement
   - navigation boundaries
   - mobile-safe layout
   - save reload/state restoration

   If an actual M12 regression appears, STOP and report it.
   Do not silently broaden scope.

8. Tracker cleanup:
   - update coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md only where proven
   - supersede obsolete old-logo preservation and V1-table-authority completion assumptions
   - add a concise top-level historical/superseded note to ui-assets-tasks.md
   - do not rewrite the historical file
   - DO NOT EDIT TASKS.md

9. Write:
coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_FINAL_CLOSURE.md

Keep it concise. Include:
- start HEAD
- changed files
- manifest validation result
- invalid duplicate groups before/after
- 10-table V2 validation
- V02 brand-state confirmation
- contact-sheet result
- M12 regression result
- visual tracker result
- implementation SHA
- final main HEAD

## Commit boundary

Commit/push only:
- seven rebuilt contact sheets
- necessary visual tracker/documentation updates
- final closure log

Do not modify canonical production PNGs.
Do not edit TASKS.md.
Do not start M13.

Final response:
- implementation SHA
- final main HEAD
- invalid semantic duplicate count
- V2 table validation result
- M12 regression result
- AWAITING_M12_FINAL_AUDIT

Then STOP.
