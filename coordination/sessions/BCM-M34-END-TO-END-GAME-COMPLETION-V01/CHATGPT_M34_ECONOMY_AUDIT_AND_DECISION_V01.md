# BCM Economy Audit, Decision Sheet V01 (2026-10-13)

## Direct source findings (Github main; sampled representative files)
- `scripts/campaign/application_shell.gd` currently defines `HOME_ENERGY_DISPLAY_DEFAULT := 100` and refreshes the home energy label using this constant. This is an **unimplemented UI placeholder**, not proof of working loss, refill or gating.
- `scripts/campaign/game_economy.gd` holds `coins`, `gems`, `boosters`, a reward ID ledger and a transaction ID ledger. It can grant/spend both currencies and purchase/consume boosters idempotently; it has **no energy authority**. All methods require full integration testing before production acceptance.
- `data/campaign/shop_catalog.json` is explicitly `provisional_free_baseline`, and currently offers only 1 Focus booster for **40 coins or 1 gem**; Focus action is `highlight_current_order`. These are provisional implementation prices, not owner-approved economic balancing.
- `data/campaign/levels/sunny_cove.json` first levels show `rewards: {coins:0}`; representative current generated `data/campaign/levels/azure_bay.json` also shows `rewards:{coins:0}`. The provided evidence does not establish level-clear income adequate to support Focus prices.
- `scripts/campaign/campaign_manager.gd` includes milestone claim and duplicate protection. `scripts/campaign/gameplay_session_bridge.gd` dispatches configured level and optional VIP economy rewards at successful terminal resolution.
- 2026-09-27 accepted owner contract in `coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/OWNER_RULING_V03.md`: VIP cocktail delivery score reward 2× the same-level ordinary To-Go delivery reward, and VIP is optional. **This is score payout, not evidence of coin/gem grant; do not reinterpret it as premium currency.**
- Canonical `TASKS.md` lists M15 economy foundations and M32 free Shop/Coins/Gems/Boosters as done and M33-004 real fairness testing open. No current evidence in these reviewed sources of fully working daily reward, energy regeneration, ad provider, purchase verification, weekly quests or comprehensive earn/spend balancing. Repository-wide CODE and screen audits remain Codex deliverables; these initial findings are not a claim of exhaustive repo scan.

## Prior owner decisions to preserve (from previous BCM discussion; confirm in code, do not confuse with ScrubBots)
- **100 max energy**, **20 energy per started attempt**, **retry costs another 20**, **+1 energy every 3 minutes**, **25 gems full energy refill**, **optional rewarded ad grants +20 energy**. This was previously approved in BCM conversation. Do NOT import ScrubBots 15-minute HEART policy.
- **Daily Rewards = 5 slots; first slot free CLAIM, remaining four individually rewarded-ad CLAIM** (prior BCM decision). No free fake ad completion; unavailable if not connected.
- Energy is consumed on actual authorized level START, not selecting preview, app reload, paused transition or viewing map; 20 deducted once per accepted start, repeat press safe; specific loss by outcome is not additional unless owner decides otherwise. Retry 20 again. Show exact time to next +1 and 100 cap; handle clock tampering with monotonic/high-water approach plus safe durable wall-time across restarts.

## PROPOSED only, awaiting new owner approval. Not yet implementation authority
A. Coin earning: 1★ +20, 2★ +30, 3★ +40 coins on FIRST CLEAR only (incremental difference on first improved star rating capped at 40 total per level), 0 replay-farm earnings. All VIP score multipliers unaffected. 100-level island completion +200 coins, claim-once. Main issue: players must have enough earnings for Focus 40 coin baseline.
B. Gems: 1 gem on first 3★ each fifth distinct global level (5/10/...); first island completion +10 gems. No gems on replay, no automatic gems for every win. Actual gem sources, frequency and anti-farming should be approved only after quantitative 1,000-level simulation.
C. Focus: current 40 coins or 1 gem per 1 Focus, exact same effect. Use coin spend as regular route. Booster should not automatically solve objectives or alter star algorithm.
D. Energy refill +20: optional reward ad once finished/verified, bounded to max100; full refill 25 gems; no real purchases until store proof.
E. Daily Rewards five slot payload proposal: [40 coins free, +20 energy ad, 1 Focus ad, 2 gems ad, 80 coins ad]; one claim per 24-hour UTC day (or user-approved local reset boundary, undecided), fail closed when no ads. Reaching max energy must not consume the reward unless explicitly accepted.
F. Starting balances proposal: 100 energy, 100 coins, 5 gems, 2 Focus; bounded and migration-safe on new profiles only.
G. Removal of ads, real-money gem packs, boosters, cash prices and exchange rates REMAIN OWNER_REQUIRED; never invent SKUs, hardcode fake Ads completion, or allow currency sales before verification.

These proposed numbers are intentionally a discussion draft, **not** user-authorized. Measure multi-island earning rates and playtime/star difficulty before finalizing; adjust based on first-100 economy and 1,000-level distribution.

## Known gaps / pending risks from evidence
P0 Energy is a constant HUD display without consumption/regeneration authority, so current intended lives system not built. P0 User-approved daily 5-claim/rewarded behavior lacks demonstrated live integration. P0 Current level earnings sample 0 coins and provisional Focus pricing create earning/spending mismatch. P0 Actual AdMob rewarded ad callback and authenticated IAP unresolved in previous master; must be verified. P1 No evidence of coherent earn/spend sinks beyond Focus; VIP score payout not coin income. P1 M33-004 complete level solvability/duration still unproven. P1 offline clock/transaction/ads receipt idempotency, save migration and restore across reinstall not fully demonstrated. P1 unreferenced assets/local import cleanup pending M34-005. P1 real Android/iOS touch/performance/store readiness unverified.

## Approval gate
A numeric ECONOMY OWNER RULING is needed for A/B/C/E/F before shipping changes; prior energy + Daily Rewards slot count/first-free policy are accepted. Codex should AUDIT and report only for unsettled numbers, and implement the locked energy policy in isolated way after proving save compatibility and existing gameplay contract, without changing product economics elsewhere without permission.
