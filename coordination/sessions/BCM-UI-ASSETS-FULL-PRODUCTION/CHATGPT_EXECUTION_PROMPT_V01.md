# BCM-UI-ASSETS-FULL-PRODUCTION — Codex Execution Prompt V01

You are the asset-production builder for Beach Cocktails Merge.

## 1. Absolute branch-isolation rule

Repository:
`https://github.com/Sekiph82/Beach-Cocktails-Merge`

You must work **only** on branch:

`ui-assets`

The `ui-assets` branch already exists and was created from the same commit as main for this isolated stream.

At the very beginning run and record:

```powershell
git status --short --branch
git branch --show-current
git remote -v
git fetch origin main ui-assets
git rev-parse HEAD
git rev-parse origin/ui-assets
git rev-parse origin/main
```

If `git branch --show-current` is not exactly `ui-assets`, STOP. Do not repair by switching branches unless the owner explicitly started you in the correct repository and the only required action is `git switch ui-assets`. Never commit to main.

Do not:
- merge main;
- rebase onto main;
- cherry-pick active main work;
- force-push;
- update main;
- resolve unrelated main conflicts;
- edit root `TASKS.md`.

Other Codex work is active on main. Your branch must remain an isolated visual-production lane.

## 2. Read these files before doing anything else

1. `AGENTS.md`
2. `ui-assets-tasks.md`
3. `docs/ui-assets/FULL_VISUAL_ASSET_MANIFEST_V1.md`
4. `docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V1.md`
5. `coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CHATGPT_AUDIT_CRITERIA_V01.md`

The locked audit criteria outrank your own implementation preferences.

## 3. Goal

Produce the **complete visual asset set** for the planned Beach Cocktails Merge product, not a minimal set.

All new production visuals go under:

`assets/ui_assets/**`

Do not overwrite existing assets in:
- `assets/cocktails/`
- `assets/environment/`
- `assets/effects/`
- `assets/ui/`

The existing assets are references only. Later integration will decide what replaces them.

The complete required inventory is defined in:

`docs/ui-assets/FULL_VISUAL_ASSET_MANIFEST_V1.md`

Do not silently omit categories.

## 4. Quality requirement

These must be final-quality usable mobile-game assets, not placeholder rectangles, flat programmer art, renamed duplicates, empty canvases, or filename-only mocks.

Art direction:
- bright tropical casual-mobile;
- polished and premium;
- readable on 720×1280 portrait;
- coherent across all screens;
- attractive but not visually noisy;
- consistent material, bevel, highlight, shadow, and icon language;
- gameplay readability is more important than decoration.

Use original/generated art only. No scraped, watermarked, or unlicensed third-party game assets.

If your available tooling cannot produce a required final-quality visual family, do **not** fake completion. Produce what you can legitimately produce, record the exact blocker in the log, and stop with the stream incomplete.

## 5. Canonical table redesign is mandatory

The current table is visually too wide and is not the future master.

Create a new table master for all islands using:

`docs/ui-assets/TABLE_GEOMETRY_CONTRACT_V1.md`

Core rule at 720×1280:
- player-facing outer-left corner lands exactly at bottom-left viewport corner;
- player-facing outer-right corner lands exactly at bottom-right viewport corner;
- rear edge is centered;
- target rear width is about 64% of viewport width;
- rear edge is deliberately wider than the earlier narrow concept;
- all tables share the exact same geometry.

Create:
- `assets/ui_assets/tables/table_geometry_v1.json`
- a canonical master silhouette/mask;
- canonical edge overlay/reference;
- ten themed gameplay-table PNGs built from the same silhouette.

All ten island tables must have identical:
- canvas;
- alpha silhouette;
- front corners;
- rear corners;
- rear Y;
- table depth;
- perspective centerline;
- launch alignment;
- future playable-area footprint.

Only the materials/themes differ.

### Table themes

1. Sunny Cove — bright teak, turquoise resin, white beach-club trim.
2. Tiki Island — dark teak, bamboo, carved tiki motifs.
3. Azure Bay — yacht-deck whites, aqua resin, marina luxury.
4. Coconut Beach — pale natural wood, woven/coconut details.
5. Sunset Island — mahogany, amber/coral sunset reflections.
6. Party Beach — dark lacquer with controlled neon accents.
7. Frozen Paradise — icy/frosted pale-blue crystalline style.
8. Volcano Bay — obsidian/basalt with restrained lava seams.
9. Billionaire Island — walnut, white marble, gold trim.
10. Final Island — exotic blackwood, mother-of-pearl/turquoise inlay, premium gold.

## 6. Important: do not integrate gameplay geometry in V01

Changing the table will eventually change the playable area, but that runtime integration is deliberately deferred to prevent collision with the other Codex on main.

In this V01 asset-production run, do **not** edit:
- `scripts/game_manager.gd`
- live gameplay scenes
- current runtime boundary code
- existing runtime asset paths

