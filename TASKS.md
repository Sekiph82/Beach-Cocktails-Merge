# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the **only** authoritative live project-status tracker and the **only project-status file consumed by the H!veAI parser**. GitHub repository metadata and the latest `main` commit are the remaining project-truth inputs. No parallel session index, roadmap, audit index, dashboard, hidden control-plane tracker, or equivalent status mirror is permitted. Prompts, criteria, logs, audits, manifests, and historical branch task files are evidence only, never competing current-state authorities.

## Project Status

- Current Milestone: BCM-M21
- Current Sprint: BCM-M21-HOME-FRONTIER-R08
- Current Task: BCM-M21-001 — Rebuild World Map as a composited multi-part island map and restore real-input Sunny Cove Island Map entry.
- Current Task Status: CHANGES_REQUIRED
- Next Task/Action: BCM-M21-001-R08 — CODEX executes `coordination/sessions/BCM-M21-HOME-FRONTIER-R08/CHATGPT_HOME_FRONTIER_PROMPT_R08.md`, makes the Home top LEVEL, PLAY plaque, and Home PLAY action use the same campaign frontier authority while preserving old-level replay from Island Map, reruns the locked regressions, and stops for independent audit.
- Required Actor: CODEX
- Tracking Repository: Sekiph82/Beach-Cocktails-Merge
- Tracking Branch: main
- Progress: Independent audit of R07 plus the 720×1280 Sunny Cove full-background follow-up found the Island Map/star/background work technically sound, but **CHANGES_REQUIRED** remains because Home still mixes authorities: the top LEVEL display uses `selected_level_id`, the PLAY plaque uses frontier, and Home PLAY launches `selected_level_id`. After replaying an old level this can show `LEVEL 11` yet launch level 4. R08 is a bounded functional remediation only: Home top LEVEL + plaque + PLAY must all use `CampaignManager.get_frontier_level_id()`. Explicit Island Map replay of old levels remains supported. R07 visuals/star thresholds/full-background are frozen. Economy draft remains inactive. BCM-M21-006 remains blocked.

## Blockers/Waits

- BCM-M21-006 is blocked until BCM-M21-001 passes independent audit and fresh owner visual/runtime acceptance.

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

Legend:
- `[x]` audited complete.
- `[~]` active/pending owner closure.
- `[!]` reopened/changes required.
- `[ ]` planned.

## Governance

> **H!veAI tracking [OWNER-LOCKED — 2026-09-28]:** repository-root `TASKS.md` is the one and only live project-status tracker and H!veAI parser input. The top `Project Status` block controls current milestone, sprint, task, workflow status, next action, required actor, repository, branch, and progress. Every canonical task ID must appear exactly once. Do not create or maintain `coordination/SESSION_INDEX.md`, `coordination/AUDIT_INDEX.md`, `docs/04_ROADMAP.md`, `.hiveai/PROJECT_DASHBOARD.md`, `.hiveai/*` control-plane files, or any equivalent parallel tracker/status mirror. Audit/prompt/log files and historical task lists may exist only as evidence. **ChatGPT is the sole writer of root `TASKS.md`; Codex reads it but never edits it.** ChatGPT updates it after every independent audit, owner-gate decision, and before handing off the next implementation prompt.

- Codex must never edit this file.
- Prompt and locked audit criteria are created before implementation/remediation.
- Codex logs are builder evidence, not acceptance proof.
- ChatGPT independently audits actual diff/source/tests/evidence against locked criteria.
- Owner runtime screenshots and annotations are authoritative when later than earlier audit interpretations.
- Only ChatGPT updates this tracker after audit.
- **H!veAI parser contract:** every counted task row must be exactly `- [x] ID — title`, `- [~] ID — title`, `- [!] ID — title`, or `- [ ] ID — title`. Headings, milestone summaries, historical notes, retired/cancelled work, and explanatory bullets must never use checkbox markers.
- **Current Task must contain exactly one canonical task ID** and that ID must exist exactly once in the task rows below. Never join simultaneous concerns with `+` in the Current Task field.
- **Current Task Status must match the task-row marker:** `[~] = IN_PROGRESS`, `[!] = BLOCKED`, `[x] = TASK_COMPLETE`, `[ ] = BACKLOG`.
- **Next Task/Action must begin with a canonical task ID followed by an em dash** so H!veAI can materialize `nextTaskId` and `nextTaskTitle`.
- If work is permanently cancelled/superseded and H!veAI has no cancelled marker, preserve it as a non-checkbox historical bullet so it does not inflate Total/Remaining task metrics.
- Per-task H!veAI metadata, when needed, is indented directly below the task row using supported labels such as `Owner:`, `Depends on:`, `Blocker:`, `Owner Gate:`, `Waiting for:`, and `Priority:`.
- No guide line.

## M00-M04 — Accepted baseline

- M00 — repository baseline. Milestone summary only; not a H!veAI task row.
- M01 — launch/current/next/gameplay contract. Milestone summary only; not a H!veAI task row.
- M02 — collision/merge/rapid-launch physics. Milestone summary only; not a H!veAI task row.
- M03 — scoring/combo/To-Go/persistence/Game Over. Milestone summary only; not a H!veAI task row.
- M04 — refreshed canonical visual asset family. Milestone summary only; not a H!veAI task row.



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
- BCM-M09-003 — RETIRED by the later owner no-timer ruling; timer-urgency feedback will not be implemented and is not a H!veAI task row.
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

V01 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V01.md` — **CHANGES_REQUIRED** for telemetry/report integrity only.

V02 locked criteria:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V02.md`

V02 execution prompt:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V02.md`

V02 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V02.md` — **AUDITED_PASS**.

V03 was superseded before execution by owner observation of fixed-lane behavior.

Owner observation V03A:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/OWNER_OBSERVATION_V03A.md`

V03A locked criteria:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V03A.md`

V03A execution prompt:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V03A.md`

V03A independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V03A.md` — **AUDITED_PASS / SOLVER_QUALIFIED_FOR_M17_007**.

V04 locked criteria:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V04.md`

V04 execution prompt:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V04.md`

V04 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V04.md` — **AUDITED_PASS / BCM-M17-007 COMPLETE**.

V04's most important finding: all 25 configured VIP levels have pre-fix mandatory-intermediate interception risk. Timer padding is not an acceptable first fix.

V05 locked criteria:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V05.md`

V05 execution prompt:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V05.md`

V05 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V05.md` — **AUDITED_PASS / V05_STRUCTURAL_REMEDIATION_COMPLETE**.

V06 post-fix rescreen batch package:
- Master prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V06.md`
- Master audit criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V06.md`
- Ordered child prompts/criteria: `CHATGPT_EXECUTION_PROMPT_V06_CHILD_01.md` through `CHATGPT_EXECUTION_PROMPT_V06_CHILD_04.md` and matching `CHATGPT_AUDIT_CRITERIA_V06_CHILD_*.md`
- Master log template: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V06.md`
- Required final marker: `AWAITING_M17_AUDIT_V06`

V06 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V06.md` — **CHANGES_REQUIRED** for the Child 03 required-test stop-condition violation.

V06-R01 bounded remediation package:
- Master remediation prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V06_R01.md`
- Master remediation criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V06_R01.md`
- Child 03 remediation prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V06_R01_CHILD_03.md` / `CHATGPT_AUDIT_CRITERIA_V06_R01_CHILD_03.md`
- Child 04 final-handoff prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V06_R01_CHILD_04.md` / `CHATGPT_AUDIT_CRITERIA_V06_R01_CHILD_04.md`
- Master log template: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V06_R01.md`
- Required final marker: `AWAITING_M17_AUDIT_V06_R01`

V06-R01 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V06_R01.md` - **CHANGES_REQUIRED** because the corrected Child 03 runner returned exit code 1 after its final integrity check rejected the established flat trial schema. Child 04 was correctly not started.

V06-R02 bounded remediation package:
- Master remediation prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V06_R02.md`
- Master remediation criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V06_R02.md`
- Child 03 remediation prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V06_R02_CHILD_03.md` / `CHATGPT_AUDIT_CRITERIA_V06_R02_CHILD_03.md`
- Child 04 final-handoff prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V06_R02_CHILD_04.md` / `CHATGPT_AUDIT_CRITERIA_V06_R02_CHILD_04.md`
- Master log template: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V06_R02.md`
- Required final marker: `AWAITING_M17_AUDIT_V06_R02`

V06-R02 is limited to correcting the runner's schema-integrity check and producing a fresh direct-PASS screen.

V06-R02 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V06_R02.md` — **AUDITED_PASS / V06-R02 REMEDIATION COMPLETE**.

V06-R02 establishes a trustworthy post-V05 one-trial screen: 3 classes are `SOLVER_FEASIBLE` (C02, C05, C10) and 42 classes remain `SCREENING_FAILURE_NEEDS_CONFIRMATION`. One failed trial is not enough for a high-risk classification.

