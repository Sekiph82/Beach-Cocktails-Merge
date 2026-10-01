# BCM-M21 Owner Runtime Remediation V01 — Restore Playability and Accepted Runtime

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `OWNER_RULING_V01.md`
5. `OWNER_RUNTIME_AUDIT_V01.md`
6. `CHATGPT_AUDIT_CRITERIA_V01.md`

The owner runtime ruling is authoritative.

## Fix all five owner-observed release blockers

### 1. Restore real mouse/touch cocktail launching

Trace the production Control input chain from ApplicationShell and CampaignNavigation to ShotController.

Fix mouse filtering/input routing so:
- menu/map/buttons keep working;
- during gameplay unused pointer events reach ShotController;
- mouse drag/release and touch drag/release launch cocktails;
- pause/result overlays still block gameplay input.

Add a production GUI input probe that sends real InputEvent objects through the viewport. Do not satisfy this with direct launcher method calls.

Prove 10/10 mouse shots and 10/10 touch shots.

### 2. Remove timers from the game

Sunny Cove L1-L100 is untimed.

Remove/deactivate positive campaign `time_limit_sec`, timed feature flags and timeout loss behavior.

Update GameplaySessionBridge so untimed sessions never timeout, including after at least one simulated hour.

Remove timed language from onboarding, pause and relevant result/presentation text.

Do not change normal To-Go objectives.

### 3. Retire +Time

No active production reward may grant or advertise the time booster.

Do not invent replacement rewards.

Preserve Upgrade rewards. Tolerate legacy saved time inventory non-destructively.

### 4. Render the correct Sunny Cove table/theme

GameplaySessionBridge already exposes `island_theme`. Wire that into GameManager presentation.

Sunny Cove campaign must use the canonical five theme assets under:
`assets/ui_assets/campaign/islands/sunny_cove/`

The fixed old game-board background is fallback only.

Do not retune R11 physics/table-contact geometry.

### 5. Fix World Map island selection alignment

The background already contains the ten islands.

Calibrate the ten interaction centers to the actual baked island centers. Prefer deterministic image/template matching using each canonical `map_asset` and the World Map background.

Do not draw a second displaced island image. Use state ring/lock/click treatment over the baked island itself.

Publish a 720×1280 runtime capture with all ten centers visibly aligned.

### 6. Enlarge Godot debug view

Keep viewport 720×1280.
Set desktop window override to 486×864.

## Evidence

Generate every runtime artifact required by the locked criteria, especially:
- corrected World Map;
- corrected Sunny Cove themed table;
- real 10-shot mouse/touch proof;
- no-timeout proof;
- WIN with no timer language.

## Stop rule

If restoring the Sunny Cove visual theme appears to require changing accepted R11 collision/rail geometry, STOP and document the mismatch. Do not silently move physics to match artwork.

Do not edit root `TASKS.md`.

On technical success create/populate:
`CODEX_LOG_OWNER_RUNTIME_REMEDIATION_V01.md`

Finish exactly:

`AWAITING_OWNER_RUNTIME_REAUDIT_V01`

Then stop. Owner manual F5 acceptance is mandatory.
