# BCM-M12-WORLD-MAP — Full Visual Asset Regeneration Criteria V03

Status: **LOCKED BEFORE IMPLEMENTATION**

## Purpose

Reset the entire Beach Cocktails Merge visual-production library and regenerate **all game visual assets** at final-quality art direction before M12 continues.

This is not a World Map-only correction.

The previous procedural/Pillow-heavy asset library is visually rejected by the owner. M12 V03 must rebuild the complete visual asset set so that every screen, island, icon, panel, effect, map, table skin, state, badge, reward, booster and campaign visual belongs to one coherent premium tropical game.

## Mandatory visual authority

These two repository images are the **highest-priority visual authority** for every newly produced visual:

1. https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board_remediation_v01.png
2. https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board.png

Codex must inspect both before generating anything.

They are not casual inspiration. They define the required rendering quality, tropical/resort atmosphere, lighting richness, material richness, palette, environmental density, premium mobile-game finish, painterly/cartoon-realistic style, and level of polish.

If a generated asset would look visibly cheaper, flatter, more procedural, more icon-font-like, more dashboard-like, or more debug-like than those boards, it is **not acceptable**.

The owner has explicitly rejected the previous flat cyan/procedural World Map and the previous programmer-art/Pillow visual language.

## No low-quality fallback

Do **not** substitute flat procedural Pillow shapes as final art, generic gradients, wireframe/path-debug visuals, stock-looking icons, repeated primitive circles/rectangles, text-only placeholders, crude vector programmer art, duplicated recolors pretending to be distinct states, generic UI-kit aesthetics, or a different visual style because generation is easier.

Pillow may still be used for post-processing, alpha cleanup, resizing, composition, mask application, contact sheets, validation, and metadata generation. It must **not** be the primary art generator for final-quality illustrated assets.

If the environment cannot create/generate final-quality art matching the mandatory visual-authority boards, STOP and report the blocker. Do not silently fall back to procedural art.

## Scope: regenerate ALL visual assets

Treat the current assets/ui_assets/ASSET_MANIFEST.json and docs/ui-assets/FULL_VISUAL_ASSET_MANIFEST_V1.md as the coverage baseline.

Regenerate every visual runtime asset represented by the complete UI-assets production stream, including all visual PNG families under:

