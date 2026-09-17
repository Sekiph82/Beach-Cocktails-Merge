# BCM-M06-R05 + BCM-M07-R04 — Owner Full-Tabletop + HUD Refinement Master Prompt V01

Status: **ISSUED**

## Goal
Apply two owner-directed refinements in one bounded Codex session while keeping them logically separated:

1. **M06-R05:** widen the horizontal gameplay area so the whole visible tabletop is actually usable, instead of artificially confining drinks to a narrow center corridor.
2. **M07-R04 V03:** keep the current owner-approved HUD artwork and apply the latest owner HUD rules, including moving BEST SCORE/SCORE higher for visual clearance.

The current canonical PNG artwork is approved. Do not replace or modify it.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R05/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M07-R03/CHATGPT_AUDIT_V02.md`
- `coordination/sessions/BCM-M07-R04/CHATGPT_AUDIT_CRITERIA_V02.md`
- `coordination/sessions/BCM-M07-R04/CHATGPT_REMEDIATION_PROMPT_V02.md`

Then run the governed sync preflight.

Do not edit TASKS.md or ChatGPT-owned prompt/audit/criteria/policy files.
Do not start M08+.
Do not self-audit.

---

# PHASE 1 — M06-R05 — Use the full visible tabletop horizontally

The owner screenshot shows drinks accumulating in a narrow center corridor while substantial visible tabletop remains unused on both sides.

This is NOT caused by BEST SCORE/SCORE HUD collision. HUD panels must never define physics bounds.

## Required behavior

The **whole visible tabletop interior** is gameplay area.

At any tabletop depth:
- the playable left edge follows the real visible left tabletop boundary;
- the playable right edge follows the real visible right tabletop boundary;
- a drink center may travel laterally until its physical glass/body collider becomes tangent to that edge;
- do not reserve an additional invisible strip merely because the collision wall has thickness;
- do not use full garnish/straw/fruit/leaf extents as collision clearance.

### Fix the current double-inset behavior
Inspect the current interaction between:
- `get_table_rail_bounds_at_y()`;
- `get_horizontal_bounds_at_y()`;
- `wall_thickness`;
- `_build_walls()`;
- `clamp_position_to_board()`;
- launch steering/bounds.

The current code adds `wall_thickness * 0.5 + radius + 3` inside the rail. If `_build_walls()` already places a physical rail with an inward collision face, do not count the same wall thickness again in clamp bounds.

Use one coherent model:
- define the intended visible playable tabletop boundary;
- place any static wall so its **inward collision face** corresponds to that boundary, with wall thickness extending outward where practical;
- define center-safe clamp bounds from `playable_edge + body_radius + tiny_epsilon` and `playable_edge - body_radius - tiny_epsilon`;
- keep epsilon minimal and documented, only for solver/numerical stability.

Do not arbitrarily shrink collider radii to create space. Collider/body mapping remains governed by M05. If M05 collider data itself creates a proven owner-visible defect, document it rather than silently retuning it here.

## Required validation
For all three viewports:
- 720x1280
- 720x1440
- 800x1280

Retain:
- clean production screenshot;
- overlay showing actual visible left/right tabletop edges;
- collision-wall inward faces;
- computed center-safe bounds;
- L01, L06 and L12 touching/reaching left and right boundaries at near/middle/far representative depths.

Acceptance intent:
- no unexplained dead strips of usable tabletop on either side;
- no narrow artificial central corridor;
- physical glass/container body stays on the table;
- garnish may visually extend beyond the collider as already intended.

Preserve exactly:
- current background;
- current table perspective;
- accepted `death_line_y`;
- accepted `launch_y`;
- 700 px/s launch;
- 180 px/s² deceleration;
- merge/momentum/economy/game-over contracts;
- no guide line.

Write:
`coordination/sessions/BCM-M06-R05/CODEX_LOG_V01.md`

Commit/push M06-R05 separately before continuing.

---

# PHASE 2 — M07-R04 V03 — HUD/content refinement

Use every requirement from `CHATGPT_REMEDIATION_PROMPT_V02.md`, with the following additional owner instruction.

## Move BEST SCORE and SCORE higher

The owner wants the upper tabletop visually unobstructed.

- Move the BEST SCORE / SCORE stack upward as much as practical while keeping both panels fully visible and preserving logo -> BEST SCORE -> SCORE ordering.
- They should remain on the left and above the tabletop accumulation/play zone.
- Do not overlap the logo.
- Do not overlap To-Go Orders.
- Do not use their rectangles to shrink the physics playfield.
- Validate at all three target aspect ratios.

## BEST SCORE / SCORE text rules remain V02
- fixed font size, not dynamic auto-shrink;
- choose fixed size(s) that safely fit up to 7 digits, including `9999999`;
- number only inside each dark recessed value rectangle.

## To-Go Orders rules remain V02
Runtime content is ONLY:
- target cocktail;
- reward digits.

Remove all `Lx/name` / level / cocktail-name runtime text.
Reward has NO leading plus sign.
The two hanging ropes visually continue to the top edge of the gameplay viewport.

## NEXT rules remain V02
Validate L01-L12 individually against the actual cream window using alpha-visible bounds.

## Held-drink baseline rules remain V02
Use a per-level visible glass/container bottom anchor; visual-only offset; do not change collider/physics.

## Progression remains unchanged
- baked 2x6 artwork;
- top L07-L12;
- bottom L01-L06;
- cocktail sprites only;
- no added cell frames.

Write:
`coordination/sessions/BCM-M07-R04/CODEX_LOG_V01.md`

Commit/push M07-R04 separately.

---

# FINAL REGRESSION

On final candidate main run:
- M01 contract
- M02 physics/collision/merge
- M03 economy/To-Go/persistence/Game Over
- M04 asset import
- M05 sprite/collider
- M06-R05 full-tabletop geometry probe
- M07-R04 focused HUD probe
- Godot 4.7.x import/startup
- `git diff --check`

Do not weaken prior tests merely to make this sequence green.

## Final response
Return only:
- M06-R05 log URL + commit SHA
- M07-R04 log URL + commit SHA
- one-line final regression result
- `AWAITING_AUDIT`

Then STOP.
