# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit Criteria V04

Status: **LOCKED BEFORE IMPLEMENTATION — SUPERSEDES V01/V02/V03**

Authority: latest owner runtime review and written alignment requirements dated 2026-09-18.

## Owner-approved / frozen behavior
The following are accepted and must remain functionally unchanged unless a direct compile/runtime dependency makes a minimal change unavoidable:

1. Desktop auto-fire / uncommanded drink creation is resolved.
2. BEST SCORE and SCORE numeric text centering inside their own value recesses is accepted.
3. To-Go Orders top placement / rope-to-ceiling result is accepted.
4. Held-drink placement on the gold launch oval is accepted.
5. NEXT content behavior is accepted.
6. Baked 2x6 progression behavior is accepted.
7. Launch speed remains 700 px/s.
8. Deceleration remains 180 px/s².
9. Collision/momentum/merge/combo/scoring/To-Go economy/persistence/Game Over/restart/rapid-launch behavior remains intact.
10. Canonical PNGs are not modified.

## Active problem A — rear tabletop contact
The rear target rule remains intentionally simple and identical for all cocktail levels L01-L12.

### Mandatory rear formula

For every cocktail level:

`rear_target_y = rear_table_y`

Equivalent runtime target:

`drink.position.y == rear_table_y`

No cocktail dimension participates in this rear Y formula.

### Explicitly forbidden rear-Y adjustments
Do not add any of the following to `rear_table_y`:

- collider radius;
- body half extent;
- sprite height or half-height;
- drink height;
- drink width;
- per-level Y offset;
- per-level rear target table;
- cocktail-size-based safety clearance.

Forbidden examples:

`rear_target_y = rear_table_y + collider_radius`

`rear_target_y = rear_table_y + body_half_extent_y`

`rear_target_y = rear_table_y + sprite_height / 2`

The accepted formula is exactly:

`rear_target_y = rear_table_y`

### Physical closure
1. A real moving RigidBody2D must not be stopped before the intended `rear_table_y` target by any stale hidden rear wall.
2. Physical TopRail inward face, rear clamp/target and `rear_table_y` must be coherent with the same rear-contact line.
3. Validation must use real normal-physics movement, not direct coordinate spawning as the sole proof.
4. Validate at least L01, L06 and L12 at rear-center plus representative rear-left/rear-right trajectories.
5. Final runtime must remove the visible unused rear tabletop strip currently behind stopped cocktails.

## Active problem B — HUD alignment refinement
The owner requests four layout changes. These are visual placement changes only and must not alter score logic, To-Go logic, NEXT logic, progression logic or gameplay bounds.

### Definitions for alignment
- **Vertical alignment** means the two images' visual center X coordinates must be equal.
- **Horizontal alignment** means the two images' visual bottom-most points must have the same Y coordinate.
- Use the actual displayed artwork rectangles/visible image bounds for alignment, not label text bounds or arbitrary node origins.

### Required layout
1. **BEST SCORE and SCORE horizontal alignment**
   - SCORE stays at its current accepted position.
   - BEST SCORE moves as needed.
   - The bottom-most visible point of BEST SCORE artwork and the bottom-most visible point of SCORE artwork must share the same Y coordinate.
   - Therefore BEST SCORE and SCORE sit on the same horizontal baseline defined by the current SCORE card.

2. **SCORE and NEXT vertical alignment**
   - SCORE stays at its current accepted position.
   - NEXT moves as needed.
   - The visual center X of NEXT must equal the visual center X of SCORE.
   - This creates one right-side vertical column centered on SCORE.

3. **Beach Cocktails Merge logo size**
   - Increase the logo modestly from its current runtime size.
   - Preserve aspect ratio.
   - Do not distort, crop, stretch or replace the canonical logo PNG.
   - It must remain on-screen and must not overlap the To-Go panel or create a new gameplay obstruction.

4. **Logo and BEST SCORE vertical alignment**
   - BEST SCORE may move vertically because of requirement 1, but its column X should be aligned with the logo.
   - The visual center X of the logo must equal the visual center X of BEST SCORE.
   - This creates one left-side vertical column centered through logo and BEST SCORE.

### HUD invariants
- SCORE itself is the positional anchor for both the BEST SCORE bottom-baseline alignment and the SCORE/NEXT center-X alignment. Do not move SCORE to satisfy these requirements.
- BEST/SCORE numeric values remain centered inside their own dark/gold value recesses after panel movement.
- To-Go panel placement remains exactly as currently owner-approved.
- Held-drink/gold-oval alignment remains exactly as currently owner-approved.
- NEXT may move only as required for center-X alignment with SCORE; do not alter NEXT content sizing/fit unless strictly necessary to preserve existing containment.
- Logo may resize and reposition only as needed to satisfy the modest size increase and center-X alignment with BEST SCORE.
- HUD nodes must remain independent of gameplay/table collision bounds.

## Evidence and regression
1. Retain clean runtime evidence for the final 720x1280 layout, plus the existing responsive layouts where applicable.
2. Evidence must make the following directly measurable:
   - BEST SCORE bottom Y == SCORE bottom Y;
   - SCORE center X == NEXT center X;
   - Logo center X == BEST SCORE center X;
   - logo is visibly larger than the immediately previous accepted R10/V03 runtime size;
   - score values remain centered in their recesses.
3. Retain rear-contact evidence using actual moving drinks.
4. Re-run desktop no-input smoke to confirm auto-fire remains fixed.
5. Run full active M01-M07 regression plus current R09/R10 focused tests.
6. Godot import/startup, parse/check-only and `git diff --check` must pass.
7. Codex must not edit `TASKS.md` or ChatGPT-owned prompt/audit/criteria/policy files.
8. No guide line and no M08+ feature work.

Any rear dead strip, stale rear blocker, broken owner-approved behavior, or failure of the four HUD alignment requirements blocks AUDITED_PASS.