V07 five-trial confirmation package:
- Execution prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V07.md`
- Locked audit criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07.md`
- Ordered Child 01 prompt/criteria/log: `CHATGPT_EXECUTION_PROMPT_V07_CHILD_01.md`, `CHATGPT_AUDIT_CRITERIA_V07_CHILD_01.md`, `CODEX_LOG_V07_CHILD_01.md`
- Ordered Child 02 prompt/criteria/log: `CHATGPT_EXECUTION_PROMPT_V07_CHILD_02.md`, `CHATGPT_AUDIT_CRITERIA_V07_CHILD_02.md`, `CODEX_LOG_V07_CHILD_02.md`
- Ordered Child 03 prompt/criteria/log: `CHATGPT_EXECUTION_PROMPT_V07_CHILD_03.md`, `CHATGPT_AUDIT_CRITERIA_V07_CHILD_03.md`, `CODEX_LOG_V07_CHILD_03.md`
- Required builder log: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07.md`
- Required final marker: `AWAITING_M17_AUDIT_V07`

The complete ordered V07 package is frozen and CODEX is authorized to execute all three children in order. A child is not accepted independently of the master batch, and no later child may begin after an earlier child fails or is unverified.

V07 direct execution produced 168 new trials and 42×5 aggregates but failed its required integrity gate because of typed mapping comparison and seed-registry accounting defects. The failed V07 report remains historical failed-run evidence and is not promoted to PASS.

Owner sync-blocker ruling:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/OWNER_RULING_V07_SYNC_BLOCKER.md` — owner explicitly authorizes deletion of only the superseded untracked `CODEX_LOG_V07_ATTEMPT_20260929_SYNC_BLOCKED.md` local file.

V07-R01 bounded remediation package:
- Prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R01.md`
- Locked criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R01.md`
- Ordered Child 01 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R01_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_R01_CHILD_01.md`
- Ordered Child 02 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R01_CHILD_02.md` / `CHATGPT_AUDIT_CRITERIA_V07_R01_CHILD_02.md`
- Ordered Child 03 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R01_CHILD_03.md` / `CHATGPT_AUDIT_CRITERIA_V07_R01_CHILD_03.md`
- Required log: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R01.md`
- Required final marker: `AWAITING_M17_AUDIT_V07_R01`

V07-R01 must fix only the mapping and seed-registry defects, preserve historical V07 evidence, run a fresh 42×5 confirmation with 168 new trials under a new seed namespace, prove 213 unique aggregate seeds, and run regressions only after direct PASS. No canonical timer/objective tuning is authorized inside V07-R01.

V07-R01 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R01.md` — **CHANGES_REQUIRED / RUNNER-PROVENANCE-INTEGRITY_FAILURE**.

V07-R01 produced 168 fresh trials and recorded 213 unique aggregate seeds, but the failed JSON contains 168 `duplicate aggregate seed` errors that cannot be emitted by the final committed R01 runner at the handoff HEAD. The failed R01 outputs remain historical evidence and are not promoted.

V07-R02 bounded remediation package:
- Prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R02.md`
- Locked criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R02.md`
- Required log: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R02.md`
- Required final marker: `AWAITING_M17_AUDIT_V07_R02`

V07-R02 requires commit-before-execution provenance: the new runner must be committed/pushed, the checkout must be clean, and the bytes executed must equal the runner bytes at current HEAD. It uses a fresh `17900000 + representative*100 + trial_index` namespace for 168 new trials. No canonical tuning is authorized in R02.

V07-R02 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R02.md` — **CHANGES_REQUIRED / DIRECT-RUNNER-INTEGRITY-FAILURE**.

V07-R03 bounded remediation package:
- Master remediation prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03.md`
- Master remediation criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03.md`
- Ordered Child 01 prompt/criteria/log: `CHATGPT_REMEDIATION_PROMPT_V07_R03_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_CHILD_01.md` / `CODEX_LOG_V07_R03_CHILD_01.md`
- Required master log template: `CODEX_LOG_V07_R03.md`
- Required final marker: `AWAITING_M17_AUDIT_V07_R03`

V07-R03 is limited to correcting the typed/numeric semantic mapping comparison and producing fresh exact-committed confirmation. No canonical timer/objective/VIP/gameplay tuning is authorized, and no later child or M18 work may begin.

V07-R03 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03.md` — **CHANGES_REQUIRED / EVIDENCE-HANDOFF-INCOMPLETE**.

V07-R03-R01 bounded evidence-handoff remediation package:
- Master remediation prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R01.md`
- Master remediation criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R01.md`
- Ordered Child 01 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R03_R01_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R01_CHILD_01.md`
- Required child/master logs: `CODEX_LOG_V07_R03_R01_CHILD_01.md` / `CODEX_LOG_V07_R03_R01.md`
- Required final marker: `AWAITING_M17_AUDIT_V07_R03_R01`

V07-R03-R01 is evidence-only: preserve the passing R03 runner/report and recapture exact regression exits and final synchronization equality. No R03 direct rerun, report repair, canonical tuning, or M18 work is authorized.

V07-R03-R01 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03_R01.md` — **CHANGES_REQUIRED / EVIDENCE-HANDOFF-INCOMPLETE**.

V07-R03-R02 complete-stdout evidence-handoff remediation package:
- Master remediation prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R02.md`
- Master remediation criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02.md`
- Ordered Child 01 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01.md`
- Required child/master logs: `CODEX_LOG_V07_R03_R02_CHILD_01.md` / `CODEX_LOG_V07_R03_R02.md`
- Required final marker: `AWAITING_M17_AUDIT_V07_R03_R02`

V07-R03-R02 is evidence-only: preserve the passing R03 runner/report and all prior evidence, do not rerun the R03 confirmation runner or repair its report, capture verbatim complete regression stdout/stderr with exact exit codes, record equality in the child/master logs, and publish the terminal final-equality record. No canonical tuning or M18 work is authorized.

V07-R03-R02 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03_R02.md` - **CHANGES_REQUIRED / EVIDENCE-HANDOFF-INCOMPLETE**.

V07-R03-R02-V03 retry package:
- Master remediation prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_V03.md`
- Master remediation criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_V03.md`
- Ordered Child 01 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V03.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V03.md`
- Required logs: `CODEX_LOG_V07_R03_R02_CHILD_01_V03.md` / `CODEX_LOG_V07_R03_R02_V03.md`
- Required final marker: `AWAITING_M17_AUDIT_V07_R03_R02`

The V03 retry is evidence-only and preserves Attempts 01/02. It must not rerun or repair the V07-R03 confirmation report, tune canonical data, or start M18.

V07-R03-R02-V03 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03_R02_V03.md` — **CHANGES_REQUIRED / CAPTURE-WRAPPER-SETUP-FAILURE**.

V07-R03-R02-V04 bounded remediation package:
- Master remediation prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_V04.md`
- Master remediation criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_V04.md`
- Ordered Child 01 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V04.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V04.md`
- Required child log / master-log template: `CODEX_LOG_V07_R03_R02_CHILD_01_V04.md` / `CODEX_LOG_V07_R03_R02_V04.md`
- Required final marker: `AWAITING_M17_AUDIT_V07_R03_R02`

V07-R03-R02-V04 is evidence-only: prove capture-wrapper compatibility before the locked sequence, preserve V07-R03 and all prior attempts, do not rerun or repair the V07-R03 confirmation report, do not tune canonical data, and do not start M18. Only one child exists; any failed or unverified command stops the batch.

V07-R03-R02-V04 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03_R02_V04.md` — **CHANGES_REQUIRED / LOG-EMBEDDED-EQUALITY-OMISSION**.

V07-R03-R02-V05 bounded no-rerun documentation package:
- Master remediation prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_V05.md`
- Master remediation criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_V05.md`
- Ordered Child 01 prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V05.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V05.md`
- Master-log template: `CODEX_LOG_V07_R03_R02_V05.md`
- Required final marker: `AWAITING_M17_AUDIT_V07_R03_R02`

V07-R03-R02-V05 is evidence-only and must not rerun the V04 sequence. It preserves V04 and all prior evidence, embeds the first-publication equality in both new logs, publishes the final second-publication equality record, and blocks M17 tuning and M18.

V07-R03-R02-V05 independent audit:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03_R02_V05.md` — **AUDITED_PASS**.

V01 covers M17-001..006 tooling/evidence only. M17-007 is closed. V05 structural optionality remediation and V06-R02 runner remediation are independently passed. V06 and V06-R01 remain historical `CHANGES_REQUIRED` handoffs. M17-008 is closed as an evidence-log correction only; no canonical difficulty tuning was accepted.


