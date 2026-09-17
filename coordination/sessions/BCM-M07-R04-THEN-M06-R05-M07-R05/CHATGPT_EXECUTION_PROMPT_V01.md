# BCM-M07-R04 → M06-R05 → M07-R05 — Sequential Owner Refinement Master Prompt V01

Status: **ISSUED**

## Critical sequencing rule

The owner has ALREADY given Codex the authoritative M07-R04 remediation prompt:

`coordination/sessions/BCM-M07-R04/CHATGPT_REMEDIATION_PROMPT_V02.md`

Therefore this master prompt MUST NOT interrupt, restart, replace, duplicate, or re-run that work.

Codex must first allow the already-running / already-issued BCM-M07-R04 task to reach its normal completion state.

### Hard prerequisite before any new work
Do not begin M06-R05 until ALL of the following exist and are verified on `main`:

1. `coordination/sessions/BCM-M07-R04/CODEX_LOG_V01.md`
2. A dedicated M07-R04 implementation commit has been created.
3. That M07-R04 commit has been pushed to `origin/main`.
4. Local HEAD, `origin/main`, and remote `main` are synchronized for that completed M07-R04 state.
5. The M07-R04 log records completion of the owner rules from V02, including:
   - fixed 7-digit-safe BEST SCORE / SCORE font sizes;
   - no To-Go `Lx/name` text;
   - reward digits without a leading `+`;
   - To-Go ropes visually attached to the viewport top;
   - NEXT L01-L12 containment;
   - held-drink body-bottom baseline alignment;
   - unchanged baked 2x6 progression.

If M07-R04 is not yet complete, DO NOT start M06-R05. Finish the already-issued M07-R04 work first under its own prompt, commit, push, write its log, then continue with this prompt.

Do not overwrite or rewrite the M07-R04 log after that phase has been completed.

---

## Read before the post-M07 work

