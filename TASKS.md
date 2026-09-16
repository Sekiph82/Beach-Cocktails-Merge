# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the only authoritative project-status tracker consumed by H!veAI for this repository. GitHub `main` and the latest committed evidence are the project-truth sources. Historical notes, Codex logs, audits, screenshots, and local files do not override this tracker.

## Project Status

- Current Milestone: M06
- Current Sprint: M06-ENVIRONMENT-RESPONSIVE-PLAYFIELD
- Current Task: BCM-M06-001 — Integrate environment background, table composition, and responsive playfield geometry.
- Current Task Status: READY
- Next Task/Action: Codex must execute `docs/prompts/BCM-M06_MILESTONE_COMPLETION_V01_PROMPT.md`, commit and push the bounded M06 environment/playfield integration work plus immutable evidence log, and stop for independent strict audit before BCM-M07-001 HUD composition begins.
- Required Actor: CODEX
- Tracking Repository: Sekiph82/Beach-Cocktails-Merge
- Tracking Branch: main

## Tasks

- [x] BCM-M00-001 — Repository synchronization and evidence baseline.
- [x] BCM-M00-002 — Repository hygiene, canonical structure, and Godot import baseline.
- [x] BCM-M01-001 — Recover and verify playable gameplay contract from synchronized v6.7 state.
- [x] BCM-M02-001 — Formalize physics, collision, merge, and rapid-launch regression suite.
- [x] BCM-M03-001 — Formalize scoring, combo, To-Go Orders, persistence, and game-over systems.
- [x] BCM-M04-001 — Import and validate the complete v7 visual asset library.
- [x] BCM-M05-001 — Integrate L01-L12 cocktail sprites and level presentation.
- [~] BCM-M06-001 — Integrate environment background, table composition, and responsive playfield geometry.
- [ ] BCM-M07-001 — Integrate logo, score panels, To-Go panel, Next panel, progression strip, launch zone, and danger line.
- [ ] BCM-M08-001 — Integrate To-Go delivery animation and visual effects.
- [ ] BCM-M09-001 — Add gameplay feedback polish, audio, and optional haptics.
- [ ] BCM-M10-001 — Add menus, settings, onboarding, accessibility, save migration, and UX polish.
- [ ] BCM-M11-001 — Mobile layout, performance, export, device QA, and release readiness.
- [ ] BCM-M12-001 — Final regression, acceptance, packaging, documentation, and v1 release closure.

# Beach Cocktails Merge MASTER TASKS

Legend: `[x]` validated complete, `[~]` active/in progress, `[ ]` planned/pending, `[!]` blocked.

A task is not complete because Codex reports completion. Completion requires independent strict audit evidence and any required owner-native acceptance. Historical Codex logs remain immutable claims, and historical audits remain immutable decisions.

## Canonical tracking rules

- Root `TASKS.md` is the sole current tracker.
- `AGENTS.md` defines Codex sync, logging, safety, and strict-audit governance.
- `docs/prompts/` contains authoritative Codex work orders.
- `docs/codex-logs/` contains immutable Codex execution claims/evidence indexes.
- `docs/audits/` contains independent strict audits and acceptance decisions.
- Codex must not create a competing hidden H!veAI tracker.
- Codex must not advance this tracker unless an active prompt explicitly authorizes a bounded tracker edit.
- Every normal milestone stops after implementation for independent audit.
- FAIL or blocking CONDITIONAL findings require bounded remediation before the next normal milestone.

---

# M00 — Repository synchronization, governance, and trustworthy baseline

Goal: make GitHub `main` accurately represent the owner's current local Godot project without losing local or remote work, then establish a clean auditable baseline for all later development.

