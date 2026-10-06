# BCM-M21-001-R09 — Independent GPT Audit: Sunny Cove Back Input Closure

Date: 2026-10-06

## VERDICT

**TECHNICAL_AUDITED_PASS / OWNER_F5_CONFIRMATION_REQUIRED**

The owner-reported Sunny Cove Island Map Back-button defect is fixed in production and the inherited V05 real-input chain is green.

## Audited range

R09 authority baseline:
`fd9ef854dd7995f78b06b0b6eb23ca18d30a76c1`

Implementation commit:
`d5937e2d497b6e315308514599decff2bb0308f0`

Publication receipt / audited main:
`b213fbd32b2e227311317bcc47e172630c587378`

Codex did not modify root `TASKS.md`.

## Root cause

PASS.

Before the production fix:
- the visible Back button occupied `(18,18)–(80,80)`;
- the long scrollable `LevelNodes` control covered the same pointer coordinates;
- viewport hover resolved to `LevelNodes`, not the Back button;
- real mouse press/release emitted no `return_requested`;
- navigation remained `ISLAND_MAP`.

This is a real production input-layer defect, not merely a stale assertion.

## Production fix

PASS.

The existing Back button is reparented from `IslandMapHeader` to the Island Map root input layer and assigned `z_index = 10`.

The fix preserves:
- the same Back button instance;
- the same position/size;
- the same styling/text;
- the same signal callback;
- Island Map art/layout;
- level coordinates;
- stars/LV labels;
- scroll/page behavior;
- World Map→Home production code.

No duplicate button is created.

## Mouse proof

PASS.

Final V05 run records:
- hover resolves to `BackToWorldMap`;
- exactly one `return_requested` is emitted;
- current view changes to `WORLD_MAP`;
- World Map visible;
- Island Map hidden;
- map instance count remains 2.

## Touch proof

PASS.

Project settings observed by the runtime:
- emulate_touch_from_mouse=false;
- emulate_mouse_from_touch=true.

Actual `InputEventScreenTouch` press/release:
- enters Sunny Cove exactly once;
- increments select/request/enter exactly once;
- Back touch emits one additional return request;
- returns to the same World Map pair.

No direct signal emit is used as the sole proof.

## World Map Back→Home

PASS.

The final V05 chain proves:
- one `WorldMapController.return_requested`;
- one `CampaignNavigationController.main_menu_requested`;
- ApplicationShell becomes `MAIN_MENU`;
- campaign navigation becomes hidden.

No World Map/Home product code was changed.

## Consecutive V05 stability

PASS.

Two consecutive final runs both end:

`M21_WORLD_MAP_PRODUCTION_V05_RESULT=PASS captures=7 mouse=PASS touch=PASS`

## Regression preservation

PASS for the task scope.

Retained evidence reports successful:
- R08 Home frontier;
- R07 page-focus logic;
- R07 node visual;
- M20 ApplicationShell;
- full Sunny Cove background;
- M18 star contract;
- asset validator 373/373;
- Godot editor parse/import;
- headless boot;
- git diff check.

Note: the headless R07 page-focus log still contains dummy-renderer screenshot capture errors even though its logic assertions and exit code pass. This is pre-existing evidence-harness noise rather than an R09 product regression. It should be cleaned during later release/audit closure rather than reopening the Back-button fix.

## Scope integrity

PASS.

The R09 implementation range changes product code only in:
- `scripts/campaign/island_map_controller.gd`

and strengthens:
- `tests/m21_world_map_production_v05_probe.gd`

No accepted Home, World Map composition, gameplay, economy draft, stars, threshold data, or Sunny Cove geometry was modified.

## Repository state note

GitHub main is at:
`b213fbd32b2e227311317bcc47e172630c587378`

Builder reports local HEAD/origin/main/remote main parity.

A preserved owner-local `project.godot` diff and two untracked critique PNGs remain outside this narrow R09 commit scope. They are not introduced by this fix and remain a later repository-cleanliness concern.

## FINAL VERDICT

**TECHNICAL_AUDITED_PASS / OWNER_F5_CONFIRMATION_REQUIRED**

Required owner runtime check:

`Home → World Map → Sunny Cove → top-left Back → World Map`

Test once with mouse and, if practical, once with touch.

If accepted, owner marker:

`OWNER_SUNNY_COVE_BACK_ACCEPTED_R09`
