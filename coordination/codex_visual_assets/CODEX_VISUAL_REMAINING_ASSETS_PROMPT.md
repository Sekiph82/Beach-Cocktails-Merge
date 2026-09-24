# SUPERSEDED — DO NOT EXECUTE

This historical prompt contains V1 table-geometry/mask rules and is not valid for current table production.

Current mandatory authority:
- https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V2.md
- https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/tables/table_geometry_v2.json

Do not execute this prompt unless the owner explicitly requests the historical workflow.

---

# BEACH COCKTAILS MERGE — CODEX VISUAL ASSET CONTINUATION / REMAINING PRODUCTION PROMPT

Status: RESUME REMAINING VISUAL PRODUCTION AFTER BATCH 009
Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `codex/visual-assets-production`

This prompt CONTINUES the existing dedicated Codex visual-production system. It does not replace the original production authority.

## 0. Current checkpoint

At the time this continuation prompt was issued:

- remote visual branch HEAD before this prompt file: `ec74d89f3ceb91cab8329ed2d81c90162c1f8a2d`;
- 398 total tracker tasks exist;
- 115 are checked complete;
- 283 remain unchecked;
- Batch 009 attempted Final Island VA-063 through VA-075 but was blocked by HTTP 429 `usage_limit_reached`;
- no Final Island raw output from that blocked attempt was promoted to canonical paths;
- no Final Island task was checked complete.

The task tracker, not this static count, is the live source of truth at execution time.

## 1. Read and obey in this order

