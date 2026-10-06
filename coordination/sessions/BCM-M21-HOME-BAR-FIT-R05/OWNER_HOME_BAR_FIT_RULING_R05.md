# BCM-M21-001-R05 — Owner Home Coin-Bar Fit Correction

Date: 2026-10-06

Status: **OWNER_HOME_EXACT_TARGET_CHANGES_REQUIRED_R04**

The owner reports only one remaining Home issue: the coin value does not fit cleanly inside the current coin bar.

The requested correction is intentionally narrow.

## Locked change

Keep all current V03 Home positions and visual decisions except:

1. shrink the current Energy bar width by 25%;
2. extend the current Coin bar width by 25%;
3. keep both bars at their current x/y positions and current heights;
4. move the Energy and Coin `ekle gorseli.png` instances so they remain seated on the resized bar ends exactly the same way they are seated now;
5. keep the Diamond plus unchanged;
6. ensure the coin number is fully inside the widened Coin bar and does not collide with the plus icon.

Current V03 reference-space values:

- Energy bar: x=229.0, y=15.0, w=181.5, h=81.0
- Energy plus center x=393.0
- Coin bar: x=444.0, y=14.0, w=162.75, h=81.0
- Coin plus center x=589.0

Required R05 values:

### Energy
- x = 229.0
- y = 15.0
- width = 136.125
- height = 81.0
- right edge = 365.125

Preserve the current visual plus-to-bar-end relationship:
- current Energy plus center is 17.5 px left of the Energy bar right edge;
- therefore new Energy plus center x = 347.625;
- keep the plus icon size and vertical centering unchanged.

### Coin
- x = 444.0
- y = 14.0
- width = 203.4375
- height = 81.0
- right edge = 647.4375

Preserve the current visual plus-to-bar-end relationship:
- current Coin plus center is 17.75 px left of the Coin bar right edge;
- therefore new Coin plus center x = 629.6875;
- keep the plus icon size and vertical centering unchanged.

### Coin value
The coin text must remain inside the widened bar, fully readable, and must not overlap the relocated Coin plus icon.

Do not solve this by shrinking the font unless a tiny bounded reduction is proven necessary after using the new width.

## Frozen

Do not move or resize:
- Level bar;
- Diamond bar;
- Diamond plus;
- Settings;
- PLAY;
- Continue label;
- World Map;
- bottom Shop / Events / Daily Rewards / Achievements row;
- background;
- any other Home element.

Do not change:
- PLAY behavior;
- WORLD MAP behavior;
- Settings behavior;
- campaign/economy semantics.

Required stop marker:

`AWAITING_OWNER_HOME_BAR_FIT_APPROVAL_R05`
