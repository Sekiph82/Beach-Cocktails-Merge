# Beach Cocktails Merge — Canonical GitHub Task State

This root `TASKS.md` is the only authoritative project-status tracker consumed by H!veAI for this repository. GitHub `main` and the latest committed evidence are the project-truth sources. Historical notes, Codex logs, audits, screenshots, and local files do not override this tracker.

## Project Status

- Current Milestone: M07
- Current Sprint: M07-DYNAMIC-HUD-INTEGRATION
- Current Task: BCM-M07-001 — Integrate logo, score panels, To-Go panel, Next panel, progression strip, launch zone, and danger line.
- Current Task Status: READY
- Next Task/Action: Codex must execute `docs/prompts/BCM-M07_MILESTONE_COMPLETION_V01_PROMPT.md`, commit and push the bounded M07 dynamic HUD/gameplay-screen composition plus immutable evidence log, and stop for independent strict audit and owner visual playtest before BCM-M08-001 begins.
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
- [x] BCM-M06-001 — Integrate environment background, table composition, and responsive playfield geometry.
- [~] BCM-M07-001 — Integrate logo, score panels, To-Go panel, Next panel, progression strip, launch zone, and danger line.
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
- Codex must never edit root `TASKS.md`.
- Every normal milestone stops after implementation for independent ChatGPT audit.
- FAIL or blocking CONDITIONAL findings require bounded remediation before progression.

---

# M00 — Repository synchronization, governance, and trustworthy baseline

- [x] BCM-M00-001 — Repository synchronization and evidence baseline.
- [x] BCM-M00-002 — Repository hygiene, canonical structure, and Godot import baseline.

Validated state: canonical workspace/repository synchronized safely, approved assets versioned, generated/cache files excluded, Godot 4.7.x import/parse/main-scene baseline clean.

---

# M01 — Gameplay contract recovery and playable baseline verification

- [x] BCM-M01-001 — Recover and verify playable gameplay contract from synchronized v6.7 state.

Validated contract includes 700 px/s launch, 180 px/s² deceleration, immediate next-held generation, simultaneous moving drinks, settled-body wake, forward-only response, merge momentum, restart/Game Over, and persistent best score.

---

# M02 — Physics, collision, merge, and rapid-launch hardening

- [x] BCM-M02-001 — Formalize physics, collision, merge, and rapid-launch regression suite.

Validated: body configuration, collision/wake behavior, no practical tunneling at accepted speed, deferred merge processing, one-pair/one-merge behavior, L12 cap, merge momentum, chain stress, rapid launches, moving restart and moving Game Over. Final sprite-footprint mapping was subsequently closed in M05.

---

# M03 — Scoring, combo, To-Go Orders, persistence, and game-over systems

- [x] BCM-M03-001 — Formalize scoring, combo, To-Go Orders, persistence, and game-over systems.

### Accepted merge scores

- [x] L2 = 20.
- [x] L3 = 50.
- [x] L4 = 100.
- [x] L5 = 200.
- [x] L6 = 350.
- [x] L7 = 600.
- [x] L8 = 1,000.
- [x] L9 = 1,600.
- [x] L10 = 2,500.
- [x] L11 = 4,000.
- [x] L12 = 6,500.

### Accepted combo contract

- [x] Combo window = 1.5 seconds.
- [x] x1 +0%, x2 +25%, x3 +50%, x4 +75%, x5 +100%, x6+ capped +125%.
- [x] Stored later To-Go delivery does not replay historical merge/combo points.

### Accepted To-Go contract

- [x] Targets span L6-L12, initial target L6, immediate repeats avoided.
- [x] Existing stored matching L6-L12 drink may satisfy a future order.
- [x] Only one stored matching drink is consumed per order.
- [x] L12 remains on table when not ordered and may satisfy a later L12 order.
- [x] L6 reward = 1,000.
- [x] L7 reward = 1,800.
- [x] L8 reward = 3,000.
- [x] L9 reward = 5,000.
- [x] L10 reward = 8,000.
- [x] L11 reward = 12,000.
- [x] L12 reward = 18,000.

### Persistence / failure

