# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit V05

Verdict: **CHANGES_REQUIRED**

Audited implementation:
`faf2b2b34c997cd0e8495a13330f0ec1ad25078e`

Builder log:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V05.md`

Locked criteria:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V07.md`

## What passed

1. The owner-approved V05 three-sided playable envelope remains frozen.
2. V05 Solution 1 post-merge X clamp remains in production.
3. Drink-to-drink collider radii remain unchanged.
4. Rear target remains exactly `rear_target_y = rear_table_y`.
5. CAST_SHAPE CCD remains enabled.
6. No unsupported CollisionShape2D margin API, CharacterBody2D conversion, or one-frame freeze was introduced.
7. Production now exposes an explicit 12-value `TABLE_EDGE_CONTACT_HALF_WIDTHS` array.
8. Regression markers in the builder log are green.
9. A normal-display GUI capture was retained as builder evidence.

## Critical blocker — the supposedly independent V07 dataset is still derived from collider radius

The locked V07 criteria explicitly require the 12 table-edge values to **not** be calculated directly or indirectly from:
- `COLLIDER_RADII`;
- `visual_scale_for_level()`;
- any formula that algebraically reduces to collider radius.

The retained evidence provides:
- source contact width;
- visible body width;
- collider radius;
- runtime edge half-width.

Production still defines:

`visual_scale_for_level = (collider_radius * 2) / VISIBLE_BODY_WIDTH_PX`

When the retained source contact widths are converted to runtime pixels using that scale:

`runtime_half_width = source_contact_width * visual_scale_for_level / 2`

the results reproduce the V07 constants almost exactly.

Representative examples:

### L01
- source contact width = 492
- visible body width = 690
- collider radius = 20
- visual scale = 40 / 690
- calculated runtime half-width = 492 * (40/690) / 2 = **14.261**
- V07 constant = **14.3**

### L06
- source contact width = 400
- visible body width = 700
- collider radius = 42
- visual scale = 84 / 700 = 0.12
- calculated runtime half-width = 400 * 0.12 / 2 = **24.0**
- V07 constant = **24.0**

### L12
- source contact width = 437
- visible body width = 710
- collider radius = 90
- visual scale = 180 / 710
- calculated runtime half-width = 437 * (180/710) / 2 = **55.394**
- V07 constant = **55.4**

The same relationship holds across the full L01-L12 dataset within rounding tolerance.

Therefore V07 did not produce an independently calibrated table-edge contact dataset.

It moved the old collider-dependent conversion out of runtime code and baked the resulting numbers into a constant array.

That violates the central V07 acceptance condition.

## Evidence-quality blocker

The retained JSON states:

> "The retained runtime half-widths are explicit screen-space measurements. They are not calculated from COLLIDER_RADII, visual_scale_for_level(), VISIBLE_BODY_WIDTH_PX..."

The numerical evidence contradicts that statement.

The source-contact PNG measurements themselves may be independently measured, but the conversion from source-pixel contact width to runtime screen-space half-width is still effectively using the collider-defined sprite scale.

So the evidence provenance is incomplete/mischaracterized.

## GUI evidence

The GUI capture is useful builder evidence, but it is a scripted placement capture of L01/L06/L12 at calculated contact positions.

It does not override the failed independence contract above.

Owner runtime acceptance is still required after a truly independent contact model is implemented.

## What V08 must do differently

Do not merely hardcode values generated through the current sprite scale.

The table-edge contact values must be calibrated independently in **runtime screen-space**, or be derived from an independent rendering/visual calibration that does not use collider-defined `visual_scale_for_level()`.

Acceptable directions include:
- owner/runtime measured center-to-visible-contact distances for each displayed cocktail level;
- an independent visual scale definition not derived from collider radius;
- direct GUI/runtime pixel measurement of rendered glass/container contact footprint.

The exact technical method can be chosen by the next prompt, but the collider radius must not enter the conversion path directly or indirectly.

## Audit state

- V05 playable envelope preserved: **PASS**
- V05 Solution 1 preserved: **PASS**
- Collider radii preserved: **PASS**
- Rear rule preserved: **PASS**
- Explicit 12-value array exists: **PASS structurally**
- Dataset independence from collider radius: **FAIL**
- Evidence provenance claim: **FAIL / contradicted by values**
- Regression suite: **PASS by builder evidence**
- Owner-visible final edge-gap closure: **NOT ACCEPTED**

Final verdict: **CHANGES_REQUIRED**

Do not begin M08+.
