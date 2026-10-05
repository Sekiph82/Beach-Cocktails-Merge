# BCM-M21-001-R01 — Owner F5 Visual Polish Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `OWNER_F5_VISUAL_POLISH_RULING_R01.md`
- owner screenshots dated 2026-10-05
- V05 World Map technical audit PASS

## Gate A — Governance / sync

- obey `AGENTS.md`;
- synchronize canonical Desktop checkout first;
- root `TASKS.md` is read-only to Codex;
- no branch/worktree;
- do not start BCM-M21-006.

## Gate B — Island Map PNG skin mapping

At runtime the reusable LevelButton must use the following visual mapping:

- LOCKED → `level_node_locked.png`
- CURRENT → `level_node_finale.png`
- COMPLETE, 0 stars → `level_node_completed.png`
- COMPLETE, 1 star → `level_node_current.png`
- COMPLETE, 2 stars → `level_node_two_star.png`
- COMPLETE, 3 stars → `level_node_milestone.png`
- OPEN → `level_node_unlocked.png`

PASS requires:
- no flat green/brown/blue StyleBoxFlat rectangle as the primary node body;
- node art is a PNG TextureRect or equivalent presentation child;
- button remains the semantic input target;
- hit target remains mobile-safe;
- runtime text/markers do not steal input;
- level state logic itself is unchanged.

## Gate C — New two-star asset

Create:
`assets/ui_assets/campaign/island_map/level_node_two_star.png`

Requirements:
- 320×180;
- RGBA/transparent family;
- style-consistent with existing node set;
- visually distinct from 1-star and 3-star skins;
- no baked level number, best score, state telemetry, or player-specific data;
- add to canonical asset manifest/dimensions;
- no accidental semantic duplicate.

The new art may be produced from the existing canonical node family with deterministic local image tooling. Do not use an unrelated external image.

## Gate D — Node information preservation

The node skin change must preserve:
- level number;
- 0–3 earned-star information;
- best score;
- VIP marker;
- selection/focus accessibility;
- milestone status;
- locked rejection;
- OPEN/CURRENT selectable behavior.

Raw state text may be omitted from the visible node if the new skin makes state clear, but automated APIs must still expose exact state.

## Gate E — Milestone separation

The existing campaign milestone definition (10/20/.../100) must remain independent of the 3-star completed skin.

PASS requires milestone tests still pass and milestone indication is retained through a separate marker/overlay or equivalent bounded presentation.

## Gate F — Island Map top header replacement

Remove the current large teal header surface.

Use:
`assets/ui_assets/campaign/world_map/island_name_panel.png`
as a centered top island-name plaque.

PASS requires:
- current island display name is centered inside it;
- old subtitle is not visible;
- old summary block is not visible;
- old completion-status header text is not visible;
- Back-to-World-Map remains available and clickable;
- no large teal rectangle remains behind the plaque;
- scrollable island art begins materially closer to the top;
- no empty legacy 166–178 px header band remains;
- 720×1280 and current 800×1422 debug presentation remain readable.

## Gate G — To-Go/VIP exact +25% scale

Current baseline:
- width = `170.0 * ui_scale`
- height = `255.0 * ui_scale`

Required:
- width = `212.5 * ui_scale`
- height = `318.75 * ui_scale`
- scale ratio exactly 1.25 relative to current production presentation.

PASS requires all panel-local dynamic content scale coherently with the panel:
- normal target;
- VIP target;
- progress values;
- reward digits;
- panel-local completion flash.

Do not merely enlarge the PNG while leaving runtime content at old visual scale.

Panel remains centered and y=0.

## Gate H — Surrounding HUD / gameplay freeze

PASS requires no unintended change to:
- BEST SCORE;
- SCORE;
- NEXT;
- logo;
- progression strip;
- table/deadline/launch positions;
- playable bounds;
- physics.

If surrounding HUD adjustment is unavoidable, it must be minimal and logged with exact old/new values.

## Gate I — Functional preservation

PASS:
- Island Map still renders 100 nodes;
- state APIs still return LOCKED/OPEN/CURRENT/COMPLETE;
- all star counts remain exact;
- level selection works;
- scroll restoration works;
- World Map ↔ Island Map navigation works;
- gameplay launches;
- To-Go/VIP logic/rewards unchanged;
- Pause/Resume and no-timer behavior unchanged.

## Gate J — Runtime evidence

Publish fresh 720×1280 renderer/runtime captures under:
`coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/evidence/`

Required:
1. `01_island_map_top.png` showing new plaque + node skins;
2. `02_island_map_state_matrix.png` showing representative LOCKED, CURRENT, 1-star, 2-star, 3-star, OPEN and 0-star completed states;
3. `03_gameplay_to_go_plus25.png` showing the enlarged panel in normal gameplay;
4. `04_gameplay_to_go_plus25_vip.png` showing VIP-active panel;
5. `05_gameplay_to_go_plus25_nonvip.png` showing persistent non-VIP 0/0 state.

## Gate K — Required regression

Run and PASS:
- new focused Island Map visual-state probe;
- M13;
- M18 Island Map replay;
- M20 app shell/campaign navigation;
- M21 V05 real Sunny Cove input probe;
- M15 focused probe twice;
- M14;
- M08;
- M07 HUD/layout probes;
- M03;
- R04 surface authority;
- asset rebuild/validator;
- Godot import/parse/boot;
- `git diff --check`.

## Gate L — Publication

Create:
`docs/codex-logs/CODEX_LOG_M21_OWNER_F5_POLISH_R01.md`

Push to main.

Final:
- clean working tree;
- local HEAD = origin/main = remote main;
- ahead/behind 0/0;
- root TASKS.md unchanged.

Stop at:

`AWAITING_GPT_M21_OWNER_F5_POLISH_AUDIT_R01`
