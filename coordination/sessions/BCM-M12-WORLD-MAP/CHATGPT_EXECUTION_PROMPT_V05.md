# BCM-M12-WORLD-MAP — Full 398-Asset Sequential Regeneration Prompt V05

Execute this ONLY AFTER V04 has successfully generated and owner/ChatGPT has visually accepted the 12 master images.

V04 is the visual-style proof stage.
V05 is the production stage.

## GOAL

Regenerate the complete visual asset library represented by:
- `assets/ui_assets/ASSET_MANIFEST.json`
- `docs/ui-assets/FULL_VISUAL_ASSET_MANIFEST_V1.md`

The current library contains 398 PNG visual assets.

V05 must regenerate the complete manifest-covered visual library **asset by asset, one by one**.

Do not stop after a sample, subset, family, or contact sheet.
Do not reinterpret this as a 12-master-only task.
Do not replace the full library with procedural/Pillow programmer art.

## REQUIRED INPUTS

Read first:
- AGENTS.md
- TASKS.md
- coordination/AUDIT_POLICY.md
- coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V03.md
- coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V04.md
- coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_EXECUTION_PROMPT_V04.md
- assets/ui_assets/ASSET_MANIFEST.json
- docs/ui-assets/FULL_VISUAL_ASSET_MANIFEST_V1.md
- assets/ui_assets/README.md

Mandatory visual authorities:
1. https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board_remediation_v01.png
2. https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board.png

Mandatory V04 style anchors:
- all 12 accepted images under `assets/ui_assets/v04_masters/`
- `assets/ui_assets/v04_masters/CONTACT_SHEET_V04.png`

These references together define the visual quality and style for every V05 production asset.

## IMPORTANT: V04 DOES NOT REDUCE THE 398-ASSET OBLIGATION

The 12 V04 masters are concept/style masters stored under `assets/ui_assets/v04_masters/`.
They are not a substitute for the 398 manifest-covered production assets.

Therefore V05 must still iterate through the full manifest and regenerate every production visual path required by the 398-asset library.

If a V04 master directly corresponds to a production asset, use it as source/reference and derive the production asset from it, but still produce the correct final file at the manifest path with the required dimensions/alpha contract.


## V04 MASTER STYLE LOCK — NON-NEGOTIABLE

The owner has visually approved the 12 V04 master images and explicitly states that they are very good.

From this point onward, the 12 approved V04 masters are the **primary visual style authority** for all remaining V05 production assets.

All remaining assets must match the V04 masters **as closely and consistently as possible**, not merely share a loose theme.

Required consistency includes:
- rendering style;
- painterly/cartoon-realistic finish;
- lighting model and contrast;
- color treatment;
- material richness;
- depth and atmospheric perspective;
- edge treatment;
- highlight/shadow behavior;
- decorative density;
- tropical/resort visual language;
- premium mobile-game polish;
- overall visual sophistication.

Do not introduce a new art style, alternate rendering language, flatter UI treatment, cheaper vector treatment, simplified programmer-art treatment, or unrelated visual family for any later asset.

When generating each asset, use the relevant V04 master(s) as direct visual/style references whenever the image-generation tool supports reference inputs.

For island-specific assets, the corresponding island V04 master is the first visual reference.
For global/shared assets, use the V04 World Map/Main Menu masters plus the two original authority boards as the governing visual references.

If a newly generated asset visibly looks like it belongs to a different game than the approved V04 masters, it must be rejected and regenerated.

The target is not 'similar enough'. The target is **one visually unified game whose remaining 398 assets look like they were created by the same art team, in the same production pass, from the same approved V04 art direction**.

V04 masters must not be redrawn, restyled, degraded, or replaced during V05. They are frozen approved style anchors.

## SEQUENTIAL PRODUCTION RULE

Process assets one by one.

For each manifest entry:
1. read its target path, dimensions, alpha expectation, island id, intended screen use and state role;
2. determine which approved V04 master(s) and/or authority board best govern its art direction;
3. generate or derive the final-quality visual;
4. resize/crop/composite only as needed to meet the exact manifest dimensions;
5. preserve or create transparency exactly as required;
6. validate the asset immediately;
7. compare it visually against its sibling/state pair and V04 masters;
8. only then proceed to the next asset.

Do not batch hundreds of files through one procedural generator.
Small batches are allowed only when every result is individually reviewed and validated.

## QUALITY BAR

Every production visual must belong to the same premium Beach Cocktails Merge visual family:
- painterly/cartoon-realistic 2D mobile-game art;
- premium tropical/resort atmosphere;
- cinematic lighting;
- rich material definition;
- strong depth;
- polished silhouettes;
- commercial casual-mobile finish;
- no generic stock look;
- no flat programmer art;
- no debug visual language;
- no low-effort generic gradients;
- no repeated primitive circles/rectangles pretending to be final art.

## NO PROCEDURAL FINAL-ART FALLBACK

Pillow/procedural code may be used only for:
- alpha cleanup;
- masks;
- cropping;
- resizing;
- composition;
- contact sheets;
- metadata;
- validation.

It must not be the primary final-art generator.

If one asset cannot be generated acceptably, retry that asset or its family. Do not downgrade the entire library to procedural art.

## ALL VISUAL FAMILIES ARE REQUIRED

