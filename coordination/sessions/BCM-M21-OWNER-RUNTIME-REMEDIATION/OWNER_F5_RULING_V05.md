# BCM-M21 Owner F5 Ruling V05 — Main Menu Buttons Blocked by Result Canvas

Date: 2026-10-02
Status: **OWNER-AUTHORITATIVE**

Owner manual F5 observation after V04-R01 technical PASS:

- the game launches;
- Main Menu is visible;
- PLAY / CONTINUE does not respond;
- SETTINGS does not respond;
- therefore the owner cannot enter the World Map.

This is a release blocker.

## Root cause confirmed from current source

`CampaignNavigationController._create_result_feedback()` creates:
- `CampaignResultCanvasLayer` at CanvasLayer layer 2;
- a full-screen `CampaignResultCanvasRoot` Control;
- root `mouse_filter = MOUSE_FILTER_PASS`.

`ApplicationShell.show_main_menu()` hides the CampaignNavigation Control with:
`campaign_navigation.visible = false`.

A CanvasLayer does not inherit the parent Control's visible state. Therefore the result CanvasLayer remains independently active above the Main Menu.

Its full-screen Control intercepts GUI pointer dispatch even while the result feedback itself is hidden.

The current architecture therefore allows an invisible result surface to block Main Menu buttons.

## Owner rule

A hidden result surface must consume **zero** pointer input.

The result CanvasLayer must be:
- hidden/inactive when no WIN/LOSE card is visible;
- hidden whenever CampaignNavigation itself is hidden;
- activated only for an actual result card;
- hidden again on Next Level, Retry, Island Map, World Map or Main Menu transition.

Main Menu PLAY / CONTINUE, SETTINGS and BACK TO MENU must be proven using real mouse event dispatch, not direct method calls.