### M00.01 — Safe synchronization preflight
- [x] BCM-M00-001 — Repository synchronization and evidence baseline.
  - [x] Prove the actual local Git root and expected workspace `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
  - [x] Record local branch, HEAD, remote URLs, status, tags, and worktrees.
  - [x] Fetch `origin/main` before reading implementation prompts.
  - [x] Compare local HEAD against `origin/main` without destructive reset/rebase/force operations.
  - [x] Inventory local tracked changes, untracked files, generated assets, and any local-only gameplay revisions.
  - [x] Inventory remote-only governance files and current GitHub project contents.
  - [x] Reconcile both sides while preserving owner-created work.
  - [x] Commit and push all intended current project files and assets.
  - [x] Verify local HEAD, `origin/main`, and remote `main` SHA match.
  - [x] Write immutable Codex evidence log and stop for strict audit.

### M00.02 — Canonical project structure and hygiene
- [x] BCM-M00-002 — Repository hygiene, canonical structure, and Godot import baseline.
  - [x] Confirm `project.godot` opens cleanly in Godot 4.7.x.
  - [x] Confirm canonical `scenes/`, `scripts/`, `data/`, and `assets/` trees.
  - [x] Ensure `.godot/`, editor caches, temporary exports, user save files, and machine-specific files are ignored.
  - [x] Confirm all approved visual assets are versioned at canonical paths.
  - [x] Confirm no duplicate/conflicting asset filenames or stale prototype copies are used by production scenes.
  - [x] Update README/documentation to identify the synchronized baseline and run instructions.
  - [x] Add or validate a deterministic headless parse/import check where technically practical.

Acceptance gate: repository truth is synchronized and auditable; Godot opens without parse/import failures; no owner work was discarded.

---

# M01 — Gameplay contract recovery and playable baseline verification

Goal: recover the actual accepted v6.7 gameplay behavior from synchronized source and prove the game still plays before visual replacement begins.

### M01.01 — Scene and runtime contract
- [x] BCM-M01-001 — Recover and verify playable gameplay contract from synchronized v6.7 state.
  - [x] Inspect `project.godot`, main scene, world hierarchy, physics configuration, and viewport/stretch behavior.
  - [x] Document launch-zone geometry, playfield geometry, walls, danger boundary, and table coordinate system.
  - [x] Verify desktop mouse and mobile touch input routes.
  - [x] Verify immediate next-drink availability after every launch.
  - [x] Verify multiple simultaneously moving drinks are supported.
  - [x] Verify restart and Game Over paths.
  - [x] Verify saved best score survives restart when expected.
  - [x] Record any mismatch between owner-accepted behavior and synchronized implementation as findings, not assumptions.

### M01.02 — Accepted gameplay constants
- [x] Confirm initial launch speed is `700 px/s` unless repository evidence proves an owner-approved later change.
- [x] Confirm deceleration is `180 px/s²` with no artificial cruise/minimum-speed assist.
- [x] Confirm a newly launched drink is replaced immediately by the next launchable drink.
- [x] Confirm stopped drinks remain physically movable when hit.
- [x] Confirm merge results preserve meaningful momentum.
- [x] Confirm post-collision motion never intentionally rebounds toward the player.
- [x] Confirm visual integration work does not silently retune these values.

Acceptance gate: playable baseline is reproduced and documented before visual integration.

---

# M02 — Physics, collision, merge, and rapid-launch hardening

Goal: convert the accepted feel into regression-protected production behavior.

### M02.01 — Drink body physics
- [x] BCM-M02-001 — Formalize physics, collision, merge, and rapid-launch regression suite.
  - [x] Validate `RigidBody2D` mode, mass progression, sleeping/wake behavior, friction, damping, and zero/near-zero bounce.
  - [x] Record current collider/radius mapping and defer final V7 sprite-footprint alignment to M05.
  - [x] Verify wall/top-boundary interactions do not produce unwanted backward return.
  - [x] Verify collisions transfer momentum to previously settled drinks.
  - [x] Verify collisions do not tunnel at accepted launch velocity.

### M02.02 — Merge resolution
- [x] Preserve deferred merge processing outside unsafe physics callbacks.
- [x] Ensure each pair can merge only once per contact event.
- [x] Ensure merged result level is correct and capped at L12.
- [x] Ensure L12 + L12 does not disappear or create L13.
- [x] Preserve resultant momentum after merge.
- [x] Prevent duplicate score/merge signals from one merge.
- [x] Stress test chain merges with several moving drinks.

### M02.03 — Rapid-launch concurrency
- [x] Launch a new drink while prior drinks are moving.
- [x] Validate rapid consecutive launches do not corrupt held/current/next references.
- [x] Validate held launch drink is non-colliding until released.
- [x] Validate restart while several drinks move.
- [x] Validate Game Over while several drinks move.

Acceptance gate: no regression in accepted feel; focused tests or deterministic test harness covers critical rules.

---

# M03 — Scoring, combo, To-Go Orders, persistence, and game-over systems

Goal: formalize the complete rules economy agreed by the owner.

### M03.01 — Merge score table
- [x] BCM-M03-001 — Formalize scoring, combo, To-Go Orders, persistence, and game-over systems.
- [x] L2 = 20 merge points.
- [x] L3 = 50 merge points.
- [x] L4 = 100 merge points.
- [x] L5 = 200 merge points.
- [x] L6 = 350 merge points.
- [x] L7 = 600 merge points.
- [x] L8 = 1,000 merge points.
- [x] L9 = 1,600 merge points.
- [x] L10 = 2,500 merge points.
- [x] L11 = 4,000 merge points.
- [x] L12 = 6,500 merge points.

### M03.02 — Combo rules
- [x] Combo window = 1.5 seconds unless later owner-approved evidence supersedes it.
- [x] x1 = +0% merge bonus.
- [x] x2 = +25%.
- [x] x3 = +50%.
- [x] x4 = +75%.
- [x] x5 = +100%.
- [x] x6+ capped at +125%.
- [x] Combo extension/reset behavior is deterministic and testable.
- [x] Stored later To-Go delivery does not retroactively earn combo bonus.

### M03.03 — To-Go Orders rules
- [x] Target levels span L6-L12.
- [x] Each active order requests exactly one target drink level unless later design expands the contract.
- [x] Existing matching L6-L12 drink already on the table can satisfy a newly appearing order.
- [x] Only one stored matching drink is consumed per order.
- [x] A drink earns its merge score only when originally created.
- [x] Later stored-drink delivery awards only the To-Go bonus, not merge score again and not historical combo again.
- [x] L12 remains on the table when not ordered and can satisfy a future L12 order.
- [x] Prevent immediately repeating the same target where the accepted implementation intends variety.

### M03.04 — To-Go bonus table
- [x] L6 = 1,000 owner-approved To-Go bonus.
- [x] L7 = 1,800 owner-approved To-Go bonus.
- [x] L8 = 3,000.
- [x] L9 = 5,000.
- [x] L10 = 8,000.
- [x] L11 = 12,000.
- [x] L12 = 18,000.

### M03.05 — Score persistence and game over
- [x] Best score persists through `user://` save data.
- [x] Save corruption/missing save has safe defaults.
- [x] Danger-line failure timing is explicit and deterministic.
- [x] Game Over freezes/ends the session without corrupting persistent score.
- [x] Restart clears session state but preserves best score.

