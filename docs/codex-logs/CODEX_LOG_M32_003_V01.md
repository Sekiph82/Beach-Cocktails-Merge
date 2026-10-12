# BCM-M32-003 — Free Economy, Shop, and Booster V01

Status: `FREE_ECONOMY_BASELINE_IMPLEMENTED; BUILDER_EVIDENCE_ONLY`.

## Authority and repository state

- Work item: `BCM-M32-003 — Implement the free Coins/Gems/Shop/Booster baseline`.
- Prompt and criteria: `coordination/sessions/BCM-M32-CAMPAIGN-FOUNDATION-V01/`.
- Start HEAD: `15f0ec2491e5ccb5940fe9b07c2daeffc2520f30` on `main`.
- Product commit: `4c5743f454acc095298f8cb9fe1770ec380da77f` (`Implement free campaign economy and Shop`).
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Root `TASKS.md` was not modified. Owner-local edits/evidence were left unstaged and preserved.

## Changes

- Implemented persisted Coins, Gems, booster inventory, and transaction receipts with idempotent grant, purchase, and consume operations plus insufficient-funds protection.
- Added save validation/migration for Gems and transaction ledger while retaining old Coins and earned booster inventory.
- Connected the first-clear Tiki reward to the economy and added a data-driven provisional free Focus booster offer: 40 Coins or 1 Gem for one Focus.
- Wired the Home Gems balance and Shop entry to live economy state; purchases update and persist balances and inventory.
- Wired Focus consumption into gameplay as a To-Go progress highlight only; it does not alter accepted physics or timer rules.
- No ads, IAP, payment SDK, subscriptions, or real-money pricing were added. The offer values are provisional builder choices.

## Validation performed

- Godot `4.7.2.stable.official.ed1daf0bf` in the M32 isolated sandbox with a distinct custom `user://` profile.
- `tests/m32_economy_shop_probe.gd`: exit 0, `M32_ECONOMY_SHOP_RESULT=PASS`.
- `tests/m32_focus_booster_probe.gd`: exit 0, `M32_FOCUS_BOOSTER_RESULT=PASS`.
- `tests/m15_vip_boosters_economy_probe.gd`: passed in the closure set; existing VIP/economy behavior remained covered.
- Save validation covered legacy schema-two state without Gems/transaction receipts and verified existing balances/inventory were retained.
- PID-controlled runner recorded zero matching sandbox Godot processes after each completed run. No real owner save data was changed.

## Limits and handoff

- Shop costs and the Focus effect are provisional, free-game baseline values; they do not represent owner-approved monetization design.
- Physical device UI acceptance, long-term economy balance, and owner review remain pending.
- Tracker transition and milestone acceptance remain with the independent ChatGPT audit.
