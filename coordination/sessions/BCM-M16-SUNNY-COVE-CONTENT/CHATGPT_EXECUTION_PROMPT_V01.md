# BCM-M16 Sunny Cove Canonical 100-Level Content — Execution Prompt V01

Execute against:

- `coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_CRITERIA_V01.md`
- `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md`
- `docs/CAMPAIGN_MODULE_TECHNICAL_DESIGN.md`
- root `TASKS.md`

Before implementation, obey `AGENTS.md` and synchronize:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

## Goal

Replace the current 2-level Sunny Cove seed with the approved canonical 100-level normal campaign content.

This pass covers BCM-M16-001..008 and BCM-M16-010.

Do **not** invent an exact VIP placement schedule. BCM-M16-009 remains open unless an already-approved exact VIP placement table is present in the repository.

## 1. Canonical data

Update:

`data/campaign/levels/sunny_cove.json`

to contain exactly 100 sequential levels.

Use `docs/SUNNY_COVE_LEVEL_PROGRESSION_V1.md` as the row-by-row authority.

For each level:
- exact normal objectives from the approved table;
- exact `time_limit_sec` from the approved table;
- valid existing schema fields;
- no normal target below L5;
- no normal target above L8;
- no L9 normal target.

Do not simplify, smooth, or reinterpret the approved table.

## 2. Anchors

Level 1:
- 1×L5
- 20 sec

Level 100:
- 1×L8
- 1×L7
- 1×L6
- 1×L5
- 300 sec

## 3. Planning-cost validator

Add focused validation for:

`cost(Ln) = 2^(n-1)`

and:

`objective_cost = SUM(quantity * 2^(cocktail_level - 1))`

Required:
- L5=16, L6=32, L7=64, L8=128;
- L1 objective cost 16;
- L100 objective cost 240.

The documented L1-L3 random spawn baseline is a planning assumption only. Do not alter spawn gameplay in this task.

## 4. Timer contract

Validate all 100 timers against the approved table.

Do not add:
- fixed minimum timer;
- 30-second padding;
- VIP cost to normal timer.

The approved table already encodes the accepted 2× planning-time target.

## 5. Difficulty waves

Preserve relief levels exactly as authored.

Do not make timer/cost progression monotonic.

## 6. Progression compatibility

Do not rewrite CampaignManager or IslandMap architecture.

Add focused assertions proving:
- exactly 100 levels load in FULL validation mode;
- IDs are exactly 1..100;
- Level 1 is initial start;
- sequential unlock compatibility remains intact;
- Level 100 retains existing Sunny Cove completion / next-island boundary behavior.

## 7. VIP in this pass

Search first for an exact owner-approved Sunny Cove VIP placement table.

If none exists:
- keep `vip: null` for the canonical 100 rows in this V01 pass;
- keep VIP feature flags consistent with that state;
- do not invent target levels, quantities, placement frequency, or booster rewards;
- record BCM-M16-009 as intentionally not implemented by Codex;
- do not edit `TASKS.md`.

M15 VIP runtime/economy systems remain frozen and must continue to pass regression.

## 8. Focused test

Add:

`tests/m16_sunny_cove_content_probe.gd`

or an equivalently scoped test.

It must validate **all 100 levels**, not merely sample anchors.

At minimum assert:
- count/IDs;
- exact orders against the approved table;
- exact timers;
- L5-L8 legality;
- merge costs;
- Level 1/100 anchors;
- FULL LevelDatabase validation;
- sequential progression compatibility;
- VIP cost excluded from normal timer model.

## 9. Regressions

Run:
- M16 focused probe twice;
- M15;
- M14;
- M13;
- M11;
- M10;
- `git diff --check`.

## Hard boundaries

Do not:
- edit root `TASKS.md`;
- modify M15 To-Go/VIP HUD asset/layout;
- retune R11 physics/table/colliders;
- change scoring/economy semantics;
- create a GitHub branch;
- create Desktop clones/worktrees;
- start M17.

## Completion

Write:

`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CODEX_LOG_V01.md`

Include:
- start/final SHA;
- exact count and ID proof;
- Level 1/100 proof;
- full-table validation method;
- timer/cost validation proof;
- whether an approved VIP placement table was found;
- explicit statement that BCM-M16-009 was not invented if absent;
- regression results;
- final sync proof.

Push to `main`, sync canonical Desktop, then return:

- implementation SHA;
- final main/canonical SHA;
- 100-level count PASS/FAIL;
- exact approved table PASS/FAIL;
- L5-L8 legality PASS/FAIL;
- timer/cost model PASS/FAIL;
- Level 1/100 anchors PASS/FAIL;
- sequential progression PASS/FAIL;
- VIP placement status;
- tests;
- log URL;
- `AWAITING_M16_AUDIT_V01`.

Then STOP.