Regenerate all manifest-covered production visuals including:
- brand/global UI;
- reusable panels/buttons/tabs/badges;
- currency/rewards/chests;
- boosters;
- Main Menu;
- World Map;
- Island Map;
- all 10 island packs;
- pre-level;
- gameplay campaign HUD;
- merge/order/timer/combo/win/confetti/milestone/trail effects;
- Pause;
- Win / Level Complete;
- Fail / Time Up;
- Milestone Reward;
- Island Complete;
- Star Reward Track;
- Shop;
- Rewarded Ad;
- Daily Reward;
- Settings;
- Tutorial/Onboarding;
- notifications/status;
- leaderboard/social;
- tables/table skins;
- all opposite-state variants.

## TEN ISLAND PACKS

Regenerate complete production packs for:
1. Sunny Cove
2. Tiki Island
3. Azure Bay
4. Coconut Beach
5. Sunset Island
6. Party Beach
7. Frozen Paradise
8. Volcano Bay
9. Billionaire Island
10. Final Island

Each island must be distinct at a glance while still matching the same game.

## TABLE VISUALS: STRICT GEOMETRY RULE

Every table visual/skin must be created strictly from the existing frozen canonical table geometry.

Do not invent, alter, reinterpret, crop away, or reshape:
- table silhouette;
- playable-area shape;
- rear edge;
- front corners;
- perspective envelope;
- table mask;
- boundary geometry;
- canonical table geometry JSON.

Generate island-specific table materials/textures/lighting first if necessary, then mask/composite them into the canonical table silhouette.

The final table asset for every island must fit the frozen geometry exactly, pixel-for-pixel in silhouette/mask.

Only these may vary:
- material;
- texture;
- color;
- island-specific decoration within the allowed visible table surface;
- lighting/highlight treatment.

Geometry must remain identical across all island tables.

## PROTECTED ASSETS

Do not redraw or overwrite:
- `assets/ui_assets/source/style_reference_board_remediation_v01.png`
- `assets/ui_assets/source/style_reference_board.png`
- canonical owner-supplied Beach Cocktails Merge logo artwork itself;
- canonical table geometry JSON/masks/silhouette masters.

Logo variants may only use the canonical owner logo with technical alpha/padding/size treatment.

## STATEFUL UI

Every opposite state must be visually and semantically distinct:
- locked / unlocked;
- current / normal;
- active / inactive;
- on / off;
- claimed / unclaimed;
- open / closed;
- complete / incomplete;
- enabled / disabled;
- filled / empty;
- win / fail where paired.

No byte-identical opposite-state files.

## FILE-BY-FILE PROGRESS TRACKING

Create:
`assets/ui_assets/V05_ASSET_REGEN_STATUS.csv`

Include one row per manifest visual asset with at least:
- index;
- path;
- category;
- dimensions;
- alpha_expected;
- generation method/model/tool;
- source master/reference;
- validation result;
- visual QA result;
- final SHA256;
- status.

Valid final status values:
- PASS
- RETRY_REQUIRED
- BLOCKED

Do not claim V05 completion unless every production asset row is PASS.

## CONTACT SHEETS AND EVIDENCE

After all assets are regenerated, rebuild:
- GLOBAL contact sheet;
- BRAND/UI contact sheet;
- WORLD MAP contact sheet;
- ISLANDS contact sheet;
- ISLAND MAP contact sheet;
- TABLES contact sheet;
- SCREENS contact sheet;
- EFFECTS contact sheet;
- STATEFUL UI contact sheet;
- MAJOR SCREENS contact sheet.

Also produce representative 720x1280 final compositions for:
- Main Menu;
- World Map;
- Sunny Cove gameplay;
- Tiki Island gameplay;
- Party Beach gameplay;
- Frozen Paradise gameplay;
- Billionaire Island gameplay;
- Pre-level;
- Win;
- Fail;
- Shop;
- Daily Reward;
- Settings.

## MANIFEST / METADATA

After successful regeneration:
- update `ASSET_MANIFEST.json` hashes/source-method metadata;
- update `ASSET_DIMENSIONS.csv` if needed;
- keep manifest path coverage complete;
- verify every declared PNG exists and decodes;
- verify required alpha contracts;
- verify table geometry equality;
- verify canonical logo preservation;
- verify reference-board preservation.

## REGRESSION

Do not alter accepted gameplay behavior.

Run relevant visual validators and active M01-M12 regressions required by repo governance after asset replacement/integration.

## FAILURE POLICY

Do not use the V03 blocker 'cannot guarantee all 398 in one pass' as a reason to stop.

V05 is explicitly designed to solve that problem by processing the library sequentially.

If a specific asset or family is blocked:
- record the exact asset path;
- record the exact reason;
- continue with other independent assets where safe;
- return to blocked assets after retries;
- do not mark overall V05 complete until all required assets pass.

If the environment truly cannot generate any premium individual visuals, report BLOCKED immediately.

## OUTPUT

Write:
`coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V05.md`

The log must include:
- total manifest visual asset count;
- total regenerated PASS count;
- retry count;
- blocked count;
- exact blocked paths if any;
- generation method/model/tool by family;
- all contact-sheet paths;
- table-geometry validation proof;
- canonical logo/reference-board preservation proof;
- manifest validation result;
- regression result;
- implementation SHA.

Push completed production work according to repo governance.

Do not edit root `TASKS.md`.

Return only:
- log URL
- implementation SHA
- total PASS / total required assets
- retry count
- blocked count
- validation result
- regression result
- AWAITING_AUDIT

Then STOP.