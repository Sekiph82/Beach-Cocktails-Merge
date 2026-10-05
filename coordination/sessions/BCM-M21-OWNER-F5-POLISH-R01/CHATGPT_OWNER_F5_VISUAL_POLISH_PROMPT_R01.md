# BCM-M21-001-R01 — Owner F5 Island Map Nodes + To-Go 125% Visual Polish

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

GitHub:
`https://github.com/Sekiph82/Beach-Cocktails-Merge`

Branch:
`main`

## Mission

Apply ONLY the two owner-requested final visual changes:

1. replace the Island Map's current flat green/colored level boxes and large teal header with the existing campaign art system;
2. enlarge the combined To-Go/VIP Orders panel and all of its local dynamic content by exactly 25%.

Do not alter the already-approved World Map or gameplay physics.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/OWNER_F5_VISUAL_POLISH_RULING_R01.md`
4. `coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/CHATGPT_OWNER_F5_VISUAL_POLISH_CRITERIA_R01.md`
5. `scripts/campaign/level_button.gd`
6. `scripts/campaign/island_map_controller.gd`
7. `scripts/game_manager.gd`
8. M13/M15/M21 relevant tests.

Root `TASKS.md` is read-only.

## Sync first

Synchronize the canonical Desktop checkout under AGENTS rules.

Do not discard owner-local work.
Do not use destructive reset/clean/rebase/force.

## Part 1 — Replace Island Map level node visuals

Current `LevelButton` uses flat StyleBox colors and text.

Replace the primary node body with the canonical PNG skin family.

Exact mapping:

```
LOCKED
→ assets/ui_assets/campaign/island_map/level_node_locked.png

CURRENT
→ assets/ui_assets/campaign/island_map/level_node_finale.png

COMPLETE + 0 stars
→ assets/ui_assets/campaign/island_map/level_node_completed.png

COMPLETE + 1 star
→ assets/ui_assets/campaign/island_map/level_node_current.png

COMPLETE + 2 stars
→ assets/ui_assets/campaign/island_map/level_node_two_star.png

COMPLETE + 3 stars
→ assets/ui_assets/campaign/island_map/level_node_milestone.png

OPEN
→ assets/ui_assets/campaign/island_map/level_node_unlocked.png
```

The state/stars mapping is owner authority even if historical asset filenames suggest another semantic use.

Use the 320×180 art family with preserved aspect ratio.

The button itself remains the hit/input authority.

Overlay runtime information cleanly on the image:
- level number;
- star result;
- best score where applicable;
- VIP marker;
- separate milestone marker when applicable.

Do not return to the current green rectangles.

### New 2-star art

Create:

`assets/ui_assets/campaign/island_map/level_node_two_star.png`

It must:
- be 320×180 RGBA;
- look like a native member of the existing level-node family;
- be clearly distinguishable from `level_node_current.png` and `level_node_milestone.png`;
- contain no baked level number, best score, or player-specific state;
- be generated locally/deterministically from the canonical family, not downloaded from an unrelated external source.

Update manifest/dimension metadata.

## Part 2 — Replace the large Island Map top header

The owner wants the large teal header shown in the current runtime screenshot removed completely as the visible presentation.

Remove/hide the visible:
- large teal header panel;
- `ISLAND MAP • SELECT A LEVEL TO VIEW ITS CAMPAIGN BOUNDARY`;
- levels/stars/next-milestone summary;
- `IN PROGRESS` / `ISLAND COMPLETE` header telemetry.

Instead use:

`assets/ui_assets/campaign/world_map/island_name_panel.png`

as the centered top plaque.

Write the current island display name centered inside the plaque.

Keep the Back-to-World-Map control available at the upper-left.

Shrink the reserved header height so the island-map artwork/scroll content begins much closer to the top.

Do not leave an empty 166–178 px band.

Do not delete summary/progression data APIs. Remove only the rejected visible header presentation.

## Part 3 — Enlarge To-Go/VIP panel exactly 25%

Current code in `scripts/game_manager.gd` uses:

`to_go_width = 170.0 * ui_scale`

Change the canonical presentation to:

`to_go_width = 212.5 * ui_scale`

Source aspect ratio is 1132×1698 = 1.5.

Therefore:

`to_go_height = 318.75 * ui_scale`

at the same canonical scale.

This must be a true 1.25× visual enlargement of the complete combined panel system.

Scale all panel-local dynamic presentation with it:
- normal cocktail;
- VIP cocktail;
- normal progress;
- VIP progress;
- normal reward digits;
- VIP reward digits;
- panel-local flash/effects.

Do not enlarge only the background PNG.

Keep:
- horizontal centering;
- y = 0;
- aspect ratio;
- normal/VIP semantics;
- persistent non-VIP 0/0;
- equal normal/VIP cocktail scaling policy.

Do not move the table or playable geometry.

Do not change physics.

BEST SCORE / SCORE / NEXT / logo stay where they are unless actual overlap proves a tiny correction is necessary. If changed, log exact before/after coordinates.

## Part 4 — Preserve frozen systems

Do not modify:
- owner-approved V04/V05 World Map composition;
- World Map positions/sizes;
- R04 gameplay surfaces/geometries;
- island order/unlock rules;
- save/progression;
- scoring/reward formulas;
- To-Go/VIP target logic;
- no-timer rule;
- physics/colliders/rails/deadline;
- M22+ plugin work.

## Part 5 — Evidence + tests

Create:
`coordination/sessions/BCM-M21-OWNER-F5-POLISH-R01/evidence/`

Capture all five required screenshots from the locked criteria.

Add a focused test that proves the exact node-state→PNG mapping and To-Go 1.25 scale.

Run the full regression list in the criteria.

Do not weaken old tests simply to accept the new visuals.

## Part 6 — Log / publication

Create:

`docs/codex-logs/CODEX_LOG_M21_OWNER_F5_POLISH_R01.md`

The log must include:
- starting/final SHA;
- files changed;
- new two-star asset dimensions/hash;
- exact level-node skin mapping;
- old/new Island Map header geometry;
- old/new To-Go width/height;
- exact 1.25 ratio proof;
- any surrounding HUD coordinate adjustment;
- regression results;
- evidence paths;
- confirmation TASKS.md unchanged;
- final clean/sync proof.

Commit/push to `main`.

Final required state:
- `git status --short` empty;
- local HEAD = origin/main = remote main;
- ahead/behind 0/0.

Finish exactly:

`AWAITING_GPT_M21_OWNER_F5_POLISH_AUDIT_R01`

STOP. Do not start BCM-M21-006.
