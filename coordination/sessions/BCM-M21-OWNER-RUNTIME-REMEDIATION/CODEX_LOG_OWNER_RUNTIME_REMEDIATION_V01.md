# CODEX Log — BCM-M21 Owner Runtime Remediation V01

Status: `READY_FOR_OWNER_RUNTIME_REAUDIT`

## Work item and authority

- Work item: `BCM-M21-OWNER-RUNTIME-REMEDIATION`
- Prompt: `CHATGPT_REMEDIATION_PROMPT_V01.md`
- Criteria: `CHATGPT_AUDIT_CRITERIA_V01.md`
- Ruling/audit: `OWNER_RULING_V01.md`, `OWNER_RUNTIME_AUDIT_V01.md`
- Required handoff marker: `AWAITING_OWNER_RUNTIME_REAUDIT_V01`

## Repository and synchronization

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Start HEAD: `0fcd199e080651a47b44a9acc52f3e4cb217cd54`
- Implementation commit: `7ca70a6fdddf1cb2763b5365fa387baa048ea71e`
- Sync preflight: local `0fcd199` was behind-only by 8 commits after `git fetch origin main`; canonical checkout was fast-forwarded to `0fcd199` before implementation.
- Owner changes preserved at preflight: the owner-modified `project.godot` was retained and bounded to the required 486×864 debug override; 14 pre-existing translation sidecars remained untracked and were not staged.
- `TASKS.md`: read for scope and left byte-for-byte unchanged.

## Root causes addressed

1. Real mouse/touch input was not reaching the production shot path reliably because campaign shell/navigation controls intercepted viewport input. The shell and navigation now pass mouse input; `ShotController` accepts real `_unhandled_input` mouse/touch events; pause blocks the shot controller without replacing the input route.
2. Production gameplay still exposed timed-session behavior. Sunny Cove levels are explicitly `time_limit_sec: 0` with `feature_flags.timed: false`; the bridge always exposes an untimed session, does not drain time, and never resolves `TIMEOUT`.
3. `+Time` is retired. `apply_time_booster()` returns `TIME_BOOSTER_RETIRED` without consuming legacy inventory. Former Sunny Cove `time` VIP rewards and cumulative-star rewards are empty; valid upgrade rewards remain.
4. Production gameplay rendered the legacy background instead of Sunny Cove’s canonical theme layers. The session now applies the configured Sunny Cove background, full table, shadow, edge overlay, and launch-zone assets.
5. World Map entries used displaced thumbnail art. The baked-background pixel centers are calibrated in `M21_WORLD_MAP_HOTSPOT_CALIBRATION_V01.json`; entry placement and route points share those calibrated centers, and duplicate island thumbnails are hidden.
6. The debug window was too small. `project.godot` now uses a 486×864 override over the canonical 720×1280 viewport.

## Changed files

Implementation/data:

- `project.godot`
- `data/campaign/islands.json`
- `data/campaign/levels/sunny_cove.json`
- `scripts/campaign/application_shell.gd`
- `scripts/campaign/campaign_feedback_overlay.gd`
- `scripts/campaign/campaign_manager.gd`
- `scripts/campaign/campaign_navigation_controller.gd`
- `scripts/campaign/gameplay_session_bridge.gd`
- `scripts/campaign/island_entry.gd`
- `scripts/campaign/level_database.gd`
- `scripts/campaign/world_map_controller.gd`
- `scripts/game_manager.gd`
- `scripts/shot_controller.gd`

Regression probes updated for the owner ruling:

- `tests/m14_gameplay_session_bridge_probe.gd`
- `tests/m15_vip_boosters_economy_probe.gd`
- `tests/m16_sunny_cove_content_probe.gd`
- `tests/m20_campaign_ux_probe.gd`
- `tests/m20_onboarding_probe.gd`
- `tests/m20_pause_lifecycle_probe.gd`
- `tests/m21_owner_runtime_remediation_probe.gd`

