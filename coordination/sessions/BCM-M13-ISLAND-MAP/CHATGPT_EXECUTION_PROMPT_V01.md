# BCM-M13 Island Map — Execution Prompt V01

Implement M13 against:
`coordination/sessions/BCM-M13-ISLAND-MAP/CHATGPT_AUDIT_CRITERIA_V01.md`

Read first:
- `AGENTS.md`
- `TASKS.md`
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- accepted M10/M11/M12 audit artifacts
- current LevelDatabase, CampaignManager, SaveManager and WorldMapController

## Goal

Build the reusable, data-driven Island Map and 100-level path engine.

Implement:
- generic `IslandMapScene.tscn`;
- reusable `LevelButton.tscn`;
- data-driven controller using `island_id`;
- vertical/mobile-safe deterministic path capable of 100 nodes;
- level LOCKED / OPEN / CURRENT / COMPLETE presentation;
- 0-3 stars;
- milestone markers at levels 10/20/30/40/50/60/70/80/90/100;
- highest-unlocked-unfinished auto-focus;
- island summary;
- back-to-World-Map boundary;
- selectable-level signal boundary;
- safe selected-level / scroll-focus restoration.

## Hard milestone boundaries

Do NOT:
- implement gameplay launch/session bridge;
- implement timer gameplay;
- implement VIP runtime;
- implement booster/economy behavior;
- author canonical Sunny Cove Level 1-100 gameplay content;
- create 100 bespoke level scenes;
- duplicate IslandMap per island;
- retune physics, R11 rails, merge, launch, colliders or accepted HUD;
- edit root `TASKS.md`.

M16 owns production Sunny Cove L1-100 content.

Use a deterministic in-memory/test fixture where needed to prove 100-level scalability.

## M12 integration

Honor the existing M12 boundary:
`island_map_requested(island_id)`

Add only the smallest navigation integration required so the selected island id can configure the generic Island Map.

Island Map must emit a level selection boundary only. It must not launch gameplay.

## Tests

Create:
`tests/m13_island_map_probe.gd`

The probe must satisfy every locked criterion, including a 100-level fixture.

Use normal Godot 4.7 headless editor/import bootstrap, then run M13 twice with no intervening file changes.

Also rerun M10, M11 and M12 focused probes.

## Completion

Write and commit:
`coordination/sessions/BCM-M13-ISLAND-MAP/CODEX_LOG_V01.md`

Return:
- implementation SHA;
- final main HEAD;
- M13 run 1 PASS/FAIL + exit code;
- M13 run 2 PASS/FAIL + exit code;
- 100-node scalability result;
- M10/M11/M12 regression result;
- builder log GitHub URL;
- `AWAITING_M13_AUDIT_V01`.

Then STOP.
