# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the **only** authoritative live project-status tracker and the **only project-status file consumed by the H!veAI parser**. GitHub repository metadata and the latest `main` commit are the remaining project-truth inputs. No parallel session index, roadmap, audit index, dashboard, hidden control-plane tracker, or equivalent status mirror is permitted. Prompts, criteria, logs, audits, manifests, and historical branch task files are evidence only, never competing current-state authorities.

## Project Status

- Current Milestone: M17
- Current Sprint: BCM-M17-DIFFICULTY-VALIDATION
- Current Task: Build the M17 deterministic difficulty model, transparent timer-planning tool, spatial telemetry schema, seeded/replayable validation harness, and first peak/relief baseline report without tuning canonical levels.
- Current Task Status: READY_FOR_CODEX
- Next Task/Action: Codex executes BCM-M17 V01 tooling/evidence foundation for M17-001..006, publishes the baseline report, and stops for independent audit. M17-007/008 tuning/outlier decisions remain blocked.
- Required Actor: CODEX
- Tracking Repository: Sekiph82/Beach-Cocktails-Merge
- Tracking Branch: main
- Progress: 68 / 101 = 67.33%. M16 is independently audited and owner-accepted. M17 V01 is active for difficulty-model/telemetry/harness foundation with canonical level data frozen.

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

Detailed canonical task rows for M08+ appear in the roadmap sections below. Each canonical task ID must appear exactly once in this file so the H!veAI parser cannot observe conflicting state.

Legend: `[x]` audited complete, `[~]` active/pending owner closure, `[!]` reopened/changes required, `[ ]` planned.

## Governance

> **H!veAI tracking [OWNER-LOCKED — 2026-09-28]:** repository-root `TASKS.md` is the one and only live project-status tracker and H!veAI parser input. The top `Project Status` block controls current milestone, sprint, task, workflow status, next action, required actor, repository, branch, and progress. Every canonical task ID must appear exactly once. Do not create or maintain `coordination/SESSION_INDEX.md`, `coordination/AUDIT_INDEX.md`, `docs/04_ROADMAP.md`, `.hiveai/PROJECT_DASHBOARD.md`, `.hiveai/*` control-plane files, or any equivalent parallel tracker/status mirror. Audit/prompt/log files and historical task lists may exist only as evidence. **ChatGPT is the sole writer of root `TASKS.md`; Codex reads it but never edits it.** ChatGPT updates it after every independent audit, owner-gate decision, and before handing off the next implementation prompt.

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

## M08 delivery polish — closed with trail verification carried forward

Locked criteria:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_EXECUTION_PROMPT_V01.md`

Independent audit:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_V01.md` — owner runtime feedback recorded; visual remediation required.

V02 locked criteria:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_AUDIT_CRITERIA_V02.md`

V02 execution prompt:
`coordination/sessions/BCM-M08-TO-GO-DELIVERY-POLISH/CHATGPT_EXECUTION_PROMPT_V02.md`

Scope is visual polish only. Accepted physics, scoring, R11 table-edge behavior, rails, HUD layout, canonical assets and gameplay contracts are frozen.

## M09 audio haptics micro-polish — audited and owner accepted

Locked criteria:
`coordination/sessions/BCM-M09-AUDIO-HAPTICS-MICRO-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M09-AUDIO-HAPTICS-MICRO-POLISH/CHATGPT_EXECUTION_PROMPT_V01.md`

Independent audit:
`coordination/sessions/BCM-M09-AUDIO-HAPTICS-MICRO-POLISH/CHATGPT_AUDIT_V01.md` — SOURCE_AUDITED_PASS / OWNER_RUNTIME_VERIFICATION_REQUIRED.

Owner-requested startup sequence for the normal main gameplay flow:
L5 -> L6 -> L7, then existing normal target selection resumes.

The existing reward table is frozen. L5 reward remains 0 unless the owner later changes the economy contract.

M08 yellow delivery-trail visibility is a carry-forward runtime verification item in this milestone.

## M10 campaign architecture — audited pass

Locked criteria:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_EXECUTION_PROMPT_V01.md`

Independent audit:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_V01.md` — CHANGES_REQUIRED.

V02 locked criteria:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_CRITERIA_V02.md`

