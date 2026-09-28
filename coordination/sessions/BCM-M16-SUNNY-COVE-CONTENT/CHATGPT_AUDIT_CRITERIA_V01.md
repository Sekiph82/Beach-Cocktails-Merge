# BCM-M16 Sunny Cove Canonical Content — Audit Criteria V01

Status: **LOCKED BEFORE EXECUTION**

Authority:
- root `TASKS.md` M16 section
- `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md`
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- current M10-M15 audited campaign/runtime contracts

## Scope

This V01 pass covers:
- BCM-M16-001 through BCM-M16-008;
- BCM-M16-010;
- the data/validation foundation needed for M16.

BCM-M16-009 (VIP placement/reward content pass) remains **PENDING OWNER CONTENT POLICY** unless an already-approved exact VIP placement table exists in the repository. Codex must not invent one.

## Gate A — Exactly 100 Sunny Cove levels

PASS requires:
- `data/campaign/levels/sunny_cove.json` contains exactly 100 records;
- `level_id` is exactly 1..100, no gaps, no duplicates;
- every record uses `island_id = sunny_cove`;
- `LevelDatabase.ValidationMode.FULL` loads canonical data successfully;
- island definition declares 100 levels.

## Gate B — Exact approved normal objective table

For every level 1..100:
- normal `orders` must exactly match `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md`;
- quantities and cocktail levels must match the approved table;
- no normal target below L5;
- no normal target above L8;
- no L9 normal target in Sunny Cove.

Spot anchors alone are insufficient. Automated validation must cover all 100 rows.

## Gate C — Timer contract

For every level:
- `time_limit_sec` must exactly match the approved V1 progression table;
- no fixed minimum-time padding or +30 second pad;
- Level 1 = 20 seconds;
- Level 100 = 300 seconds;
- the normal timer remains based on the approved normal objective cost model only.

## Gate D — Merge-cost planning model

Automated validation must implement the documented planning model:

`cost(Ln) = 2^(n-1)`

and:

`objective_cost = SUM(quantity * 2^(cocktail_level - 1))`

Required anchors:
- L5 = 16
- L6 = 32
- L7 = 64
- L8 = 128
- Level 1 cost = 16
- Level 100 cost = 240.

The L1-L3 spawn baseline remains a planning assumption and must not be changed by M16.

## Gate E — Level 1 / Level 100 anchors

Level 1:
- exactly 1×L5;
- exactly 20 seconds.

Level 100:
- exactly 1×L8 + 1×L7 + 1×L6 + 1×L5;
- exactly 300 seconds.

## Gate F — Difficulty-wave fidelity

The full 100-level data must match the approved progression table, including intentional relief levels after demanding peaks.

Do not normalize the table into a monotonic staircase.

## Gate G — Sequential progression compatibility

Automated tests must prove:
- Level 1 is initially selectable/unlocked;
- completion advances sequentially;
- no level is skipped in the canonical chain;
- completing Level 100 remains compatible with Sunny Cove completion / next-island unlock behavior already owned by CampaignManager.

Do not rewrite M11/M13 progression architecture.

## Gate H — Schema / immutability / legality

Every record must satisfy the existing level schema:
- positive timer;
- valid orders;
- valid reward/star/feature-flag structures;
- immutable read copies from LevelDatabase;
- no duplicate IDs;
- no unresolved island reference.

## Gate I — VIP handling in this V01 pass

Codex must not invent an exact Sunny Cove VIP placement schedule.

Unless an already-approved exact table is found in repo:
- keep VIP content neutral / null in the new canonical rows;
- do not include VIP cost in normal timer validation;
- leave BCM-M16-009 open for a later owner-approved pass.

Existing M15 VIP runtime/economy capability must remain intact.

## Gate J — Tests

Add `tests/m16_sunny_cove_content_probe.gd` (or equivalent focused probe) that validates all 100 canonical rows.

Required regression PASS:
- M16 focused probe twice;
- M15;
- M14;
- M13;
- M11;
- M10;
- `git diff --check`.

## Governance

Codex must:
- sync canonical Desktop before/after;
- not edit root `TASKS.md`;
- not create a branch;
- not create Desktop copies/worktrees;
- not start M17;
- not alter M15 HUD visuals;
- not retune physics/table/colliders.

## Builder log

Write:
`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CODEX_LOG_V01.md`

Final verdict requires independent ChatGPT audit.