Acceptance gate: all score increments are auditable, non-duplicated, and regression tested.

---

# M04 — V7 asset library import and validation

Goal: make all owner-approved visual assets canonical, import-safe, and ready for dynamic Godot composition.

### M04.01 — Cocktail assets
- [x] BCM-M04-001 — Import and validate the complete v7 visual asset library.
- [x] Validate `assets/cocktails/L01.png` through `L12.png` exist and import.
- [x] Confirm all cocktail assets have transparent backgrounds and expected alpha.
- [x] Record transparent bounds and confirm readable progression; runtime pivot/scale mapping is deferred to M05.
- [x] Confirm every cocktail includes a straw per owner art rule.
- [x] Preserve owner-approved garnish differences.

### M04.02 — Environment asset
- [x] Validate `assets/environment/game_board_background.png`.
- [x] Confirm it contains only tropical environment + empty perspective wooden table.
- [x] Confirm no baked dynamic UI, logo, score, Next, To-Go, drink sprites, progression strip, danger line, guide line, or launch ring.

### M04.03 — UI assets
- [x] Validate `assets/ui/logo_beach_cocktails_merge.png`.
- [x] Validate `assets/ui/panel_best_score.png`.
- [x] Validate `assets/ui/panel_score.png` and record the non-blocking 2 px width delta from Best Score panel.
- [x] Validate `assets/ui/panel_to_go_orders.png` has blank dynamic content area.
- [x] Validate `assets/ui/panel_next.png` has blank dynamic preview area.
- [x] Validate `assets/ui/progression_strip.png` contains exactly 12 empty slots.
- [x] Validate `assets/ui/launch_zone.png` is a simple glowing gold oval with transparent center and no extra decoration/text.
- [x] Validate `assets/ui/danger_line.png` as the horizontal dashed boundary asset.
- [x] `guide_line` is explicitly out of scope and was not introduced.

