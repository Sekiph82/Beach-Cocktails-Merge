# BCM-M21-001-R02 — Owner F5 Visual Polish Ruling

Date: 2026-10-05

Status: **OWNER_F5_VISUAL_CHANGES_REQUIRED**

The owner reports that the current F5 flow is functionally PASS, but requests three final visual changes before final M21 acceptance.

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


## 3. Home / Main Menu redesign

The current flat dark-teal/green Main Menu shown by F5 is rejected as the final Home screen.

The new Home must follow the owner's supplied visual reference in hierarchy and mood: a premium, colorful, tropical beach/sunset game-home composition rather than a plain utility screen.

### Existing canonical Home assets to use

Use the repository's existing Main Menu asset family as production source material:

- `assets/ui_assets/screens/main_menu/main_menu_background.png` — 720×1280 production background
- `assets/ui_assets/v04_masters/main_menu_master.png` — visual/reference master only
- `assets/ui_assets/brand/logo_beach_cocktails_merge.png` — canonical game logo
- `assets/ui_assets/screens/main_menu/main_menu_play_button.png`
- `assets/ui_assets/screens/main_menu/main_menu_world_map_button.png`
- `assets/ui_assets/screens/main_menu/main_menu_shop_button.png`
- `assets/ui_assets/screens/main_menu/main_menu_daily_button.png`
- `assets/ui_assets/screens/main_menu/main_menu_settings_button.png`
- `assets/ui_assets/screens/main_menu/profile_frame.png`
- `assets/ui_assets/screens/main_menu/coin_counter_panel.png`
- `assets/ui_assets/screens/main_menu/gem_counter_panel.png`
- `assets/ui_assets/screens/main_menu/main_menu_decor_left.png`
- `assets/ui_assets/screens/main_menu/main_menu_decor_right.png`

Do not invent an unrelated new art direction when these assets already exist for this screen.

### Required Home hierarchy

At 720×1280:
- full-screen tropical Main Menu background, no flat ColorRect as the visible page background;
- large Beach Cocktails Merge logo in the upper hero area;
- PLAY / CONTINUE as the largest primary action;
- dynamic sublabel `CONTINUE LEVEL N` when a valid current level exists, never hardcoded to 12;
- separate large WORLD MAP button below the primary action;
- bottom utility actions using existing canonical button art: SHOP, DAILY REWARDS, SETTINGS;
- optional profile / coin / gem presentation only where the project has real authoritative values; never fabricate energy, currency, inventory, achievement, or player data simply because the reference mockup contains them;
- decorative tropical elements should remain subordinate to navigation.

### Functional navigation contract

The reference hierarchy implies PLAY/CONTINUE and WORLD MAP are different actions.

- WORLD MAP must open the production World Map directly.
- PLAY/CONTINUE must continue the current campaign progress, not merely duplicate the World Map button.
- Preferred behavior: launch the currently selected/unlocked campaign level directly when a valid current selection exists.
- If no valid current level is available, degrade safely to the current island map or World Map rather than fabricating a level.
- Preserve save/progression authority and do not create a second campaign state.

### Unsupported feature policy

The owner reference contains Inventory and Achievements buttons, but the current repository does not have canonical production screens/controllers for those features.

Do NOT add fake/non-functional Inventory or Achievements screens in this remediation.

The reference image is authority for visual hierarchy, richness and composition, not permission to invent missing product systems.

### Rejected current presentation

The visible current Main Menu implementation based on:
- `ColorRect("#08283c")`;
- top accent wash;
- plain text `BEACH COCKTAILS`;
- plain text `MERGE • MASTER • DISCOVER`;
- generic teal `MenuCard`;
- flat PLAY / SETTINGS buttons;
- status copy `Progress is kept safe across menu and campaign transitions.`

must not remain as the final Home presentation.

The underlying ApplicationShell ownership, onboarding, settings persistence and campaign navigation architecture remain valid.

## 4. Frozen systems

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

The previous F5 checklist behavior is functionally PASS, but final owner acceptance is withheld pending these three visual polish items.

Required post-remediation gate:
`AWAITING_GPT_M21_OWNER_F5_POLISH_AUDIT_R02`
