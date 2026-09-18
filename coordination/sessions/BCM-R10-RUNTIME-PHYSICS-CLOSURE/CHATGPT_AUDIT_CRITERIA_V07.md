# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V07

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V01/V02/V03/V04/V05/V06**

Authority: latest owner GUI runtime screenshot dated 2026-09-18 12:13 and independent V06 audit.

## Owner conclusion carried forward

The current owner-approved three-sided playable envelope remains correct.

The remaining defect is still the visible cocktail-to-table-edge gap.

V05 Solution 1 post-merge clamp improved gameplay feel and must stay.

V06 did not materially improve the visible gap because its supposed table-edge footprint algebraically reduced to approximately the collider radius itself.

## Frozen behavior
Do not redesign or regress:
1. V05 three-sided playable envelope coordinates;
2. V05 post-merge X clamp behavior;
3. auto-fire fix;
4. BEST/SCORE numeric centering;
5. To-Go top placement;
6. held-drink / gold-oval alignment;
7. NEXT content behavior;
8. baked 2x6 progression;
9. V04 HUD alignment and logo sizing;
10. launch speed 700 px/s;
11. deceleration 180 px/s²;
12. merge/combo/scoring/To-Go economy/persistence/Game Over/restart/rapid-launch behavior;
13. canonical PNGs.

## Active problem — V06 footprint was not truly independent

V06 used:

`edge_contact_half_width = visible_body_width * visual_scale * 0.5 * presentation_scale`

while:

`visual_scale = (collider_radius * 2) / visible_body_width`

which collapses to approximately:

`edge_contact_half_width = collider_radius * presentation_scale`

This is not acceptable for V07.

The new table-edge dataset must **not be derived from collider radius directly or indirectly**.

## Mandatory V07 model — independent per-level table-edge contact dataset

Create an explicit per-level dataset for L01-L12:

`TABLE_EDGE_CONTACT_HALF_WIDTHS`

or an equally clear project-consistent name.

There must be exactly 12 independent values.

### Mandatory independence rules

The 12 values:
- must not be calculated from `COLLIDER_RADII`;
- must not be calculated from `visual_scale_for_level()`;
- must not be generated from any formula that algebraically reduces to collider radius;
- must not be inferred from transparent texture bounds;
- must not include garnish/straw/fruit/flowers/leaves/umbrellas;
- must not move the owner-approved rails themselves.

These values represent the 2D screen-space half-width of the visible glass/container body that should visually contact a side playable boundary.

## Measurement requirement

Derive the 12 values from the actual cocktail PNG visible glass/container geometry.

The measurement process must be explicit and retained as immutable evidence.

For each L01-L12 retain:
- texture dimensions;
- visible glass/container contact width in source pixels;
- excluded garnish regions/rationale;
- final independent table-edge contact half-width used by production;
- comparison against collider radius.

The measurement evidence must be independent from the production constant array and from collider-radius formulas.

A test that merely imports the production array as the expected truth is insufficient.

## Production use

Drink-to-drink collision continues using the existing unchanged collider radius.

Table-edge side limits use the independent edge-contact half-width:

`left_limit = left_playable_edge + edge_contact_half_width`

`right_limit = right_playable_edge - edge_contact_half_width`

The accepted V05 merge correction must use the same independent edge-contact half-width for the newly merged level.

Rear target remains exactly:

`rear_target_y = rear_table_y`

No width/height/radius/depth offset may be added to rear Y.

## Physical-wall compatibility

Because the actual RigidBody2D circle may be wider than the independent visual edge footprint, production must ensure the physical StaticBody2D side walls do not solver-eject a cocktail from a logically valid edge-contact position.

Codex may choose the implementation mechanism for this compatibility, but:
- the owner-approved logical rail coordinates must remain unchanged;
- drink-to-drink collider radii must remain unchanged;
- the final visible cocktail must not leave the accepted playable table;
- no fake 3D depth concept is allowed.

## CCD

CAST_SHAPE CCD is already present and should simply be preserved.

Do not treat CCD as a new acceptance mechanism.

Do not add unsupported `CollisionShape2D.margin`, CharacterBody2D safe-margin behavior, or one-frame freeze unless a later owner-approved prompt explicitly requests it.

## Required focused proof

1. All 12 production collider radii are unchanged.
2. All 12 independent table-edge contact half-widths exist.
3. The table-edge dataset is not algebraically derived from collider radii.
4. Representative L01/L06/L12:
   - left edge contact;
   - right edge contact;
   - visibly closer contact than V06.
5. Left-wall merge:
   - raw merge X;
   - independent edge footprint;
   - valid X range;
   - corrected X.
6. Right-wall merge with same evidence.
7. Center merge remains a no-op.
8. Rear target stays exactly `rear_table_y`.
9. V05 envelope source coordinates remain numerically unchanged.
10. GUI/F5 evidence must allow the owner to visually verify that the edge gap is materially reduced.

## Regression

Run:
- full active M01-M07 regression;
- R09/R10 focused tests;
- V05 envelope regression;
- new V07 independent-edge-dataset probe;
- left/right wall-merge regression;
- center merge no-op;
- desktop no-input smoke;
- Godot startup/import;
- parse/check-only;
- `git diff --check`.

Codex must not edit `TASKS.md`, ChatGPT-owned files, historical logs, canonical PNGs or M08+ work.

Any derivation from collider radius, movement of owner-approved rails, regression of V05 Solution 1, loss of drink-to-drink collision behavior, or continued owner-visible edge gap blocks AUDITED_PASS.
