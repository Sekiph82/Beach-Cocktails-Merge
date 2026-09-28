# BCM-M17 VIP Optionality Structural Remediation — Execution Prompt V05

Execute against:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V04.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V05.md`
- current `main`

Before work:
- obey `AGENTS.md`;
- synchronize `C:\Users\sekip\Desktop\Beach Cocktails - Merge`;
- confirm clean `main`.

## Goal

V04 proved a structural problem:

All 25 configured Sunny Cove VIP levels currently auto-capture mandatory intermediate material.

VIP is logically optional, but current production routing makes its workload mechanically forced.

Fix that structural problem **without changing any canonical level data or timers**.

Do not solve it by adding seconds.

## 1. Preserve all owner-approved content

Do not change:

- 25 VIP level cadence;
- VIP target levels;
- VIP quantities;
- +Time/Upgrade reward cadence;
- normal objectives;
- timers;
- normal rewards;
- star thresholds;
- M15 tall To-Go/VIP HUD;
- 2× VIP delivery score.

This is runtime optionality remediation only.

## 2. Add a deterministic mandatory-reserve test for VIP capture

A matching VIP cocktail may be auto-captured only when it is surplus to all remaining mandatory normal objectives.

Normative test:

`candidate_is_surplus == true`

only if:

> Removing that candidate from the current eligible board inventory does not increase the minimum additional production required to satisfy every remaining mandatory normal objective under legal equal-level merges.

Use the bridge's authoritative:

`get_objective_state()["normal_remaining"]`

and current board inventory.

Do not infer remaining normal demand from HUD text.

## 3. Respect non-splittability

A higher cocktail cannot be split downward.

Therefore do not implement a naive rule such as:

`total_board_L1_value >= total_remaining_L1_value`

as the only reserve test.

Example:

An existing L8 cannot satisfy a remaining L5 order merely because its numeric L1-equivalent value is large.

Your planner may use:
- deterministic dynamic programming;
- a bounded merge-resource state calculation;
- another exact deterministic method;

but it must pass the locked non-splittability fixtures.

Keep it bounded. It only runs when evaluating a potential VIP capture, not every frame.

## 4. Apply one guard to both VIP capture paths

### Direct merged candidate

In/around:

`GameManager.on_merged()`

when:

`new_level == _active_vip_level()`

do not call VIP capture unless the candidate is surplus.

If it belongs to mandatory reserve:
- leave it on the board;
- let normal merge progression use it.

### Stocked VIP candidate

In:

`_try_collect_stocked_target()`

do not collect the stored VIP candidate unless the same surplus test passes.

The stock path must not bypass the protection added to the merge path.

## 5. Preserve mandatory normal-first behavior

If the active normal target and VIP target are the same level:

- normal claim remains first;
- existing M15 behavior stays authoritative.

Do not weaken this while adding surplus protection.

## 6. VIP must remain completable

The fix must not turn VIP off.

When the player intentionally creates a matching cocktail beyond mandatory reserve:

- that surplus may be captured as VIP;
- progress advances;
- 2× score is paid exactly as M15 defines;
- configured booster reward remains once-only.

No new tap/button/toggle interaction in this task.

## 7. Required L4 behavioral proof

Use real GameManager + bridge integration.

### Skip VIP path

L4:
- normal = 1×L6
- VIP = 1×L5

Prove:
1. first L5-equivalent required for L6 is protected;
2. second required L5-equivalent is protected;
3. normal L6 completes;
4. session can WIN;
5. VIP delivered remains 0;
6. VIP completed remains false;
7. no VIP reward is granted.

This is the core owner-policy proof.

### Complete VIP path

Fresh L4 session:

1. retain enough L5-equivalent reserve to build L6;
2. produce an additional surplus L5;
3. surplus L5 is captured as VIP;
4. protected reserve still produces L6;
5. normal WIN succeeds;
6. VIP completed = true;
7. reward grants exactly once.

## 8. Pure reserve-planner fixtures

Add focused deterministic cases:

### L4
- 1×L5 including candidate => not surplus;
- 2×L5 including candidate => not surplus;
- 3×L5 including candidate => surplus.

### Non-splittability
Create a state where a higher cocktail has enough numeric total value but cannot fulfill a lower remaining target.

Candidate must remain protected if needed.

### L60
Use exact canonical:
- normal objectives;
- VIP L7.

Prove:
- minimal normal material is protected;
- one extra L7 beyond mandatory reserve becomes VIP-eligible.

### L100
Use exact canonical:
- normal L8/L7/L6/L5 set;
- VIP L7.

Prove:
- minimum mandatory reserve is protected;
- one additional L7 can be identified as surplus.

## 9. Replay-later proof

Use the real campaign persistence/economy flow.

### First play
- normal WIN;
- VIP missed;
- persisted `vip_completed=false`;
- no VIP booster reward.

### Replay
- produce legitimate surplus VIP material;
- normal WIN;
- `vip_completed=true`;
- reward granted once.

### Replay again
- reward not duplicated;
- persisted VIP remains true.

Do not satisfy the test through:
- `set_vip_completed()`;
- direct reward-ledger mutation;
- direct terminal-result fabrication.

## 10. All-25 structural evidence

Create:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_VIP_OPTIONALITY_V05.json`

and:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_VIP_OPTIONALITY_V05.md`

For each of the 25 VIP levels include:

- level ID;
- normal objectives;
- VIP target/quantity;
- V04 historical forced-capture count;
- V04 historical forced cost;
- post-fix forced capture count on the minimal mandatory path;
- whether one deliberately surplus VIP delivery remains possible.

Required aggregate result:

- pre-fix historical interception risk: `25/25`;
- post-fix forced VIP captures: `0/25`;
- surplus VIP path available: `25/25`.

If any level fails either post-fix property:
- STOP;
- do not claim V05 success.

## 11. Historical V04 label

Do not alter V04 report bytes.

In the V05 report/docs explicitly state:

`M17_CANONICAL_SCREENING_V04 = PRE_OPTIONALITY_FIX / HISTORICAL_FOR_PHYSICAL_CLASSIFICATION`

because runtime capture semantics changed after that screening.

M17 canonical tuning must wait for a post-fix rescreen.

## 12. Tests

Add a focused V05 probe, suggested:

`tests/m17_vip_optionality_probe.gd`

Run:

- V05 focused probe;
- M17 difficulty probe ×2;
- M16;
- M15;
- M14;
- M02;
- `git diff --check`.

Update existing M15/M16 tests only if needed to make the existing "VIP optional" contract executable rather than merely logical.

Do not weaken prior assertions.

## Hard boundaries

Do not:

- edit `data/campaign/levels/sunny_cove.json`;
- change any timer;
- change any normal order;
- change any VIP target/quantity/reward;
- change HUD visuals;
- change table/physics/colliders;
- implement canonical M17-008 tuning;
- start M18;
- edit root `TASKS.md`;
- create a GitHub branch;
- create Desktop clones/worktrees.

## Completion

Write:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V05.md`

Include:

- exact production logic changed;
- reserve/surplus algorithm;
- L4 skip-VIP proof;
- L4 complete-VIP proof;
- replay-later proof;
- all-25 aggregate evidence;
- canonical-data hash/freeze proof;
- regression results;
- final sync proof.

Push to `main`, sync canonical Desktop, then return:

- implementation SHA;
- final main/canonical SHA;
- mandatory reserve protection PASS/FAIL;
- L4 VIP-miss path PASS/FAIL;
- L4 surplus-VIP path PASS/FAIL;
- replay-later PASS/FAIL;
- all-25 forced capture 0/25 PASS/FAIL;
- all-25 surplus path 25/25 PASS/FAIL;
- canonical data frozen PASS/FAIL;
- regressions;
- report links;
- log URL;
- `AWAITING_M17_AUDIT_V05`.

Then STOP.

Do not start post-fix screening or canonical tuning in this run.