1. `coordination/codex_visual_assets/CODEX_VISUAL_PUBLISH_AND_LOG_POLICY.md`
2. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_PROMPT.md`
3. THIS continuation prompt
4. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_MASTER_LIST.md`
5. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_TASKS.md`
6. `coordination/codex_visual_assets/CODEX_VISUAL_ASSET_LOG.md`
7. `coordination/codex_visual_assets/CODEX_VISUAL_PRODUCTION_MASTER_LOG.md`

The original Codex visual-production prompt remains the primary production specification.
This continuation prompt clarifies resume behavior, protected-task conflicts, and remaining-work ordering.

## 2. Dynamic scope: ONLY unfinished work

Before generating anything:

1. fetch `origin/codex/visual-assets-production`;
2. confirm current branch is exactly `codex/visual-assets-production`;
3. read the current task tracker;
4. build the execution queue from tasks that are STILL `[ ]`;
5. do NOT regenerate a task already marked `[x]` unless remote verification proves its canonical output is missing or fails required QA.

At the checkpoint above, the unchecked ranges were:

- VA-001–VA-004
- VA-006
- VA-063–VA-101
- VA-115–VA-337
- VA-348–VA-352
- VA-358–VA-360
- VA-362
- VA-367
- VA-370–VA-375

These ranges are informational only. Recompute from the live tracker before execution.

Already completed batches must remain untouched unless a concrete QA failure is discovered.

## 3. Absolute visual authority

The 12 owner-approved V04 masters remain PRIMARY and NON-NEGOTIABLE visual authority.

The V05 production visuals remain OWNER-REJECTED and must NOT be used as style references.

Every newly produced asset must match the same premium painterly/cartoon-realistic mobile-game production family as V04:
- same renderer feel;
- same lighting quality;
- same material richness;
- same polish;
- same tropical-resort visual language;
- same small-screen readability.

Reject and regenerate output that looks:
- flatter;
- cheaper;
- generic;
- vector-like;
- procedural;
- dashboard-like;
- atlas-derived;
- inconsistent with the relevant V04 master.

## 4. Separate operation rule remains mandatory

For every DISTINCT non-protected final asset:

- use a separate purpose-specific image-generation or image-edit operation;
- use the relevant V04 master directly as the primary image/style reference whenever supported;
- do not use one atlas/sprite sheet as production source for unrelated final assets;
- do not generate one sheet and crop it into many semantically different assets;
- do not use V05 art as a shortcut;
- do not promote unlabelled raw outputs whose asset-role mapping is uncertain.

Each final asset needs its own semantic identity and QA.

## 5. CRITICAL protected-task reconciliation

The master/task list contains three rows labelled `Generate` that conflict with the protected-asset rules in the primary prompt.

The protected rule WINS.

### NEVER regenerate or overwrite these:

- VA-319 → `assets/ui_assets/source/style_reference_board.png`
- VA-320 → `assets/ui_assets/source/style_reference_board_remediation_v01.png`
- VA-322 → `assets/ui_assets/tables/table_silhouette_mask.png`

For these three tasks:

1. verify the current remote canonical file exists;
2. verify it has not been changed by dedicated visual production;
3. DO NOT modify its bytes;
4. update only the Codex visual task tracker wording from `Generate` to `PRESERVE` if needed;
5. mark it complete only after preservation verification;
6. log the preservation evidence.

Also preserve:
- VA-005 canonical owner logo;
- all 12 V04 masters;
- `assets/ui_assets/tables/table_geometry_v1.json`;
- accepted cocktails under `assets/cocktails/**`;
- all other protected authorities named by the primary prompt.

### VA-321 is NOT the protected silhouette mask

VA-321 `assets/ui_assets/tables/table_edge_overlay_master.png` remains a production target.

Generate/edit it as a distinct asset, but preserve all frozen table geometry constraints.

## 6. Brand tasks VA-001–VA-004 and VA-006

The canonical owner logo VA-005 is the brand identity authority.

For:
- app icon;
- small brand badge;
- small wordmark;
- legal logo mark;
- splash logo;

prefer protected technical derivation from the canonical owner logo where the semantic role permits it:
- crop;
- pad;
- resize;
- alpha treatment;
- layout adaptation;
- non-destructive framing.

Do not casually re-illustrate the brand and do not introduce a second logo identity.

If a role genuinely needs generated supporting artwork, keep the owner logo itself visually faithful and use V04 main-menu art direction for the surrounding treatment.

## 7. Contact sheets VA-176–VA-182 are DERIVED EVIDENCE

Do NOT use image generation to invent contact sheets.

Do NOT build them early.

VA-176 through VA-182 must be created LAST, from the actual final canonical production assets after those assets are complete.

They are review/evidence composites only:
- GLOBAL
- ISLANDS
- MAJOR SCREENS
- SCREENS
- SEMANTIC ICONS
- STATEFUL UI
- TABLES

Contact sheets must never become source artwork for production assets.

When derived successfully, the tracker may be updated to reflect the actual derivation semantics.

## 8. Resume order

Work autonomously in visual-only batches.

Preferred continuation order:

### A. Resume the blocked island batch
- Final Island VA-063–VA-075 using `final_island_master.png`.

### B. Finish the remaining island packs
One island per meaningful publish batch:
- Frozen Paradise VA-076–VA-088
- Party Beach VA-089–VA-101
- Sunset Island VA-115–VA-127
- Tiki Island VA-128–VA-140
- Volcano Bay VA-141–VA-153

Use only that island's V04 master as the primary visual authority.

### C. World Map
- VA-154–VA-175
- primary authority: `world_map_master.png`

### D. Brand
- unfinished VA-001–VA-004 and VA-006
- canonical owner logo + `main_menu_master.png`

### E. Effects
- VA-183–VA-196

### F. Screens
Complete unfinished screen families in coherent batches:
- Daily Reward
- Main Menu
- Milestones
- Pause
- Pre-level
- Results
- Rewarded Ad
- Settings
- Shop
- Social
- Splash
- Tutorial

### G. Table master / boosters / gameplay / remaining global UI
- VA-321
- VA-323–VA-337
- remaining unchecked global UI tasks VA-348–VA-375

### H. Protected preservation reconciliation
- VA-319
- VA-320
- VA-322

### I. Contact sheets LAST
- VA-176–VA-182

Recompute unchecked tasks between batches and skip anything already legitimately completed.

## 9. Island table geometry contract

For every island `gameplay_table.png`:

- canvas exactly 720x1280;
- canonical table silhouette alpha must match `table_silhouette_mask.png` pixel-for-pixel;
- frozen geometry may not change;
- perspective envelope may not change;
- front corners may not change;
- rear edge may not change;
- playable-area shape may not change.

Only material, texture, trim, inlay, surface decoration and lighting may vary.

A table with beautiful art but wrong geometry FAILS.

## 10. 429 / generator-limit behavior

The previous run was blocked by HTTP 429 `usage_limit_reached`.

If image generation is available now, continue normally.

If the generator returns 429 again:

- do NOT consume reset credits unless the owner has explicitly authorized that;
- do NOT promote ambiguous/unlabelled partial outputs;
- do NOT mark affected generation tasks complete;
- log the exact blocked task/range and service response;
- preserve all already completed work;
- continue only independent NON-generation work that is safe and meaningful, such as preservation verification or deterministic contact-sheet work when its prerequisites are actually complete;
- publish any legitimate completed non-generation work under the normal policy;
- report the exact remaining queue and blocker.

Do not fabricate completion and do not substitute procedural programmer art for unavailable generation.

## 11. Per-asset QA remains mandatory

For each generated final:

- exact canonical path;
- exact dimensions;
- correct alpha contract;
- correct V04 family;
- correct island/global identity;
- no checkerboard;
- no white/black matte;
- no accidental text;
- no watermark;
- no malformed object;
- no extra object;
- no semantic duplication;
- mobile readability.

For state pairs compare side by side:
- locked/unlocked;
- active/inactive;
- current/normal;
- complete/incomplete;
- open/closed;
- filled/empty;
- enabled/disabled;
- claimed/unclaimed.

If a candidate fails, reject it and regenerate with one targeted correction.

## 12. Batch size and publication discipline

Prefer coherent family-sized batches rather than one enormous uncommitted run.

Good examples:
- one 13-asset island pack;
- one screen family;
- one UI family;
- one effects family.

After EVERY meaningful batch:

1. `git status --short`
2. confirm all changed paths are authorized
3. update only legitimate task checkboxes
4. append execution evidence to `CODEX_VISUAL_ASSET_LOG.md`
5. append concise summary to `CODEX_VISUAL_PRODUCTION_MASTER_LOG.md`
6. stage exact paths only
7. NEVER use `git add .`
8. NEVER use `git add -A`
9. commit visual-only changes
10. push ONLY `origin codex/visual-assets-production`
11. fetch and verify the remote branch
12. verify canonical target paths remotely
13. only then treat those tasks as complete

Never modify or push `main`.

## 13. Tracker integrity

A checkbox may become `[x]` only when:
- canonical remote output exists, OR a protected-preserve task has been verified;
- required QA passed;
- official log was updated;
- relevant commit was pushed;
- remote existence was verified.

Do not bulk-check tasks merely because a generation call was issued.

At the end of every batch, report:
- completed task IDs;
- exact remaining unchecked count;
- commit SHA;
- remote HEAD;
- blockers.

## 14. Finish condition

Continue until every legitimate production target and preserve task is complete.

Only after the live tracker reaches a fully verified state should you execute:

`coordination/codex_visual_assets/CODEX_VISUAL_FINALIZATION_PROMPT.md`

Finalization must:
- verify 398/398 canonical task outcomes;
- preserve protected authorities;
- recreate contact sheets from final production images;
- run semantic-duplication QA;
- verify all ten gameplay-table alpha masks;
- update both official logs;
- verify remote publication;
- confirm `main` was untouched.

Do NOT run finalization prematurely.

## 15. Final owner report

When the remaining-production program is actually finished, return:

- total task status;
- regenerated count;
- protected-preserve count;
- exact missing/blocked targets, if any;
- commit SHA(s);
- remote branch HEAD SHA;
- confirmation official logs were updated;
- confirmation all required canonical paths exist remotely;
- confirmation V04/protected files are unchanged;
- confirmation `main` was untouched;
- FULL LONG GitHub browser URLs to:
  - visual asset log;
  - production master log;
  - task tracker;
  - finalization evidence if created.

BEGIN BY RE-READING THE LIVE TRACKER AND RESUME ONLY THE REMAINING UNCHECKED WORK.
