# BCM-M14 Gameplay Session Bridge — Codex Execution Log V01

- Work item: `BCM-M14-GAMEPLAY-SESSION-BRIDGE`
- Prompt version: `CHATGPT_EXECUTION_PROMPT_V01.md`
- Locked criteria: `CHATGPT_AUDIT_CRITERIA_V01.md`
- Branch target: `main` via fast-forward `HEAD:main` publication
- Remote: `origin` — `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`
- Start HEAD: `1f5dbddcef78593e7870d5c83330ebfa9bb59b1c`
- Implementation SHA: `9aaba7ffed0bc0b9f48252432a0d492985607c38`
- Status: implementation complete; awaiting independent audit

## Sync-first preflight

- Owner checkout `C:\Users\sekip\Desktop\Beach Cocktails - Merge` was inspected first and preserved unchanged.
- Owner checkout was detached, had pre-existing owner changes (two deleted source atlases plus an untracked backup/logo), and was `0 70` relative to fetched `origin/main`; no reset, stash, checkout overwrite, or deletion was used there.
- A fresh managed worktree was created from `origin/main` at `1f5dbddcef78593e7870d5c83330ebfa9bb59b1c`.
- In the implementation worktree: `git fetch origin main` completed and `git rev-list --left-right --count HEAD...origin/main` returned `0 0` before edits.
- `AGENTS.md`, root `TASKS.md`, `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`, accepted M10/M11/M12/M13 audit artifacts, the M14 execution prompt, and locked M14 criteria were read.

## Changed files

- `scripts/campaign/gameplay_session_bridge.gd` — production M14 session authority: exact level selection, mutable runtime over a deeply immutable snapshot, objective ledger, timer state machine, VIP-optional state, immutable terminal results, progression handoff, Retry/Next/Island Map boundaries, and duplicate protection.
- `scripts/campaign/campaign_navigation_controller.gd` — consumes the existing M13 `level_selected(island_id, level_id)` signal, launches exactly one reused `scenes/main.tscn` gameplay instance, and exposes bounded Retry/Next/Island Map routing.
- `scripts/game_manager.gd` — additive campaign hooks only: bridge readiness/ticking, deterministic campaign To-Go target selection, delivery reporting, and terminal stop behavior. Accepted physics, scoring, collider, HUD, and table-edge code was not retuned.
- `tests/m14_gameplay_session_bridge_probe.gd` — deterministic fixture probe covering all locked M14 behaviors and actual M13 navigation-to-gameplay launch.
- `coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CODEX_LOG_V01.md` — this immutable builder evidence log.

## Session architecture

- `LevelDatabase` remains the definition authority; `GameplaySessionBridge.start_session()` rejects malformed, nonexistent, and campaign-locked selections.
- The session configuration contains exact island/level identity, time limit, normal orders, optional VIP, passive rewards, star thresholds, feature flags, and the full deeply read-only level definition.
- Runtime objective counts are detached mutable state. Duplicate delivery IDs are idempotent, quantities are aggregated by cocktail level, and the next required target is deterministic.
- `CampaignNavigationController` owns one World Map, one Island Map, and at most one existing `main.tscn` gameplay instance. M13 remains a signal boundary; M14 consumes it.

## Timer state machine

`IDLE -> READY -> ACTIVE -> PAUSED -> ACTIVE -> TERMINAL`.

- The timer starts only from `mark_gameplay_ready()` after the existing gameplay node is ready.
- `tick(delta)` is the only countdown source; it clamps at zero and resolves timeout exactly once.
- Legitimate gameplay pause and background pause stop ticking; background resume does not accidentally resume an unrelated user pause.
- WIN and LOSE move to `TERMINAL`; terminal results and progression submission are single-commit operations.

## Objective, VIP, result, and progression semantics

