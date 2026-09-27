# BCM-M14 Gameplay Session Bridge — Execution Prompt V01

Implement M14 against:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CHATGPT_AUDIT_CRITERIA_V01.md`

Read first:
- `AGENTS.md`
- `TASKS.md`
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- accepted M10/M11/M12/M13 audit artifacts
- `scripts/campaign/gameplay_session_bridge.gd`
- `scripts/campaign/campaign_navigation_controller.gd`
- `scripts/campaign/campaign_manager.gd`
- `scripts/campaign/level_database.gd`
- `scripts/game_manager.gd`
- `scenes/main.tscn`

## Goal

Turn the existing GameplaySessionBridge stub into the real bounded campaign-to-gameplay session layer.

Wire the accepted M13 level-selection boundary into the existing gameplay implementation without retuning accepted gameplay.

## Required implementation

Implement:
- exact island/level launch from M13 selection;
- immutable level snapshot;
- normal To-Go objective configuration;
- optional VIP state;
- one authoritative countdown timer;
- pause/resume/background-pause behavior;
- deterministic WIN/LOSE resolution;
- CampaignManager progression submission on WIN only;
- Retry;
- Next Level;
- Island Map return;
- duplicate-terminal and duplicate-session protection.

## Critical gameplay preservation

Do not modify physics merely to support campaign mode.

Preserve:
- R11 table footprint;
- launch behavior;
- merge behavior;
- collider radii;
- score/combo behavior;
- accepted HUD positioning;
- existing rule that qualifying stored L6-L12 drinks may satisfy later matching To-Go orders.

Add only bounded hooks where the existing GameManager needs campaign session input/output.

## VIP boundary

VIP is optional in M14.

VIP completion may be tracked and returned in session results, but:
- VIP failure never blocks normal win;
- do not grant M15 booster/economy rewards yet;
- do not implement +Time booster/ad continuation.

## Content boundary

Do not author canonical Sunny Cove L1-L100 data.

Use deterministic fixtures or existing seed campaign data to exercise timer/orders/VIP/result behavior.

## Tests

Create:
`tests/m14_gameplay_session_bridge_probe.gd`

Satisfy every locked V01 criterion.

Run normal Godot 4.7 import/bootstrap, then:
- M14 probe run 1;
- M14 probe run 2 without intervening changes;
- M10;
- M11;
- M12;
- M13;
- relevant R11/core gameplay regression probes.

## Governance

Do not edit root `TASKS.md`.
Do not implement M15.
Do not implement M16.
Do not regenerate accepted visual assets.

## Completion

Write:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CODEX_LOG_V01.md`

Return:
- implementation SHA;
- final main HEAD;
- M14 run 1 PASS/FAIL + exit code;
- M14 run 2 PASS/FAIL + exit code;
- timer lifecycle result;
- normal win/timeout/VIP-optional result;
- Retry/Next/IslandMap result;
- M10/M11/M12/M13 + core regression result;
- builder log GitHub URL;
- `AWAITING_M14_AUDIT_V01`.

Then STOP.