After M07-R04 is complete and pushed, read:

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R05/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M07-R05/CHATGPT_AUDIT_CRITERIA_V01.md`
- `coordination/sessions/BCM-M07-R04/CODEX_LOG_V01.md`

Run governed sync preflight before starting M06-R05.

Do not edit `TASKS.md` or any ChatGPT-owned prompt/audit/criteria/policy file.
Do not start M08+.
Do not self-audit.

---

# PHASE 1 — M06-R05 — Full visible tabletop gameplay width

## Owner intent

The entire visible wooden tabletop interior must be usable gameplay area.

The current behavior visibly funnels cocktails into a narrow central corridor even though substantial wooden tabletop remains available on the left and right.

BEST SCORE, SCORE, logo, To-Go and NEXT are HUD only. They must never define physics bounds.

## Required geometry behavior

At every playable tabletop depth:

- derive the real visible left tabletop edge;
- derive the real visible right tabletop edge;
- allow a cocktail center to travel laterally until its **physical glass/body collider** becomes tangent to the real visible tabletop edge;
- do not reserve an unexplained additional dead strip inside the visible table;
- do not use straw, fruit, flower, leaf or garnish alpha extents to reduce gameplay width;
- preserve the perspective taper of the table.

### Correct the current inset model

Inspect the combined behavior of:

- `get_table_rail_bounds_at_y()`
- `get_horizontal_bounds_at_y()`
- `wall_thickness`
- `_build_walls()`
- `clamp_position_to_board()`
- launch steering / held-drink X bounds

The current implementation previously used an inward clearance equivalent to:

`wall_thickness * 0.5 + radius + 3`

If wall placement already makes the inward collision face correspond to the playable edge, do not count the same half-wall thickness again in clamp logic.

Use one coherent boundary model:

1. visible tabletop edge = gameplay boundary;
2. static wall inward face aligns with that boundary;
3. wall body thickness extends outward where practical;
4. center-safe bound = visible edge ± physical body radius ± a tiny documented solver epsilon only;
5. no unrelated HUD inset enters the calculation.

Do not arbitrarily shrink M05 collider radii to obtain more room.

## Preserve

- current canonical background PNG;
- current table perspective;
- accepted `death_line_y`;
- accepted `launch_y`;
- launch speed 700 px/s;
- deceleration 180 px/s²;
- merge/momentum/economy/Game Over behavior;
- no guide line;
- all completed M07-R04 owner rules.

## Required M06-R05 evidence

For each viewport:

- 720x1280
- 720x1440
- 800x1280

retain:

- clean screenshot;
- geometry overlay showing visible tabletop left/right edges;
- static wall inward faces;
- computed center-safe bounds;
- representative L01, L06 and L12 placements reaching/touching left and right limits at far/middle/near depths without body escape;
- evidence that HUD rectangles are not consulted for physics bounds.

Write only:

`coordination/sessions/BCM-M06-R05/CODEX_LOG_V01.md`

Commit and push M06-R05 separately before Phase 2.

---

# PHASE 2 — M07-R05 — Post-geometry HUD adaptation only

Read:

`coordination/sessions/BCM-M07-R05/CHATGPT_AUDIT_CRITERIA_V01.md`

This phase is NOT a replay of M07-R04.

Preserve every completed M07-R04 behavior. Only adapt HUD positioning where necessary after M06-R05 opens the full tabletop.

## BEST SCORE / SCORE placement

The owner wants the upper tabletop visually open.

- move BEST SCORE and SCORE upward as much as practical;
- preserve left-side order: logo → BEST SCORE → SCORE;
- keep all three fully on-screen;
- do not overlap logo;
- do not overlap To-Go Orders;
- do not overlap each other;
- keep BEST SCORE and SCORE above the tabletop accumulation/play region as much as practical;
- do not let their rectangles alter or shrink the M06-R05 playfield.

### Preserve completed M07-R04 score behavior

- fixed font size only;
- fixed font must remain safe through 7 digits including `9999999`;
- no digit-count auto-shrink;
- runtime number only inside the baked dark value window.

## Preserve completed M07-R04 To-Go behavior

- runtime content = target cocktail + reward digits only;
- no `Lx`;
- no level name;
- no cocktail name;
- no leading `+` before reward;
- both hanging ropes remain visually connected to the top edge of the gameplay viewport.

## Preserve completed M07-R04 NEXT behavior

- one NEXT panel only;
- L01-L12 each remain within measured safe cream content bounds;
- true-next synchronization remains correct.

## Preserve completed M07-R04 held-drink behavior

- per-level visible glass/container bottom anchor remains active;
- held body bottoms remain on the common launch baseline;
- visual offset only;
- physics/collider center remains unchanged.

## Preserve progression

- current baked 2x6 artwork;
- top row L07-L12;
- bottom row L01-L06;
- runtime cocktail sprites only;
- no runtime cell frames.

## Required M07-R05 evidence

For all three required viewports retain clean screenshots proving:

- upper tabletop is visually more open;
- logo/BEST/SCORE remain fully visible and non-overlapping;
- full M06-R05 playfield remains available underneath/independent of HUD;
- all M07-R04 behavior remains intact.

Write only:

`coordination/sessions/BCM-M07-R05/CODEX_LOG_V01.md`

Commit and push M07-R05 separately.

---

# FINAL REGRESSION

After M07-R05, run the complete candidate-main regression:

- M01 contract
- M02 physics/collision/merge
- M03 economy/To-Go/persistence/Game Over
- M04 asset import
- M05 sprite/collider
- M06-R05 full-tabletop geometry probe
- M07-R04 owner-HUD behavior checks
- M07-R05 post-geometry HUD adaptation checks
- Godot 4.7.x import/startup
- `git diff --check`

Do not weaken prior tests to obtain green output.

## Final response

Return only:

1. existing completed M07-R04 log URL + its commit SHA
2. M06-R05 log URL + commit SHA
3. M07-R05 log URL + commit SHA
4. one-line final regression result
5. `AWAITING_AUDIT`

Then STOP for independent ChatGPT audit.
