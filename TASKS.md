# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the authoritative current project-status tracker. GitHub `main`, locked ChatGPT audit criteria, independent audits, owner runtime screenshots/annotations, and committed repository evidence define project truth.

## Project Status

- Current Milestone: M08
- Current Sprint: BCM-M08-TO-GO-DELIVERY-POLISH
- Current Task: Integrate To-Go delivery animation and restrained merge/order visual feedback without changing accepted physics, scoring, table-edge behavior, HUD layout, or canonical assets.
- Current Task Status: OWNER_RUNTIME_VERIFICATION_REQUIRED
- Next Task/Action: Owner runs the normal Godot GUI/F5 build and visually verifies M08 merge feedback, To-Go delivery trail, order-completion flash, unchanged HUD/table composition, and absence of distracting effect stacking. Source/state audit passed; M08 closes only after owner runtime acceptance.
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

## Active M08 delivery polish — source audited, owner runtime verification required

Locked criteria:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_EXECUTION_PROMPT_V01.md`

Independent audit:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_V01.md` — SOURCE_AUDITED_PASS / OWNER_RUNTIME_VERIFICATION_REQUIRED.

Scope is visual polish only. Accepted physics, scoring, R11 table-edge behavior, rails, HUD layout, canonical assets and gameplay contracts are frozen.

## M08-M21 — Roadmap

### M08 — To-Go delivery polish

- [~] BCM-M08-001 — Integrate To-Go delivery animation and restrained visual effects.
- [ ] BCM-M08-002 — Preserve accepted physics, scoring, table-edge footprint, HUD placement, and canonical assets during delivery polish.
- [ ] BCM-M08-003 — Run focused and full regression evidence and close only after independent audit.

### M09 — Audio, haptics, and micro-polish

- [ ] BCM-M09-001 — Add bounded merge, order-complete, VIP, level-win, level-fail, and UI audio hooks.
- [ ] BCM-M09-002 — Add optional mobile haptics with settings toggle and safe no-op fallback on unsupported platforms.
- [ ] BCM-M09-003 — Add restrained timer urgency feedback that does not alter gameplay physics or obscure the board.
- [ ] BCM-M09-004 — Add regression coverage for audio/haptic toggles and pause/resume behavior.

### M10 — Campaign architecture and canonical data model

- [ ] BCM-M10-001 — Introduce Campaign Module boundaries: CampaignManager, LevelDatabase, SaveManager, GameEconomy, and GameplaySessionBridge.
- [ ] BCM-M10-002 — Define canonical island schema with island id, display name, level count, unlock rule, next-island relation, map/background references, and reward-track metadata.
- [ ] BCM-M10-003 — Define canonical level schema with island id, level id, timer, normal To-Go objectives, optional VIP objective, rewards, score/star thresholds, and feature flags.
- [ ] BCM-M10-004 — Define player progression/save schema for unlocked islands, unlocked levels, completion state, stars, best score, claimed milestone rewards, boosters, coins, and schema version.
- [ ] BCM-M10-005 — Implement schema validation and deterministic loading failures for malformed/duplicate/missing campaign data.
- [ ] BCM-M10-006 — Document campaign data ownership and extension rules so future islands require data/content changes rather than gameplay rewrites.

### M11 — Save, migration, and campaign progression core

- [ ] BCM-M11-001 — Implement SaveManager persistence under user:// with atomic-write/backup strategy and explicit schema version.
- [ ] BCM-M11-002 — Preserve existing best-score and gameplay persistence while migrating into campaign-aware save state.
- [ ] BCM-M11-003 — Implement CampaignManager APIs for island unlock, level unlock, completion, replay, star update, reward claim, and next-level resolution.
- [ ] BCM-M11-004 — Make completion idempotent so replaying a level cannot duplicate one-time unlock or milestone rewards.
- [ ] BCM-M11-005 — Define recovery behavior for absent, older, malformed, and partially written saves without silently erasing valid owner progress.
- [ ] BCM-M11-006 — Add automated tests for first boot, progression, replay, migration, corrupted-save fallback, and persistence reload.

### M12 — World Map

- [ ] BCM-M12-001 — Create reusable WorldMapScene that reads island definitions from LevelDatabase/CampaignManager rather than hardcoded progression logic.
- [ ] BCM-M12-002 — Add island nodes/cards for Sunny Cove and future islands with OPEN, LOCKED, COMPLETE, and CURRENT presentation states.
- [ ] BCM-M12-003 — Implement sequential island unlock rules with Sunny Cove open by default and Tiki Island locked until Sunny Cove completion.
- [ ] BCM-M12-004 — Implement navigation from main flow to world map and from world map to selected island map.
- [ ] BCM-M12-005 — Add clear locked-island reason/progress text without requiring character animation or additional gameplay scenes.
- [ ] BCM-M12-006 — Make layout mobile-safe and data-driven for at least 10 planned islands without scene-code duplication.
- [ ] BCM-M12-007 — Add tests for island state rendering, selection, lock enforcement, and save reload.

