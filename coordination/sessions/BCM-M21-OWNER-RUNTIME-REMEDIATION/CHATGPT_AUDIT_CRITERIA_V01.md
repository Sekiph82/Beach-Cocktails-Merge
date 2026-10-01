# BCM-M21 Owner Runtime Remediation — Locked Audit Criteria V01

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `OWNER_RULING_V01.md`
- `OWNER_RUNTIME_AUDIT_V01.md`
- owner runtime screenshots/observations dated 2026-10-01
- accepted R11 physics boundary
- accepted canonical M12/M19 island/theme assets.

## A — governance

- Work only on clean synchronized `main`.
- CODEX must not edit root `TASKS.md`.
- Do not start a new milestone.
- Do not retune merge physics, drink radii, R11 table-contact geometry, scoring, normal To-Go objective quantities/levels, or unrelated economy.
- Historical prompts/audits remain historical evidence; do not rewrite them.
- Current owner runtime ruling supersedes conflicting timer assumptions.

## B — real gameplay input must work

Production F5 path:
ApplicationShell → CampaignNavigation → IslandMap → Gameplay.

Required:
- unused mouse/touch events reach `ShotController._unhandled_input()`;
- interactive menu/map/result/pause controls continue to consume their own events correctly;
- mouse press + horizontal drag + release launches a held cocktail;
- touch press + drag + release launches a held cocktail;
- 10 consecutive launches work in one production session;
- launched drinks enter physics, move upward, collide/merge normally, and a fresh held drink appears after each shot;
- pause/result overlays block shots while visible;
- no auto-fire.

Automated proof must dispatch `InputEventMouseButton/InputEventMouseMotion` and `InputEventScreenTouch/InputEventScreenDrag` through the actual viewport/input boundary. Direct calls to `_launch()`, `_end_drag_and_fire()`, `spawn_drink()`, or equivalent do not satisfy this gate.

## C — remove all gameplay time limits

Production campaign gameplay is untimed.

Required:
- Sunny Cove all 100 rows have `time_limit_sec=0` or absent;
- all Sunny Cove `feature_flags.timed=false` or absent;
- session configuration explicitly reports untimed;
- `GameplaySessionBridge.tick()` never resolves timeout for untimed levels;
- no TIME UP result can occur in canonical campaign play;
- normal completion depends only on satisfying required To-Go orders and existing non-timer loss conditions;
- pause/background still stops gameplay interaction/physics appropriately but no timer copy is shown;
- onboarding/settings/result copy contains no normal timed-objective claim;
- future placeholder islands default untimed.

Tests must include a session advanced by at least 1 simulated hour without normal objective completion and prove it does not timeout.

## D — retire +Time production mechanic

Because owner forbids timers:
- `time` booster is not granted by new production play;
- active Sunny Cove reward definitions must not grant `{"id":"time"}`;
- do not invent a replacement reward;
- former +Time reward slots become unconfigured/no-reward pending a later owner ruling;
- Upgrade rewards already approved remain unchanged;
- legacy saved time inventory remains readable/non-destructive but cannot alter untimed gameplay;
- UI must not advertise +Time as an active reward.

Produce a report listing every removed/deactivated production `time` reward reference.

## E — Sunny Cove campaign theme must actually render

For Sunny Cove campaign gameplay, runtime must consume the resolved session `island_theme`.

Required visible layers use the canonical existing assets:
- `gameplay_background.png`
- `gameplay_table_shadow.png`
- `gameplay_table.png`
- `table_edge_overlay.png`
- `launch_zone.png`

The old fixed `assets/environment/game_board_background.png` may remain only as backward-compatible non-campaign fallback.

Required:
- no duplicated old+new table composition;
- accepted R11 physics/contact geometry unchanged;
- collision/launch/death coordinates unchanged unless an independent proof shows a purely coordinate-space adapter is necessary; any such need stops for audit rather than silently retuning;
- production capture at 720×1280 proving Sunny Cove theme identity;
- source/runtime assertion proving the configured texture paths equal Sunny Cove theme paths.

## F — World Map hotspots align to the baked ten-island map

The production `world_map_background.png` already contains the canonical visual islands.

Required:
- derive/calibrate ten canonical hotspot centers against that actual background;
- do not render a second displaced island thumbnail on top of the baked map;
- `IslandEntry` becomes a state/click target treatment over the actual baked island location;
- OPEN/LOCKED/CURRENT/COMPLETE remain visible;
- route line, selection ring and lock indicator use the same calibrated island centers;
- every hotspot remains inside viewport and non-overlapping enough to select;
- produce a calibration artifact with island id, pixel center, normalized center, and method;
- prefer deterministic template/image matching using the per-island `map_asset` against `world_map_background.png`; if a reliable match cannot be established, stop rather than guess.

Mandatory 720×1280 runtime capture must visibly show all ten hotspots centered on their corresponding baked islands.

## G — larger Godot manual-review window

Keep canonical viewport:
- 720×1280.

Set desktop debug override to:
- 486×864.

Do not scale/re-layout canonical UI coordinates for this developer-window change.

## H — runtime evidence

Generate production-path 720×1280 captures for:
1. corrected World Map;
2. corrected Sunny Cove Island Map entry;
3. Sunny Cove gameplay before first shot;
4. Sunny Cove gameplay after real-dispatch 10-shot smoke;
5. pause overlay with untimed copy;
6. normal gameplay still active after simulated/accelerated time beyond the retired L1 timer;
7. WIN result without timer wording.

Additionally record a machine-readable real-input smoke result:
- mouse shots fired = 10/10;
- touch shots fired = 10/10;
- direct ShotController launch method calls = 0.

## I — regression

Run:
- R11 gameplay physics/table boundary;
- M02 collision/merge/rapid-launch;
- M03 scoring/To-Go/game-over;
- M07-R06 HUD;
- M08 delivery;
- M09 audio/haptics;
- M10-M13 campaign/map/save;
- updated untimed M14;
- M15 VIP optionality excluding retired +Time;
- updated M16 Sunny Cove content;
- M18 stars/replay/rewards excluding retired +Time;
- M19 multi-island/theme;
- M20 menu/settings/pause/result/save;
- `git diff --check`.

Any old regression whose sole expectation is a timer must be updated/superseded by this owner ruling, not treated as a blocker.

## J — handoff

Create:
`CODEX_LOG_OWNER_RUNTIME_REMEDIATION_V01.md`

Successful technical handoff marker:

`AWAITING_OWNER_RUNTIME_REAUDIT_V01`

This is not release acceptance. Final PASS requires the owner to run F5 and manually confirm actual playability and visual correctness.
