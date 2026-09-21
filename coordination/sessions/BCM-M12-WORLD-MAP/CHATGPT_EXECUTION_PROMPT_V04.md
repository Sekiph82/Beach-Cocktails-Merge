# BCM-M12-WORLD-MAP — Codex Staged Visual Production Prompt V04

Retry visual generation, but DO NOT attempt all 398 assets in one pass.

Read:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V03.md
- coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_STAGED_VISUAL_CRITERIA_V04.md



## WHY V03 WAS BLOCKED

V03 was blocked because it attempted to replace the entire 398-asset visual library in one execution while simultaneously requiring:

- premium illustrated quality matching the two reference boards;
- exact manifest dimensions;
- alpha contracts;
- semantic state pairs;
- 10 distinct island packs;
- full-screen compositions;
- evidence/contact sheets;
- repository-wide validation.

Codex reported that its environment can generate **individual illustrations**, but it could not reliably guarantee the entire 398-asset replacement set with all repository-level technical contracts in one pass without falling back to lower-quality procedural output.

That specific blocker is the reason V04 is staged.

## HOW V04 MUST SOLVE THE V03 BLOCKER

Do **not** evaluate V04 as if you are still responsible for all 398 production assets.

For V04, your job is only to prove that the environment can create **12 premium master images**.

You are explicitly NOT required in this stage to:
- replace the 398-asset library;
- satisfy every final manifest dimension;
- export every transparent state pair;
- derive all runtime icons/panels/effects;
- update the full production manifest;
- validate all final alpha/state contracts;
- integrate the masters into runtime scenes.

Therefore, do not return BLOCKED merely because the complete 398-asset pipeline cannot be guaranteed yet.

Use the available **individual image-generation capability** that V03 itself confirmed exists.

Required production approach:
1. Inspect both mandatory visual-authority boards.
2. When the available image tool supports reference/style images, pass **both boards as visual/style references** for every master generation.
3. Generate the 12 masters one at a time or in small batches. Do not require all 12 to be generated in one monolithic operation.
4. Review each result against the authority boards before accepting it.
5. Regenerate any master that is visibly flatter, more procedural, less detailed, or stylistically inconsistent.
6. Save the accepted PNG masters under `assets/ui_assets/v04_masters/`.
7. Build `CONTACT_SHEET_V04.png` only after all 12 accepted masters exist.
8. Record the exact generation method/model/tool used for each master in the README and log.

For Stage 1, use **720x1280 portrait** as the target master canvas unless the generation tool requires a larger same-ratio source. A larger 9:16 source is acceptable, but export/copy a 720x1280 review master without distorting aspect ratio.

A V04 BLOCKED result is allowed only if the environment truly has **no usable image-generation capability for individual premium illustrations**, or every available generator fails to reach the mandatory visual quality after reasonable retries.

The V03 reason "cannot guarantee the complete 398-asset pipeline" is **not a valid V04 blocker**.


MANDATORY VISUAL AUTHORITIES:

https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board_remediation_v01.png

https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board.png

Generate ONLY these 12 final-quality master visuals:

1. Sunny Cove environment master
2. Tiki Island environment master
3. Azure Bay environment master
4. Coconut Beach environment master
5. Sunset Island environment master
6. Party Beach environment master
7. Frozen Paradise environment master
8. Volcano Bay environment master
9. Billionaire Island environment master
10. Final Island environment master
11. World Map master composition
12. Main Menu master composition

Requirements:
- premium painterly/cartoon-realistic mobile-game art
- match the two authority boards in polish, lighting, depth, material richness and tropical/resort art direction
- no procedural/Pillow primitive final art
- no programmer art
- no generic gradients or debug visuals
- do not overwrite current runtime assets

Store only under:
assets/ui_assets/v04_masters/

Also create:
- CONTACT_SHEET_V04.png
- README.md

If your environment cannot create these 12 masters at the required quality, STOP and report BLOCKED.

If successful, do NOT continue into the 398-asset derivation/export stage yet.

Write:
coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V04.md

Return:
- log URL
- implementation SHA
- number of masters generated
- contact sheet path
- generation method
- AWAITING_AUDIT

Then STOP.


## TABLE VISUAL NOTE

When later generating any table visuals/skins, derive them strictly from the existing frozen table geometry.

Do not invent or alter the table silhouette, playable-area shape, rear edge, front corners, perspective envelope, mask, or boundary geometry.

Any table visual must be generated/composited to fit the canonical table geometry exactly; only material, texture, lighting and island-specific surface treatment may change.