- [x] BCM-M17-001 — Implement deterministic L1-equivalent objective cost calculation for every campaign level.
- [x] BCM-M17-002 — Implement timer-calculation tooling that exposes theoretical cost, expected L1-L3 spawn production, raw calculated time, and ×2 final target time.
- [x] BCM-M17-003 — Treat theoretical merge cost as a lower-level planning metric only; do not assume spatially separated same-level cocktails merge for free.
- [x] BCM-M17-004 — Define spatial-complexity telemetry for board occupancy, large-piece coexistence, travel/contact time, congestion, and failed merge approaches.
- [x] BCM-M17-005 — Build a level validation/simulation harness or replayable bot test interface that can run repeated seeded trials against campaign data.
- [x] BCM-M17-006 — Report completion rate, median completion time, percentile completion times, timeout causes, and board-congestion metrics per tested level.
- [x] BCM-M17-007 — Flag mathematically impossible, effectively impossible, or outlier levels before they are accepted into canonical campaign data.
- [x] BCM-M17-008 — Tune data only after evidence; never hide impossible level design behind arbitrary timer extensions.

### M18 — Stars, score mastery, milestones, and replay

M18 V01 complete ordered milestone-batch package:
- Master prompt: `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_EXECUTION_PROMPT_V01.md`
- Master audit criteria: `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_AUDIT_CRITERIA_V01.md`
- Ordered child prompts/criteria: six files `CHATGPT_EXECUTION_PROMPT_V01_CHILD_01.md` through `CHATGPT_EXECUTION_PROMPT_V01_CHILD_06.md` and matching `CHATGPT_AUDIT_CRITERIA_V01_CHILD_*.md`
- Master log template: `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CODEX_LOG_V01.md`
- Required final marker: `AWAITING_M18_AUDIT_V01`

The complete M18 V01 package was frozen before execution. Child 01/02 are independently audited PASS. V01 Child 03 truthfully stopped at OWNER_REQUIRED and Children 04-06 remained unstarted.

Owner ruling V02:
`coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/OWNER_RULING_V02.md` — **OWNER_APPROVED** exact Sunny Cove cumulative-star reward payload:
- 30/60/90/120 stars: `time ×1`
- 150 stars: `upgrade ×1`
- 180/210/240/270 stars: `time ×1`
- 300 stars: `upgrade ×1`

M18 V02 continuation package:
- Master continuation prompt: `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_CONTINUATION_PROMPT_V02.md`
- Locked continuation criteria: `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_AUDIT_CRITERIA_V02.md`
- Master log: `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CODEX_LOG_V02.md`
- Ordered V02 logs: `CODEX_LOG_V02_CHILD_03.md` through `CODEX_LOG_V02_CHILD_06.md`
- Required final marker: `AWAITING_M18_AUDIT_V02`

V02 resumes at BCM-M18-003 only. M18-001/002 must not be reimplemented. BCM-M18-004..006 may execute only in order after each prior child passes and publishes clean equality. M19 remains blocked until independent M18 closure.

M18 V02 independent audit:
`coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_AUDIT_V02.md` — **CHANGES_REQUIRED / BOUNDED V02-R01 REMEDIATION**.

V02-R01 remediation package:
- Prompt: `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_REMEDIATION_PROMPT_V02_R01.md`
- Locked criteria: `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_AUDIT_CRITERIA_V02_R01.md`
- Required log: `coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CODEX_LOG_V02_R01.md`
- Required final marker: `AWAITING_M18_AUDIT_V02_R01`

The remediation is limited to the economy-unavailable cumulative-star claim edge case, four missing Child 05 replay-state runtime captures, and the exact Child 05 merge-SHA evidence correction. Existing V02 functional behavior outside that scope remains frozen.

M18 V02-R01 independent audit:
`coordination/sessions/BCM-M18-STARS-MASTERY-REPLAY/CHATGPT_AUDIT_V02_R01.md` — **AUDITED_PASS / M18 CLOSED**.

- [x] BCM-M18-001 — Define star award contract using completion, VIP completion, and score mastery rather than using stars as the island-unlock gate.
- [x] BCM-M18-002 — Preserve best score per level and only replace stored stars/score when the replay result is better.
- [x] BCM-M18-003 — Add Sunny Cove cumulative star/reward track with non-blocking milestone rewards.
- [x] BCM-M18-004 — Keep next-level progression based on level completion, not mandatory perfect-star replay.
- [x] BCM-M18-005 — Add replay flow from Island Map with previously earned state visible.
- [x] BCM-M18-006 — Add tests for star upgrades, worse replay preservation, milestone claims, and 100% island completion.

### M19 — Multi-island scalability and Tiki Island handoff

M19 V01 ordered batch package:
- Master prompt: `coordination/sessions/BCM-M19-MULTI-ISLAND-SCALABILITY/CHATGPT_EXECUTION_PROMPT_V01.md`
- Master locked criteria: `coordination/sessions/BCM-M19-MULTI-ISLAND-SCALABILITY/CHATGPT_AUDIT_CRITERIA_V01.md`
- Ordered child prompts/criteria: `CHATGPT_EXECUTION_PROMPT_V01_CHILD_01.md` through `CHATGPT_EXECUTION_PROMPT_V01_CHILD_06.md` and matching locked child criteria.
- Master log template: `coordination/sessions/BCM-M19-MULTI-ISLAND-SCALABILITY/CODEX_LOG_V01.md`
- Required final marker: `AWAITING_M19_AUDIT_V01`

M19 is architecture/data scalability only. Tiki remains a zero-level canonical placeholder; no Tiki production levels or final-island owner name may be invented. Existing approved island asset families under `assets/ui_assets/campaign/islands/<island_id>/` are immutable inputs.

M19 V01 independent audit:
`coordination/sessions/BCM-M19-MULTI-ISLAND-SCALABILITY/CHATGPT_AUDIT_V01.md` — **CHANGES_REQUIRED / ORDERED-PUBLICATION-INTEGRITY FAILURE**.

V01-R01 remediation package:
- Prompt: `coordination/sessions/BCM-M19-MULTI-ISLAND-SCALABILITY/CHATGPT_REMEDIATION_PROMPT_V01_R01.md`
- Locked criteria: `coordination/sessions/BCM-M19-MULTI-ISLAND-SCALABILITY/CHATGPT_AUDIT_CRITERIA_V01_R01.md`
- Ordered R01 child logs: `CODEX_LOG_V01_R01_CHILD_01.md` through `CODEX_LOG_V01_R01_CHILD_06.md`
- Master R01 log: `coordination/sessions/BCM-M19-MULTI-ISLAND-SCALABILITY/CODEX_LOG_V01_R01.md`
- Required final marker: `AWAITING_M19_AUDIT_V01_R01`

The existing M19 product implementation is frozen. R01 is evidence/provenance verification only. Each child must publish clean evidence/equality before the next child executes.

M19 V01-R01 independent audit:
`coordination/sessions/BCM-M19-MULTI-ISLAND-SCALABILITY/CHATGPT_AUDIT_V01_R01.md` — **AUDITED_PASS / M19 CLOSED**.

- [x] BCM-M19-001 — Prove the campaign engine can load a second island without duplicating CampaignManager, IslandMap, LevelButton, timer, or save logic.
- [x] BCM-M19-002 — Add Tiki Island locked placeholder and unlock it only when Sunny Cove Level 100 is completed.
- [x] BCM-M19-003 — Reserve L9 introduction for Tiki Island data and document higher-level progression policy for later islands.
- [x] BCM-M19-004 — Define planned island sequence: Sunny Cove, Tiki Island, Azure Bay, Coconut Beach, Sunset Island, Party Beach, Frozen Paradise, Volcano Bay, Billionaire Island, and final island slot/name TBD.
- [x] BCM-M19-005 — Define per-island skin/background hooks while keeping the same core table/gameplay engine.
- [x] BCM-M19-006 — Add regression proving a new island can be added primarily through data plus map/background assets.

### M20 — Menus, onboarding, settings, accessibility, and campaign UX polish

M20 V01 ordered batch package:
- Master prompt: `coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/CHATGPT_EXECUTION_PROMPT_V01.md`
- Master locked criteria: `coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/CHATGPT_AUDIT_CRITERIA_V01.md`
- Ordered child prompts/criteria: `CHATGPT_EXECUTION_PROMPT_V01_CHILD_01.md` through `CHATGPT_EXECUTION_PROMPT_V01_CHILD_06.md` and matching locked child criteria.
- Ordered child logs: `CODEX_LOG_V01_CHILD_01.md` through `CODEX_LOG_V01_CHILD_06.md`
- Master log: `coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/CODEX_LOG_V01.md`
- Required final marker: `AWAITING_M20_AUDIT_V01`

M20 adds application/menu/UX/settings layers around the accepted campaign engine. It must not fork progression, timer, save, gameplay physics, scoring, VIP, reward, or multi-island authorities. Every child requires separate publication/equality before the next child starts.

M20 V01 independent audit:
`coordination/sessions/BCM-M20-CAMPAIGN-UX-POLISH/CHATGPT_AUDIT_V01.md` — **AUDITED_PASS / M20 CLOSED**.