- assets/ui_assets/brand/**
- assets/ui_assets/ui/**
- assets/ui_assets/campaign/world_map/**
- assets/ui_assets/campaign/island_map/**
- assets/ui_assets/campaign/islands/**
- assets/ui_assets/screens/**
- assets/ui_assets/effects/**
- assets/ui_assets/tables/** visual PNGs

Also regenerate all full-screen screen compositions/mockups, contact sheets, visual evidence sheets, stateful variants, and island-specific art packs.

### Brand and global UI
- splash visuals; reusable panels; buttons; tabs; badges; navigation; currency; rewards; chests; boosters; notification/status visuals; global decorative UI.

### Main menu and World Map
- full Main Menu asset set; premium World Map background/layers; 10 distinct island destination visuals; open/current/locked/complete treatments; route/path visuals; map title/navigation/status visuals.

### Ten island environment packs
Regenerate complete environment/map/gameplay art for Sunny Cove, Tiki Island, Azure Bay, Coconut Beach, Sunset Island, Party Beach, Frozen Paradise, Volcano Bay, Billionaire Island, and Final Island.

Each island must have a clearly distinct identity while remaining inside the same Beach Cocktails Merge art family.

### Island Map progression UI
- level-node states; connectors; milestone nodes; finale presentation; star states; scroll decorations; summary/progress panels; 100-level-map presentation components.

### Pre-level and gameplay campaign HUD
- pre-level screen assets; timer; level labels; pause; VIP treatment; VIP reward frame; campaign gameplay overlays.

### Feedback/effects
- merge; sparkle; score; order complete; VIP complete; timer warning; combo; win; confetti; milestone; trail; all other manifest-listed effects.

### Results and progression screens
- Pause; Win / Level Complete; Fail / Time Up; Milestone Reward; Island Complete; Star Reward Track.

### Monetization and retention
- Shop; Rewarded Ad; Daily Reward.

### Settings/onboarding/social
- Settings; Tutorial/Onboarding; status/notification visuals; leaderboard/social visuals.

## Canonical assets that are not to be redesigned

### Owner logo
The canonical owner-supplied Beach Cocktails Merge logo is protected. Do not redraw or reinterpret it. Allowed: alpha cleanup, proportional resize, padding, and use inside new compositions. All new screens that show the game logo must use the canonical owner logo.

### Table geometry
The accepted table/play-area geometry is protected. Do not alter canonical table silhouette, table geometry JSON, table alpha mask, front corners, rear width/position, or gameplay boundary geometry. Regenerate the **visual material/skin** of each island table only while preserving the exact frozen common geometry.

### Reference boards
Do not overwrite or modify:
- assets/ui_assets/source/style_reference_board_remediation_v01.png
- assets/ui_assets/source/style_reference_board.png
They are immutable art-direction authorities.

## Art direction

Target premium tropical casual mobile game; polished illustrated 2D; semi-realistic/painterly cartoon rendering; bright cinematic lighting; rich turquoise water; warm sand/gold/wood accents; lush vegetation; readable silhouettes; high material definition; layered depth; tasteful bloom/highlights; visually inviting resort/travel fantasy.

The final result should look like one commercial game, not a collection of unrelated UI experiments.

## Island identity requirements

All ten islands must be visually distinct at a glance.

- Sunny Cove: bright tropical cove, sunlit resort beach.
- Tiki Island: premium tiki bar, carved wood, torches, palms.
- Azure Bay: elegant blue marina/coastal luxury.
- Coconut Beach: lush coconut grove, relaxed beach huts.
- Sunset Island: warm golden-hour/pink-orange sunset.
- Party Beach: neon tropical nightlife.
- Frozen Paradise: tropical-meets-ice fantasy, crystalline blue.
- Volcano Bay: lava/volcanic tropical drama.
- Billionaire Island: ultra-luxury marina/resort/yacht visual language.
- Final Island: dramatic aspirational finale, rare/exclusive destination.

These should echo the visual-authority boards, not literal copies.

## Stateful UI quality

Every paired/opposite state must be visibly and semantically distinct: locked vs unlocked; active vs inactive; claimed vs unclaimed; complete vs incomplete; on vs off; enabled vs disabled; current vs normal; filled vs empty stars; closed vs open chests.

No byte-identical opposite states. No weak one-pixel/color-only distinction where a stronger semantic distinction is expected.

## World Map V03 specific requirement

The new World Map must use final-quality illustrated world/archipelago art; show 10 distinct destinations spatially; make Sunny Cove the only initially open/current island; make the other 9 visibly locked without giant repetitive lock circles; use one clean non-self-intersecting progression route; integrate labels/navigation/status into the visual composition; and look consistent with the two mandatory reference boards.

The previous cyan debug/procedural map is forbidden as a visual basis.

Preserve the M12 V02 lifecycle-safe refresh/data-driven state architecture where technically reusable.

## Dimensions and transparency

Preserve required dimensions and alpha contracts from the manifest unless a documented V03 correction is necessary.

Full-screen portrait composition target: 720x1280. Also validate visual coherence in the owner's embedded 405x720 preview.

Transparent assets must preserve clean alpha edges with no checkerboard remnants or matte halos.

## Production workflow

Before finalizing:
1. inventory all visual paths from the manifest;
2. regenerate every visual asset in scope;
3. update manifest SHA/source method metadata;
4. update dimensions CSV;
5. rebuild all contact sheets;
6. rebuild island/major-screen/stateful/effect evidence;
7. visually review contact sheets against both mandatory reference boards;
8. reject and regenerate any family that looks procedural, duplicated, inconsistent, or visibly below the reference quality;
9. validate all protected geometry/logo/reference-board hashes;
10. run runtime/source regressions relevant to M12.

## Required evidence

Produce contact sheets that make independent visual audit practical: GLOBAL; BRAND/UI; WORLD MAP; ISLANDS; ISLAND MAP; TABLES; SCREENS; EFFECTS; STATEFUL UI; MAJOR SCREENS.

Also provide representative 720x1280 final compositions for Main Menu, World Map, Sunny Cove gameplay, Tiki Island gameplay, Party Beach gameplay, Frozen Paradise gameplay, Billionaire Island gameplay, Pre-level, Win, Fail, Shop, Daily Reward, and Settings.

## Acceptance

File existence is not acceptance.

V03 passes only if every intended visual asset is regenerated or explicitly protected by contract; the two mandatory reference boards are visibly reflected in quality/style; no programmer-art/procedural-placeholder family remains; all 10 islands are distinct; state pairs are distinct; table geometry is unchanged; canonical logo is unchanged; world map is premium and coherent; all required evidence/contact sheets exist; validator passes; no gameplay regression is introduced; and final visual acceptance is still owner-authoritative.

## Codex ownership restrictions

Codex must not edit root TASKS.md, ChatGPT-owned audit/criteria/history files, the two visual-authority reference boards, or protected gameplay physics/scoring/R11/M08/M09/M10/M11 behavior except non-visual M12 integration already authorized.

Write an immutable execution log under:
coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V03.md