V02 execution prompt:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_EXECUTION_PROMPT_V02.md`

V02 independent audit:
`coordination/sessions/BCM-M10-CAMPAIGN-ARCHITECTURE/CHATGPT_AUDIT_V02.md` — AUDITED_PASS.

Scope is architecture/data foundation only. World Map, Island Map, live save migration, timer gameplay, VIP runtime, boosters and the full 100-level Sunny Cove dataset remain deferred.

## M11 save migration progression — audited pass

Locked criteria:
`coordination/sessions/BCM-M11-SAVE-MIGRATION-PROGRESSION/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M11-SAVE-MIGRATION-PROGRESSION/CHATGPT_EXECUTION_PROMPT_V01.md`

Scope: campaign persistence, backup/recovery, legacy best-score migration, idempotent progression, and isolated save tests only. Campaign UI and timed gameplay remain deferred.

## M12 World Map — Closed

Final owner-accepted audit:
`coordination/sessions/BCM-M12-WORLD-MAP/CHATGPT_AUDIT_FINAL_CLOSURE_V03.md` — **AUDITED_PASS / OWNER_ACCEPTED**.

M12 closure:
- 398/398 manifest/checksum PASS;
- 10/10 V2 table families PASS;
- invalid semantic duplicates = 0;
- M12 deterministic clean-import regression PASS twice;
- all visual sets owner accepted.

## M13 Island Map — Closed

Independent audit V02:
`coordination/sessions/BCM-M13-ISLAND-MAP/CHATGPT_AUDIT_V02.md` — **AUDITED_PASS**.

M13 closure:
- generic data-driven IslandMapScene PASS;
- reusable LevelButton PASS;
- 100-node mobile path PASS;
- milestones/summary/state rendering PASS;
- real M12↔M13 campaign navigation PASS;
- first-entry highest-unlocked-unfinished focus PASS;
- exact selected/focus/scroll restoration PASS;
- M10/M11/M12 regressions preserved.

## M14 Gameplay Session Bridge — Closed

Independent audit V02:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CHATGPT_AUDIT_V02.md` — **AUDITED_PASS**.

M14 closure:
- executable campaign shell entry PASS;
- real M12 -> M13 -> M14 launch PASS;
- immutable session and authoritative timer PASS;
- production gameplay pause/background lifecycle PASS;
- normal To-Go objective win/lose PASS;
- optional VIP semantics PASS;
- corrected 1/2/3-star contract PASS;
- Retry / Next / Island Map PASS;
- campaign progression/regressions preserved.

## Active M15 — VIP, Boosters, Rewards & Economy

Locked criteria:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V01.md`

Execution prompt:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_EXECUTION_PROMPT_V01.md`

Pending independent audit:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_V01.md`

Independent audit V01:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_V01.md` — **CHANGES_REQUIRED**.

V02 locked criteria:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V02.md`

V02 execution prompt:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_EXECUTION_PROMPT_V02.md`

Independent audit V02:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_V02.md` — **TECHNICAL_AUDIT_PASS / OWNER_VISUAL_ACCEPTANCE_REQUIRED**.

Owner ruling V03:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V03.md`
- VIP targets follow the same campaign To-Go target eligibility rule as normal objectives; no separate VIP range.
- Each accepted VIP cocktail delivery pays 2× the normal To-Go reward for that same level.
- Existing configured VIP economy reward remains separate and one-time on normal WIN + VIP completion.

V03 locked criteria:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V03.md`

V03 execution prompt:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_EXECUTION_PROMPT_V03.md`

Independent audit V03:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_V03.md` — **TECHNICAL_AUDIT_PASS / OWNER_VISUAL_ACCEPTANCE_REQUIRED**.

Owner rejected the V03 inline VIP presentation. Technical V03 behavior remains accepted.

Owner visual ruling V04:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V04.md`

V04 locked criteria:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V04.md`

V04 execution prompt:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_EXECUTION_PROMPT_V04.md`

Independent audit V04:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_V04.md` - **TECHNICAL_AUDIT_PASS / OWNER_VISUAL_ACCEPTANCE_REQUIRED**.

Owner rejected the V04 runtime composition after visual review; V04 technical behavior remains accepted.

Owner-approved V05 canonical HUD asset:
`assets/ui/panel_to_go_vip_orders.png` — source width 1132 px, matching the previous To-Go source width.

Owner ruling V05:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V05.md`