- [x] BCM-M20-001 — Integrate campaign entry into main menu/start flow.
- [x] BCM-M20-002 — Add minimal first-run onboarding for World Map, Island Map, timed order objective, VIP optionality, and level completion.
- [x] BCM-M20-003 — Add settings for audio, haptics, accessibility-relevant feedback, and other release-required toggles.
- [x] BCM-M20-004 — Add pause/resume and app-lifecycle behavior that cannot consume campaign time while legitimately paused/backgrounded.
- [x] BCM-M20-005 — Add concise locked/unlocked/milestone/result UX without adding character systems or animation-heavy meta gameplay.
- [x] BCM-M20-006 — Complete save migration and backward-compatibility verification for existing players.

### M21 — Mobile QA, final regression, packaging, and v1 campaign release closure

M21 V01 ordered release-closure package:
- Master prompt: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_EXECUTION_PROMPT_V01.md`
- Master locked criteria: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01.md`
- Ordered child prompts/criteria: `CHATGPT_EXECUTION_PROMPT_V01_CHILD_01.md` through `CHATGPT_EXECUTION_PROMPT_V01_CHILD_06.md` and matching locked child criteria.
- Ordered child logs: `CODEX_LOG_V01_CHILD_01.md` through `CODEX_LOG_V01_CHILD_06.md`
- Master log: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CODEX_LOG_V01.md`
- Required builder marker: `AWAITING_M21_AUDIT_V01`

M21 is release validation/packaging only. It must not invent physical-device, signed-store, or platform-toolchain PASS results that were not actually produced. Final v1 release-ready closure requires independent ChatGPT audit plus explicit owner-native mobile acceptance.

M21 V01 independent audit:
`coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_AUDIT_V01.md` — **CHANGES_REQUIRED / EVIDENCE-CLOSURE-INCOMPLETE**.

V01-R01 evidence-only remediation package:
- Prompt: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_REMEDIATION_PROMPT_V01_R01.md`
- Locked criteria: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_AUDIT_CRITERIA_V01_R01.md`
- Required log: `coordination/sessions/BCM-M21-RELEASE-CLOSURE/CODEX_LOG_V01_R01.md`
- Required marker: `AWAITING_M21_AUDIT_V01_R01`

R01 is evidence-only. Product/source files and all original M21 V01 evidence/captures are frozen. It must add only a complete supplemental release manifest and audit-readable review copies/provenance for the 14 original mobile QA captures.

M21 V01-R01 independent audit:
`coordination/sessions/BCM-M21-RELEASE-CLOSURE/CHATGPT_AUDIT_V01_R01.md` — historical **TECHNICAL PASS**, superseded for final release acceptance by later owner runtime evidence.

Owner runtime FAIL:
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_RUNTIME_AUDIT_V01.md`
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_RULING_V01.md`

Owner-runtime remediation V01 was implemented at handoff `814198440dc5c13792087b351a151241bd2664a5`.

Final combined closure V02:
- Prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_FINAL_OWNER_RUNTIME_CLOSURE_PROMPT_V02.md`
- Locked criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_FINAL_OWNER_RUNTIME_CLOSURE_CRITERIA_V02.md`
- Log: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CODEX_LOG_FINAL_OWNER_RUNTIME_CLOSURE_V02.md`
- Active task IDs: `BCM-M21-001`, `BCM-M21-004`, `BCM-M21-006`
- Successful technical marker: `AWAITING_OWNER_F5_ACCEPTANCE_V02`

The owner explicitly rejects all gameplay time limits. Final owner F5 acceptance remains mandatory even after technical verification.

Final V02-R01 independent audit:
`coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_FINAL_OWNER_RUNTIME_CLOSURE_AUDIT_V02_R01.md` — historical **TECHNICAL PASS**, superseded by owner F5 V02 visual/runtime findings.

Owner F5 V03 ruling:
- `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V03.md`
- Prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V03.md`
- Locked criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V03.md`
- Independent audit: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V03.md` — historical **TECHNICAL PASS**, superseded by owner F5 V04 findings.

Owner F5 V05 active remediation:
- Owner ruling: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V05.md`
- Owner audit: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_AUDIT_V05.md`
- Prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V05.md`
- Locked criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V05.md`
- Independent audit: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V05.md` — historical **TECHNICAL PASS**, superseded by owner F5 V06 visual/geometry findings.

Owner F5 V06 active remediation:
- Owner ruling: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V06.md`
- Prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V06.md`
- Locked criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V06.md`
- Independent audit: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V06.md` — historical **TECHNICAL PASS**, superseded by owner V07 process/art ruling.

