# BCM-M17 Decision-Grade Solver Qualification — Independent Audit V03A

Verdict: **AUDITED_PASS / SOLVER_QUALIFIED_FOR_M17_007**

Auditor: ChatGPT  
Builder: CODEX  
Branch: `main`  
Implementation/evidence publication SHA: `202e2e913974976c519e662bbeca7c78a82a795c`  
Final audited HEAD: `e55ca73359d436b70ff290cba18a7608d280f089`

## 1. Summary

V03A passes independent audit.

The owner's observed fixed-lane failure mode is demonstrably removed.

The stronger policy:
- changes horizontal launch position from board state;
- directly targets current same-level cocktails;
- chooses lower-congestion lanes when no immediate same-level target exists;
- is deterministic for the same observed state;
- records the required decision evidence;
- runs qualification at canonical physics time scale 1.0;
- clears the locked minimum solver thresholds.

Machine verdict is correctly:

`SOLVER_QUALIFIED_FOR_M17_007`

This qualifies the solver for **screening / flagging work under M17-007**.

It does **not** itself complete M17-007, and it does not authorize M17-008 canonical tuning.

## 2. Anti-fixed-lane verification

Independent parsing of all 30 canonical-scale trial action logs confirms:

- trials with >=5 shots: **30**
- trials with >=2 unique x positions: **30**
- lateral-variation fraction: **1.00**
- minimum required fraction: **0.80**
- tested levels without lateral variation: **0**
- `FIXED_LANE_FAILURE = false`

Per-trial `unique_x_positions` is 5 or 6.

Observed horizontal positions across the cohort include:
- 150
- 220
- 290
- 360
- 500
- 570

This is not cosmetic metadata. Raw action logs show actual position changes within individual trials.

Example L1 action sequence includes transitions among center, left, and right launch positions with both:
- `low_congestion_lane`
- `same_level_target`

decision reasons.

## 3. Decision-evidence integrity

Every stronger-policy action inspected in the 30-trial report contains:

- `x_position`
- `lane_index`
- `decision_reason`
- `same_level_target_found`
- `target_instance_id`

Missing required action fields: **0**.

Across the cohort, decision reasons are:

- `same_level_target`: **1068 actions**
- `low_congestion_lane`: **392 actions**

Independent consistency checks found:
- same-level-target reason with false target flag: **0**
- same-level target flag with missing target ID: **0**

## 4. Policy source audit

PASS.

The production validation policy observes:
- current spawned level;
- live non-held board drinks;
- board x/y positions;
- motion state;
- current normal objective level;
- authoritative legal launch geometry.

It does not receive a future RNG value or future spawn list.

Policy behavior:
1. if a same-level cocktail exists, choose a deterministic lower-board target and launch at the nearest legal x;
2. otherwise score legal horizontal positions by local congestion, with extra lower-board weight;
3. choose the lowest-congestion lane with deterministic center/tie-break behavior.

No source evidence shows:
- spawn-level rewriting;
- post-launch teleportation;
- direct merge calls;
- direct objective completion;
- board-piece deletion;
- physics/collider/timer modification.

## 5. Focused owner-observation fixtures

PASS.

Focused tests explicitly verify:

- same spawned level + left target => left-shifted action;
- same spawned level + right target => right-shifted action;
- left-side congestion without same-level target => safer non-left choice;
- identical observation state => identical action;
- no future-RNG input exists in the policy seam;
- returned horizontal bucket is legal.

The left-congestion fixture's selection resolves away from the congested left edge under the production scoring rule.

## 6. Canonical-scale qualification cohort

Independent report parsing confirms:

Levels:
`1, 10, 11, 50, 51, 100`

Trials:
- 5 each
- 30 total

Seed:
- base `17300000`
- formula `base + level_id * 1000 + trial_index`

Qualification physics scale:
- **1.0**

No harness aborts.

Completion results:
- L1: **3/5**
- L10: **1/5**
- L11: **3/5**
- L50: **0/5**
- L51: **0/5**
- L100: **0/5**

The locked qualification thresholds are therefore satisfied:
- L1 >= 3/5: PASS
- L10 or L11 >=1 completion: PASS
- no aborts: PASS
- same-seed action-log reproducibility: PASS
- replay logical reproducibility: PASS
- telemetry valid: PASS
- anti-fixed-lane gate: PASS

## 7. Time-scale fidelity

The V03A evidence correctly demonstrates that historical 4× runs are not decision-grade.

### L1 fixed action log
1×:
- outcome: timeout
- merges: 8

4×:
- outcome: timeout
- merges: 2

Merge count diverges.

### L50 fixed action log
1×:
- outcome: danger / TABLE_DANGER
- merges: 28

4×:
- outcome: timeout / TIMEOUT
- merges: 25

Both outcome and merge count diverge.

Therefore the report correctly marks:

`historical_4x_telemetry_only_not_decision_grade = true`

Future M17-007/008 decisions must use canonical 1× evidence.

## 8. V02 telemetry preservation

PASS.

V03A preserves the audited V02:
- danger-vs-timeout classification;
- rail-proximity transition proxy;
- telemetry metadata;
- replay/action-log mechanism.

No evidence indicates V03A regressed those contracts.

## 9. Canonical/product freeze

PASS.

Compared V03A start to final audited HEAD.

Changed runtime/tooling files are limited to:
- M17 harness;
- M17 focused test;
- M17 solver qualification tool;
- M17 qualification reports/log.

Canonical Sunny Cove JSON is byte-for-byte unchanged.

No canonical objective, timer, VIP content, reward, M15 HUD, or production physics/table/collider tuning occurred.

## 10. Regression evidence

Builder reports PASS:
- M17 focused probe ×2;
- M16;
- M15;
- M02;
- `git diff --check`.

ChatGPT did not execute Godot locally, but independently verified:
- live final GitHub HEAD;
- qualification JSON;
- raw 30-trial action logs;
- policy source;
- qualification runner;
- focused probe assertions;
- canonical-data immutability.

No repository evidence contradicts the builder results.

## 11. Gate matrix

| Gate | Result |
| --- | --- |
| A preserve V01/V02 contracts | PASS |
| B stronger deterministic policy | PASS |
| C canonical physics scale | PASS |
| D 30-trial cohort | PASS |
| E minimum solver qualification | PASS |
| F V02 comparison | PASS |
| G 1×/4× fidelity spot check | PASS |
| H no premature tuning | PASS |
| I focused tests | PASS |
| J owner-observed anti-fixed-lane gate | PASS |

## 12. M17 status

**V03A: AUDITED_PASS.**

Machine/audit verdict:

`SOLVER_QUALIFIED_FOR_M17_007`

Important scope boundary:

**BCM-M17-007 is not yet complete.**

V03A qualifies the tool needed to perform M17-007. The next pass must use this qualified canonical-scale solver to screen the full canonical Sunny Cove challenge space and produce the actual mathematically-impossible / effective-impossibility / outlier candidate table.

**BCM-M17-008 remains blocked.**
