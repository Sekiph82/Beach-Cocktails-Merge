# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M08
- Current Sprint: BCM-M08-TO-GO-DELIVERY-POLISH
- Current Task: Integrate To-Go delivery animation and restrained merge/order visual feedback without changing accepted physics, scoring, table-edge behavior, HUD layout, or canonical assets.
- Current Task Status: READY
- Next Task/Action: Codex executes `coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_EXECUTION_PROMPT_V01.md`, implements bounded To-Go delivery/merge feedback, runs focused/full regressions, pushes evidence/log, then stops for independent audit.
- Required Actor: CODEX
- Tracking Repository: Sekiph82/Beach-Cocktails-Merge
- Tracking Branch: main

## Tasks

- [x] BCM-M00-001 — Repository synchronization and evidence baseline.
- [x] BCM-M00-002 — Repository hygiene, canonical structure, and Godot import baseline.
- [x] BCM-M01-001 — Recover and verify playable gameplay contract from synchronized v6.7 state.
- [x] BCM-M02-001 — Formalize physics, collision, merge, and rapid-launch regression suite.
- [x] BCM-M03-001 — Formalize scoring, combo, To-Go Orders, persistence, and game-over systems.
- [x] BCM-M04-001 — Canonical refreshed visual asset family accepted from owner runtime evidence.
- [x] BCM-M05-001 — Independent sprite/body/collider evidence closure completed and audited.
- [x] BCM-M06-001 — Three-sided playable-envelope and cocktail-to-edge behavior closed by owner-accepted BCM-R11 table-footprint solution.
- [x] BCM-M07-001 — HUD alignment/refinement closed; owner-accepted BEST/SCORE/NEXT/logo/To-Go/held behavior preserved through R11 regression.
- [~] BCM-M08-001 — Integrate To-Go delivery animation and restrained visual effects.
- [ ] BCM-M09-001 — Add gameplay feedback polish, audio, and optional haptics.
- [ ] BCM-M10-001 — Add menus, settings, onboarding, accessibility, save migration, and UX polish.
- [ ] BCM-M11-001 — Mobile layout, performance, export, device QA, and release readiness.
- [ ] BCM-M12-001 — Final regression, acceptance, packaging, documentation, and v1 release closure.

Legend: `[x]` audited complete, `[~]` active/pending owner closure, `[!]` reopened/changes required, `[ ]` planned.

## Governance

- Codex must never edit this file.
- Prompt and locked audit criteria are created before implementation/remediation.
- Codex logs are builder evidence, not acceptance proof.
- ChatGPT independently audits actual diff/source/tests/evidence against locked criteria.
- Owner runtime screenshots and annotations are authoritative when later than earlier audit interpretations.
- Only ChatGPT updates this tracker after audit.
- No guide line.

## M00-M04 — Accepted baseline

- [x] M00 repository baseline.
- [x] M01 launch/current/next/gameplay contract.
- [x] M02 collision/merge/rapid-launch physics.
- [x] M03 scoring/combo/To-Go/persistence/Game Over.
- [x] M04 refreshed canonical visual asset family.



## M05 strict closure — audited pass

Locked criteria:
`coordination/sessions/BCM-M05-STRICT-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M05-STRICT-CLOSURE/CHATGPT_EXECUTION_PROMPT_V01.md`

Independent audit:
`coordination/sessions/BCM-M05-STRICT-CLOSURE/CHATGPT_AUDIT_V01.md` — AUDITED_PASS.

Production gameplay, R11 table-edge behavior, collider radii, canonical PNGs and HUD remained frozen.

## M05-R02 — Still open

Audit:
`coordination/sessions/BCM-M05-R02/CHATGPT_AUDIT_V01.md`

Verdict: **CHANGES_REQUIRED**.

Open concerns remain around independently evidenced body/collider measurements, shape classification, and contact-fit proof.

## Owner-approved behavior to preserve

Latest owner runtime evidence establishes:
- auto-fire / uncommanded drink creation is resolved;
- BEST SCORE digits are correctly centered inside their value recess;
- SCORE digits are correctly centered inside their value recess;
- To-Go Orders top placement / rope-to-ceiling result is correct;
- held drink is correctly positioned on the gold launch oval;
- NEXT content behavior and baked 2x6 progression are functionally accepted.

R10 V05 may reposition BEST SCORE, NEXT and the logo only as required by the alignment instructions; it must preserve the accepted internal content/number fit and all gameplay behavior.

## R11 table-edge closure — audited pass

Independent audit:
`coordination/sessions/BCM-R11-TABLE-EDGE-CLOSURE/CHATGPT_AUDIT_V01.md` — AUDITED_PASS for M06 closure.

Owner-accepted R11 implementation:
`9d6d8950da5f62f6c22d495f58414d70d034d893`

R11 supersedes the failed R10 V09/V10 full-silhouette boundary model. The authoritative table contact representation is now the glass table-plane footprint, not the full cocktail silhouette. Boundary enforcement runs at all relevant speeds and is shared by live motion, merge correction, drag positioning, and settling.

Historical R10 V09/V10 full-hull containment probes are superseded acceptance artifacts and must not block current R11 behavior.

M06 is closed. M07 is closed based on preserved owner-accepted visual behavior and passing regression evidence.

M05-R02 remains the only pre-M08 blocker.

## Historical R10 V10 — superseded by R11

Locked criteria:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_CRITERIA_V09.md`

Independent audit:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V07.md` — CHANGES_REQUIRED.

