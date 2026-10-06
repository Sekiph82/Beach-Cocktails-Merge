# BCM-M21-001 — Owner Home Acceptance R06

Date: 2026-10-06

Status: **OWNER_HOME_ACCEPTED_R06**

## Accepted production state

The owner explicitly states that the current Home screen is OK and must now be fully integrated as the player welcome screen for normal Godot runtime review.

Accepted GitHub main HEAD at the time of owner decision:

`d265865f67770be34e3c45f83ea07141feb3c5ca`

The accepted Home authority is the current production implementation built from:
- `assets/ui_assets/screens/home/`
- `coordination/sessions/BCM-M21-HOME-EXACT-TARGET-R04/HOME_TARGET_LAYOUT_R04.json`
- current `scripts/campaign/application_shell.gd`

Latest accepted owner corrections include:
- Energy bar narrowed and centered between Level and Coin;
- Coin bar widened so its value fits;
- Energy/Coin/Diamond plus buttons remain seated at the bar ends;
- Level/Energy/Coin/Gem numeric overlays centered in their intended inner bar surfaces;
- Continue label positioned at the owner-approved final height;
- PLAY resumes the real current campaign level;
- WORLD MAP opens the production World Map;
- SETTINGS opens the existing Settings;
- Home is the player welcome screen.

## Freeze rule

No visual redesign is authorized after this acceptance.

Do not:
- move any Home element;
- resize any Home element;
- change bar geometry;
- change text geometry;
- replace any owner Home PNG;
- alter Home colors, labels, button hierarchy, or background;
- reintroduce the old R02 Home;
- add new Home features.

Only technical integration/runtime-readiness changes are authorized by the subsequent R06 prompt.

## Next gate

The owner wants to run the current complete game in Godot and test the latest integrated state.

Required next marker:

`AWAITING_OWNER_FULL_GAME_RUNTIME_REVIEW_R06`
