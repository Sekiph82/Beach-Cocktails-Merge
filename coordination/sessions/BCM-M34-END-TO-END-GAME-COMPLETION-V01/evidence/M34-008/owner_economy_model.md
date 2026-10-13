# M34-008 Owner Economy Model

## Authority and measured content

**Owner-locked V04 values** are the only shipped numerical values in this pass: new wallet 100 Energy / 100 Coins / 5 Gems; Energy cap 100; 20 Energy on each actual attempt including Retry; +1 Energy per 180 seconds; full refill costs 25 Gems; verified opt-in rewarded video grants +20 Energy capped at 100; first star tiers pay 20/30/40 cumulative Coins per global level, replay does not farm, first-ever 3-star on each fifth global level pays 1 Gem, and first island completion pays 200 Coins +10 Gems. VIP is a score multiplier only.

Source basis: `data/campaign/levels/*.json` (canonical `tiki_island_full.json` is the Tiki authority; legacy `tiki_island.json` is retained seed evidence and not counted a second time), `data/campaign/islands.json`, `scripts/campaign/gameplay_session_bridge.gd`, `scripts/campaign/game_economy.gd`, and the active V04 override in `CHATGPT_M34_MASTER_PROMPT_V03_ECONOMY_CLEANUP_ADS_IAP.md`.

Measured across the ten canonical 100-level files:

| Data fact | Count |
|---|---:|
| Canonical levels | 1,000 |
| Explicit global IDs | 900 |
| Legacy Sunny Cove levels missing global IDs | 100 |
| Level rows with `rewards.coins = 0` | 900 |
| Preserved Tiki levels with `rewards.coins = 10` and `rewards.gems = 1` | 100 |
| `vip.enabled = true` | 167 |
| Levels with an explicit `move_limit` | 900 |

No currency income is granted by objective delivery or VIP score multiplier. First-clear level payloads are granted by the production bridge once; star-tier awards are a separate one-time global-level ledger. Island completion is separately idempotent. Thus canonical Tiki payload income remains additive: 1,000 Coins +100 Gems over Tiki L1–L100 when all are cleared; other 900 level payloads carry zero currency. The 100 Sunny Cove rows resolve to global IDs 1–100 by canonical order for star ledger idempotency.

## Scenario model

The table models sequential unique level clears at the three approved star reward tiers. “Win rate” is an explicit scenario assumption for attempt cost only; it is not measured player telemetry or a solvability claim. Medium assumes 40% of every fifth global level eventually earns a first 3-star; low assumes none and high assumes every fifth level gets 3 stars. The model includes existing Tiki level payloads and the once-per-island completion payout at each completed 100-level boundary. It excludes daily rewards because reset and claim policy remain paused, and excludes ads, paid SKUs, and unapproved boosters.

| Scenario | Assumed win rate | Eventual star tier | Attempts per clear (expected) | Energy spent per clear (expected) | 10 clears: Coins / Gems | 100 clears: Coins / Gems | 1,000 clears: Coins / Gems |
|---|---:|---:|---:|---:|---:|---:|---:|
| Low | 40% | 1 star | 2.50 | 50.0 | 200 / 0 | 2,200 / 10 | 23,000 / 200 |
| Medium | 70% | 2 stars | 1.43 | 28.6 | 300 / 0 | 3,200 / 18 | 33,000 / 280 |
| High | 90% | 3 stars | 1.11 | 22.2 | 400 / 0 | 4,200 / 30 | 43,000 / 400 |

Totals are gross earned currency before spending. They include the initial 100 Coins / 5 Gems wallet only when explicitly added; the table excludes it so earned flows remain visible. To get wallet-inclusive totals, add 100 Coins and 5 Gems to each cell. At 1,000 clears, Coin totals are respectively 20,000 / 30,000 / 40,000 star-tier Coins +1,000 Tiki Coins +2,000 island-completion Coins. Gem totals are respectively 0 / 80 / 200 first-3-star milestone Gems +100 Tiki Gems +100 island-completion Gems.

Energy time-equivalent: one 20-Energy attempt represents 60 minutes of natural regeneration. Using the scenario win rates, the long-run regeneration-equivalent is about 150 / 86 / 67 minutes per successful clear for low / medium / high. A full initial bar still allows five attempts before waiting; the expected retries are scenario arithmetic, not observed behavior. No ad, clock manipulation, or refill is assumed.

## Sink and anti-farm audit

- The only enabled in-game currency sink after Focus removal is the approved full Energy refill at 25 Gems. With the 1 Gem / fifth-global-level 3-star rule, 125 such star milestones alone equal one refill; Tiki’s preserved payloads and island-completion Gems add further free supply. The 5-Gem starting balance cannot buy a refill.
- There is no paid-currency SKU, cash price, Coin-to-Gem exchange, or approved real-money price. Monetary price-to-income ratios are therefore **not applicable**. Do not infer a cash value for a Gem.
- Star awards use `level-stars:<global-id>:<tier>` reward IDs and only positive differences to 40 cumulative Coins. The Gem award has a distinct `level-first-three-star:<global-id>` ID. Replays at the same star count return no currency. Island bonus uses one `island-complete:<id>` reward ID.
- Actual attempt IDs are unique per started session and persisted in `transaction_ledger`; failed validation/locked selection does not reach the energy debit. Loss/quit after start does not refund the 20 Energy. Retry passes through `start_session` and consumes another 20.
- A 100-Energy cap, partial 180-second remainder, and rollback-resistant stored timestamp prevent over-cap and backward-clock grants. Forward-clock jumps still grant elapsed regeneration; wall-clock trust across device restore is a known offline-save limitation.
- VIP deliveries continue to award the existing score bonus; they do not call currency reward functions. Probe coverage asserts the VIP completion flag does not change the 20/30/40 Coin or Gem result.

## Owner questions

1. **Daily reset boundary:** approve UTC day, local calendar day, or another named reset rule? Claims currently remain disabled.
2. **Daily slot 3:** choose a reward type and amount, or keep the slot unavailable? No replacement was invented.
3. **Restore/clock policy:** should offline Energy trust a forward device-clock jump after app close, and how should reinstall/restore be reconciled without an account backend?
4. **Booster family:** should the free Shop remain Energy-only after Focus removal, or should another booster family be considered in a separately reviewed balance decision? No substitute has been added.
5. **Ads consent and audience:** approve app IDs, test unit IDs, privacy wording, age-directed status, consent UX, and platform tracking choices before enabling any provider.
6. **Store catalog:** approve any product names, IDs, per-store mappings, and prices only after a trusted receipt-verification backend and both store adapters are ready. All current product IDs/prices remain blank and nonbuyable.
