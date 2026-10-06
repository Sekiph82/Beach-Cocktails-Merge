# Beach Cocktails Merge — Owner Economy Draft V01

Date: 2026-10-06

Status: **OWNER_DRAFT / NOT YET ACTIVATED FOR IMPLEMENTATION**

This document records owner-approved economy design decisions discussed to date. It is intentionally **not** an implementation prompt, not an active milestone, and does not modify root TASKS.md.

## 1. LEVEL

There is no separate Player Level / XP system.

The Home LEVEL field shows only the player's current/latest campaign frontier level.

The Home LEVEL value and `CONTINUE LEVEL N` must use the same campaign progression authority.

Replaying an older level must not reduce the Home frontier level.

## 2. ENERGY

Planned Energy contract:

- Max Energy: **100**
- Cost per gameplay attempt: **20 Energy**
- 100 Energy therefore equals **5 attempts**
- Energy is consumed only when a real gameplay attempt successfully starts
- Retry = a new attempt = **20 Energy**
- Navigating Home / World Map / Island Map / Settings consumes no Energy
- Technical loading/startup failure must not consume Energy
- Regeneration: **+1 Energy every 3 minutes**
- 20 Energy regenerates in **60 minutes**
- 0 → 100 full regeneration takes **5 hours**
- Energy refill via Gems is planned at **25 Gems → full refill to 100**
- No separate ad refill is planned on the Energy bar at this stage
- Clock rollback / offline regeneration must use a high-water-time protection model

## 3. COIN

Coin remains the soft currency.

Current proposed draft rewards:

- New player starting balance: **500 Coin**
- First clear: **+100 Coin**
- Replay win: **+25 Coin**
- First 3-star completion: **+50 Coin**
- Every 10-level milestone: **+250 Coin**
- Island completion: **+1,000 Coin**

Existing To-Go and VIP reward rules remain separate inputs into Coin earnings and must be preserved when the economy is implemented.

Coin spending/pricing is not yet finalized.

## 4. GEMS

Gems will become the rare/premium currency.

Current proposed draft:

- New player starting balance: **50 Gems**
- Every 10-level milestone: **+3 Gems**
- Island completion: **+15 Gems**
- Daily Rewards can grant Gems
- **25 Gems → full Energy refill to 100**

Gem purchase/use tables are not yet finalized.

## 5. DAILY REWARDS

Daily Rewards will have **5 reward slots per day**.

Important: there are 5 rewards total, but only 4 require rewarded ads.

### Reward 1
- Immediately claimable
- No ad required
- Proposed reward: **100 Coin**

### Reward 2
- WATCH AD
- Proposed reward: **+20 Energy**

### Reward 3
- WATCH AD
- Proposed reward: **+200 Coin**

### Reward 4
- WATCH AD
- Proposed reward: **+2 Gems**

### Reward 5
- WATCH AD
- Proposed reward: **+40 Energy**

Daily total if all five are claimed:
- **300 Coin**
- **60 Energy** (= 3 extra attempts under the 20-Energy attempt cost)
- **2 Gems**

### Daily Rewards behavior

- Rewards are claimed sequentially
- Reward 1 is directly claimable
- Rewards 2–5 each require one successfully completed rewarded ad
- A reward is granted only after successful ad completion
- Closing/failing the ad does not consume the reward
- If no rewarded-ad provider is available, the ad reward button is disabled and the reward remains unclaimed
- Each reward may be claimed only once per day
- Daily claim state persists across app restarts
- Daily reset must be protected against clock rollback/time manipulation
- Daily Rewards is currently the primary rewarded-ad surface
- No separate rewarded-ad Energy refill is planned on the Home Energy `+` button at this stage

## 6. SAVE / ARCHITECTURE DIRECTION

When implemented, the economy will require a SaveManager schema migration.

Expected future persistent fields include:
- coins
- gems
- energy
- energy regeneration anchor
- high-water time / anti-clock-rollback state
- Daily Rewards daily claim state
- existing boosters
- existing reward ledger
- existing campaign progression

Existing player campaign progress, coins, boosters, reward ledger, and save data must be preserved during migration.

## 7. NOT YET DECIDED

The following remain intentionally open:

- Coin shop prices
- Gem shop prices
- Booster prices
- Shop bundles
- IAP / real-money purchase model
- Rewarded-ad provider/integration
- Daily Rewards visual design
- Event economy
- Achievement economy
- exact save schema version number
- whether Level 1 is free or consumes Energy
- any additional Energy sources

## 8. GOVERNANCE

This is a saved design draft only.

Do NOT:
- implement it yet;
- activate it in TASKS.md;
- change GameEconomy;
- change SaveManager;
- change Home values;
- change Daily Rewards runtime.

Wait for a later explicit owner instruction before converting this draft into an active economy milestone/sprint and implementation prompt.
