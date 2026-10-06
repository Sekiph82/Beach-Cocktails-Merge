# BCM-M21-001-R05 — Fix Final Home Coin-Bar Fit

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Branch:
`main`

## Mission

Fix ONLY the final Home issue identified by the owner:

- shrink Energy bar horizontally by 25%;
- widen Coin bar horizontally by 25%;
- keep both bar heights unchanged;
- keep their current left x positions unchanged;
- move the Energy/Coin plus images so they remain seated on the new bar ends exactly as they are now;
- make the coin value fit cleanly inside the widened Coin bar.

Do not change anything else.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-HOME-BAR-FIT-R05/OWNER_HOME_BAR_FIT_RULING_R05.md`
4. `coordination/sessions/BCM-M21-HOME-BAR-FIT-R05/CHATGPT_HOME_BAR_FIT_CRITERIA_R05.md`
5. current `HOME_TARGET_LAYOUT_R04.json`
6. current Home focused probe.

Root `TASKS.md` is read-only.

## Exact new reference geometry

Use 941×1672 reference coordinates.

### Energy bar

Current:
`x=229.0, y=15.0, w=181.5, h=81.0`

New:
`x=229.0, y=15.0, w=136.125, h=81.0`

This is exactly 25% narrower.

New right edge:
`365.125`

Current Energy plus is seated with its center 17.5 px left of the bar right edge.

Preserve that exact seating.

New Energy plus center:
`x=347.625`

Keep:
- existing plus width/height;
- existing vertical center alignment to the Energy bar.

### Coin bar

Current:
`x=444.0, y=14.0, w=162.75, h=81.0`

New:
`x=444.0, y=14.0, w=203.4375, h=81.0`

This is exactly 25% wider.

New right edge:
`647.4375`

Current Coin plus is seated with its center 17.75 px left of the Coin bar right edge.

Preserve that exact seating.

New Coin plus center:
`x=629.6875`

Keep:
- existing plus width/height;
- existing vertical center alignment to the Coin bar.

### Diamond

DO NOT move or resize Diamond bar or Diamond plus.

## Coin number

Use the extra Coin bar width for the number.

The value must:
- fit fully inside the bar;
- not overlap the Coin plus;
- not overlap the baked coin icon on the left;
- remain centered in the usable text region.

Fixture `4.250` must fit cleanly.

Do not reduce the font simply as the first solution. The owner specifically asked for a wider Coin bar.

## Freeze everything else

Do not move, resize, or restyle:
- Level;
- Diamond;
- Settings;
- PLAY;
- Continue text;
- World Map;
- Shop;
- Events;
- Daily Rewards;
- Achievements;
- background;
- any other Home art.

Do not change PLAY/WORLD MAP/SETTINGS behavior.

Do not touch Island Map, World Map, gameplay, To-Go, M07, M08, or project.godot.

## Evidence

Render the real Home after the correction at:
- 941×1672;
- 720×1280;
- 800×1422.

Also create a tight coin-bar crop so the number fit and plus seating are easy for the owner to inspect.

Save under:

`coordination/sessions/BCM-M21-HOME-BAR-FIT-R05/evidence/`

Create:
`HOME_BAR_FIT_R05.json`

## Tests

Add/update focused assertions for:
- exact Energy width;
- exact Coin width;
- exact new plus centers;
- unchanged heights;
- exact plus-to-right-edge offsets;
- coin text fully contained;
- all other Home layout values unchanged;
- PLAY/WORLD MAP/SETTINGS still function.

Run the locked R05 criteria.

## Publish and stop

Create:
`docs/codex-logs/CODEX_LOG_M21_HOME_BAR_FIT_R05.md`

Do not edit root `TASKS.md`.

Push to main.

Return the GitHub path/link to:
`01_home_bar_fit_941x1672.png`

Finish exactly:

`AWAITING_OWNER_HOME_BAR_FIT_APPROVAL_R05`

STOP.
