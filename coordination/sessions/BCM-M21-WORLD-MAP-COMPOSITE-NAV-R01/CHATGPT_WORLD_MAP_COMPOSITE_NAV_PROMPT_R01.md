# BCM-M21-001 + BCM-M21-006 — Composite World Map + Sunny Cove Navigation Remediation R01

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`
`https://github.com/Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/OWNER_F5_REJECTION_V03.md`
4. `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_COMPOSITE_NAV_CRITERIA_V01.md`
5. `scripts/campaign/world_map_controller.gd`
6. `scripts/campaign/island_entry.gd`
7. `scripts/campaign/campaign_navigation_controller.gd`
8. `scripts/campaign/island_map_controller.gd`
9. `data/campaign/islands.json`
10. `tests/m12_world_map_probe.gd`
11. `tests/m13_island_map_probe.gd`
12. `tests/m20_app_shell_probe.gd`

Root TASKS.md is read-only.

## Owner verdict

`OWNER_F5_REJECTED_V03`

- Item 1 PASS.
- Item 2 FAIL: many islands are not visually in the correct place.
- Item 3 FAIL: Sunny Cove Island Map does not open from the production World Map.
- Items 4-10 were not evaluated.

## Critical architecture change

Do NOT try to salvage the baked ten-island map by merely moving invisible markers.

The baked map architecture is rejected.

Build a true composite World Map:

### Background
Create:
`assets/ui_assets/campaign/world_map/world_map_ocean_base_v01.png`

720×1280, clean ocean/tropical map base, NO island bodies baked in.

### Island visuals
Use these exact existing files as the production island bodies:
- sunny_cove.png
- tiki_island.png
- azure_bay.png
- coconut_beach.png
- sunset_island.png
- party_beach.png
- frozen_paradise.png
- volcano_bay.png
- billionaire_island.png
- final_island.png

They are 220×220 transparent assets.

Do not regenerate them.

## The key rule

**THE VISIBLE ISLAND IS THE CLICK TARGET.**

Every island's art, ring/state, label, hitbox and route anchor must derive from the same layout center/transform.

No invisible displaced hotspot.

No second duplicate thumbnail.

## Layout

Create a coherent ten-island progression across the 720×1280 map.

You are explicitly authorized to recalibrate all `map_position` values.

Keep the gameplay progression order:
Sunny Cove → Tiki Island → Azure Bay → Coconut Beach → Sunset Island → Party Beach → Frozen Paradise → Volcano Bay → Billionaire Island → Final Island.

Use enough spacing for mobile readability and touch targets.

Preserve header/back/compass only if they remain clean.

Boat/clouds/routes are decorative and subordinate.

## First reproduce Sunny Cove failure

Before implementation:
- enter World Map through the real production app-shell flow;
- click the visible Sunny Cove body using actual viewport mouse input;
- trace the full signal chain;
- record exactly where it stops.

The current M12 direct `select_island("sunny_cove")` test is NOT sufficient.

After the composite-map implementation, repeat using the actual Sunny Cove art/hitbox center.

Required end-to-end result:
visible Sunny Cove click → exactly one selection → Island Map visible → active id sunny_cove → 100 level buttons → Sunny Cove Island Map background loaded.

Also validate touch.

## Do not over-fix

If Sunny Cove failed only because the visible island and hitbox were in different places, do not invent an unnecessary navigation subsystem change.

If the real signal chain has another defect, fix the minimum correct seam and document it.

## Old background

Keep:
`world_map_background.png`

in the repository for now, but remove it from production World Map usage.

Do not delete it until owner acceptance of the new composite map.

## Tests

Rewrite stale baked-map assumptions.

Add a focused production-input test that proves actual art click/tap opens Sunny Cove.

Run the full locked regression matrix.

M12 must PASS twice consecutively after final code change.

## Visual evidence

Use real renderer + Godot AI at 720×1280.

Save all required screenshots and layout JSON.

Do not self-approve the visuals.

## Publish

Commit in logical chunks:
1. composite base + World Map architecture/layout;
2. Sunny Cove real-input navigation fix/test;
3. evidence/regressions/log.

Do not commit owner-local plugin/project files.

Verify local HEAD = origin/main = remote main.

Finish exactly:

`AWAITING_GPT_M21_WORLD_MAP_COMPOSITE_NAV_AUDIT_V01`