Immutable owner-runtime evidence:

- `evidence/runtime/01_world_map_720x1280.png` through `07_win_untimed_no_timer_language_720x1280.png`
- `evidence/runtime/M21_OWNER_RUNTIME_INPUT_SMOKE_V01.json`
- `evidence/world_map/M21_WORLD_MAP_HOTSPOT_CALIBRATION_V01.json`
- `evidence/world_map/M21_WORLD_MAP_HOTSPOT_CALIBRATION_V01.md`

The two frozen `BCM-M21-RELEASE-CLOSURE` performance/progression evidence files were not included. They were restored after the long regression probes rewrote them as incidental test output.

## Commands and exact results

- `git status --short --branch`, `git remote -v`, `git fetch origin main`, `git rev-list --left-right --count HEAD...origin/main`: PASS; behind-only sync was reconciled before edits.
- `godot_console.exe --headless --editor --path . --quit`: PASS, Godot 4.7.2; only the expected ignored `original_reference` project warning was emitted.
- `git diff --cached --check`: PASS.
- `godot_console.exe --path . --rendering-method gl_compatibility --script res://tests/m21_owner_runtime_remediation_probe.gd`: PASS.
- Owner runtime probe result: `M21_OWNER_RUNTIME_REMEDIATION_RESULT=PASS mouse=10/10 touch=10/10 direct_launch_calls=0 captures=7`.
- Real input proof: the probe dispatched `InputEventMouseButton`/`InputEventMouseMotion` and `InputEventScreenTouch`/`InputEventScreenDrag` through `Viewport.push_input`; direct `ShotController` launch-method calls were `0`.
- Untimed proof: one simulated hour remained active with timer `0.0`; pause showed no timer copy; WIN showed no timer wording; all 100 Sunny Cove levels validated untimed.
- `godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd`: `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m15_vip_boosters_economy_probe.gd`: `M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m16_sunny_cove_content_probe.gd`: `M16_SUNNY_COVE_CONTENT_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m20_onboarding_probe.gd`: `M20_CHILD_02_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m20_campaign_ux_probe.gd`: `M20_CHILD_05_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m20_pause_lifecycle_probe.gd`: `M20_CHILD_04_RESULT=PASS`.
- `godot_console.exe --headless --path . --script res://tests/m21_full_progression_probe.gd`: `M21_CHILD_03_RESULT=PASS completed=100 checkpoints=5`.
- `godot_console.exe --headless --path . --script res://tests/m21_performance_profile_probe.gd`: `M21_CHILD_02_RESULT=PASS samples=21 frame_samples=60`.

## Manual and visual checks

- Performed: inspected the 720×1280 World Map, Sunny Cove Island Map, themed gameplay, post-input gameplay, one-hour untimed gameplay, pause, and WIN captures.
- Performed: confirmed baked island artwork is the sole island artwork, Sunny Cove table/theme layers are visible, progression remains visible, pause has no timer language, and WIN has no timer language.
- Not performed by Codex: owner-native F5 acceptance, physical mobile-device acceptance, signed/exported artifact acceptance, or independent audit. These remain owner/auditor gates.
- Headless capture note: headless Godot uses a dummy renderer and cannot provide viewport textures; capture proof therefore comes from the non-headless GL Compatibility probe. Headless logic probes remain valid for their stated checks.

## Final repository proof and handoff

- Implementation commit SHA: `7ca70a6fdddf1cb2763b5365fa387baa048ea71e`.
- At implementation push verification: local `HEAD`, `origin/main`, and `git ls-remote origin refs/heads/main` all matched `7ca70a6fdddf1cb2763b5365fa387baa048ea71e`.
- No release/owner acceptance claim is made by this log.
- Stop marker: `AWAITING_OWNER_RUNTIME_REAUDIT_V01`

AWAITING_OWNER_RUNTIME_REAUDIT_V01