Owner F5 V07 history and active R03 remediation:
- Owner ruling: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V07.md`
- Historical sync-preserve prompt/criteria: `CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07_R01.md` / `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R01.md`
- Historical builder self-audit: `BUILDER_SELF_VISUAL_AUDIT_V07.md` + `BUILDER_SELF_VISUAL_AUDIT_V07.json` — builder PASS, **not independently accepted**
- Independent audit: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V07.md` — **CHANGES_REQUIRED / BUILDER_VISUAL_SELF-AUDIT_NOT_ACCEPTED**
- Historical V07-R02 prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07_R02.md`
- Historical V07-R02 criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R02.md`
- V07-R02 owner visual audit: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V07_R02.md` — **CHANGES_REQUIRED / GAMEPLAY_TABLE_COMPOSITION_REJECTED**
- Base V07-R03 prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07_R03.md`
- Active V07-R03-R01 sync-preserve continuation: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07_R03_R01.md`
- Active V07-R03 criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R03.md`
- Required marker: `AWAITING_OWNER_VISUAL_SELECTION_V07_R03`
- Independent V07-R03 candidate audit: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V07_R03.md` — historical candidate-gate PASS, later **SUPERSEDED_BY_OWNER / REJECT_ALL / CHANGES_REQUIRED**.
- V07-R04 owner ruling: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V07_R04.md`
- Active V07-R04 criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V07_R04.md`
- Active V07-R04 prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V07_R04.md`
- Required marker: `AWAITING_OWNER_VISUAL_ACCEPTANCE_V07_R04`.
- Later owner decision (2026-10-04): **ALL TEN current R04 gameplay surfaces/playable geometries OWNER-APPROVED**. This supersedes the pending R04 visual-selection/acceptance gate for the current island surface/profile set.
- Current R04 gameplay contract: `docs/ui-assets/GAMEPLAY_SURFACE_CONTRACT_V07_R04.md`.
- Active repository-hygiene owner ruling: `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/OWNER_RULING_R04_REPOSITORY_HYGIENE_V01.md`.
- Active repository-hygiene locked criteria: `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_R04_REPOSITORY_HYGIENE_CRITERIA_V01.md`.
- Active repository-hygiene prompt: `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_R04_REPOSITORY_HYGIENE_PROMPT_V01.md`.
- Required cleanup marker: `AWAITING_GPT_R04_REPOSITORY_HYGIENE_AUDIT_V01`.
- Independent hygiene audit: `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_R04_REPOSITORY_HYGIENE_AUDIT_V01.md` — **CONDITIONAL / CLEANUP_SCOPE_PASS / M12 WORLD MAP REGRESSION OPEN**.
- M21-001 World Map criteria: `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_M21_WORLD_MAP_LAYOUT_CRITERIA_V01.md`.
- M21-001 World Map prompt: `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_M21_WORLD_MAP_LAYOUT_PROMPT_V01.md`.
- Independent World Map audit: `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_M21_WORLD_MAP_LAYOUT_AUDIT_V01.md` — **AUDITED_PASS / BCM-M21-001 COMPLETE / OWNER_F5_ACCEPTANCE_REQUIRED**.
- Current final owner checklist: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_ACCEPTANCE_CHECKLIST_V03.md`.
- Required owner marker: `OWNER_F5_ACCEPTED_V03` or `OWNER_F5_REJECTED_V03`.
- Composite World Map owner rejection: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/OWNER_F5_REJECTION_V03.md`.
- Historical direct-implementation criteria: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_COMPOSITE_NAV_CRITERIA_V01.md` — superseded before execution by the owner-first visual gate.
- Historical direct-implementation prompt: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_COMPOSITE_NAV_PROMPT_R01.md` — DO NOT EXECUTE unless later explicitly re-authorized after owner visual approval.
- Owner-first preview criteria: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_OWNER_PREVIEW_CRITERIA_V02.md`.
- Owner-first preview prompt: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_OWNER_PREVIEW_PROMPT_V02.md`.
- Owner visual acceptance: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/OWNER_WORLD_MAP_VISUAL_ACCEPTANCE_V04.md` — **OWNER_WORLD_MAP_VISUAL_APPROVED_V02**.
- Accepted visual target HEAD: `e8e1f9a70aea4b460c04c43733be745b1f7633e1`.
- Active production criteria: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_PRODUCTION_CRITERIA_V05.md`.
- Active production prompt: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_PRODUCTION_PROMPT_V05.md`.
- Required builder marker: `AWAITING_GPT_M21_WORLD_MAP_PRODUCTION_AUDIT_V05`.
- Independent V05 audit: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/CHATGPT_WORLD_MAP_PRODUCTION_AUDIT_V05.md` — **TECHNICAL_AUDITED_PASS / OWNER_F5_ACCEPTANCE_REQUIRED**.
- Fresh owner F5 checklist: `coordination/sessions/BCM-M21-WORLD-MAP-COMPOSITE-NAV-R01/OWNER_F5_ACCEPTANCE_CHECKLIST_V04.md`.
- Prior owner F5 V04 checklist behavior: functionally PASS, but final acceptance withheld for owner-requested visual polish.
- Active owner polish ruling: `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/OWNER_F5_VISUAL_POLISH_RULING_R01.md`.
- Active polish criteria: `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/CHATGPT_OWNER_F5_VISUAL_POLISH_CRITERIA_R01.md`.
- Active polish prompt: `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/CHATGPT_OWNER_F5_VISUAL_POLISH_PROMPT_R01.md`.
- R02 independent audit: `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/CHATGPT_OWNER_F5_VISUAL_POLISH_AUDIT_R02.md` — **CHANGES_REQUIRED / REGRESSION_AND_CLEAN_STATE_CLOSURE**.
- Active R03 criteria: `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R03/CHATGPT_OWNER_F5_VISUAL_POLISH_CRITERIA_R03.md`.
- Active R03 prompt: `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R03/CHATGPT_OWNER_F5_VISUAL_POLISH_PROMPT_R03.md`.
- R03 technical-closure package is deferred/superseded-before-execution by the newer owner Home visual ruling; its findings remain open for a later post-R04 closure.
- Active R04 owner ruling: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/OWNER_HOME_EXACT_TARGET_RULING_R04.md`.
- Active R04 criteria: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/CHATGPT_HOME_EXACT_TARGET_CRITERIA_R04.md`.
- Active R04 prompt: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/CHATGPT_HOME_EXACT_TARGET_PROMPT_R04.md`.
- Latest independent Home audit: `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/CHATGPT_HOME_OWNER_CRITIQUE_AUDIT_V03.md` — **TECHNICAL_AUDITED_PASS / OWNER_HOME_VISUAL_APPROVAL_REQUIRED**.
- Final Home owner acceptance: `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/OWNER_HOME_ACCEPTANCE_R06.md` — **OWNER_HOME_ACCEPTED_R06**.
- R06 owner runtime review: **CHANGES_REQUIRED** for Home label fit, Island Map frontier paging/header/node readability, and incomplete star mastery.
- Active R07 owner ruling: `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/OWNER_ISLAND_MAP_STAR_RULING_R07.md`.
- Active R07 criteria: `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/CHATGPT_ISLAND_MAP_STAR_CRITERIA_R07.md`.
- Active R07 prompt: `coordination/sessions/BCM-M21-ISLAND-MAP-STAR-R07/CHATGPT_ISLAND_MAP_STAR_PROMPT_R07.md`.
- Independent R07/full-background audit: `coordination/sessions/BCM-M21-HOME-FRONTIER-R08/CHATGPT_R07_FULL_BACKGROUND_AUDIT.md` — **CHANGES_REQUIRED / HOME_FRONTIER_AUTHORITY_MISMATCH**.
- Active R08 criteria: `coordination/sessions/BCM-M21-HOME-FRONTIER-R08/CHATGPT_HOME_FRONTIER_CRITERIA_R08.md`.
- Active R08 prompt: `coordination/sessions/BCM-M21-HOME-FRONTIER-R08/CHATGPT_HOME_FRONTIER_PROMPT_R08.md`.
- Required builder marker: `AWAITING_GPT_M21_HOME_FRONTIER_AUDIT_R08`.
- Required builder marker: `AWAITING_OWNER_ISLAND_MAP_STAR_REVIEW_R07`.
- Active R06 criteria: `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/CHATGPT_FULL_RUNTIME_CRITERIA_R06.md`.
- Active R06 prompt: `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/CHATGPT_FULL_RUNTIME_PROMPT_R06.md`.
- Required builder marker: `AWAITING_OWNER_FULL_GAME_RUNTIME_REVIEW_R06`.
- R05 Home bar-fit is owner accepted and superseded as active work by R06 runtime integration.
- The older direct-implementation R01 package remains superseded.

Owner F5 V04 historical remediation:
- Owner ruling: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_RULING_V04.md`
- Owner audit: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/OWNER_F5_AUDIT_V04.md`
- Active sync-preserve prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V04_R01.md`
- Active sync-preserve criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V04_R01.md`
- Base V04 prompt: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_PROMPT_V04.md`
- Base V04 criteria: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V04.md`
- Independent audit: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CHATGPT_OWNER_F5_REMEDIATION_AUDIT_V04_R01.md` — **TECHNICAL_AUDITED_PASS / OWNER_F5_ACCEPTANCE_REQUIRED**
- Log: `coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/CODEX_LOG_OWNER_F5_REMEDIATION_V04.md`
- Required marker: `AWAITING_OWNER_F5_ACCEPTANCE_V04`

- [~] BCM-M21-001 — Rebuild World Map as a composited multi-part island map and restore real-input Sunny Cove Island Map entry.
  Owner: Codex
  Priority: 100
- [x] BCM-M21-002 — Profile Island Map node count, scrolling, loading, save IO, and gameplay memory/performance on target devices.
- [x] BCM-M21-003 — Run full campaign progression test from fresh save through Sunny Cove Level 100 and Tiki Island unlock.
- [x] BCM-M21-004 — Run full legacy gameplay regression for physics, merge, scoring, To-Go behavior, R11 table-edge footprint, and HUD.
- [x] BCM-M21-005 — Validate export/release configuration, persistence across app restarts, and no developer/test-only progression bypass.
- [!] BCM-M21-006 — Complete independent audit, owner runtime acceptance, documentation, packaging, and v1 campaign release closure.
  Owner: Human
  Depends on: BCM-M21-001
  Blocker: BCM-M21-001 composite World Map remediation must pass independent audit and fresh owner visual/runtime acceptance.
  Owner Gate: OWNER_F5_ACCEPTED after the new composite World Map is approved.
- [x] BCM-M21-007 — Remove proven obsolete/orphan visual assets, evidence, generated import metadata, stale JSON/tests/tools, and normalize repository truth around the owner-approved ten-island R04 surface/profile authority.

## Campaign design references

- Technical architecture: `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`.
- Sunny Cove historical progression spec: `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md` — **timer portions superseded by 2026-10-01 OWNER_RULING_V01; no gameplay time limits are permitted.**

M21 completion = Beach Cocktails Merge v1 campaign release-ready closure.
 
## M22-M27 — Planned GameFeelFlow + Saltmire Spark presentation program

**Planning gate:** future work only. M22-M27 MUST NOT start, pre-empt, reorder, or broaden the active M21 composite-World-Map/navigation remediation and final owner-acceptance sequence. The ten current R04 gameplay surfaces/geometries are owner-approved and frozen; M22 starts only after the new composite World Map + Sunny Cove navigation remediation passes independent audit, the owner completes a fresh F5 acceptance, and ChatGPT records final M21 release closure.

**Presentation-only constitution**
- Gameplay/campaign truth stays with `Drink`, `ShotController`, `GameManager`, `GameplaySessionBridge`, `CampaignManager`, `GameEconomy`, `SaveManager`, canonical level data, and accepted table geometry. Presentation observes finalized facts only.
- `FeedbackService` is the preferred semantic feedback boundary. A single presentation bridge/adapter is the only layer allowed to call the two plugins. It must never become a second gameplay/progression authority.
- Plugin absence, disablement, missing preset/API, or runtime failure must degrade to a presentation no-op. Physics, score, To-Go/VIP acceptance, stars, rewards, unlocks, saves, and result outcome must remain identical.
- Never add effects to physics authority, drag/launch calculations, collision decisions, merge eligibility, scoring calculations, timers, progression/save logic, every generic button, or anything that reduces cocktail/table/deadline readability.
- GameFeelFlow `impulse`, `velocity`, `freeze_frame`, and `time_scale` are forbidden. Full-screen flash is forbidden. Camera/screen shake is off by default and may only be considered later as a tiny owner-approved presentation-layer impulse; never transform gameplay bodies/rails/camera authority.
- Transform effects may target presentation children only, e.g. `Drink/Visual`, `Drink/Visual/CocktailSprite`, HUD panels, result controls, map entries, and `LevelButton`. Never scale/move a `RigidBody2D` or collision root.
- Existing `_juice_effect()`, `_order_completion_feedback()`, delivery tweens/trails, and other presentation tweens are migration inputs. If replaced, retire the superseded visual path after parity instead of stacking effects.