V05 locked criteria:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V05.md`

V05 execution prompt:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_EXECUTION_PROMPT_V05.md`

Independent audit V05:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_V05.md` — **TECHNICAL_AUDIT_PASS / OWNER_VISUAL_ACCEPTANCE_REQUIRED**.

V05 technical audit passed. Owner runtime visual acceptance remains required
for the four committed V05 captures before M15 closure.

V05 technical audit passed, but owner runtime visual acceptance was rejected because the combined HUD was too short/small relative to BEST SCORE/SCORE and the ropes were too short.

V06 owner ruling:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V06.md`

V06 locked criteria:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V06.md`

V06 execution prompt:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_EXECUTION_PROMPT_V06.md`

V06 pending audit:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_V06.md`

M16 must not begin until V06 technical audit and owner runtime visual acceptance close M15.

Scope:
- persistent GameEconomy authority;
- VIP reward dispatch;
- booster inventory;
- +Time contract;
- milestone rewards;
- coin/reward ledger;
- compact VIP state;
- no purchases/ads/backend;
- no M16 production level content;
- no R11 physics/HUD geometry retuning.


## M08-M21 — Roadmap

### M08 — To-Go delivery polish

- [x] BCM-M08-001 — Integrate To-Go delivery animation and restrained visual effects.
- [x] BCM-M08-002 — Preserve accepted physics, scoring, table-edge footprint, HUD placement, and canonical assets during delivery polish.
- [x] BCM-M08-003 — Run focused and full regression evidence and close only after independent audit.

### M09 — Audio, haptics, and micro-polish

- [x] BCM-M09-001 — Add bounded merge, order-complete, VIP, level-win, level-fail, and UI audio hooks.
- [x] BCM-M09-002 — Add optional mobile haptics with settings toggle and safe no-op fallback on unsupported platforms.
- [ ] BCM-M09-003 — Add restrained timer urgency feedback that does not alter gameplay physics or obscure the board.
- [x] BCM-M09-004 — Add regression coverage for audio/haptic toggles and pause/resume behavior.

### M10 — Campaign architecture and canonical data model

- [x] BCM-M10-001 — Introduce Campaign Module boundaries: CampaignManager, LevelDatabase, SaveManager, GameEconomy, and GameplaySessionBridge.
- [x] BCM-M10-002 — Define canonical island schema with island id, display name, level count, unlock rule, next-island relation, map/background references, and reward-track metadata.
- [x] BCM-M10-003 — Define canonical level schema with island id, level id, timer, normal To-Go objectives, optional VIP objective, rewards, score/star thresholds, and feature flags.
- [x] BCM-M10-004 — Define player progression/save schema for unlocked islands, unlocked levels, completion state, stars, best score, claimed milestone rewards, boosters, coins, and schema version.
- [x] BCM-M10-005 — Implement schema validation and deterministic loading failures for malformed/duplicate/missing campaign data.
- [x] BCM-M10-006 — Document campaign data ownership and extension rules so future islands require data/content changes rather than gameplay rewrites.

### M11 — Save, migration, and campaign progression core

- [x] BCM-M11-001 — Implement SaveManager persistence under user:// with atomic-write/backup strategy and explicit schema version.
- [x] BCM-M11-002 — Preserve existing best-score and gameplay persistence while migrating into campaign-aware save state.
- [x] BCM-M11-003 — Implement CampaignManager APIs for island unlock, level unlock, completion, replay, star update, reward claim, and next-level resolution.
- [x] BCM-M11-004 — Make completion idempotent so replaying a level cannot duplicate one-time unlock or milestone rewards.
- [x] BCM-M11-005 — Define recovery behavior for absent, older, malformed, and partially written saves without silently erasing valid owner progress.
- [x] BCM-M11-006 — Add automated tests for first boot, progression, replay, migration, corrupted-save fallback, and persistence reload.

### M12 — World Map

- [x] BCM-M12-001 — Create reusable WorldMapScene that reads island definitions from LevelDatabase/CampaignManager rather than hardcoded progression logic.
- [x] BCM-M12-002 — Add island nodes/cards for Sunny Cove and future islands with OPEN, LOCKED, COMPLETE, and CURRENT presentation states.
- [x] BCM-M12-003 — Implement sequential island unlock rules with Sunny Cove open by default and Tiki Island locked until Sunny Cove completion.
- [x] BCM-M12-004 — Implement navigation from main flow to world map and from world map to selected island map.
- [x] BCM-M12-005 — Add clear locked-island reason/progress text without requiring character animation or additional gameplay scenes.
- [x] BCM-M12-006 — Make layout mobile-safe and data-driven for at least 10 planned islands without scene-code duplication.
- [x] BCM-M12-007 — Add tests for island state rendering, selection, lock enforcement, and save reload.

### M13 — Reusable Island Map and 100-level path

- [x] BCM-M13-001 — Create generic IslandMapScene receiving island_id and rendering its configured level count.
- [x] BCM-M13-002 — Create reusable LevelButton component with level number, locked/unlocked/current/completed state, 0-3 stars, and milestone marker.
- [x] BCM-M13-003 — Implement a vertically scrollable mobile path capable of showing 100 level nodes without creating 100 unique scenes.
- [x] BCM-M13-004 — Implement deterministic path/layout generation or reusable authored anchor pattern so every island can use one map engine with different skin/data.
- [x] BCM-M13-005 — Auto-scroll/focus to the highest currently unlocked unfinished level when entering an island.
- [x] BCM-M13-006 — Add milestone presentation for levels 10/20/30/40/50/60/70/80/90/100 without requiring bespoke gameplay art.
- [x] BCM-M13-007 — Add island summary UI for stars earned, levels completed, next milestone, and island completion.
- [x] BCM-M13-008 — Add navigation back to World Map and safe restoration of selected/scroll state.

### M14 — Level launch and timed gameplay session bridge

- [x] BCM-M14-001 — Implement GameplaySessionBridge to launch the existing gameplay scene from selected campaign level data.
- [x] BCM-M14-002 — Feed level timer, normal To-Go objectives, optional VIP objective, rewards, and scoring rules into gameplay without retuning accepted launch/merge/table physics.
- [x] BCM-M14-003 — Add authoritative countdown timer with start, pause, resume, app-background, success-stop, and timeout behavior.
- [x] BCM-M14-004 — Define win condition as completion of all normal level orders before timer expiry.
- [x] BCM-M14-005 — Define VIP objective as optional; VIP failure must never block normal level completion.
- [x] BCM-M14-006 — Add win/lose result model and return flow to Retry, Next Level, and Island Map.
- [x] BCM-M14-007 — Prevent campaign objectives from breaking the existing To-Go rule that qualifying stored L6-L12 drinks may satisfy later matching orders.
- [x] BCM-M14-008 — Add regression tests proving campaign mode preserves accepted core merge/scoring/edge behavior.

### M15 — VIP orders, boosters, rewards, and economy hooks

- [x] BCM-M15-001 — Integrate the owner-approved V06 tall combined To-Go + VIP HUD master at unchanged width with long ropes, expanded vertical footprint, dynamic normal/VIP content, equal cocktail scaling, and persistent non-VIP `0/0` state.
- [x] BCM-M15-002 — Implement optional VIP completion reward dispatch for booster rewards.
- [x] BCM-M15-003 — Define initial booster inventory model and campaign reward integration.
- [x] BCM-M15-004 — Implement +Time booster contract for timed levels without altering base timer definitions.
- [x] BCM-M15-005 — Implement one-time milestone reward claim state and duplicate-claim protection.
- [x] BCM-M15-006 — Add coin/reward ledger hooks while keeping campaign completion independent from purchases or ads.
- [x] BCM-M15-007 — Add tests for VIP optionality, reward grant, inventory persistence, replay, and duplicate prevention.
- [x] BCM-M15-R01 — Replace the owner-rejected V05 miniature runtime presentation with the V06 1132×1698 tall long-rope master while preserving accepted M15 gameplay/economy behavior.

### M15 final closure V06

Final independent audit:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_V06.md` — **AUDITED_PASS / OWNER_ACCEPTED**.

