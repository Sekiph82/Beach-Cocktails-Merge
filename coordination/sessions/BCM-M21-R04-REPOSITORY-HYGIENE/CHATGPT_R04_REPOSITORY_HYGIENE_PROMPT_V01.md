# BCM-M21-007 — R04 Repository Hygiene / Obsolete Asset & Evidence Cleanup V01

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`
`https://github.com/Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/OWNER_RULING_R04_REPOSITORY_HYGIENE_V01.md`
4. `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_R04_REPOSITORY_HYGIENE_CRITERIA_V01.md`
5. `docs/ui-assets/GAMEPLAY_SURFACE_CONTRACT_V07_R04.md`
6. `docs/codex-logs/CODEX_LOG_R04_OBSOLETE_JSON_IMPORT_CLEANUP.md`

Root TASKS.md is read-only.

## Owner state to preserve

The owner has personally approved the current gameplay background/playable-area design and current playable geometry for ALL TEN islands.

For every island, these are protected:
- gameplay_surface_v07_r04.png
- gameplay_surface.png
- playable_geometry_r04.json
- complete_badge.png
- map_background.png
- map_title.png
- theme_badge.png
- world_icon.png

Do not redesign, regenerate, replace, normalize, recompress, or delete any of those protected files.

Also preserve current/planned-use cocktail, HUD, World Map, Island Map, campaign, gameplay, economy, persistence, and future M22-M27 assets/code.

## Mission

Perform a COMPLETE repository hygiene pass.

Find, prove obsolete, test around, and remove:
- orphan/generated .import files;
- stale .import files for deleted assets;
- old unused images;
- rejected candidate images;
- old visual evidence that only proves retired/rejected visuals;
- retired split table/background/table-edge/shadow/mask assets;
- obsolete JSON/provenance/calibration/measurement files;
- stale manifests/catalog entries;
- stale tests/fixtures for retired paths;
- stale helper scripts used only for deleted assets/evidence;
- other files with no current runtime/config/test/current-contract/future-roadmap use.

This is not “delete everything old.” It is “delete everything proven obsolete.”

If a file may still be used now or in the planned roadmap, KEEP it.

## Phase 1 — inventory before deletion

Build a full inventory first.

Search:
- scripts/
- scenes/
- data/
- tests/
- tools/
- assets/
- docs/
- coordination/
- AGENTS.md
- current technical contracts
- current active prompts/criteria
- root TASKS.md
- future M22-M27 plan

Classify every cleanup candidate:
- KEEP
- DELETE
- REVIEW

Do not delete REVIEW.

Write the machine-readable inventory before deletion.

## Phase 2 — .import cleanup

The owner explicitly authorizes deletion of obsolete/generated .import sidecars.

At minimum remove all orphan .import files whose source no longer exists.

Because *.import is already ignored/generated metadata, you may also remove legacy repository-local .import sidecars that are unnecessary under this Godot 4 project, provided clean-import/parse/boot proves the project regenerates/imports correctly.

Target end state: orphan .import count = 0.

If shell/git rm is blocked by external execution policy, use another normal delete/edit operation exposed and allowed by the coding environment. Do not bypass platform safeguards.

## Phase 3 — obsolete visual/evidence cleanup

Aggressively inspect superseded visual generations, especially:
- rejected V07-R03 material;
- pre-final R04 candidate/review variants;
- retired V1/V2 split-table visual assets;
- old gameplay table/background/overlay/shadow/mask outputs;
- obsolete geometry-fit/calibration screenshots;
- old contact sheets/debug overlays;
- duplicate visual review images where a newer owner-approved R04 authority/evidence exists.

Delete only when current truth does not need them.

Preserve evidence for current nonvisual behaviors that still matter.

## Phase 4 — JSON/catalog cleanup

Remove obsolete JSON/provenance/calibration/measurement records after reference proof.

Do not delete:
- ten playable_geometry_r04.json files;
- current campaign/level/runtime JSON;
- current difficulty/economy/progression records still needed.

Rebuild current asset catalogs/manifests so no deleted asset remains listed.

## Phase 5 — rules/tests/tools cleanup

Update current rules/tests to the owner-approved R04 architecture.

Delete or rewrite tests that only assert retired split-table asset paths.

Retain equivalent current coverage:
- ten-island surface/profile identity;
- geometry/profile integrity;
- gameplay physics/scoring;
- To-Go/VIP;
- campaign/progression/persistence;
- map/navigation;
- current release/runtime behavior.

Delete helper scripts that have no remaining input/output/use after cleanup.

## Phase 6 — resolve game_board_background.png

The owner has already deleted locally:
`assets/environment/game_board_background.png`

Do NOT restore it automatically.

There is still a Sunny Cove `map_background` reference in `data/campaign/islands.json`.

Trace the actual consumer.

If that top-level field is obsolete because the current Island Map uses `theme.island_map_background`, remove/update the obsolete data/schema/test expectation and preserve the owner's deletion.

If a current accepted screen truly requires this image, stop on this single item and document it as REVIEW/BLOCKED. Do not fabricate a replacement.

## Phase 7 — validation

After cleanup run all locked criteria tests.

Mandatory final checks:
- all ten R04 source/runtime/profile families intact;
- all protected planned-use assets present;
- no orphan .import files;
- no current broken resource references;
- no current manifest entry for deleted files;
- clean Godot import/parse/boot;
- R04 surface/profile validation PASS;
- current gameplay/campaign regressions PASS;
- git diff --check PASS;
- TASKS.md unchanged.

## Commits

Use small logical commits:
1. obsolete generated/import cleanup;
2. obsolete asset/evidence cleanup;
3. test/rule/tool/catalog reconciliation;
4. final evidence/log.

Do not mix owner-local plugin/project.godot files into commits.

Do not use destructive repo-wide reset/clean.

## Handoff

Create the required inventory/manifests/log from locked criteria.

Push intended changes to main.

Verify:
- local HEAD = origin/main = remote main;
- only authorized owner-local dirty files remain.

Finish exactly:

`AWAITING_GPT_R04_REPOSITORY_HYGIENE_AUDIT_V01`
