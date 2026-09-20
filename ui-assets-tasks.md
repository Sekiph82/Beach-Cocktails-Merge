# Beach Cocktails Merge — UI Assets Branch Task State

This tracker is authoritative **only for the isolated `ui-assets` branch visual-production stream**. It does not replace root `TASKS.md` on main.

## Branch isolation

- Repository: `Sekiph82/Beach-Cocktails-Merge`
- Working branch: `ui-assets`
- Base branch at stream creation: `main`
- Main work must never be merged, rebased, overwritten, force-pushed, or committed by the UI-assets Codex.
- Existing assets are reference-only during generation.
- New visual production goes under `assets/ui_assets/**`.
- Root `TASKS.md` must remain untouched.
- Only ChatGPT updates this tracker after independent audit.
- Codex writes immutable execution logs under `coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/`.

## Project status

- Current Milestone: UIA-M00
- Current Sprint: BCM-UI-ASSETS-FULL-PRODUCTION
- Current Task: Produce the complete visual asset library and canonical 10-island table family on the isolated ui-assets branch.
- Current Task Status: READY
- Required Actor: CODEX
- Audit Owner: ChatGPT
- Merge Status: DO NOT MERGE TO MAIN
- Runtime Integration Status: DEFERRED UNTIL ASSET AUDIT PASSES

## Locked design documents

- Full manifest: `docs/ui-assets/FULL_VISUAL_ASSET_MANIFEST_V1.md`
- Table geometry: `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V1.md`
- Execution prompt: `coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CHATGPT_EXECUTION_PROMPT_V01.md`
- Locked audit criteria: `coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CHATGPT_AUDIT_CRITERIA_V01.md`

## Milestones and tasks

### UIA-M00 — Isolation, inventory, and production workspace

- [ ] UIA-M00-001 — Verify current branch is exactly `ui-assets`; stop if not.
- [ ] UIA-M00-002 — Fetch main for awareness only; do not merge/rebase/cherry-pick main into ui-assets during the run.
- [ ] UIA-M00-003 — Inventory existing assets as references without overwriting them.
- [ ] UIA-M00-004 — Create `assets/ui_assets/` production tree and source/export substructure.
- [ ] UIA-M00-005 — Create deterministic asset-generation/export tooling under allowed branch-only tooling paths.
- [ ] UIA-M00-006 — Record start HEAD and branch isolation proof in `CODEX_LOG_V01.md`.

### UIA-M01 — Unified design system

- [ ] UIA-M01-001 — Define shared tropical premium casual-mobile palette and material language.
- [ ] UIA-M01-002 — Define reusable panel, button, tab, badge, icon, bevel, highlight, shadow, and outline rules.
- [ ] UIA-M01-003 — Define consistent lighting direction and readability rules.
- [ ] UIA-M01-004 — Establish production sizes, transparency rules, safe zones, and naming conventions.
- [ ] UIA-M01-005 — Export visual style reference/contact sheet.

### UIA-M02 — Canonical table geometry master

- [ ] UIA-M02-001 — Inspect accepted 720×1280 composition and current table geometry.
- [ ] UIA-M02-002 — Build one canonical replacement table silhouette with front outer corners exactly at viewport bottom corners.
- [ ] UIA-M02-003 — Set centered rear edge to approximately 64% viewport width, visibly wider than the narrow-table concept.
- [ ] UIA-M02-004 — Freeze rear Y, depth, centerline, launch alignment, and one common playable-boundary geometry.
- [ ] UIA-M02-005 — Produce `assets/ui_assets/tables/table_geometry_v1.json`.
- [ ] UIA-M02-006 — Produce shared alpha/silhouette master and table-edge overlay master.
- [ ] UIA-M02-007 — Prove all ten island tables use identical geometry by alpha-mask/overlay validation.
- [ ] UIA-M02-008 — Do not modify current gameplay physics or runtime scene integration in this production pass.

### UIA-M03 — Brand, splash, global UI, currency, rewards, boosters

- [ ] UIA-M03-001 — Produce all Brand and Splash assets in manifest sections A.
- [ ] UIA-M03-002 — Produce all Global UI assets in section B.
- [ ] UIA-M03-003 — Produce all Currency/Reward/Chest assets in section C.
- [ ] UIA-M03-004 — Produce all Booster assets in section D.
- [ ] UIA-M03-005 — Validate transparency and small-screen icon readability.

### UIA-M04 — Main menu and world map

- [ ] UIA-M04-001 — Produce full Main Menu asset set.
- [ ] UIA-M04-002 — Produce full World Map background/layer set.
- [ ] UIA-M04-003 — Produce ten island world-map icons.
- [ ] UIA-M04-004 — Produce reusable lock/current/complete presentation assets without duplicating unnecessary island variants.
- [ ] UIA-M04-005 — Produce contact-sheet mockup of the complete 10-island world-map composition.

### UIA-M05 — Ten island environment packs

- [ ] UIA-M05-001 — Sunny Cove full environment/map/table pack.
- [ ] UIA-M05-002 — Tiki Island full environment/map/table pack.
- [ ] UIA-M05-003 — Azure Bay full environment/map/table pack.
- [ ] UIA-M05-004 — Coconut Beach full environment/map/table pack.
- [ ] UIA-M05-005 — Sunset Island full environment/map/table pack.
- [ ] UIA-M05-006 — Party Beach full environment/map/table pack.
- [ ] UIA-M05-007 — Frozen Paradise full environment/map/table pack.
- [ ] UIA-M05-008 — Volcano Bay full environment/map/table pack.
- [ ] UIA-M05-009 — Billionaire Island full environment/map/table pack.
- [ ] UIA-M05-010 — Final Island full environment/map/table pack.
- [ ] UIA-M05-011 — Verify every table uses identical master silhouette and canvas.
- [ ] UIA-M05-012 — Verify table skins change material/theme only, never play-area geometry.

