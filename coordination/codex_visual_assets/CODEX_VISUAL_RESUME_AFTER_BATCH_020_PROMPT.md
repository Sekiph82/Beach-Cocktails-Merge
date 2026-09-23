# BEACH COCKTAILS MERGE — CODEX VISUAL RESUME AFTER BATCH 020

Status: RESUME FROM LIVE TRACKER AFTER RATE-LIMIT BLOCK
Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `codex/visual-assets-production`

This prompt is a thin resume launcher over the existing visual-production system.

## Authorities

Read and obey in this order:

1. `coordination/codex_visual_assets/CODEX_VISUAL_PUBLISH_AND_LOG_POLICY.md`
2. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_PROMPT.md`
3. `coordination/codex_visual_assets/CODEX_VISUAL_REMAINING_ASSETS_PROMPT.md`
4. THIS prompt
5. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_MASTER_LIST.md`
6. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md`
7. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_LOG.md`
8. `coordination/codex_visual_assets/CODEX_VISUAL_PRODUCTION_MASTER_LOG.md`

The V04 masters remain the primary visual authority.
V05 production visuals remain rejected and must not be used as style references.

## Current checkpoint

At the time this prompt was created:

- 398 total visual tasks;
- 258 complete;
- 140 unchecked;
- Batch 020 attempted VA-218 through VA-234 and was blocked by HTTP 429 `usage_limit_reached`;
- no affected generation task was falsely marked complete;
- protected VA-319, VA-320 and VA-322 were correctly reconciled as PRESERVE and are complete.

The live tracker is always the source of truth. Recompute the unchecked queue before doing any work.

## Resume frontier

The current unfinished production families are:

- VA-218–VA-228 — Milestones
- VA-229–VA-234 — Pause
- VA-235–VA-244 — Pre-level
- VA-245–VA-260 — Results
- VA-261–VA-266 — Rewarded Ad
- VA-267–VA-279 — Settings
- VA-280–VA-296 — Shop
- VA-297–VA-303 — Social
- VA-304–VA-309 — Splash
- VA-310–VA-318 — Tutorial
- VA-321 — table edge overlay master
- VA-323–VA-330 — Boosters
- VA-331–VA-337 — Gameplay UI
- VA-348–VA-352, VA-358–VA-360, VA-362, VA-367, VA-370–VA-375 — remaining Global UI
- VA-176–VA-182 — contact sheets, DERIVED LAST only

## Execution

Resume with the first live unchecked task, expected to be VA-218.

Work in coherent family-sized visual batches.

For every distinct non-protected production asset:
- use a separate purpose-specific image-generation or image-edit operation;
- use the relevant approved V04 master as direct primary authority whenever supported;
- do not use atlas slicing;
- do not use one generated sheet as source for unrelated final assets;
- do not use V05 art.

For global/screen families, use `main_menu_master.png` as primary authority unless the master list names a more specific approved V04 authority.

After every family:
- inspect all outputs visually;
- verify exact dimensions and alpha contract;
- compare state pairs for semantic distinction;
- update only legitimate tracker rows;
- append both official logs;
- commit exact authorized paths only;
- push only to `codex/visual-assets-production`;
- verify remote paths and branch HEAD before proceeding.

## Rate limit handling

The previous stop was a service limit, not a production failure.

Attempt generation normally now.

If HTTP 429 `usage_limit_reached` appears again:
- do not consume reset credits unless explicitly authorized by the owner;
- do not promote ambiguous partial outputs;
- do not mark affected tasks complete;
- record the exact blocked range in both official logs;
- preserve all completed work;
- publish any legitimate safe non-generation changes;
- stop generation cleanly and report the live remaining count and frontier.

Never replace unavailable image generation with procedural programmer art.

## Contact sheets

VA-176 through VA-182 remain LAST.

Do not generate them with AI.
Derive them from the actual final canonical production assets only after all ordinary production families are complete.

## Finalization

When all legitimate production/preserve tasks are remotely verified complete, derive VA-176–VA-182 and then execute:

`coordination/codex_visual_assets/CODEX_VISUAL_FINALIZATION_PROMPT.md`

Do not run finalization early.

## Git isolation

Never modify, merge, reset, rebase, force-push or push `main`.

Work and publish only on:

`codex/visual-assets-production`

BEGIN BY FETCHING THE REMOTE BRANCH, READING THE LIVE TRACKER, AND RESUMING THE FIRST UNCHECKED PRODUCTION FAMILY.
