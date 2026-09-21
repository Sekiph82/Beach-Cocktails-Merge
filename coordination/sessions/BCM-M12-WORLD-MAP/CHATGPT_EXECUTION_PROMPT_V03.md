# BCM-M12-WORLD-MAP — Full Visual Asset Regeneration Execution Prompt V03

Execute a **complete visual-production reset** for Beach Cocktails Merge.

This is not a World Map-only task.

Read first:
- AGENTS.md
- TASKS.md
- ui-assets-tasks.md
- coordination/AUDIT_POLICY.md
- docs/ui-assets/FULL_VISUAL_ASSET_MANIFEST_V1.md
- assets/ui_assets/ASSET_MANIFEST.json
- assets/ui_assets/README.md
- coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_V02.md
- coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_ART_DIRECTION_BRIEF_V01.md
- coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_FULL_VISUAL_REGEN_CRITERIA_V03.md

## NON-NEGOTIABLE VISUAL AUTHORITY

You MUST inspect and use both of these repository images as the mandatory visual authority for **every regenerated visual family**:

1. https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board_remediation_v01.png
2. https://github.com/Sekiph82/Beach-Cocktails-Merge/blob/main/assets/ui_assets/source/style_reference_board.png

These are not optional inspiration.

They define the required final-quality rendering language: premium tropical resort art, cinematic lighting, rich turquoise water, warm wood/sand/gold, lush foliage, strong depth, polished painterly/cartoon-realistic rendering, and commercial mobile-game finish.

The owner explicitly rejected the existing flat cyan/procedural World Map and programmer-art visual language.

## REGENERATE ALL VISUALS

Regenerate the **entire visual asset library**, not only World Map assets.

Use the current ASSET_MANIFEST and full visual manifest as the coverage baseline.

Regenerate every final visual runtime asset in:
- assets/ui_assets/brand/**
- assets/ui_assets/ui/**
- assets/ui_assets/campaign/world_map/**
- assets/ui_assets/campaign/island_map/**
- assets/ui_assets/campaign/islands/**
- assets/ui_assets/screens/**
- assets/ui_assets/effects/**
- visual PNGs under assets/ui_assets/tables/**

Also regenerate all full-screen compositions, mockups, contact sheets, evidence sheets, and state variants.

Cover the full visual-production scope: brand/global UI; currencies/rewards/chests; boosters; Main Menu; World Map; all 10 island packs; Island Map progression UI; pre-level screen; gameplay campaign HUD; all visual effects; Pause; Win/Level Complete; Fail/Time Up; Milestone Reward; Island Complete; Star Reward Track; Shop; Rewarded Ad; Daily Reward; Settings; Tutorial/Onboarding; notification/status visuals; leaderboard/social visuals.

## FORBIDDEN FALLBACK

Do NOT use deterministic Pillow/procedural primitives as the primary final-art generation method.

Pillow is allowed only for technical post-processing, masks, resizing, compositing, contact sheets, validation and metadata.

Do not ship flat primitive graphics, generic gradients, debug-line visuals, repeated circular lock badges as the dominant design, crude icon-font/pictogram art, duplicated/recolored placeholders, programmer art, or generic dashboard UI.

If your available environment cannot produce art matching the mandatory reference boards, STOP and report that limitation. Do not generate a lower-quality substitute.

## PROTECTED ITEMS

Do NOT redesign or modify:
- assets/ui_assets/source/style_reference_board_remediation_v01.png
- assets/ui_assets/source/style_reference_board.png
- canonical owner-supplied Beach Cocktails Merge logo artwork
- frozen table geometry JSON/mask/silhouette/play-area geometry

You may regenerate all table **skins/material visuals**, but they must use the exact same frozen geometry.

Canonical logo variants may only use alpha cleanup, proportional resizing and padding. No redraw.

## TEN ISLANDS

Regenerate all complete island visual packs:
- Sunny Cove
- Tiki Island
- Azure Bay
- Coconut Beach
- Sunset Island
- Party Beach
- Frozen Paradise
- Volcano Bay
- Billionaire Island
- Final Island

They must be instantly distinguishable while clearly belonging to the same game. Use the authority boards to drive environment quality.

## WORLD MAP

Rebuild World Map using the new final-quality art:
- real illustrated archipelago/ocean composition;
- 10 spatially placed island destinations;
- Sunny Cove only current/open;
- other 9 visibly locked;
- tasteful lock treatment;
- one clean progression route with no self-intersections;
- no cyan debug map;
- no route spaghetti;
- no tiny generic circles standing in for islands.

Preserve the V02 data-driven unlock logic and lifecycle-safe deferred/queue_free refresh behavior.

## STATEFUL UI

All opposite states must be genuinely visually different and semantically clear. No byte-identical opposite state files.

## EVIDENCE AND VALIDATION

After regeneration:
- update ASSET_MANIFEST.json;
- update ASSET_DIMENSIONS.csv;
- regenerate all contact sheets;
- produce dedicated WORLD MAP, ISLANDS, STATEFUL, SCREENS, EFFECTS, TABLES and MAJOR SCREENS evidence;
- include representative 720x1280 compositions;
- validate alpha/dimensions;
- validate canonical logo preservation;
- validate immutable reference-board hashes;
- validate identical table geometry across all island skins;
- run M12 focused tests and active regressions.

Before pushing, visually inspect your own contact sheets against BOTH mandatory reference boards.

Any family visibly below the authority-board quality must be regenerated before completion.

## OUTPUT

Write:
coordination/sessions/BCM-M12-WORLD-MAP/CODEX_LOG_V03.md

The log must include:
- exact number of visual assets regenerated;
- protected assets intentionally preserved;
- generation method by asset family;
- final contact-sheet paths;
- validation results;
- table-geometry proof;
- logo/reference-board preservation proof;
- regressions;
- implementation SHA.

Push all completed V03 visual-production work to main unless repo governance requires an isolated visual branch, in which case follow AGENTS.md and explicitly report the branch/ref.

Do not edit root TASKS.md.

Return only:
- log URL
- implementation SHA
- total visual asset count regenerated
- validation result
- regression result
- AWAITING_AUDIT

Then STOP.