### UIA-M06 — Island-map progression UI

- [ ] UIA-M06-001 — Produce all reusable level-node states.
- [ ] UIA-M06-002 — Produce route connectors, milestone markers, finale crown, star states, and scroll decorations.
- [ ] UIA-M06-003 — Produce island summary, star count, and next-milestone panels.
- [ ] UIA-M06-004 — Produce a 100-level Sunny Cove map visual mockup using reusable components, not 100 unique assets.

### UIA-M07 — Level pre-start and gameplay campaign HUD

- [ ] UIA-M07-001 — Produce full pre-level screen asset set.
- [ ] UIA-M07-002 — Produce timer, level label, pause, VIP badge, and VIP reward-frame assets.
- [ ] UIA-M07-003 — Ensure new gameplay HUD assets visually coexist with existing canonical BEST/SCORE/NEXT/To-Go panels.
- [ ] UIA-M07-004 — Produce 720×1280 gameplay mockups for Sunny Cove plus representative dark/light islands.

### UIA-M08 — Effects and feedback

- [ ] UIA-M08-001 — Produce merge, sparkle, score, order-complete, VIP-complete, timer warning, combo, win, confetti, milestone, and trail assets.
- [ ] UIA-M08-002 — Keep all effects restrained enough that cocktails/orders remain readable.
- [ ] UIA-M08-003 — Produce effect contact sheet on light and dark backgrounds.

### UIA-M09 — Results, pause, milestone, island-complete, star track

- [ ] UIA-M09-001 — Produce Pause screen assets.
- [ ] UIA-M09-002 — Produce Win/Level Complete assets.
- [ ] UIA-M09-003 — Produce Fail/Time Up assets.
- [ ] UIA-M09-004 — Produce Milestone Reward assets.
- [ ] UIA-M09-005 — Produce Island Complete assets.
- [ ] UIA-M09-006 — Produce Star Reward Track assets.

### UIA-M10 — Monetization and retention screens

- [ ] UIA-M10-001 — Produce full Shop assets.
- [ ] UIA-M10-002 — Produce Rewarded Ad assets.
- [ ] UIA-M10-003 — Produce Daily Reward assets.
- [ ] UIA-M10-004 — Ensure monetization art matches the same design system rather than looking like a separate game.

### UIA-M11 — Settings, onboarding, notifications, social

- [ ] UIA-M11-001 — Produce Settings screen assets.
- [ ] UIA-M11-002 — Produce Tutorial/Onboarding assets.
- [ ] UIA-M11-003 — Produce notification/status badges.
- [ ] UIA-M11-004 — Produce full optional leaderboard/social asset set.

### UIA-M12 — Manifest, dimensions, contact sheets, validation

- [ ] UIA-M12-001 — Generate `ASSET_MANIFEST.json` for every produced runtime asset.
- [ ] UIA-M12-002 — Generate `ASSET_DIMENSIONS.csv`.
- [ ] UIA-M12-003 — Generate global/island/table/screen contact sheets.
- [ ] UIA-M12-004 — Verify all manifest paths exist and all declared PNGs decode.
- [ ] UIA-M12-005 — Verify required transparent assets contain alpha and full-screen backgrounds are opaque where intended.
- [ ] UIA-M12-006 — Verify no table geometry mismatch across all islands.
- [ ] UIA-M12-007 — Verify no pre-existing asset was deleted or overwritten.
- [ ] UIA-M12-008 — Verify no changes exist on main.

### UIA-M13 — Branch-only preview and handoff

- [ ] UIA-M13-001 — Create branch-only non-production preview/contact-sheet tooling without changing live gameplay.
- [ ] UIA-M13-002 — Document old-runtime-asset to new-ui-assets mapping for later integration.
- [ ] UIA-M13-003 — Document current table replacement mapping and required future playable-boundary update.
- [ ] UIA-M13-004 — Record all files, generation method, checks, limitations, and end HEAD in `CODEX_LOG_V01.md`.
- [ ] UIA-M13-005 — Push only `ui-assets` and stop for independent ChatGPT audit.

### UIA-M14 — Future table/runtime integration, blocked until separate authorization

- [ ] UIA-M14-001 — Replace current visible table with the accepted canonical table asset on the isolated branch.
- [ ] UIA-M14-002 — Update authoritative playable boundary to match the canonical new table exactly.
- [ ] UIA-M14-003 — Preserve one and only one playable area across all levels, maps, and islands.
- [ ] UIA-M14-004 — Preserve accepted drink collision/merge semantics while changing table bounds.
- [ ] UIA-M14-005 — Add island table-skin switching with zero geometry changes.
- [ ] UIA-M14-006 — Run strict physics/table-edge regression and owner runtime acceptance before any merge toward main.

## Completion rule

Asset production is not accepted because files merely exist.

The stream requires:
- complete manifest coverage;
- visual coherence;
- usable transparency/dimensions;
- ten distinct island identities;
- exact common table geometry;
- original/non-watermarked art;
- evidence contact sheets;
- branch isolation;
- strict independent audit.

Codex must never mark tasks complete in this tracker. ChatGPT updates status after audit.
