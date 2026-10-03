# BCM-M21 V07-R02 — Owner Visual Audit

Status: **CHANGES_REQUIRED / GAMEPLAY_TABLE_COMPOSITION_REJECTED**

Active tasks:
- BCM-M21-001
- BCM-M21-006

Evidence reviewed:
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v07-r02/SC-01_single_flattened_surface_720x1280_REVIEW.jpg`
- V07-R02 builder log, provenance, geometry calibration, builder self-audit, and owner checklist.

## Accepted from V07-R02

The following may be preserved:
- production navigation and input behavior;
- mouse/touch gameplay behavior;
- no-timer rule;
- Pause/Resume;
- WIN / Next / Island Map lifecycle;
- persistence;
- zero-red-error runtime result;
- V07-R02 World Map semantic calibration unless a later regression requires repair;
- art-first ordering requirement: final art must exist before gameplay geometry is derived.

## Owner visual finding

The V07-R02 Sunny Cove gameplay composition is not accepted.

The central problem is not basic technical validity. The table is composed as a relatively distant object inside the scene instead of being the dominant player-facing gameplay surface.

Observed issues:
1. The table is too small and too far from the player/camera.
2. The usable tabletop does not dominate enough of the 720×1280 screen.
3. The L1-L12 cocktail progression panel is placed below the table as a detached floating panel. It must sit visually between the two table legs.
4. The deadline is drawn on/at the front rim. It must be a visible line on the tabletop, slightly farther into the table than the currently held cocktail.
5. Too much vertical space is consumed by the front structure, long legs, and detached progression panel instead of usable tabletop depth.
6. The final composition must still leave enough surrounding space for the existing PAUSE, Beach Cocktails Merge logo, To-Go Orders, Next, Best Score, and Score UI.
7. Sunny Cove surroundings may remain tropical beach/ocean/palm scenery, but the table must be the dominant gameplay stage rather than a prop in the scenery.

## Correct visual architecture

At 720×1280:
- the rear tabletop edge should begin high enough to leave the accepted upper HUD/scenery readable;
- the tabletop must then extend strongly toward the player and occupy most of the central/lower screen;
- the player-facing table edge must be close to the camera;
- the current cocktail appears naturally near the player-facing part of the tabletop;
- the deadline appears on the tabletop a short distance farther into the table;
- beyond the deadline, the table continues for a large clear gameplay depth before reaching the rear edge;
- the two table legs descend from the player-facing structure;
- the L1-L12 cocktail progression panel sits between those two legs, not beneath them and not detached from the table composition;
- island-specific scenery remains visible behind and to both sides of the table.

No special colored, outlined, boxed, shaded, labeled, or arrow-marked region is wanted around the held cocktail. The only gameplay marking requested on the tabletop is the deadline.

## Disposition

V07-R02 builder technical PASS does not grant owner visual acceptance.

Proceed with V07-R03 as an **owner visual candidate gate** before changing production geometry or rebinding production gameplay.

Required next marker:
`AWAITING_OWNER_VISUAL_SELECTION_V07_R03`