**Plugin API planning baseline**
- Current GitHub `main` does not contain the owner's local plugin folders, so exact local plugin bytes/version are not remotely verifiable yet. M22-001 must inspect the installed copies before any effect implementation.
- Public GameFeelFlow v1.0.0 exposes autoload `GameFeelFlow`, including `play(effect,target,params)`, `play_combo(combo,target,params)`, `play_global(effect,params)`, `stop/stop_all`, effect registries, punch/scale/flash/camera/particle effects, and dictionary-compatible params. Physics/time effects remain forbidden here.
- Public Saltmire Spark v1.0.0 exposes autoload `Spark`, including `burst(position,preset_or_overrides)`, `at(node,preset_or_overrides)`, `clear()`, presets `spark`, `hit`, `explode`, `pickup`, `dust`, `confetti`, and bounded custom override dictionaries.
- Before coding, inspect exact local `addons/game_feel_flow` and `addons/saltmire_spark`, both `plugin.cfg` files, autoloads, method signatures, effect registry, and Spark presets. Installed source overrides this planning shorthand if different.

**Beach Cocktails effect language**
- `MICRO`: launch, restrained table contact, whitelisted primary CTA.
- `MERGE`: merge feedback; combo bands BASE = chain 1-2, SURGE = 3-4, PEAK = 5-6. PEAK is the hard cap.
- `ORDER`: accepted To-Go progress/completion.
- `VIP`: premium delivery/completion distinct from ORDER.
- `WIN`: ordinary level completion.
- `MASTERY`: three-star, meaningful first-clear, or major reward.
- `ISLAND_UNLOCK`: island completion/new-island reveal, the largest allowed tier.
These are presentation tiers only and never influence gameplay values.

**FULL / REDUCED contract**
- FULL may use short local punch/spring/scale, local color emphasis, bounded Spark particles, and restrained reveal sequencing.
- REDUCED removes shake, camera/screen movement, squash/stretch, spring/position travel, large confetti, and rapid sequential motion. Use immediate state changes plus brief low-contrast alpha/color emphasis; MICRO/table-contact particles = 0; important tiers use at most ~25% of FULL particles with lower speed/lifetime.
- Both modes show identical semantic information, stars, rewards, unlocks, actions, and gameplay/campaign truth.

**Initial mobile ceilings, to be tightened by evidence rather than expanded:** MICRO <=5 particles / 0.16 s; MERGE <=10 / 0.30 s; MERGE PEAK <=18 / 0.35 s; ORDER <=16 / 0.45 s; VIP <=24 / 0.65 s; WIN <=48 live / 1.20 s; MASTERY <=64 / 1.50 s; ISLAND_UNLOCK <=72 / 1.60 s. Gameplay live-particle ceiling = 48; result/meta ceiling = 96; max one large celebration at once.

### M22 — Presentation architecture, plugin contract, semantic bridge, and settings

- [ ] BCM-M22-001 — Lock exact installed plugin APIs, packaging, and graceful no-plugin behavior.
  - Purpose: inspect exact local GameFeelFlow/Saltmire Spark versions/autoloads/APIs and establish release-safe optional dependency behavior before effect coding.
  - Existing seam: `project.godot` plus installed `addons/game_feel_flow` and `addons/saltmire_spark`.
  - Semantic trigger: none; dependency gate.
  - Plugin responsibility: verify callable methods/registries; future bridge must dynamically resolve `/root/GameFeelFlow` and `/root/Spark` and capability-check before calls.
  - Reduced Motion: verify plugins can remain loaded while motion-heavy categories are centrally disabled.
  - One-shot/idempotency: inspect/cache once per presentation host; no duplicate listeners/autoloads.
  - Mobile/performance budget: zero effects/particles; no per-frame API discovery.
  - Automated regression: both present, each missing, both missing, bad preset/effect, and export-start cases preserve identical game initialization/state.
  - Godot AI evidence: autoload/plugin inventory, method/preset probe, production boot screenshot, clean logs.
  - Owner acceptance: technical audit only; no visual sign-off required.

- [ ] BCM-M22-002 — Make FeedbackService the semantic presentation bus and add one sole plugin-calling presentation bridge.
  - Purpose: centralize semantic presentation requests without duplicate event authority.
  - Existing seam: `GameManager.feedback_service`; `FeedbackService.feedback_emitted/emit_merge/emit_order_complete/emit_game_success/emit_game_fail/emit_ui_tap`; `ShotController.shot_fired`; `CampaignNavigationController.gameplay_session_finished/_on_session_terminal`; `CampaignManager.progression_changed`; `UserSettings.presentation_changed`.
  - Semantic trigger: structured `cocktail_launch`, `table_contact`, `merge`, `order_progress`, `order_complete`, `vip_delivery`, `vip_complete`, `score_mastery`, `game_success`, `game_fail`, `level_unlock`, `island_milestone`, `island_complete`, `island_unlock`, `reward_granted`, and whitelisted `ui_primary`.
  - Plugin responsibility: one `PresentationFeedbackBridge`/equivalent translates semantics to GameFeelFlow UI/visual transforms and Spark bursts; no direct plugin API calls elsewhere.
  - Reduced Motion: bridge centrally maps every semantic event to FULL/REDUCED.
  - One-shot/idempotency: non-MICRO requests carry stable event/token IDs; preserve existing merge-source and order-token dedupe.
  - Mobile/performance budget: event-driven only, no polling; zero effects during this architecture task.
  - Automated regression: exact-one semantic dispatch, duplicate suppression, immutable result/state payloads, plugin failure cannot alter score/progression/save hashes.
  - Godot AI evidence: live wiring/event telemetry, duplicate probes, plugin-on/off runs, clean logs.
  - Owner acceptance: architecture audit, no visual sign-off.

- [ ] BCM-M22-003 — Freeze effect-tier configuration, FULL/REDUCED matrix, target restrictions, overlap/cancellation rules, and global budgets.
  - Purpose: turn MICRO/MERGE/ORDER/VIP/WIN/MASTERY/ISLAND_UNLOCK into executable presentation policy before production effects.
  - Existing seam: `UserSettings.get_presentation_state()/presentation_changed`, `GameManager.apply_presentation_settings`, `CampaignFeedbackOverlay`, HUD, `Drink/Visual`, `LevelButton`, World Map entries, Island Map nodes.
  - Semantic trigger: tier lookup only.
  - Plugin responsibility: map only locally verified GameFeelFlow effects/combos and Spark presets/overrides; blacklist physics/time effects, full-screen flash, heavy stock combos containing freeze/shake, and authoritative-root transforms.
  - Reduced Motion: complete alternative for every tier; cancellation on view/session changes.
  - One-shot/idempotency: stable key scheme; one large celebration maximum; lifecycle cancellation cannot affect gameplay state.
  - Mobile/performance budget: codify the ceilings above; zero production particles in this task.
  - Automated regression: every semantic kind mapped in both modes; forbidden effects/targets rejected; unknown event safely no-ops.
  - Godot AI evidence: live settings toggle/config inspection and clean logs.
  - Owner acceptance: owner approves the effect-language matrix before M23.

### M23 — Gameplay MICRO, merge, combo, and meaningful score feedback

- [ ] BCM-M23-001 — Add restrained launch and table-contact MICRO feedback without touching launch/collision authority.
  - Purpose: tactile launch/contact while preserving aiming, table/rail readability, and accepted physics.
  - Existing seam: `ShotController.shot_fired(drink,velocity)` after launch velocity is committed; table-contact notification may be emitted only after `Drink._integrate_forces()` applies `GameManager.project_footprint_inside_table()` and after existing `_on_body_entered()` rail handling.
  - Semantic trigger: one `cocktail_launch` per shot; `table_contact` only for meaningful contact, never settle jitter or merge contact.
  - Plugin responsibility: GameFeelFlow may affect only `Drink/Visual`/`CocktailSprite`; Spark tiny local `spark` accent. No root/body transform.
  - Reduced Motion: no transform punch, zero particles; optional <=0.10 s local alpha/color cue.
  - One-shot/idempotency: shot identity; contact cooldown >=120 ms per drink/contact class.
  - Mobile/performance budget: launch <=4 particles/0.14 s; contact <=5/0.16 s; one GFF visual effect maximum.
  - Automated regression: identical launch velocity/trajectory/rail projection with presentation on/off; collider/root transforms unchanged; contact-spam tests.
  - Godot AI evidence: portrait launch/contact captures, rail-readability comparison, telemetry, clean logs.
  - Owner acceptance: FULL and REDUCED required.