- [x] Missing/corrupt save safely defaults.
- [x] Best score persists through `user://`.
- [x] Danger-line failure timing deterministic.
- [x] Game Over and restart preserve persistent record while clearing session state.

---

# M04 — V7 asset library import and validation

- [x] BCM-M04-001 — Import and validate the complete v7 visual asset library.

Validated canonical inventory:

- [x] `assets/cocktails/L01.png` through `L12.png`.
- [x] `assets/environment/game_board_background.png`.
- [x] logo, Best Score, Score, To-Go, Next, progression strip, launch zone and danger line UI assets.
- [x] `assets/effects/to_go_trail.png`.
- [x] Cocktail transparency, straw/garnish semantics and readable progression.
- [x] Background contains empty perspective table without baked dynamic UI/gameplay pieces.
- [x] Progression strip contains exactly 12 empty slots.
- [x] Launch zone is a clean gold oval/ring with transparent center and no clutter.
- [x] No `guide_line` asset.

Non-blocking note: Best Score source PNG is 2 px wider than Score source PNG; runtime display should normalize their visual dimensions without editing source art.

---

# M05 — Cocktail sprite integration

- [x] BCM-M05-001 — Integrate L01-L12 cocktail sprites and level presentation.

Validated:

- [x] One reusable canonical level-to-texture mapping.
- [x] Placeholder drink graphics replaced by canonical Sprite2D presentation.
- [x] Table, held and merge-result drinks share canonical mapping; accessor exposed for later HUD consumers.
- [x] Per-level scale/offset/pivot strategy defined.
- [x] Collider footprint is based on visible glass/body rather than garnish extremes.
- [x] Compressed runtime mass progression preserved.
- [x] Merge result visual/collider/level update coherently and momentum is preserved.
- [x] Rapid launch/restart/Game Over visual ownership remains coherent.

Audit note `F-M05-EVIDENCE-001`: immutable M05 builder log misstated the historical pre-M05 JSON radius series. Repository truth was `14,21,29,38,48,59,71,84,98,113,129,146`; this was documentation-only and did not invalidate the accepted M05 runtime mapping.

---

# M06 — Environment and responsive playfield integration

- [x] BCM-M06-001 — Integrate environment background, table composition, and responsive playfield geometry.

### M06.01 — Background/table composition

- [x] Canonical `game_board_background.png` is the production base visual.
- [x] World/playfield geometry maps to source-space visible table landmarks.
- [x] Four bounded perspective rails follow the visible table.
- [x] Launch position, danger coordinate and top stop are mapped from the approved environment.

### M06.02 — Portrait scaling

- [x] Uniform cover mapping preserves source aspect ratio.
- [x] Canonical 720x1280 tested.
- [x] Taller 720x1440 tested.
- [x] Shorter/wider 800x1280 tested.
- [x] No gameplay-critical black bars introduced.

### M06.03 — Play-space tuning

- [x] Danger line is near the launch side while preserving usable accumulation area.
- [x] Held launch position remains inside lower visible table.
- [x] L01/L06/L12 representative footprints remain within perspective rails.
- [x] Runtime render evidence retained under `docs/evidence/m06/`.
- [x] M01-M05 regressions remain green.

Acceptance gate: PASS in `docs/audits/BCM-M06_MILESTONE_COMPLETION_V01_AUDIT.md`. Owner/native final aesthetic acceptance remains later.

---

# M07 — Dynamic HUD integration

Goal: reproduce the owner-approved master gameplay screen from separate reusable assets and live Godot data. M07 completion is the first owner-playable near-final visual checkpoint.

### M07.01 — Branding and score panels

- [~] BCM-M07-001 — Integrate logo, score panels, To-Go panel, Next panel, progression strip, launch zone, and danger line.
- [ ] Place top-left Beach Cocktails Merge logo.
- [ ] Place Best Score directly below logo.
- [ ] Place Score directly below Best Score.
- [ ] Normalize displayed Best Score/Score panel dimensions despite the 2 px source-width delta.
- [ ] Render dynamic numeric values as live Godot text, not baked PNG data.
- [ ] Remove/suppress superseded prototype score/best/next/target/hint UI.

### M07.02 — To-Go Orders panel

