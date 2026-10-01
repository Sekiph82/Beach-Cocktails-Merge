# BCM-M21 Owner Runtime Audit V01

Verdict: **OWNER_RUNTIME_FAIL / RELEASE BLOCKED**

Date: 2026-10-01

The owner manually launched the production project from Godot and supplied runtime screenshots.

## Observed release blockers

1. Gameplay input is broken
- owner cannot launch cocktails onto the table in Level 1 or Level 2 using the mouse;
- gameplay therefore cannot be manually played.

2. Unapproved time limits are active
- Level 1/2 reach TIME UP;
- owner explicitly states the game must have no time limits.

3. Wrong Sunny Cove gameplay visual
- campaign runtime displays the old fixed oversized table/background instead of the accepted Sunny Cove island theme/table family.

4. World Map destination alignment is wrong
- the baked 10-island World Map exists;
- interactive island markers are displaced from the actual islands.

5. Godot manual review window is too small
- current `project.godot` overrides 720×1280 viewport to 405×720 desktop window, making owner manual QA unnecessarily difficult.

## Source-level root causes already identified

### Input
`ShotController` waits for real mouse/touch in `_unhandled_input()`.

Production gameplay is nested below full-screen Control roots:
- `ApplicationShell`;
- `CampaignNavigationController`.

These roots currently rely on default Control mouse filtering while menu-specific layers own STOP behavior. Real pointer dispatch must be repaired so gameplay unhandled input receives unused events.

Previous automated gameplay probes often invoked session/gameplay methods directly and therefore did not prove real pointer playability.

### Timer
Sunny Cove production data contains positive `time_limit_sec` values and `feature_flags.timed=true`.

`GameplaySessionBridge.start_session()` copies `time_limit_sec`; `mark_gameplay_ready()` starts it; `tick()` decrements it and resolves timeout.

### Wrong table/theme
`GameplaySessionBridge` correctly exposes `island_theme`.

`GameManager` still builds its visible board from fixed:
`res://assets/environment/game_board_background.png`

and therefore does not consume the Sunny Cove campaign theme layers.

### World Map
`world_map_controller.gd` places IslandEntry controls from `islands.json.map_position` and each IslandEntry renders another `map_asset` island image.

The current visual background already contains the ten islands, so stale marker positions and duplicate island art create visibly displaced interaction targets.

### Window
`project.godot`:
- canonical viewport = 720×1280;
- debug override = 405×720.

## Audit consequence

All prior release-ready/technical closure statements are superseded for owner-runtime acceptance.

M21 is reopened. No release-ready claim is permitted until the owner can actually play the game and visually accepts the corrected runtime.