- [ ] BCM-M23-002 — Replace legacy merge juice with one coherent MERGE Spark burst plus visual-only cocktail punch.
  - Purpose: crisp merge pop without duplicate legacy effects.
  - Existing seam: `GameManager.on_merged(new_level,merged_drink)` after score/combo update; current `_juice_effect()` + `feedback_service.emit_merge()`; target `merged_drink/Visual`/`CocktailSprite`.
  - Semantic trigger: `merge` once with new level and current chain context.
  - Plugin responsibility: Spark custom `pickup`/`spark`; GameFeelFlow local scale punch/elastic effect. Retire `_juice_effect()` after parity rather than stack.
  - Reduced Motion: no squash/punch; <=4 low-speed particles/<=0.18 s or local color cue.
  - One-shot/idempotency: preserve merge-source dedupe; one event per merged result.
  - Mobile/performance budget: BASE <=10 particles/0.28 s + one GFF effect; no global flash/shake/freeze.
  - Automated regression: merge result, score, combo, physics, collider size, terminal cleanup identical with effects disabled.
  - Godot AI evidence: low/high-level merges, transient counts, boundary readability, REDUCED, clean logs.
  - Owner acceptance: required.

- [ ] BCM-M23-003 — Add capped combo escalation and selective score/mastery emphasis without animating every number.
  - Purpose: escalating but calm chain feel and feedback only for meaningful score milestones.
  - Existing seam: `GameManager.chain` 1..6, `COMBO_WINDOW`, `_chain_label`, score/best panels, `_refresh_hud()`, active level `score_star_thresholds`.
  - Semantic trigger: BASE 1-2, SURGE 3-4, PEAK 5-6; score UI only on first session crossing of prior best score and configured 2-star/3-star score thresholds.
  - Plugin responsibility: GameFeelFlow local chain/score/panel emphasis; Spark only scales the merge burst within caps. Camera movement remains off by default even at PEAK.
  - Reduced Motion: static label/state + <=0.10 s color cue; no scale/spring or extra particles beyond reduced merge allowance.
  - One-shot/idempotency: threshold/band crossing once per session; same-band merges add only normal merge feedback.
  - Mobile/performance budget: SURGE <=14 particles; PEAK <=18/0.35 s; score emphasis = zero particles.
  - Automated regression: combo/bonus math unchanged; exact-once threshold tests; repeated/worse score updates do not retrigger or alter persistence.
  - Godot AI evidence: chain 1→6, best-score and mastery crossings, REDUCED, clean logs.
  - Owner acceptance: BASE/SURGE/PEAK intensity required.

### M24 — To-Go and VIP presentation

- [ ] BCM-M24-001 — Add accepted To-Go delivery/progress feedback at the existing destination.
  - Purpose: make accepted progress clear without celebrating every HUD refresh.
  - Existing seam: `GameManager._collect_merge_target()/_finish_target_collection()`, existing delivery tween/trail, `_to_go_panel`, and `GameplaySessionBridge.record_to_go_delivery()` response.
  - Semantic trigger: `order_progress` only for `ok && accepted > 0`; terminal final delivery yields to Results WIN instead of double-celebrating.
  - Plugin responsibility: GameFeelFlow small target/panel emphasis; Spark small destination pickup sparkle; keep existing travel tween unless later proven redundant.
  - Reduced Motion: immediate progress update; no added travel/punch; <=3 low-speed particles/0.16 s or zero.
  - One-shot/idempotency: bridge delivery ID + accepted result; duplicates/rejections silent.
  - Mobile/performance budget: <=8 particles/0.25 s + one panel effect.
  - Automated regression: paused/rejected/duplicate = no effect; accepted quantities/rewards unchanged; terminal precedence tested.
  - Godot AI evidence: accepted progress, duplicate suppression, terminal transition, REDUCED, clean logs/screenshots.
  - Owner acceptance: required.

- [ ] BCM-M24-002 — Add ORDER-complete panel emphasis and reward flourish without stacking the current flash.
  - Purpose: distinguish requirement completion from ordinary progress.
  - Existing seam: `FeedbackService.emit_order_complete()`, `_order_completion_feedback()`, `_to_go_panel`, progress/reward labels, and authoritative delivery response.
  - Semantic trigger: `order_complete` only on authoritative incomplete→complete; suppress when immediate WIN owns the celebration.
  - Plugin responsibility: Spark bounded panel sparkle; GameFeelFlow short panel emphasis; replace/retire `_order_completion_feedback()` after parity.
  - Reduced Motion: brief color/alpha cue + <=4 low-speed particles; no spring.
  - One-shot/idempotency: completion token is dedupe key.
  - Mobile/performance budget: <=16 particles/0.45 s; no camera/full-screen effect.
  - Automated regression: token dedupe, final-order precedence, score/reward/panel parity, terminal cleanup.
  - Godot AI evidence: progress→complete, duplicate token, final-order result handoff, REDUCED, clean logs.
  - Owner acceptance: required.

- [ ] BCM-M24-003 — Give VIP delivery and VIP completion a distinct premium language.
  - Purpose: premium optional mastery distinct from ordinary To-Go without implying VIP is mandatory.
  - Existing seam: `GameManager._collect_vip_target()/_finish_vip_target()`, `GameplaySessionBridge.record_vip_delivery()` fields `accepted/vip_completed/delivered/remaining`, `vip_state_changed`, VIP target/progress/reward controls.
  - Semantic trigger: `vip_delivery` for accepted >0; `vip_complete` only false→true. Rejected/mismatch/duplicate silent.
  - Plugin responsibility: Spark premium custom pickup/burst; GameFeelFlow VIP panel/emblem/target emphasis only.
  - Reduced Motion: immediate progress/check state; no spring/travel; <=6 low-speed particles for completion only.
  - One-shot/idempotency: accepted state delta; VIP complete once/session.
  - Mobile/performance budget: delivery <=12 particles/0.35 s; complete <=24/0.65 s; one VIP celebration at a time.
  - Automated regression: optionality, premium score, normal-order precedence, mismatch/duplicate, stars identical with plugins disabled.
  - Godot AI evidence: ordinary vs VIP, multi-quantity progress, VIP complete, REDUCED, clean logs.
  - Owner acceptance: required.

### M25 — Results presentation and celebration hierarchy

- [ ] BCM-M25-001 — Add presentation-only Results choreography for panel entrance, title, stars, score, and rewards.
  - Purpose: polish Results while keeping `CampaignFeedbackOverlay` a pure view over immutable terminal truth.
  - Existing seam: `CampaignNavigationController._on_session_terminal()` exact-once guard, `_present_pending_terminal_result()`, `_result_presentation_count`, `CampaignFeedbackOverlay.show_result()`, FeedbackCard/title/body/actions.
  - Semantic trigger: exactly one `game_success` or `game_fail` from terminal result; stars/rewards read supplied result only.
  - Plugin responsibility: GameFeelFlow panel entrance/title/score/reward emphasis and star reveal; no Spark yet.
  - Reduced Motion: immediate or <=0.12 s alpha entry; stars together/minimal alpha; no spring/position motion.
  - One-shot/idempotency: existing terminal guards; presentation cannot recompute/grant anything.
  - Mobile/performance budget: zero particles; choreography <=0.75 s; actions remain safely usable.
  - Automated regression: WIN/LOSE actions and result data unchanged; one presentation; navigation/cancellation safe.
  - Godot AI evidence: WIN/LOSE reveal captures, node state before/after, REDUCED, clean logs.
  - Owner acceptance: required before particle celebrations.

- [ ] BCM-M25-002 — Add tiered WIN, three-star MASTERY, first-clear, and meaningful reward celebrations.
  - Purpose: ordinary win satisfying; mastery/first-clear/major reward clearly stronger without noise.
  - Existing seam: terminal result/progression/economy fields from `GameplaySessionBridge` + `CampaignManager.mark_level_completed()` (`record`, stars, `cumulative_rewards`, `next_level`, `next_island`, `island_complete`, grants). Presentation may snapshot pre/post state only to classify first-clear/unlock.
  - Semantic trigger: `game_success` every WIN; `mastery` at 3 stars; `first_clear` only first incomplete→complete; `reward_granted` only newly granted non-duplicate entries. Stronger tier subsumes weaker duplicate flourishes.
  - Plugin responsibility: evaluate Spark confetti/celebration/reward particles; GameFeelFlow title/panel/star/score punch/spring. M22 must verify Spark result CanvasLayer visibility; do not hack plugin internals if local API lacks layer/parent support.
  - Reduced Motion: no confetti rain/shake/spring/stagger; static stars/reward + brief color/alpha; <=8 low-speed particles only for major MASTERY/reward if accepted.
  - One-shot/idempotency: terminal ID + reward ledger + first-clear transition; one large celebration maximum.
  - Mobile/performance budget: WIN <=48 live/1.20 s; MASTERY <=64/1.50 s; combined first-clear/reward <=72 live.
  - Automated regression: 1/2/3-star, replay, duplicate reward, no-particle fallback, plugin-off parity, action hitbox/readability.
  - Godot AI evidence: normal WIN, mastery, first clear, reward, replay, FULL/REDUCED, clean logs.
  - Owner acceptance: mandatory.