### M04.04 — Effects assets
- [x] Validate `assets/effects/to_go_trail.png` is the simplified gold light trail with small sparkles/bubbles and no large garnish objects.
- [x] Record that additional merge/order VFX should remain procedural/later bounded effect work rather than be added in M04.

Acceptance gate: asset inventory passes import, alpha, naming, dimensional, and semantic checks.

---

# M05 — Cocktail sprite integration

Goal: replace placeholder drink circles with real L01-L12 cocktail sprites without changing gameplay physics.

### M05.01 — Sprite mapping
- [x] BCM-M05-001 — Integrate L01-L12 cocktail sprites and level presentation.
- [x] Add deterministic level-to-texture mapping for L01-L12.
- [x] Replace placeholder geometry with `Sprite2D`/appropriate nodes.
- [x] Keep gameplay/body logic separated from visual texture logic.
- [x] Expose the same canonical texture mapping for future Next, To-Go and progression consumers; table/held/merge visuals already use it.

### M05.02 — Size and collider mapping
- [x] Define per-level visual scale and offset/pivot strategy.
- [x] Define per-level collision footprint based on visible glass body, not garnish extremes.
- [x] Use bounded body-only colliders to avoid large invisible gaps/obvious garnish-driven footprint inflation.
- [x] Preserve compressed runtime mass progression without extreme immovable high-level drinks.
- [x] Verify L01-L12 presentation remains bounded/distinguishable in the portrait playfield; final integrated/native visual acceptance remains later.

### M05.03 — Merge visual continuity
- [x] New merged sprite appears at a physically plausible contact/merge position.
- [x] Result sprite does not visibly teleport excessively in deterministic merge evidence.
- [x] Result collider and sprite update atomically with level.
- [x] Result continues moving according to preserved momentum.

Acceptance gate: M05 deterministic presentation/physics integration passes and M01-M03 gameplay/economy regressions remain accepted. Audit note F-M05-EVIDENCE-001 corrects the historical pre-M05 radius table in the immutable builder log.

---

# M06 — Environment and responsive playfield integration

Goal: replace prototype background/table visuals with the approved beach-bar environment while preserving gameplay coordinates and usable play area.

### M06.01 — Background composition
- [~] BCM-M06-001 — Integrate environment background, table composition, and responsive playfield geometry.
- [ ] Place `game_board_background.png` as the base visual layer.
- [ ] Align world playfield to the visible perspective table surface.
- [ ] Keep collision boundaries inside visually credible table rails.
- [ ] Ensure launch position, danger line, and top stop boundary match visible geometry.

### M06.02 — Portrait scaling
- [ ] Establish canonical portrait design resolution.
- [ ] Verify stretch/aspect behavior on representative desktop debug windows and phone aspect ratios.
- [ ] Avoid cropping critical future-HUD/playfield regions on tall/short devices.
- [ ] Avoid black bars where practical without distorting gameplay coordinates.

### M06.03 — Play-space tuning
- [ ] Keep danger line closer to launch glass than the early master mockup to preserve more playable table area, per owner direction.
- [ ] Confirm launch position leaves enough room below the danger line for readable interaction.
- [ ] Confirm top accumulation area remains visible beneath future To-Go/UI panels.
- [ ] Retain runtime screenshots/render captures for canonical, taller, and shorter/wider portrait aspect evidence.

Acceptance gate: world collision geometry and visual table geometry agree across tested aspect ratios while M01-M05 regressions remain green.

---

