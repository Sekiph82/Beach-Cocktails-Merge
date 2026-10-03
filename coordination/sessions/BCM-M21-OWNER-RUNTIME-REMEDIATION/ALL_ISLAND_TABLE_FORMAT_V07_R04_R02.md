# BCM-M21-001 + BCM-M21-006 — All-Island Table Format Extension V07-R04-R02

## Owner-approved format

The owner confirmed the Sunny Cove blank-board scene in `evidence/visual-candidates/v07-r04-r02/sunny_cove_master_surface_source_v07_r04_r02.png` as the desired visual format. Its SHA-256 matches the user's supplied approved image byte-for-byte. The defining format is a portrait, close player-facing tabletop with a strong trapezoid, long boards running from rear to player, raised side rails, a thick front fascia, and a framed island background.

The scene is intentionally blank: it contains no HUD, drinks, deadline, vertical guide, trajectory, or other gameplay marking. Those remain separate runtime/review layers. In particular, the vertical dotted/arrow cocktail guide is absent.

## Ten saved island scenes

| Island | Background / wood treatment |
|---|---|
| Sunny Cove | Bright turquoise beach, palms, warm honey teak; owner-approved format reference |
| Tiki Island | Sunset cove, tiki architecture and amber lanterns; deeper reddish teak and carved trim |
| Azure Bay | Mediterranean marina, pale cliffs and blue water; honey teak with restrained azure trim |
| Coconut Beach | Coconut palms, sandy lagoon and huts; light coconut-honey wood and rope trim |
| Sunset Island | Orange-magenta sunset and lanterns; richer amber/rosewood grain |
| Party Beach | Neon aqua-magenta resort evening; warm wood with restrained event-color trim |
| Frozen Paradise | Ice lagoon, snow-covered palms and aurora; pale wood with frosted blue trim |
| Volcano Bay | Lava-lit volcanic cove; dark mahogany and ember-bronze trim |
| Billionaire Island | Luxury marina and villas; polished golden teak with champagne trim |
| Final Island | Waterfalls, cliffs and island palace; golden teak with pearl/emerald trim |

Every island has a full-resolution 941x1672 PNG and a 720x1280 review-size PNG under `evidence/visual-candidates/v07-r04-r02/all_island_surfaces/`. `all_islands_contact_sheet_v07_r04_r02.png` presents the ten variants together. Exact filenames, dimensions, and SHA-256 digests are in `all_islands_manifest_v07_r04_r02.json`.

## Build and review

Run `evidence/visual-candidates/v07-r04-r02/build_all_island_variants.py` to regenerate the 720x1280 previews, contact sheet, and manifest from the saved full-resolution sources. The builder checks all source dimensions and that Sunny Cove remains byte-identical to the owner's approved format source.

The Sunny Cove gameplay review composite is separately saved as `evidence/visual-candidates/v07-r04-r02/sunny_cove_master_review_v07_r04_r02_720x1280.png`; its HUD, sample cocktails, horizontal deadline, held cocktail, and progression are review overlays. It has no vertical guide.

## Scope and production boundary

This is a visual review set. No gameplay code, R11 collision rails, gameplay physics, scoring, campaign behavior, production surface binding, or root `TASKS.md` was changed. These full-scene generated images have not been fitted to the V2 table masks and are **not production `gameplay_table.png`, edge overlay, or shadow assets**. Production conversion must separately follow `docs/ui-assets/TABLE_ASSET_PRODUCTION_RULECHAIN_V2.md`, which requires exact V2 geometry fitting, source-derived edge extraction, and the fixed shadow master.

The Sunny Cove format itself is owner-approved. The nine island-specific generated looks remain review candidates pending owner visual review; matching canvas size and composition is builder evidence, not V2 geometry acceptance.

## Handoff

`AWAITING_OWNER_VISUAL_ACCEPTANCE_V07_R04`