- [ ] BCM-M25-003 — Add understated LOSE feedback with no confetti or aggressive punishment.
  - Purpose: clear failure and calm retry flow.
  - Existing seam: `FeedbackService.emit_game_fail()`, `GameplaySessionBridge.resolve_lose()`, navigation terminal handler, `CampaignFeedbackOverlay.show_result()` LOSE branch.
  - Semantic trigger: `game_fail` once per terminal loss.
  - Plugin responsibility: GameFeelFlow local card/title settle or alpha/color emphasis only; Spark not used.
  - Reduced Motion: immediate static result or <=0.10 s alpha only.
  - One-shot/idempotency: FeedbackService one-shot + terminal guard; retry clears presentation.
  - Mobile/performance budget: zero particles; <=0.25 s; no shake/flash/freeze/screen impulse.
  - Automated regression: no Spark emitter, retry/island actions usable, outcome/reason unchanged, repeat/retry clean.
  - Godot AI evidence: LOSE FULL/REDUCED, zero-particle proof, retry transition, clean logs.
  - Owner acceptance: required for tone.

### M26 — Campaign/map unlocks, island milestones, rewards, and selective UI

- [ ] BCM-M26-001 — Add level-unlock and Island Map milestone presentation from authoritative progression.
  - Purpose: highlight genuinely new level/milestone states without animating every refresh.
  - Existing seam: `CampaignManager.progression_changed`, `mark_level_completed()` return `next_level/cumulative_rewards`, `IslandMapController.refresh()/_state_for()`, `LevelButton`, milestone list, summary.
  - Semantic trigger: `level_unlock` only locked→open; `island_milestone` only newly reached/claimed configured threshold.
  - Plugin responsibility: GameFeelFlow affected LevelButton/milestone emphasis; Spark small local unlock/reward burst.
  - Reduced Motion: immediate state; color/outline cue, <=4 low-speed milestone particles only.
  - One-shot/idempotency: authoritative pre/post snapshot; refresh/re-entry cannot replay.
  - Mobile/performance budget: level unlock <=10 particles/0.35 s; milestone <=18/0.55 s; only affected node.
  - Automated regression: refresh/restart no replay; CampaignManager remains unlock authority; button layout/hitboxes unchanged.
  - Godot AI evidence: next-level unlock, milestone, refresh/re-entry, REDUCED, clean logs.
  - Owner acceptance: required.

- [ ] BCM-M26-002 — Add island-completion and new-island-unlock celebration on Island/World Maps.
  - Purpose: campaign-scale celebration without changing unlock rules or map geometry.
  - Existing seam: `CampaignManager.is_island_complete()/resolve_next_island()/_refresh_island_unlocks()`, terminal `island_complete/next_island`, `WorldMapController.refresh()/_state_for()`, map entry nodes, navigation view transitions.
  - Semantic trigger: `island_complete` first transition; `island_unlock` first locked→unlocked transition.
  - Plugin responsibility: Spark bounded campaign burst where layering is verified; GameFeelFlow completed-island summary/new World Map entry emphasis. Never move marker/click centers.
  - Reduced Motion: immediate unlock + brief color/alpha; <=10 low-speed particles only for new island if accepted; no pan/shake.
  - One-shot/idempotency: save/pre-post state prevents replay on restart/refresh/navigation.
  - Mobile/performance budget: island complete <=40 particles/1.10 s; island unlock <=72/1.60 s; serialize large meta celebrations.
  - Automated regression: unlock rules/coordinates unchanged; old unlocks do not replay; locked islands remain non-selectable; plugin-off navigation identical.
  - Godot AI evidence: final-level→map→new-island sequence, marker geometry comparison, REDUCED, clean logs.
  - Owner acceptance: mandatory.

- [ ] BCM-M26-003 — Add campaign/reward notification emphasis and narrowly whitelisted primary-CTA feedback.
  - Purpose: polish real rewards and primary actions without animating every generic button.
  - Existing seam: terminal `cumulative_rewards`/economy grants, `CampaignFeedbackOverlay` reward/actions, ApplicationShell primary PLAY, Results primary NEXT/RETRY, `FeedbackService.emit_ui_tap()`.
  - Semantic trigger: `reward_granted` only newly granted ledger entry; `ui_primary` only explicit PLAY/NEXT/RETRY whitelist, not back/settings/toggles/map nodes/every button.
  - Plugin responsibility: GameFeelFlow notification/button emphasis; Spark small reward burst only, never tap particles.
  - Reduced Motion: immediate color/alpha; CTA zero particles; important reward <=5 low-speed particles.
  - One-shot/idempotency: reward ID dedupe; CTA effect cannot delay/double navigation.
  - Mobile/performance budget: CTA <=0.10 s/zero particles; reward <=20/0.55 s.
  - Automated regression: whitelist enforcement, generic-button negative tests, exactly one action invocation, duplicate reward suppression, plugin-off parity.
  - Godot AI evidence: PLAY/NEXT/RETRY examples, generic negative evidence, reward, REDUCED, clean logs.
  - Owner acceptance: required for restraint.

### M27 — Performance, Reduced Motion, failure-mode, and runtime visual closure

- [ ] BCM-M27-001 — Enforce mobile budgets, emitter cleanup, overlap/cancellation, and terminal hygiene under stress.
  - Purpose: prove rapid merges/deliveries/navigation do not leak or overwhelm portrait mobile.
  - Existing seam: presentation-bridge telemetry, `GameManager.get_terminal_visual_counts()`, `campaign_transient_world_effect`, session/view lifecycle, Spark live pool, GameFeelFlow active effects/`stop_all`.
  - Semantic trigger: stress replay of existing semantic catalog only.
  - Plugin responsibility: cap live effects/emitters, cancel presentation on terminal/view disposal, prevent stale effects crossing Results/maps.
  - Reduced Motion: same stress suite with stricter caps.
  - One-shot/idempotency: no duplicate listeners after retry/map loops; event tokens exact-once.
  - Mobile/performance budget: hard <=48 live gameplay particles, <=96 result/meta, one large celebration, no unbounded nodes; lower counts if target device requires.
  - Automated regression: rapid combo, repeated To-Go/VIP, WIN/LOSE, retry xN, map loops, mid-effect cancellation, leak/listener checks, zero terminal world effects.
  - Godot AI evidence: particle/node telemetry, terminal screenshots, performance logs, zero errors.
  - Owner acceptance: feeds M27 final review.

- [ ] BCM-M27-002 — Audit every category in FULL and REDUCED and prove accessibility behavior is complete.
  - Purpose: Reduced Motion becomes a coherent alternative mode, not scattered exceptions.
  - Existing seam: `UserSettings.reduced_motion/presentation_changed`, ApplicationShell settings propagation, `GameManager.apply_presentation_settings()`, shared bridge, gameplay, Results, maps, rewards/CTA.
  - Semantic trigger: complete M22 semantic catalog.
  - Plugin responsibility: verify FULL/REDUCED mapping category by category.
  - Reduced Motion: runtime toggles safely; no motion-heavy replay, MICRO/table particles zero, important particles <=25% FULL, no camera movement.
  - One-shot/idempotency: mode changes never replay consumed events or duplicate listeners.
  - Mobile/performance budget: REDUCED strictly cheaper than FULL.
  - Automated regression: all semantic kinds, runtime toggle, restart persistence, high-contrast compatibility, identical score/progression/save outputs.
  - Godot AI evidence: paired FULL/REDUCED frames for launch, contact, merge/combo, ORDER, VIP, WIN, MASTERY, LOSE, level/island unlock, reward, CTA; clean logs.
  - Owner acceptance: mandatory paired-matrix review.

- [ ] BCM-M27-003 — Close presentation with authority regression, plugin-failure fallback, Godot AI evidence, and owner-native visual acceptance.
  - Purpose: prove GameFeelFlow/Spark remain removable presentation layers and close only after production-flow owner acceptance.
  - Existing seam: full regression suite, FeedbackService telemetry, presentation bridge, GameplaySessionBridge results, CampaignManager state, SaveManager output, Results/maps/settings, plugin/autoload presence.
  - Semantic trigger: representative end-to-end flows across all tiers.
  - Plugin responsibility: test both plugins, GameFeelFlow only, Spark only, neither plugin; authoritative outputs must match.
  - Reduced Motion: FULL + REDUCED end-to-end passes and persistence.
  - One-shot/idempotency: event-ledger comparison across replay/restart/navigation; historical reward/unlock/result feedback never replays without a new authoritative event.
  - Mobile/performance budget: all M27-001 ceilings pass target-device evidence; breaches reduce effects rather than relax limits.
  - Automated regression: physics/trajectory/merge/scoring/To-Go/VIP/no-timer/stars/rewards/unlocks/persistence parity with presentation disabled; injected plugin failure no-op; zero red Godot errors.
  - Godot AI evidence: complete production navigation captures, representative effect frames, clean logs, plugin-failure runs, cleanup reports, owner-native mobile package.
  - Owner acceptance: mandatory; builder self-audit cannot close M27.