# M07 — Dynamic HUD integration

Goal: reproduce the owner-approved master HUD from separate reusable assets and dynamic Godot controls.

### M07.01 — Branding and score panels
- [ ] BCM-M07-001 — Integrate logo, score panels, To-Go panel, Next panel, progression strip, launch zone, and danger line.
- [ ] Top-left `Beach Cocktails Merge` logo.
- [ ] Best Score panel directly below logo.
- [ ] Score panel directly below Best Score.
- [ ] Best Score and Score panel dimensions/visual rhythm match.
- [ ] Dynamic numbers are Godot text, not baked into PNG.

### M07.02 — To-Go Orders panel
- [ ] Place panel upper-middle.
- [ ] Dynamically show current target cocktail using canonical L01-L12 texture.
- [ ] Dynamically show To-Go reward value.
- [ ] Trigger completion visual state and target replacement.

### M07.03 — Next panel
- [ ] Place panel top-right.
- [ ] Dynamically show the true next launch drink.
- [ ] Ensure immediate-next generation after launch updates panel correctly.

### M07.04 — Progression strip
- [ ] Place 12-slot strip near bottom without shrinking playable table excessively.
- [ ] Populate exactly 12 slots with L01-L12 textures.
- [ ] Optionally label levels dynamically if needed for clarity; do not bake wrong text into art.
- [ ] Ensure cocktail icons remain legible at target phone size.

### M07.05 — Launch zone and danger line
- [ ] Place launch-zone gold oval under the held cocktail.
- [ ] Hide/animate launch zone appropriately during game-over or transitions.
- [ ] Place danger line at final owner-approved vertical coordinate.
- [ ] No guide-line asset or persistent aiming line.

Acceptance gate: HUD matches master composition closely while all values remain live/dynamic.

---

# M08 — To-Go delivery and visual effects

Goal: make merges and order delivery feel polished without obscuring gameplay.

### M08.01 — To-Go delivery animation
- [ ] BCM-M08-001 — Integrate To-Go delivery animation and visual effects.
- [ ] Matching drink leaves the table and travels visually to To-Go panel.
- [ ] Use simplified `to_go_trail.png` or equivalent particle/trail composition.
- [ ] Remove/disable physics body cleanly during delivery to prevent collisions after pickup.
- [ ] Award To-Go score exactly once.
- [ ] After completion, show next order at deterministic safe timing.

### M08.02 — Merge feedback
- [ ] Add restrained merge glow/sparkle.
- [ ] Add brief scale/pop animation without disrupting physics transform ownership.
- [ ] Differentiate high-level merges without excessive screen obstruction.
- [ ] Combo feedback remains readable but does not block launch input.

### M08.03 — Performance and cleanup
- [ ] Pool or efficiently clean temporary effects where appropriate.
- [ ] No lingering particles/nodes after restart.
- [ ] Stress test repeated rapid merges and deliveries.

Acceptance gate: effects enhance clarity and reward without changing scoring or physics.

---

# M09 — Audio, haptics, and gameplay juice

Goal: complete sensory feedback while retaining a calm premium casual-game feel.

### M09.01 — Audio architecture
- [ ] BCM-M09-001 — Add gameplay feedback polish, audio, and optional haptics.
- [ ] Define separate music/SFX buses.
- [ ] Add launch, collision, merge, combo, order-complete, game-over, and button SFX.
- [ ] Prevent collision sound spam under dense contact.
- [ ] Add tropical background music only if licensed/owned and approved.

### M09.02 — Haptics/mobile feedback
- [ ] Add optional light haptic for launch/merge/order where platform support permits.
- [ ] Respect settings toggle.
- [ ] Fail safely on unsupported desktop platforms.

### M09.03 — Visual micro-polish
- [ ] Subtle button/score animations.
- [ ] Score increment feedback.
- [ ] Best-score celebration without excessive blocking effects.

Acceptance gate: feedback is responsive, optional where appropriate, and performant.

---

# M10 — Menus, onboarding, settings, accessibility, and persistence

Goal: turn the gameplay scene into a complete user-facing game flow.