### M13 — Reusable Island Map and 100-level path

- [ ] BCM-M13-001 — Create generic IslandMapScene receiving island_id and rendering its configured level count.
- [ ] BCM-M13-002 — Create reusable LevelButton component with level number, locked/unlocked/current/completed state, 0-3 stars, and milestone marker.
- [ ] BCM-M13-003 — Implement a vertically scrollable mobile path capable of showing 100 level nodes without creating 100 unique scenes.
- [ ] BCM-M13-004 — Implement deterministic path/layout generation or reusable authored anchor pattern so every island can use one map engine with different skin/data.
- [ ] BCM-M13-005 — Auto-scroll/focus to the highest currently unlocked unfinished level when entering an island.
- [ ] BCM-M13-006 — Add milestone presentation for levels 10/20/30/40/50/60/70/80/90/100 without requiring bespoke gameplay art.
- [ ] BCM-M13-007 — Add island summary UI for stars earned, levels completed, next milestone, and island completion.
- [ ] BCM-M13-008 — Add navigation back to World Map and safe restoration of selected/scroll state.

### M14 — Level launch and timed gameplay session bridge

- [ ] BCM-M14-001 — Implement GameplaySessionBridge to launch the existing gameplay scene from selected campaign level data.
- [ ] BCM-M14-002 — Feed level timer, normal To-Go objectives, optional VIP objective, rewards, and scoring rules into gameplay without retuning accepted launch/merge/table physics.
- [ ] BCM-M14-003 — Add authoritative countdown timer with start, pause, resume, app-background, success-stop, and timeout behavior.
- [ ] BCM-M14-004 — Define win condition as completion of all normal level orders before timer expiry.
- [ ] BCM-M14-005 — Define VIP objective as optional; VIP failure must never block normal level completion.
- [ ] BCM-M14-006 — Add win/lose result model and return flow to Retry, Next Level, and Island Map.
- [ ] BCM-M14-007 — Prevent campaign objectives from breaking the existing To-Go rule that qualifying stored L6-L12 drinks may satisfy later matching orders.
- [ ] BCM-M14-008 — Add regression tests proving campaign mode preserves accepted core merge/scoring/edge behavior.

### M15 — VIP orders, boosters, rewards, and economy hooks

- [ ] BCM-M15-001 — Add a compact VIP badge/state to the existing To-Go Orders UI without customer characters or new animated scenes.
- [ ] BCM-M15-002 — Implement optional VIP completion reward dispatch for booster rewards.
- [ ] BCM-M15-003 — Define initial booster inventory model and campaign reward integration.
- [ ] BCM-M15-004 — Implement +Time booster contract for timed levels without altering base timer definitions.
- [ ] BCM-M15-005 — Implement one-time milestone reward claim state and duplicate-claim protection.
- [ ] BCM-M15-006 — Add coin/reward ledger hooks while keeping campaign completion independent from purchases or ads.
- [ ] BCM-M15-007 — Add tests for VIP optionality, reward grant, inventory persistence, replay, and duplicate prevention.

### M16 — Sunny Cove canonical Level 1-100 content

- [ ] BCM-M16-001 — Add Sunny Cove island definition with exactly 100 sequential levels.
- [ ] BCM-M16-002 — Encode the approved minimum normal target rule: no normal campaign target below L5.
- [ ] BCM-M16-003 — Encode spawn assumption baseline L1-L3 and merge cost model L(n)=2^(n-1) L1-equivalent units.
- [ ] BCM-M16-004 — Encode timer baseline from calculated production time multiplied by exactly 2; do not add a fixed minimum-time padding.
- [ ] BCM-M16-005 — Set Level 1 baseline to 1×L5 with approximately 20 seconds.
- [ ] BCM-M16-006 — Keep Sunny Cove normal targets within L5-L8 and reserve L9 as future-island progression content.
- [ ] BCM-M16-007 — Set Sunny Cove Level 100 target to 1×L8 + 1×L7 + 1×L6 + 1×L5 with a 300-second / 5:00 timer.
- [ ] BCM-M16-008 — Populate all 100 Sunny Cove level records from the approved progression table, including intentional difficulty-wave relief levels.
- [ ] BCM-M16-009 — Add VIP placements/rewards separately from the normal timer-cost calculation.
- [ ] BCM-M16-010 — Validate unique ids, sequential unlock chain, objective legality, timers, and Level 1/100 anchor values in automated tests.

