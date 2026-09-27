# BCM-M15 VIP, Boosters, Rewards & Economy — Remediation Audit Criteria V02

Status: **LOCKED BEFORE EXECUTION**

Remediate only the V01 blockers while preserving accepted M15 economy work.

## Frozen accepted work

Preserve:
- GameEconomy authority and persisted reward ledger;
- save compatibility;
- booster inventory APIs;
- +Time semantics;
- level/VIP/milestone deterministic reward IDs;
- milestone claim integration;
- M14 WIN/LOSE/stars/progression;
- shared economy across navigation/session;
- R11 physics/table/HUD geometry;
- no purchases/ads/backend/M16 content.

## Gate A — Real independent VIP delivery path

A level with normal target L6 and VIP target L12 must allow an actual L12 drink to satisfy the VIP objective while L6 remains the mandatory normal objective.

PASS requires production GameManager behavior, not direct bridge mutation.

The qualifying VIP drink must be actually captured/consumed through a bounded delivery path. No customer-character scene is required.

Normal To-Go remains mandatory and visually primary.

## Gate B — VIP quantity accumulation

VIP runtime state must track at minimum:
- required quantity;
- delivered quantity;
- remaining quantity;
- completed state.

Multiple one-unit deliveries must accumulate deterministically.

For VIP quantity 2:
- first valid delivery => pending, delivered 1, remaining 1;
- second valid delivery => completed, delivered 2, remaining 0.

Extra deliveries after completion must be idempotent/non-duplicating.

## Gate C — Production GameManager integration

Production gameplay must detect/capture valid VIP-target drinks independently of the normal To-Go target.

Requirements:
- newly merged qualifying drink can fulfill pending VIP;
- a qualifying stored drink can be discovered/delivered without breaking M14 stored normal-order behavior;
- no drink may be double-freed or double-rewarded;
- normal To-Go capture remains unchanged for mandatory objectives;
- if normal and VIP target levels coincide, behavior must be deterministic and documented; mandatory normal completion must not be made harder by VIP.

Do not retune physics, rails, launch, merge, scoring, or table containment.

## Gate D — VIP reward dispatch remains bounded

VIP reward still grants only after:
- normal WIN;
- VIP completed.

LOSE/timeout/incomplete VIP => no VIP reward.

Replay/reload => no duplicate reward.

VIP completion before normal WIN only marks VIP state; it does not grant immediately.

## Gate E — Probe must prove real runtime path

Update `tests/m15_vip_boosters_economy_probe.gd` so it:
- uses a normal L6 objective and distinct VIP L12 target;
- completes VIP through the actual GameManager production capture/delivery route;
- does NOT call `set_vip_completed(true)` for the functional completion proof;
- proves quantity 2 with two separate one-unit deliveries;
- proves normal WIN remains independent;
- proves completed VIP reward grants exactly once;
- proves stored qualifying VIP drink path;
- proves non-VIP hides badge;
- preserves all existing economy/save/+Time/milestone assertions.

The probe should fail if the production VIP capture path is removed.

## Gate F — Independent visual evidence

Capture Windows/OpenGL runtime screenshots after the real production VIP path:
1. VIP pending;
2. VIP partially progressed if quantity >1 is shown by UI, otherwise pending before final delivery;
3. VIP completed;
4. non-VIP hidden state.

Commit bounded evidence PNG copies under:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/evidence/v02/`

Do not replace accepted production assets.

Screenshots must show the normal To-Go panel remains readable and unchanged in geometry.

Owner visual acceptance remains required after technical audit.

## Gate G — Regression

Required PASS:
- M15 run 1;
- M15 run 2 without source changes;
- M14;
- M13;
- M12;
- M11;
- M10;
- M08;
- M03;
- M02.

## Gate H — Governance / sync

At task start, obey mandatory canonical Desktop sync from `AGENTS.md`.

At task end, after push, fast-forward canonical Desktop to final remote main if clean.

Codex must not edit root `TASKS.md`.

No new GitHub branch without owner approval.

No Desktop clone/worktree proliferation.

## Builder log

Write:
`coordination/sessions/BCM-M15-VIP-BOOSTERS-ECONOMY/CODEX_LOG_V02.md`

Include exact real VIP delivery architecture, quantity state, same-level precedence rule, evidence PNG paths, test matrix, final SHA synchronization, and TASKS untouched proof.

Any material technical FAIL/UNVERIFIED => CHANGES_REQUIRED.