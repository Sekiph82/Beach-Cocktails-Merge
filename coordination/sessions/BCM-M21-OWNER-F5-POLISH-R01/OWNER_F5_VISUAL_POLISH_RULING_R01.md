# BCM-M21-001-R01 — Owner F5 Visual Polish Ruling

Date: 2026-10-05

Status: **OWNER_F5_VISUAL_CHANGES_REQUIRED**

The owner reports that the current F5 flow is functionally PASS, but requests two final visual changes before final M21 acceptance.

## 1. Island Map node/header redesign

The current green/flat text-box level nodes are rejected as the final visual treatment.

Use the existing Island Map art family:

- LOCKED level:
  `assets/ui_assets/campaign/island_map/level_node_locked.png`

- CURRENT level being played / current campaign level:
  `assets/ui_assets/campaign/island_map/level_node_finale.png`

- COMPLETE with 1 earned star:
  `assets/ui_assets/campaign/island_map/level_node_current.png`

- COMPLETE with 2 earned stars:
  create a new production asset:
  `assets/ui_assets/campaign/island_map/level_node_two_star.png`

- COMPLETE with 3 earned stars:
  `assets/ui_assets/campaign/island_map/level_node_milestone.png`

- COMPLETE with 0 earned stars:
  `assets/ui_assets/campaign/island_map/level_node_completed.png`

- OPEN/unlocked but not current:
  `assets/ui_assets/campaign/island_map/level_node_unlocked.png`

The new 2-star asset must belong to the same 320×180 RGBA visual family, be clearly distinct from the 1-star and 3-star states, and contain no baked level number, score, or runtime-specific text.

The existing milestone semantics (levels 10/20/.../100) remain separate from earned-star skin selection. If milestone indication is needed, keep it as a separate marker/overlay such as the existing milestone marker asset. Do not overload the 3-star node skin as campaign milestone logic.

Preserve:
- level number;
- earned stars;
- best score;
- VIP marker;
- level selection;
- lock behavior;
- milestone semantics;
- 100-level path/layout;
- scroll/focus/restoration behavior.

Replace the current StyleBoxFlat green/blue/brown node rectangles with the PNG skin system.

### Island Map top area

Remove the existing large teal/green header surface and its visible subtitle/summary text block.

Use:
`assets/ui_assets/campaign/world_map/island_name_panel.png`

as the new centered island-name plaque.

Write only the current island display name inside that plaque.

Preserve the Back-to-World-Map control as a separate usable control.

The page background must begin visually much closer to the top once the old large header is removed. Do not leave an empty 166–178 px dead band.

The old visible strings:
- `ISLAND MAP • SELECT A LEVEL TO VIEW ITS CAMPAIGN BOUNDARY`
- levels/stars/next-milestone summary block
- `IN PROGRESS` / `ISLAND COMPLETE` header text

must no longer occupy the top header.

Underlying progression data/APIs may remain for logic/tests.

## 2. To-Go + VIP Orders panel +25%

The current production panel uses:
`assets/ui/panel_to_go_vip_orders.png`

Current canonical runtime width at 720×1280:
`170.0 * ui_scale`

Owner requires the entire combined To-Go/VIP panel presentation to be **25% larger**.

New canonical width:
`212.5 * ui_scale`

Because the source asset is 1132×1698 (1.5 aspect ratio), new canonical height:
`318.75 * ui_scale`

The complete panel composition must scale uniformly by 1.25:
- panel artwork;
- normal target cocktail;
- VIP target cocktail;
- normal progress;
- VIP progress;
- reward digits;
- any panel-local feedback/flash.

Keep:
- horizontal centering;
- top edge at y=0;
- asset aspect ratio;
- existing To-Go/VIP gameplay/economy semantics;
- existing HUD/table/gameplay geometry.

BEST SCORE, SCORE, NEXT and logo should remain at their accepted coordinates unless the 25% scale causes a real collision. If a bounded correction is required, document exact before/after coordinates and keep it minimal.

## 3. Frozen systems

Do not redesign or modify:
- owner-approved World Map V04/V05 production composition;
- World Map island positions/sizes;
- R04 gameplay surface/profile;
- table/playable geometry;
- launch/death/deadline lines;
- physics/colliders/merge behavior;
- scoring formulas;
- campaign save/progression;
- To-Go/VIP reward semantics;
- no-timer ruling;
- M22+ plugin presentation roadmap.

## Owner state

The previous F5 checklist behavior is functionally PASS, but final owner acceptance is withheld pending these two visual polish items.

Required post-remediation gate:
`AWAITING_GPT_M21_OWNER_F5_POLISH_AUDIT_R01`