### M17 — Difficulty model and level validation

- [ ] BCM-M17-001 — Implement deterministic L1-equivalent objective cost calculation for every campaign level.
- [ ] BCM-M17-002 — Implement timer-calculation tooling that exposes theoretical cost, expected L1-L3 spawn production, raw calculated time, and ×2 final target time.
- [ ] BCM-M17-003 — Treat theoretical merge cost as a lower-level planning metric only; do not assume spatially separated same-level cocktails merge for free.
- [ ] BCM-M17-004 — Define spatial-complexity telemetry for board occupancy, large-piece coexistence, travel/contact time, congestion, and failed merge approaches.
- [ ] BCM-M17-005 — Build a level validation/simulation harness or replayable bot test interface that can run repeated seeded trials against campaign data.
- [ ] BCM-M17-006 — Report completion rate, median completion time, percentile completion times, timeout causes, and board-congestion metrics per tested level.
- [ ] BCM-M17-007 — Flag mathematically impossible, effectively impossible, or outlier levels before they are accepted into canonical campaign data.
- [ ] BCM-M17-008 — Tune data only after evidence; never hide impossible level design behind arbitrary timer extensions.

### M18 — Stars, score mastery, milestones, and replay

- [ ] BCM-M18-001 — Define star award contract using completion, VIP completion, and score mastery rather than using stars as the island-unlock gate.
- [ ] BCM-M18-002 — Preserve best score per level and only replace stored stars/score when the replay result is better.
- [ ] BCM-M18-003 — Add Sunny Cove cumulative star/reward track with non-blocking milestone rewards.
- [ ] BCM-M18-004 — Keep next-level progression based on level completion, not mandatory perfect-star replay.
- [ ] BCM-M18-005 — Add replay flow from Island Map with previously earned state visible.
- [ ] BCM-M18-006 — Add tests for star upgrades, worse replay preservation, milestone claims, and 100% island completion.

### M19 — Multi-island scalability and Tiki Island handoff

- [ ] BCM-M19-001 — Prove the campaign engine can load a second island without duplicating CampaignManager, IslandMap, LevelButton, timer, or save logic.
- [ ] BCM-M19-002 — Add Tiki Island locked placeholder and unlock it only when Sunny Cove Level 100 is completed.
- [ ] BCM-M19-003 — Reserve L9 introduction for Tiki Island data and document higher-level progression policy for later islands.
- [ ] BCM-M19-004 — Define planned island sequence: Sunny Cove, Tiki Island, Azure Bay, Coconut Beach, Sunset Island, Party Beach, Frozen Paradise, Volcano Bay, Billionaire Island, and final island slot/name TBD.
- [ ] BCM-M19-005 — Define per-island skin/background hooks while keeping the same core table/gameplay engine.
- [ ] BCM-M19-006 — Add regression proving a new island can be added primarily through data plus map/background assets.

### M20 — Menus, onboarding, settings, accessibility, and campaign UX polish

- [ ] BCM-M20-001 — Integrate campaign entry into main menu/start flow.
- [ ] BCM-M20-002 — Add minimal first-run onboarding for World Map, Island Map, timed order objective, VIP optionality, and level completion.
- [ ] BCM-M20-003 — Add settings for audio, haptics, accessibility-relevant feedback, and other release-required toggles.
- [ ] BCM-M20-004 — Add pause/resume and app-lifecycle behavior that cannot consume campaign time while legitimately paused/backgrounded.
- [ ] BCM-M20-005 — Add concise locked/unlocked/milestone/result UX without adding character systems or animation-heavy meta gameplay.
- [ ] BCM-M20-006 — Complete save migration and backward-compatibility verification for existing players.

### M21 — Mobile QA, final regression, packaging, and v1 campaign release closure

- [ ] BCM-M21-001 — Validate mobile layout and touch navigation across World Map, 100-level Island Map, gameplay, and result flow.
- [ ] BCM-M21-002 — Profile Island Map node count, scrolling, loading, save IO, and gameplay memory/performance on target devices.
- [ ] BCM-M21-003 — Run full campaign progression test from fresh save through Sunny Cove Level 100 and Tiki Island unlock.
- [ ] BCM-M21-004 — Run full legacy gameplay regression for physics, merge, scoring, To-Go behavior, R11 table-edge footprint, and HUD.
- [ ] BCM-M21-005 — Validate export/release configuration, persistence across app restarts, and no developer/test-only progression bypass.
- [ ] BCM-M21-006 — Complete independent audit, owner runtime acceptance, documentation, packaging, and v1 campaign release closure.

## Campaign design references

- Technical architecture: `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`.
- Sunny Cove content/timer contract: `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md`.

M21 completion = Beach Cocktails Merge v1 campaign release-ready closure.