Independent audit:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V06.md` — SOURCE_AUDITED_PASS / OWNER_RUNTIME_VERIFICATION_REQUIRED.

Independent audit:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V05.md` — CHANGES_REQUIRED.

Execution prompt:
`coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_EXECUTION_PROMPT_V09.md`

### V05 owner-approved baseline

The owner visually accepted the current three-sided playable envelope. Do not move it in V06.

The V05 explicit post-merge boundary clamp also improved gameplay feel and must be preserved.

### V07 independent edge-contact dataset audit result

Mandatory owner rule for all L01-L12:

`rear_target_y = rear_table_y`

Forbidden rear-target adjustments include collider radius, body half extent, sprite/drink height, width, per-level Y offsets or per-level rear-target tables.

Required boundary closure:
1. Move left and right playable rails modestly inward to the owner's annotated white-line intent.
2. Move the opposite/rear playable boundary inward to the owner's annotated white-line position as well.
3. Moving RigidBody2D cocktails physically reach the owner-defined `rear_table_y` line.
4. Physical rear collision, clamp/target and `rear_table_y` are coherent.
5. Preserve the perspective/trapezoidal playable envelope.
6. Validate actual moving contacts at left, right, and opposite/rear boundaries, not direct-spawn coordinate agreement only.

### Critical V07 finding

The explicit `TABLE_EDGE_CONTACT_HALF_WIDTHS` array exists, but the values numerically reproduce:

`source_contact_width * visual_scale_for_level / 2`

where `visual_scale_for_level` is collider-radius-derived.

Therefore the dataset is structurally hardcoded but not independent from collider radius as required.

A next remediation must obtain/calibrate runtime contact distances independently from collider-defined sprite scaling.

### Edge-contact / merge-wall rules

1. Keep drink-to-drink collider radii unchanged.
2. Introduce a separate 2D table-edge contact footprint/clearance derived from the visible glass/container body, excluding garnish and transparent margins.
3. Side center limits use the table-edge footprint instead of automatically using the full drink collider radius.
4. The preserved V05 merge clamp must use the new table-edge footprint for X containment.
5. Enable/test RigidBody2D CAST_SHAPE continuous collision detection as an auxiliary stabilizer.
6. Do not implement a fake unsupported CollisionShape2D margin API or CharacterBody2D safe-margin behavior.
7. Rear target remains exactly `rear_target_y = rear_table_y`.
8. Playable envelope coordinates must remain unchanged.

### Audit result

Independent audit: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V04.md` — CHANGES_REQUIRED / OWNER_RUNTIME_VERIFICATION_REQUIRED.

Key finding: the V06 `edge_contact_half_width` algebraically reduces to `collider_radius * visual_body_depth_scale_for_y`, where the scale is only 0.96–1.0. This yields only ~0.4–1.9 px less clearance in the retained sample cases, so the new footprint is structurally separate but not meaningfully independent from collider radius. CAST_SHAPE CCD was already active before V06 and therefore did not introduce a new corrective effect.

### Preserved HUD / runtime rules

1. Move the left/right playable rails modestly inward while preserving perspective and usable table area.
2. When a merge creates a larger drink near a side wall, immediately clamp the new result to the authoritative valid X range using the new drink's current half-width before physics overlap resolution can eject it inward.
3. Test Solution 1 only in this round. Do not use Continuous CD tuning, collision-margin tuning, or one-frame freeze as the primary remedy.
4. Preserve meaningful inherited momentum after merge.

### HUD alignment rules

Alignment definitions:
- vertical alignment = equal visual center X;
- horizontal alignment = equal visual bottom Y.

Required layout:
1. SCORE stays at its current accepted position.
2. BEST SCORE moves so its visible bottom Y equals SCORE visible bottom Y.
3. NEXT moves so its visual center X equals SCORE visual center X.
4. Beach Cocktails Merge logo becomes modestly larger with preserved aspect ratio.
5. Logo moves as needed so its visual center X equals BEST SCORE visual center X.
6. BEST/SCORE number centering remains correct after panel movement.
7. To-Go top placement and held-drink/gold-oval alignment remain unchanged.
8. HUD layout never affects gameplay/table bounds.

Independent audit: `coordination/sessions/BCM-R10-RUNTIME-PHYSICS-CLOSURE/CHATGPT_AUDIT_V03.md` — CHANGES_REQUIRED / OWNER_RUNTIME_VERIFICATION_REQUIRED. Source-level geometry, rear-target formula, Solution 1 merge X clamp and HUD alignment code are present, but final GUI visual proof is missing and the physical TopRail does not literally coincide with `rear_table_y` under the locked criterion.

M05, M06 and M07 are closed. M08 may start.

## Active M08 delivery polish

Locked criteria:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_EXECUTION_PROMPT_V01.md`

Scope is visual polish only. Accepted physics, scoring, R11 table-edge behavior, rails, HUD layout, canonical assets and gameplay contracts are frozen.

## M08-M12 — Planned

- [ ] M08 — To-Go delivery and restrained merge/order effects.
- [ ] M09 — Audio, optional haptics and micro-polish.
- [ ] M10 — Menus, onboarding, settings, accessibility and save migration.
- [ ] M11 — Mobile performance/export/device QA.
- [ ] M12 — Full final regression, owner visual acceptance, packaging and release closure.

M12 completion = Beach Cocktails Merge v1 release-ready closure.
