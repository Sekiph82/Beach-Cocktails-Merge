# BCM-M21-007 — R04 Repository Hygiene Locked Criteria V01

Status: **LOCKED BEFORE EXECUTION**

## A. Baseline and inventory

Before deleting anything:
1. synchronize canonical Desktop checkout safely with origin/main using AGENTS.md;
2. preserve all owner-local plugin/project changes;
3. record HEAD, status, tracked/untracked counts;
4. build a repository-wide cleanup inventory.

Required inventory fields per candidate:
- path;
- tracked/untracked;
- type/extension;
- bytes;
- reference count;
- exact current references;
- historical-only references;
- current replacement/authority;
- future-roadmap relevance;
- classification: KEEP / DELETE / REVIEW;
- reason.

Default uncertainty to KEEP.

## B. Protected current island packs

For all ten islands preserve:
- gameplay_surface_v07_r04.png
- gameplay_surface.png
- playable_geometry_r04.json
- complete_badge.png
- map_background.png
- map_title.png
- theme_badge.png
- world_icon.png

Validate:
- source/runtime PNG pair is byte-identical per island;
- dimensions remain 720×1280 RGB;
- profile paths/hashes match;
- all ten profiles keep current shared accepted boundary contract.

## C. Godot import cleanup

Delete obsolete/generated repository-local `*.import` sidecars when they are not source assets.

At minimum:
- delete all orphan `.import` sidecars whose corresponding source file no longer exists;
- delete legacy `.import` sidecars that are reproducible/ignored and unnecessary under the current Godot 4 project after clean-import validation.

Never delete the source PNG merely because its `.import` is deleted.

After cleanup:
- orphan `.import` count must be 0;
- clean Godot import/parse/boot must pass.

## D. Superseded visual pipeline cleanup

Find and remove files belonging solely to retired/superseded visual systems, including where proven obsolete:
- V1/V2 split gameplay table/background layers;
- gameplay_table / table-edge / separate shadow runtime artifacts;
- retired masks and geometry-fit assets;
- rejected V07-R03 candidates;
- superseded V07-R04 draft/review variants no longer part of current owner-approved authority;
- old contact sheets, visual debug outputs, calibration renderings, and duplicated review images;
- obsolete table/source images not used by runtime, tests, current contracts, or future roadmap.

Do not delete current island-map assets or current HUD/cocktail assets.

## E. Evidence cleanup

Current acceptance should point to the newest approved R04 truth.

Codex may remove superseded visual evidence directories/files if:
- they validate only rejected/retired visuals;
- no current test/contract/TASKS requirement depends on the binary evidence;
- equivalent/current R04 validation remains.

Preserve nonvisual evidence still needed for current accepted gameplay/campaign behavior, including current VIP/economy, difficulty, mastery/replay, UX, release/performance/progression evidence where still relevant.

Do not preserve an obsolete image merely because an old historical Markdown log names it.

## F. JSON / manifest / catalog cleanup

Delete obsolete JSON/provenance/calibration/measurement reports after reference analysis.

Protected JSON includes:
- all ten playable_geometry_r04.json;
- data/campaign/islands.json;
- current campaign/level/data JSON needed by runtime;
- current difficulty/economy/save truth still used or tested.

Rebuild/update:
- assets/ui_assets/ASSET_MANIFEST.json
- assets/ui_assets/ASSET_DIMENSIONS.csv
- current semantic/duplicate/state reports if their toolchain treats them as current asset-catalog truth.

No deleted path may remain as a current asset entry.

## G. Test and rule cleanup

Search all tests, tools, scenes, scripts, contracts, prompts/criteria, and current docs.

- Replace/remove tests whose only purpose is retired split-layer paths.
- Preserve gameplay/physics/scoring/To-Go/VIP/campaign/persistence coverage.
- Update active tests to validate R04 surface/profile identity and current paths.
- Retire obsolete helper scripts used only for deleted evidence/assets.
- Current R04 contract and AGENTS must remain coherent.
- Root TASKS.md is read-only to Codex.

## H. game_board_background.png

Treat the owner-local deletion as intentional cleanup input.

Before finalizing:
- identify every current reference and consumer;
- if the reference is obsolete, update authoritative data/schema/tests safely and keep the file deleted;
- if genuinely required by a current accepted screen, do not invent a replacement: STOP and report REVIEW/BLOCKED for this one path.

## I. No broken current references

After deletion:
- scan textual current references;
- validate resource paths;
- validate all scenes/data load;
- validate asset catalogs;
- ensure no active/current contract/test points to a missing required file.

Historical text may mention a removed obsolete filename only if that historical text is intentionally retained and is not part of current runtime/test/contract authority.

## J. Required tests

Run, at minimum:
- current R04 surface/profile authority probe;
- LevelDatabase/data validation;
- gameplay surface/profile hash/load validation for all 10 islands;
- clean Godot import/parse/boot;
- current focused gameplay regression;
- current campaign/navigation/persistence regression relevant to touched files;
- asset catalog/manifest validation;
- orphan-file/reference scan;
- `git diff --check`.

If repository has a canonical broader test suite, run it as well unless technically impossible and document exact reason.

## K. Required evidence and handoff

Create:
- `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/R04_CLEANUP_INVENTORY_V01.json`
- `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/R04_CLEANUP_DELETION_MANIFEST_V01.md`
- `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/R04_CLEANUP_REFERENCE_AUDIT_V01.json`
- `docs/codex-logs/CODEX_LOG_R04_REPOSITORY_HYGIENE_V01.md`

Deletion manifest must summarize:
- total files deleted;
- tracked vs untracked;
- bytes removed;
- counts by category/extension;
- protected files verified;
- REVIEW/KEEP items and why;
- test results.

Final marker:
`AWAITING_GPT_R04_REPOSITORY_HYGIENE_AUDIT_V01`