- Normal WIN requires every configured normal quantity. A stored qualifying L6-L12 drink is accepted through the same delivery hook; no alternate merge physics is used.
- VIP is optional. It can set `vip_completed`, never gates normal WIN, and grants no M15 reward/economy/booster behavior.
- Results include island/level, outcome, reason, score, remaining time, normal completed/remaining quantities, VIP state, deterministic stars, and navigation availability. WIN calls `CampaignManager.mark_level_completed()` once; LOSE never advances progression.
- Replay uses the original level definition and CampaignManager's monotonic best score/star behavior. Next Level is offered only from a resolved WIN and an unlocked next-level response. Island Map return clears the session and preserves the exact island boundary.

## Verification

Normal Godot 4.7.2 import/bootstrap:

- `godot_console.exe --headless --editor --path . --import` — exit `0`; existing warning about ignored nested `res://original_reference/project.godot` only.

Focused M14:

- `godot_console.exe --headless --path . --script res://tests/m14_gameplay_session_bridge_probe.gd` — run 1 exit `0`; `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`.
- Same command without intervening source changes — run 2 exit `0`; `M14_GAMEPLAY_SESSION_BRIDGE_RESULT=PASS`.
- Timer lifecycle: PASS — ready/start, active decrement, gameplay pause/resume, background pause/resume, timeout clamp, and terminal stop.
- Normal WIN/timeout/VIP-optional: PASS — 2xL6 quantity, L7 completion, stored L6 delivery, timeout LOSE without progression, incomplete VIP with normal WIN.
- Retry/Next/Island Map: PASS — fresh timer/objective reset, monotonic replay result, unlocked next-level resolution, exact island-map return, and no duplicate gameplay instance.

Required regressions:

- M10 `m10_campaign_architecture_probe.gd` — exit `0`, PASS.
- M11 `m11_save_migration_progression_probe.gd` — exit `0`, PASS; expected malformed-save parser diagnostics were emitted by its recovery cases.
- M12 `m12_world_map_probe.gd` — exit `0`, PASS.
- M13 `m13_island_map_probe.gd` — exit `0`, PASS.
- Core M02 `m02_physics_regression.gd` — exit `0`, PASS.
- Core M03 `m03_economy_regression.gd` — exit `0`, PASS.
- M08 `m08_to_go_delivery_probe.gd` — exit `0`, PASS; existing headless screenshot `save_png` null-texture diagnostics remained in that probe's capture helper.
- `git diff --check` — PASS.

R11-era focused probe limitation:

- `r10_runtime_physics_closure_probe.gd`, `r10_v06_edge_footprint_probe.gd`, and `m06_r05_full_tabletop_probe.gd` remain pre-existing Godot 4.7 parser blockers (inferred-type errors; one stale `Drink.visual_body_depth_scale_for_y()` reference). They were not modified or represented as passing. M02 core physics regression passed and no accepted physics constants were changed.

## Manual checks and limitations

- Performed source/diff review of the bridge, navigation host, GameManager hooks, fixtures, and changed-file scope.
- Performed deterministic headless runtime checks only; no owner/native visual acceptance or independent audit was performed.
- No canonical Sunny Cove L1-L100 content, M15 economy/booster/ad behavior, accepted visual assets, physics constants, or HUD layout was authored or regenerated.
- Godot import generated untracked translation resources for existing CSV assets; those generated files were removed and are not part of the implementation.

## Publication and governance

- `TASKS.md` was read and left byte-for-byte unchanged; `git diff --cached --exit-code -- TASKS.md` passed before the implementation commit.
- Implementation commit: `9aaba7ffed0bc0b9f48252432a0d492985607c38` (`feat: implement M14 gameplay session bridge`).
- Publication command: `git push origin HEAD:main` (fast-forward only; no force-push).
- Final synchronization verification after publication must show equal values for `git rev-parse HEAD`, `git rev-parse origin/main`, and `git ls-remote origin refs/heads/main`; the exact final publication SHA is reported in the completion handoff.
- Worktree must be clean except ignored Godot/editor state before handoff.

## Audit boundary

This is builder evidence only. Codex does not update `TASKS.md`, issue the milestone verdict, or perform the independent audit.

`AWAITING_M14_AUDIT_V01`