Final accepted runtime HEAD at audit: `96488258453e4aee23da57f3b73db8fd3a69464a`.

The owner accepted the V06-R01 tall To-Go/VIP HUD visuals, including white centered reward digits. M15 gameplay/economy behavior and the final HUD are closed. M16 may proceed.

## M16 — Sunny Cove canonical Level 1-100 content

Active M16 V01 locked criteria:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_CRITERIA_V01.md`

Active M16 V01 execution prompt:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_EXECUTION_PROMPT_V01.md`

M16 V01 independent audit result:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_V01.md` — **AUDITED_PASS / V01_SCOPE_COMPLETE**.

BCM-M16-001..008 and BCM-M16-010 are closed. BCM-M16-009 remains owner-required because no approved exact VIP placement/reward table exists.

Authoritative level table:
`docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md`

BCM-M16-009 owner policy is now approved.

Owner ruling V02:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/OWNER_RULING_V02.md`

Locked audit criteria V02:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_CRITERIA_V02.md`

Execution prompt V02:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_EXECUTION_PROMPT_V02.md`

V02 independent audit:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_V02.md` — **CHANGES_REQUIRED** only for the Island Map marker visual semantics.

V03 locked criteria:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_CRITERIA_V03.md`

V03 remediation prompt:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_EXECUTION_PROMPT_V03.md`

V03 independent audit:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_V03.md` — **TECHNICAL_AUDIT_PASS / OWNER_VISUAL_ACCEPTANCE_REQUIRED**.