### M10.01 — Start/menu flow
- [ ] BCM-M10-001 — Add menus, settings, onboarding, accessibility, save migration, and UX polish.
- [ ] Add title/start flow consistent with Beach Cocktails visual identity.
- [ ] Add Pause/Resume.
- [ ] Add Restart with confirmation where appropriate.
- [ ] Add Return to menu.

### M10.02 — Onboarding
- [ ] Explain drag left/right and release-to-slide interaction without permanent guide line.
- [ ] Explain matching/merge progression.
- [ ] Explain danger line.
- [ ] Explain To-Go order behavior and stored high-level drinks.
- [ ] Make onboarding dismissible and non-repetitive after completion.

### M10.03 — Settings/accessibility
- [ ] Music volume.
- [ ] SFX volume.
- [ ] Haptics toggle where supported.
- [ ] Reduced motion option where practical.
- [ ] Color/contrast/readability audit for text and boundaries.
- [ ] Safe-area handling for notches/system UI.

### M10.04 — Save model
- [ ] Version save schema.
- [ ] Preserve best score/settings across upgrades.
- [ ] Safe recovery from corrupt/old save.

Acceptance gate: complete navigable game loop from launch to replay with accessible controls.

---

# M11 — Mobile optimization, export, performance, and device QA

Goal: make the project shippable on intended mobile platforms and stable on desktop development builds.

### M11.01 — Performance budget
- [ ] BCM-M11-001 — Mobile layout, performance, export, device QA, and release readiness.
- [ ] Profile physics with dense table states.
- [ ] Profile texture memory for 12 cocktails and UI assets.
- [ ] Configure texture import/compression appropriately per target.
- [ ] Eliminate avoidable allocations in hot physics/UI paths.
- [ ] Validate stable frame pacing on representative mid-range mobile hardware where available.

### M11.02 — Android export
- [ ] Configure Android export preset.
- [ ] Validate portrait orientation.
- [ ] Validate touch input, pause/resume, back behavior, and save location.
- [ ] Produce test APK/AAB as appropriate.

### M11.03 — iOS readiness
- [ ] Document iOS export prerequisites if macOS/Xcode environment is unavailable.
- [ ] Validate project-side settings, icons, orientations, safe areas, and input assumptions.
- [ ] Mark device-only validation explicitly UNVERIFIED until performed.

### M11.04 — Desktop development regression
- [ ] F5 launches without parse/import errors.
- [ ] Mouse input remains functional.
- [ ] Window scaling remains usable for QA.

Acceptance gate: target exports are reproducible and unverified platform steps are explicitly documented.

---

# M12 — Final release audit, acceptance, packaging, and v1 closure

Goal: independently prove the game matches its gameplay, visual, score, persistence, and release contracts.

### M12.01 — Full regression
- [ ] BCM-M12-001 — Final regression, acceptance, packaging, documentation, and v1 release closure.
- [ ] Run all focused gameplay tests.
- [ ] Run rapid-launch and collision stress tests.
- [ ] Run merge/score/combo/To-Go regression matrix.
- [ ] Run restart/save/game-over regression.
- [ ] Run all UI/aspect-ratio checks.
- [ ] Run performance/export checks.

### M12.02 — Final visual acceptance
- [ ] Compare implementation against owner-approved master visual direction.
- [ ] Verify environment, logo, panels, cocktails, progression strip, launch zone, and danger line.
- [ ] Verify dynamic data is not baked incorrectly into static art.
- [ ] Obtain owner visual/native acceptance.

### M12.03 — Documentation and packaging
- [ ] Final README with controls, rules, build/run/export instructions.
- [ ] Asset inventory and license/provenance notes.
- [ ] Version/release notes.
- [ ] Tag/release candidate only after strict audit PASS.

### M12.04 — Independent strict final audit
- [ ] Audit builder claims against repository truth.
- [ ] Verify GitHub/local HEAD synchronization.
- [ ] Verify no stale/untracked production assets are required.
- [ ] Verify no BLOCKER/MAJOR findings remain.
- [ ] Close project only on unconditional PASS plus required owner acceptance.

M12 completion = Beach Cocktails Merge v1 release-ready closure.