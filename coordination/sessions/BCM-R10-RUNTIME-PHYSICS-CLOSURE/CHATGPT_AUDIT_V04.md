# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit V04

Verdict: **CHANGES_REQUIRED / OWNER_RUNTIME_VERIFICATION_REQUIRED**

Audited implementation:
`225014e039f4ad5136db3bdf91b3feddff329bf1`

Builder log:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V04.md`

Locked criteria:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V06.md`

## What is correctly implemented

1. V05 three-sided owner-approved playable envelope remains unchanged.
2. V05 Solution 1 post-merge X clamp remains in the real production merge path.
3. Merge clamp now calls a dedicated table-edge-contact bound helper instead of directly using full collider radius.
4. Drink-to-drink collider radii remain unchanged.
5. Rear target remains exactly:
   `rear_target_y = rear_table_y`.
6. No unsupported fake `CollisionShape2D.margin = 0.08` API was introduced.
7. No CharacterBody2D conversion or one-frame freeze was introduced.
8. Regression markers in the builder log are green for the active suite.

## Blocking finding 1 — the new edge footprint is mathematically almost the old collider radius

Production defines:

`visual_scale_for_level = (collider_radius * 2) / VISIBLE_BODY_WIDTH_PX`

Then V06 defines:

`edge_contact_half_width = VISIBLE_BODY_WIDTH_PX * visual_scale_for_level * 0.5 * visual_body_depth_scale_for_y`

Substituting the first equation into the second gives:

`edge_contact_half_width = collider_radius * visual_body_depth_scale_for_y`

The new `visual_body_depth_scale_for_y` ranges only from 0.96 to 1.0.

Therefore the supposedly independent table-edge footprint is not independently derived from visible body geometry in any meaningful sense. It is mathematically the existing collider radius multiplied by a very small 2D scale factor.

At the retained sample Y=620:
- L01 radius 20.000 -> footprint 19.588
- L06 radius 42.000 -> footprint 41.134
- L12 radius 90.000 -> footprint 88.144

This changes side clearance by only:
- ~0.41 px for L01
- ~0.87 px for L06
- ~1.86 px for L12

That is far too small to establish that the owner-visible edge gap has actually been addressed.

The criteria required a separate table-edge contact footprint derived from the visible glass/container body. The implementation creates a separate variable/API, but its numerical value is still effectively determined by the collider radius.

Verdict for this criterion: **CHANGES_REQUIRED**.

## Blocking finding 2 — CCD was not a new remediation effect

The builder log says:

`Drink.create() continues to use RigidBody2D.CCD_MODE_CAST_SHAPE`.

The implementation diff does not introduce CAST_SHAPE CCD as a new production behavior. It was already active before V06.

Therefore V06 did not meaningfully test a new CCD remedy against the observed owner-visible gap; it only verified the existing CCD state.

This is not itself a regression, but it means the "Solution 2 CCD" branch produced no new corrective effect.

## Blocking finding 3 — physical walls were moved outward to accommodate the new logical footprint

V06 shifts side wall collision shapes outward by:

`max(collider_radius - edge_contact_half_width)`

This is logically consistent with allowing the full circular RigidBody collider to occupy a center position closer to the accepted logical rail.

However, because the footprint reduction itself is only approximately 0-4%, the physical wall relocation is likewise very small. It cannot be assumed to resolve the visually significant owner-reported gap without GUI evidence.

## Evidence finding

The focused tests prove:
- the new API is used;
- wall merges are clamped;
- center merge clamp is a no-op;
- V05 rail coordinates remain unchanged;
- regression suite remains green.

But the locked V06 criteria explicitly state:

> Headless coordinate PASS is not sufficient for visual closure.

The builder log again states that normal GUI/F5 visual owner verification was not performed.

Therefore visual closure remains **UNVERIFIED**.

## Important test-quality note

The test assertion:

`edge footprint is distinct from collider at sample depth`

passes merely because the footprint is slightly smaller than radius by more than 0.01 px.

That proves numerical inequality, not meaningful independence or owner-visible improvement.

A future test should validate the actual independently measured/defined edge-contact footprint and a materially different owner-visible contact result, not only `footprint < radius`.

## Audit state

- V05 playable envelope preserved: **PASS**
- V05 Solution 1 preserved: **PASS**
- Drink-to-drink collider radii preserved: **PASS**
- Rear rule preserved: **PASS**
- Unsupported margin API avoided: **PASS**
- Separate API/value exists: **PASS structurally**
- Edge footprint meaningfully independent from collider radius: **FAIL**
- CCD provides new remediation behavior: **NO, pre-existing**
- Owner-visible edge gap solved: **UNVERIFIED**
- Full active regression: **PASS by builder evidence**

Final verdict: **CHANGES_REQUIRED / OWNER_RUNTIME_VERIFICATION_REQUIRED**

Do not begin M08+.