Instead:
- freeze the future common geometry in `table_geometry_v1.json`;
- make the table art match it;
- produce branch-only preview/contact sheets;
- document the later old→new mapping;
- leave UIA-M14 in `ui-assets-tasks.md` for separately authorized integration.

The eventual requirement is already locked: there will be **one identical playable area for all levels, maps, and islands**. No island-specific table physics will ever be allowed.

## 7. Full asset families to produce

Produce every item in the manifest, including:
- brand and splash;
- global panels/buttons/icons;
- currency/stars/rewards/chests;
- boosters;
- main menu;
- world map;
- 10 island world icons;
- all 10 island full environment packs;
- 10 distinct table skins on one geometry;
- island-map progression UI;
- pre-level UI;
- timer/VIP/campaign HUD;
- effects/feedback;
- pause;
- win/fail;
- milestones;
- island-complete;
- star reward track;
- shop;
- rewarded-ad;
- daily-reward;
- settings;
- onboarding/tutorial;
- notifications/status badges;
- optional leaderboard/social pack.

Do not duplicate static art when a reusable state overlay is the intended architecture.

## 8. Production structure

All new runtime art:
`assets/ui_assets/**`

Recommended additional paths:
- editable/generated sources: `assets/ui_assets/source/**`
- table master: `assets/ui_assets/tables/**`
- generation/export scripts: `tools/ui_assets/**`
- validation: `tests/ui_assets/**`
- non-production previews only: `scenes/ui_assets_preview/**`

Do not put production assets in random repository-root locations.

## 9. PNG / transparency rules

Every runtime-target visual must have a PNG export.

Use transparency for:
- icons;
- buttons where appropriate;
- panels;
- table layers;
- decorations;
- effects;
- island icons;
- badges.

Use full opaque/layer-appropriate canvases for full-screen backgrounds.

Do not commit font files as part of this task.

Avoid baking mutable gameplay text/numbers into panels. Leave dynamic-value regions clean for Godot labels.

## 10. Required metadata and contact sheets

Generate:
- `assets/ui_assets/ASSET_MANIFEST.json`
- `assets/ui_assets/ASSET_DIMENSIONS.csv`
- `assets/ui_assets/README.md`
- `assets/ui_assets/CONTACT_SHEET_GLOBAL.png`
- `assets/ui_assets/CONTACT_SHEET_ISLANDS.png`
- `assets/ui_assets/CONTACT_SHEET_TABLES.png`
- `assets/ui_assets/CONTACT_SHEET_SCREENS.png`

The manifest must record:
- path;
- category;
- use/screen;
- dimensions;
- alpha expectation;
- island where applicable;
- table geometry version where applicable;
- generation/source method;
- checksum.

## 11. Required automated validation

Build/run branch-only validation that checks at minimum:

1. every required manifest path exists;
2. every PNG decodes;
3. actual dimensions match `ASSET_DIMENSIONS.csv`;
4. required transparent assets contain alpha;
5. all ten table canvases are identical in size;
6. all ten table outer alpha/silhouette masks are identical;
7. canonical front corners match the geometry contract;
8. canonical rear width/center match `table_geometry_v1.json`;
9. all 10 tables align in overlay proof;
10. no existing asset outside `assets/ui_assets/**` was overwritten;
11. root `TASKS.md` is unchanged;
12. no prohibited gameplay source was edited;
13. main ref was not modified.

Record exact commands and exact results.

## 12. Commit strategy

Use small coherent commits on `ui-assets`, for example:
- workspace/design system;
- table geometry master;
- global UI;
- world map;
- island packs;
- screen packs;
- effects;
- metadata/contact sheets;
- validation/log.

Do not create or merge a PR to main.

Push only:
`origin/ui-assets`

## 13. Builder log

Create exactly:

`coordination/sessions/BCM-UI-ASSETS-FULL-PRODUCTION/CODEX_LOG_V01.md`

The log is immutable builder evidence and must contain all items required by locked audit criteria.

Do not edit:
- `CHATGPT_EXECUTION_PROMPT_V01.md`
- `CHATGPT_AUDIT_CRITERIA_V01.md`
- `ui-assets-tasks.md`
- root `TASKS.md`

ChatGPT owns tracker transitions and audit verdicts.

## 14. Final pre-stop verification

Before claiming the build pass finished:

```powershell
git status --short --branch
git rev-parse HEAD
git rev-parse origin/ui-assets
git ls-remote origin refs/heads/ui-assets
git ls-remote origin refs/heads/main
```

Also compare against the start/main reference and confirm forbidden paths are unchanged.

Push the final log to `ui-assets`.

Then STOP.

Do not self-audit, do not mark tasks complete, do not merge to main. ChatGPT will read your log and independently audit actual repository evidence against the locked criteria. If remediation is required, ChatGPT will create a new remediation prompt and matching locked criteria.
