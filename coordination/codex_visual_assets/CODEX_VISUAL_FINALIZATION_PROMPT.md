# BEACH COCKTAILS MERGE — CODEX VISUAL FINALIZATION PROMPT

Status: FINAL STATIC VISUAL PRODUCTION QA/PUBLISH BATCH  
Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `codex/visual-assets-production`

This prompt closes the current dedicated Codex visual-production program after all asset-generation tasks are complete.

## 1. Read first

Read and obey, in this order:

1. `coordination/codex_visual_assets/CODEX_VISUAL_PUBLISH_AND_LOG_POLICY.md`
2. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_PROMPT.md`
3. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_MASTER_LIST.md`
4. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md`
5. `coordination/codex_visual_assets/CODEX_VISUAL_PRODUCTION_MASTER_LOG.md`

Do not regenerate already completed/QA-passed assets during finalization unless a final QA check fails.

## 2. Final visual QA

Verify every one of the 398 canonical target paths.

Required:
- every target exists remotely on the visual branch;
- 397 non-protected targets were regenerated under the dedicated system;
- canonical owner logo remains byte-preserved;
- all 12 V04 masters remain unchanged;
- all visuals match the V04 art direction;
- no V05-atlas-looking art remains as accepted final production art;
- isolated assets have correct transparency;
- no baked checkerboards;
- no unintended text/watermarks;
- no malformed objects;
- paired states are semantically distinct;
- small icons remain readable at mobile scale.

## 3. Table QA

For all ten island `gameplay_table.png` assets:
- verify 720×1280 canvas;
- verify table visuals against `TABLE_GEOMETRY_CONTRACT_V2.md` / `table_geometry_v2.json`: R11 playable rail alignment, tabletop-front transition near y=988.333, mandatory front apron + two visible legs, and unobstructed L01-L12 progression area; do NOT use the legacy V1 mask as acceptance authority;
- verify frozen table geometry JSON unchanged;
- verify only material/texture/trim/inlay/lighting varies.

Any geometry mismatch is a finalization failure.

## 4. Cross-library semantic duplication QA

Scan final output hashes.

If unrelated semantic roles have identical bytes, inspect them.
Intentional technical reuse must be explicitly justified in the log.
Invalid semantic duplication must be regenerated before finalization.

Examples that must NOT collapse to identical art:
- primary / secondary / disabled / locked buttons;
- distinct badges with different meanings;
- panel size/type variants;
- star-track checkpoint/chest/fill/marker/panel;
- open/closed chests;
- locked/current/completed level nodes.

## 5. Contact/evidence sheets

Create fresh review-only contact sheets from the final production images:
- BRAND/UI;
- WORLD MAP;
- ISLANDS;
- ISLAND MAP;
- TABLES;
- SCREENS;
- EFFECTS;
- STATEFUL UI;
- MAJOR SCREENS.

These sheets are evidence only. Do not use them as the source artwork.

## 6. Update GitHub logs

Append finalization summary to:
- `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_LOG.md`
- `coordination/codex_visual_assets/CODEX_VISUAL_PRODUCTION_MASTER_LOG.md`

Include:
- exact completed task range;
- total 398/398 target verification;
- generation/derivation actions;
- QA performed;
- rejected/regenerated attempts;
- commit SHA(s);
- remote branch HEAD;
- blockers;
- confirmation that main was untouched.

## 7. Update task tracker

Update:
`coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md`

Mark tasks complete only after exact-path remote existence and QA.

Do not touch root `TASKS.md`.

## 8. Git rules

Work only on:
`codex/visual-assets-production`

Do not touch `main`.
Do not rebase or force-push.
Do not use `git add .`.
Do not use `git add -A`.

Stage exact authorized paths only.

Push only:
`origin/codex/visual-assets-production`

## 9. Mandatory remote verification

After push:
1. fetch `origin/codex/visual-assets-production`;
2. verify all 398 target paths remotely;
3. verify the updated task file and both logs remotely;
4. verify the 12 V04 masters remain unchanged;
5. verify protected logo/table geometry/reference files unchanged;
6. verify `origin/main` was not changed by this work.

Do not claim completion before remote verification.

## 10. Final response to owner

Return:
- canonical asset total: 398 / 398;
- regenerated target count: 397 / 397;
- protected canonical logo: preserved;
- commit SHA(s);
- remote branch HEAD SHA;
- missing targets: none, or exact list;
- confirmation that GitHub logs were updated;
- confirmation that main was untouched.

Provide the FULL LONG GitHub browser URLs to:
- authoritative visual asset log;
- master production log;
- task tracker.

After successful completion and remote verification, consider this static visual-generation program FINALIZED pending independent ChatGPT + owner visual acceptance.

BEGIN FINALIZATION NOW.