- [ ] Place panel upper-middle without consuming the active accumulation region.
- [ ] Dynamically show current target via shared M05 canonical cocktail texture mapping.
- [ ] Dynamically show current To-Go reward.
- [ ] Update target/reward when production order state changes.
- [ ] Exactly one active To-Go presentation.

### M07.03 — NEXT panel

- [ ] Place exactly one NEXT panel top-right.
- [ ] Show actual next launch drink through shared canonical mapping.
- [ ] Immediate/rapid launch updates must stay coherent with true next state.
- [ ] No bottom/duplicate NEXT presentation.

### M07.04 — Progression strip

- [ ] Place the 12-slot strip near bottom without shrinking the playfield excessively.
- [ ] Populate exactly L01-L12 left-to-right through shared canonical mapping.
- [ ] No L13 slot.
- [ ] Keep icons legible at representative portrait sizes.

### M07.05 — Launch zone and danger line

- [ ] Place canonical launch-zone gold oval under held cocktail at M06 launch position.
- [ ] Launch-zone visual is non-colliding and does not change shot physics.
- [ ] Replace temporary/procedural danger boundary visual with canonical `danger_line.png` at the accepted M06 `death_line_y`.
- [ ] Do not move gameplay threshold merely to fit visual art.
- [ ] No guide-line asset or persistent aiming line.

### M07.06 — Responsive/owner-playable evidence

- [ ] Validate 720x1280, 720x1440 and 800x1280 HUD composition.
- [ ] Retain actual production screenshots under `docs/evidence/m07/`.
- [ ] Verify no duplicate legacy UI remains visible.
- [ ] Rerun M01-M06 regressions and focused M07 probe.
- [ ] After independent ChatGPT audit, perform owner visual/playtest before M08 progression.

Acceptance gate: owner-approved master HUD composition is closely reproduced, all changing values remain live/dynamic, gameplay contracts remain green, and the screen is ready for owner playtest.

---

# M08 — To-Go delivery and visual effects

- [ ] BCM-M08-001 — Integrate To-Go delivery animation and visual effects.
- [ ] Matching drink visually travels to To-Go panel while physics ownership is disabled cleanly.
- [ ] Award To-Go score exactly once.
- [ ] Use approved trail/equivalent restrained particle composition.
- [ ] Add restrained merge glow/sparkle/pop feedback.
- [ ] Ensure effects clean up on restart and under rapid stress.

---

# M09 — Audio, haptics, and gameplay juice

- [ ] BCM-M09-001 — Add gameplay feedback polish, audio, and optional haptics.
- [ ] Separate music/SFX buses and gameplay/button feedback.
- [ ] Prevent dense-contact sound spam.
- [ ] Optional platform-safe haptics with toggle.
- [ ] Subtle score/best-score micro-polish.

---

# M10 — Menus, onboarding, settings, accessibility, and persistence

- [ ] BCM-M10-001 — Add menus, settings, onboarding, accessibility, save migration, and UX polish.
- [ ] Start/title flow, Pause/Resume, Restart and Return to Menu.
- [ ] Dismissible onboarding without permanent guide line.
- [ ] Music/SFX/haptics/reduced-motion controls where applicable.
- [ ] Contrast/readability and safe-area treatment.
- [ ] Versioned save schema/migration.

---

# M11 — Mobile optimization, export, performance, and device QA

- [ ] BCM-M11-001 — Mobile layout, performance, export, device QA, and release readiness.
- [ ] Dense-table physics and texture-memory profiling.
- [ ] Android export/test package.
- [ ] iOS project readiness/documented device-only gaps if macOS/Xcode unavailable.
- [ ] Desktop development regression remains functional.

---

# M12 — Final release audit, acceptance, packaging, and v1 closure

- [ ] BCM-M12-001 — Final regression, acceptance, packaging, documentation, and v1 release closure.
- [ ] Full gameplay/economy/To-Go/restart/save regression.
- [ ] Final visual comparison against owner-approved direction.
- [ ] Owner native visual acceptance.
- [ ] Final README/build/export/asset provenance/release notes.
- [ ] Independent strict audit with no remaining BLOCKER/MAJOR findings.

M12 completion = Beach Cocktails Merge v1 release-ready closure.