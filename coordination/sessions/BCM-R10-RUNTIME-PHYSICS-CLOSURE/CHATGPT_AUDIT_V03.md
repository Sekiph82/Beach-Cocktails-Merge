# BCM-R10-RUNTIME-PHYSICS-CLOSURE — ChatGPT Audit V03

Verdict: **CHANGES_REQUIRED / OWNER_RUNTIME_VERIFICATION_REQUIRED**

Audited implementation: `045705a311864b1ab7498e88990c46b116b80e71`

Authoritative criteria:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V05.md`

Builder log:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CODEX_LOG_V03.md`

## Accepted source-level findings

1. The three-sided owner envelope is present in production.
   - rear source Y changed to 478;
   - left/right source rails were replaced by the owner-annotation-derived perspective samples;
   - the lower table blends back into the existing near-table perspective.

2. The owner rear-target formula is implemented exactly:
   `get_rear_target_center_y(...) -> rear_table_y`
   with no radius/body/sprite/per-level Y addition.

3. V05 Solution 1 is implemented in the actual merge path.
   In `MergeQueue._do_merge()`, immediately after the new merged drink exists, production calls:
   `get_horizontal_bounds_at_y(new_drink.position.y, new_drink.radius)`
   and clamps `new_drink.position.x` into that range.
   Y and inherited merge velocity are not zeroed by this correction.

4. The focused left/right wall merge probe demonstrates a real size increase from L01 radius 20 to L02 radius 23 and a 3 px corrective shift to the new tangent X on both sides.

5. HUD source implements the requested V04 relationships using visible PNG bounds:
   - BEST bottom aligned to SCORE bottom;
   - NEXT center-X aligned to SCORE center-X;
   - logo widened from 190 to 210 display px and center-X aligned to BEST;
   - SCORE remains the anchor.

6. Regression markers in the builder log are green, including M01-M07, R09 no-input, R10 focused probes, parse/import and diff-check.

## Blocking finding 1 — no final visual runtime proof

The locked V05 criteria require retained runtime evidence showing the three-sided owner envelope, left/right/rear contacts, wall-merge behavior and final HUD alignment.

The builder log explicitly states:
- headless capture could not produce PNG evidence;
- interactive GUI/manual play was not performed.

Therefore the most important owner-visible acceptance criteria remain visually **UNVERIFIED**.

Green coordinate/probe assertions do not replace owner-visible runtime evidence.

Required closure:
- run the current implementation in normal Godot GUI/F5;
- provide a clean runtime screenshot showing the three-sided playable envelope result and final HUD;
- exercise at least one merge near a side wall and confirm the new larger result does not jump inward and leave the artificial gap.

## Blocking finding 2 — physical TopRail does not literally coincide with rear_table_y

Locked V05 criteria say the physical rear collision/TopRail must coincide with the new inward `rear_table_y`.

Current production instead places TopRail above the rear center target by:
`max_body_radius + TOP_RAIL_CLEARANCE`.

That design lets the normal-motion clamp/solver enforce the common center Y target and avoids L12 being nudged, but it is not literal geometric coincidence between the TopRail inward face and `rear_table_y`.

This is a criteria/source mismatch and must either:
- be corrected in production, or
- be explicitly superseded by owner acceptance of the current runtime behavior after visual verification.

## Evidence quality note — merge clamp

The focused wall-merge probe validates left/right boundary correction after a size increase and the source implementation is correctly located in `MergeQueue._do_merge()`.

However the V05 criteria also requested before/after positional evidence sufficient to show the clamp happens only when needed. The retained output gives input X and final result X for boundary cases but does not include a non-boundary control merge or an explicit pre-clamp merged X value.

This is not the primary blocker because the production source clearly performs a standard clamp, which is a no-op for already-valid X. Still, future evidence should include an already-valid control case if another remediation is required.

## Audit state

- Three-sided production geometry: **SOURCE PASS / VISUAL UNVERIFIED**
- Rear target formula: **PASS**
- Solution 1 merge X clamp: **SOURCE PASS / OWNER RUNTIME UNVERIFIED**
- Auto-fire regression: **PASS by current evidence**
- HUD alignment implementation: **SOURCE PASS / VISUAL UNVERIFIED**
- Full regression: **PASS by builder evidence**
- Physical TopRail exact-coincidence criterion: **CHANGES_REQUIRED or owner supersession required**

Final verdict: **CHANGES_REQUIRED / OWNER_RUNTIME_VERIFICATION_REQUIRED**

Do not begin M08+.
