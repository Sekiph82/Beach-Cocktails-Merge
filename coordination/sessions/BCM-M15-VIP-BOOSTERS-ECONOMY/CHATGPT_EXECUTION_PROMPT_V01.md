# BCM-M15 VIP, Boosters, Rewards & Economy — Execution Prompt V01

Implement M15 against:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CHATGPT_AUDIT_CRITERIA_V01.md`

Read first:
- `AGENTS.md`
- `TASKS.md`
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- accepted M10-M14 audits
- `scripts/campaign/game_economy.gd`
- `scripts/campaign/save_manager.gd`
- `scripts/campaign/campaign_manager.gd`
- `scripts/campaign/gameplay_session_bridge.gd`
- `scripts/campaign/campaign_navigation_controller.gd`
- `scripts/game_manager.gd`

## Goal

Build the bounded M15 economy layer without turning Beach Cocktails Merge into a shop/meta rewrite.

Implement:
- one persistent GameEconomy authority;
- booster inventory;
- reward ledger/idempotency;
- optional VIP reward dispatch;
- compact VIP gameplay badge/state;
- +Time booster contract;
- milestone reward dispatch;
- coin reward hooks;
- save/reload persistence.

## 1. Economy persistence

Use M11 SaveManager as the persistence boundary.

Persist:
- coins;
- boosters;
- deterministic granted reward IDs/ledger needed to stop duplicate grants.

Preserve existing campaign progression, stars, best score and claimed milestones.

Older valid saves with no M15 reward-ledger field must load safely with an empty ledger.

The production campaign shell must initialize its runtime state from SaveManager; do not reset economy state every app boot.

## 2. Reward normalization

Support the documented VIP reward shape, e.g.:

`{"type":"booster","id":"upgrade","quantity":1}`

and bounded coin reward data.

Use deterministic IDs such as equivalent stable keys for:
- VIP reward per island/level;
- milestone reward per island/milestone.

Do not use random IDs.

Replay/reload must not duplicate grants.

## 3. VIP UI

Add a compact VIP badge/state to the existing To-Go Orders area.

Show only when VIP is enabled.

Show:
- VIP;
- target level/quantity;
- pending/completed state.

Do not add customer characters.
Do not create a new animated scene.
Do not move/retune the accepted gameplay table or HUD geometry.

Capture deterministic runtime screenshot evidence for:
- VIP pending;
- VIP complete;
- non-VIP level.

## 4. VIP reward behavior

VIP remains optional.

Grant its configured reward only on normal WIN + VIP completed.

Do not grant on:
- timeout/LOSE;
- VIP-incomplete WIN.

Grant only once across replay and save/reload.

Reward grant failure must not change WIN into LOSE.

## 5. Booster inventory and +Time

Implement safe booster grant/consume APIs.

For +Time:
- consume one configured +Time booster only on successful application;
- add an explicit positive extension to current remaining session time;
- do not alter LevelDatabase or the base level `time_limit_sec`;
- no inventory => no time;
- nonpositive extension => no consumption;
- terminal/idle => no consumption.

Do not invent a permanent economy balance amount. Use deterministic fixture/config/API values.

No ads or purchases.

## 6. Milestone rewards

Integrate one-time milestone claims with GameEconomy.

Requirements:
- milestone must be reached;
- claim marker and reward are idempotent;
- duplicate call/reload cannot duplicate reward;
- ineligible claim grants nothing;
- campaign progression does not depend on claiming.

Use deterministic reward IDs.

## 7. Tests

Create:
`tests/m15_vip_boosters_economy_probe.gd`

Satisfy every locked criterion, including real save/reload and real campaign runtime reuse of the same economy authority.

Run normal Godot 4.7 bootstrap, then:
- M15 run 1;
- M15 run 2 with no intervening changes;
- M10;
- M11;
- M12;
- M13;
- M14;
- M02;
- M03;
- M08.

## Hard boundaries

Do not:
- edit root `TASKS.md`;
- author M16 Sunny Cove L1-L100;
- implement purchases, ads or backend economy;
- retune R11 physics/table/colliders;
- redesign accepted HUD geometry;
- regenerate accepted visual assets.

## Completion

Write:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V01.md`

Return:
- implementation SHA;
- final main HEAD;
- economy persistence PASS/FAIL;
- VIP reward idempotency PASS/FAIL;
- +Time PASS/FAIL;
- milestone reward PASS/FAIL;
- M15 run1/run2;
- M10-M14/M02/M03/M08 regressions;
- screenshot evidence paths;
- log GitHub URL;
- `AWAITING_M15_AUDIT_V01`.

Then STOP.
