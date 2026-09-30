# BCM-M18 Owner Ruling V02 — Sunny Cove Cumulative-Star Reward Payload

Date: 2026-09-30
Status: **OWNER_APPROVED**

This ruling resolves the `BCM-M18-003` owner gate recorded by `CHATGPT_AUDIT_V01.md`.

## Approved Sunny Cove cumulative-star track

Sunny Cove has 100 levels and a maximum of 3 stars per level, for a maximum cumulative total of 300 stars.

The owner approves exactly these cumulative-star thresholds and rewards:

| Cumulative stars | Reward |
|---:|---|
| 30 | `{"type":"booster","id":"time","quantity":1}` |
| 60 | `{"type":"booster","id":"time","quantity":1}` |
| 90 | `{"type":"booster","id":"time","quantity":1}` |
| 120 | `{"type":"booster","id":"time","quantity":1}` |
| 150 | `{"type":"booster","id":"upgrade","quantity":1}` |
| 180 | `{"type":"booster","id":"time","quantity":1}` |
| 210 | `{"type":"booster","id":"time","quantity":1}` |
| 240 | `{"type":"booster","id":"time","quantity":1}` |
| 270 | `{"type":"booster","id":"time","quantity":1}` |
| 300 | `{"type":"booster","id":"upgrade","quantity":1}` |

## Locked semantics

- These are cumulative-star rewards, not level-number milestone rewards.
- Each threshold reward is grantable exactly once.
- Crossing multiple unclaimed thresholds may grant every newly eligible threshold exactly once.
- Claims persist across save/reload and are idempotent on replay.
- A player's cumulative total is derived from authoritative stored best stars for completed Sunny Cove levels.
- Reward eligibility never blocks level completion, next-level progression, island completion, or Tiki Island unlock.
- Existing level-number milestones `10,20,...,100` remain intact and semantically separate.
- Existing VIP rewards remain intact and separate.
- No coin reward is added by this ruling.
- No purchase, ad, monetization, timer, objective, VIP, gameplay, physics, HUD, or progression tuning is authorized.
- The existing production booster ids `time` and `upgrade` are authoritative for this payload.

This payload is the exact owner-approved economy input for BCM-M18-003 and is repository truth for the bounded M18 continuation.