- [x] BCM-M16-001 — Add Sunny Cove island definition with exactly 100 sequential levels.
- [x] BCM-M16-002 — Encode the approved minimum normal target rule: no normal campaign target below L5.
- [x] BCM-M16-003 — Encode spawn assumption baseline L1-L3 and merge cost model L(n)=2^(n-1) L1-equivalent units.
- [x] BCM-M16-004 — Encode timer baseline from calculated production time multiplied by exactly 2; do not add a fixed minimum-time padding.
- [x] BCM-M16-005 — Set Level 1 baseline to 1×L5 with approximately 20 seconds.
- [x] BCM-M16-006 — Keep Sunny Cove normal targets within L5-L8 and reserve L9 as future-island progression content.
- [x] BCM-M16-007 — Set Sunny Cove Level 100 target to 1×L8 + 1×L7 + 1×L6 + 1×L5 with a 300-second / 5:00 timer.
- [x] BCM-M16-008 — Populate all 100 Sunny Cove level records from the approved progression table, including intentional difficulty-wave relief levels.
- [x] BCM-M16-009 — Add VIP placements/rewards separately from the normal timer-cost calculation.
- [x] BCM-M16-010 — Validate unique ids, sequential unlock chain, objective legality, timers, and Level 1/100 anchor values in automated tests.

### M16 final closure V03

Final independent audit:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_V03.md` — **AUDITED_PASS / OWNER_ACCEPTED**.

Final owner-approved V03 marker uses the existing gameplay crown+VIP badge at 36×36 and preserves the fully audited 25-level VIP content/reward/replay contract.

**M16 CLOSED.**

## M17 — Difficulty model and level validation

Active M17 V01 locked criteria:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V01.md`

Active M17 V01 execution prompt:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V01.md`

Pending independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V01.md`

V01 covers M17-001..006 tooling/evidence only. M17-007/008 remain pending; no canonical level tuning is authorized before independent audit of the harness.


- [~] BCM-M17-001 — Implement deterministic L1-equivalent objective cost calculation for every campaign level.
- [~] BCM-M17-002 — Implement timer-calculation tooling that exposes theoretical cost, expected L1-L3 spawn production, raw calculated time, and ×2 final target time.
- [~] BCM-M17-003 — Treat theoretical merge cost as a lower-level planning metric only; do not assume spatially separated same-level cocktails merge for free.
- [~] BCM-M17-004 — Define spatial-complexity telemetry for board occupancy, large-piece coexistence, travel/contact time, congestion, and failed merge approaches.
- [~] BCM-M17-005 — Build a level validation/simulation harness or replayable bot test interface that can run repeated seeded trials against campaign data.
- [~] BCM-M17-006 — Report completion rate, median completion time, percentile completion times, timeout causes, and board-congestion metrics per tested level.
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
