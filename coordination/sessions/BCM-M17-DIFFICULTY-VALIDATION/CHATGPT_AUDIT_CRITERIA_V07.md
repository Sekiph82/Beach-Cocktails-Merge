# BCM-M17 V07 Five-Trial Confirmation — Locked Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `CHATGPT_AUDIT_V06_R02.md`
- `M17_CANONICAL_SCREENING_V06_R02.json/.md`
- V05 optionality semantics
- V03A-qualified `MERGE_AWARE_V01` solver
- M17 rule that one failed trial is only a confirmation candidate and exact-class 0/5 is required for `HIGH_RISK_SOLVER_FAILURE`.

## Gate A0 - complete batch package and order

Before builder execution, the following ordered child prompt/criteria pairs must be present and read:

1. `CHATGPT_EXECUTION_PROMPT_V07_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_CHILD_01.md`, handoff `CODEX_LOG_V07_CHILD_01.md`;
2. `CHATGPT_EXECUTION_PROMPT_V07_CHILD_02.md` / `CHATGPT_AUDIT_CRITERIA_V07_CHILD_02.md`, handoff `CODEX_LOG_V07_CHILD_02.md`;
3. `CHATGPT_EXECUTION_PROMPT_V07_CHILD_03.md` / `CHATGPT_AUDIT_CRITERIA_V07_CHILD_03.md`, handoff `CODEX_LOG_V07_CHILD_03.md`.

The children must execute in that order. The master `CODEX_LOG_V07.md` must include each child result and the final marker. A missing child artifact or out-of-order handoff is `CHANGES_REQUIRED`.

## Gate A — governance, synchronization and freeze

The canonical Desktop checkout must start clean and synchronized with `origin/main` after pulling the ChatGPT audit/tracker/prompt commits.

CODEX must not edit root `TASKS.md`.

The following remain frozen:
- `data/campaign/levels/sunny_cove.json`;
- canonical timers and normal objectives;
- VIP targets, quantities and rewards;
- V04, V05, V06, V06-R01 and V06-R02 evidence;
- M15 HUD;
- score/economy/progression;
- table, physics and colliders;
- M18 and later milestone implementation.

No canonical data tuning is permitted in V07.

## Gate B — exact candidate set

V07 must derive the confirmation set from the audited V06-R02 report, not from a handwritten replacement classification.

The set must be exactly the 42 classes marked `SCREENING_FAILURE_NEEDS_CONFIRMATION` in V06-R02:

`C01,C03,C04,C06,C07,C08,C09,C11,C12,C13,C14,C15,C16,C17,C18,C19,C20,C21,C22,C23,C24,C25,C26,C27,C28,C29,C30,C31,C32,C33,C34,C35,C36,C37,C38,C39,C40,C41,C42,C43,C44,C45`.

The three already solver-feasible V06-R02 classes must remain:
- C02 / representative L3;
- C05 / representative L7;
- C10 / representative L14.

Representative/member mappings must remain identical to V06-R02.

## Gate C — five-trial post-V05 evidence

For each of the 42 candidate classes:
- retain the audited V06-R02 trial as trial 1;
- add exactly four new deterministic trials using the same exact class representative;
- use `MERGE_AWARE_V01`;
- use `Engine.time_scale = 1.0`;
- use four seeds distinct from the V06-R02 seed and from one another;
- preserve the established flat telemetry schema and legal action-log contract.

The aggregate evidence for each candidate class must therefore be exactly five **post-V05** canonical-scale trials.

Pre-V05 V03A/V04 trials may be cited historically but may not count toward the V07 five-trial classification threshold.

If the V06-R02 source trial cannot be validated against its audited hash/schema, V07 must stop rather than silently substitute evidence. A new V08 contract would then be required.

## Gate D — classification semantics

For each candidate class after exactly 5 post-V05 trials:
- at least one completion => `SOLVER_FEASIBLE`;
- 0 completions out of 5 => `HIGH_RISK_SOLVER_FAILURE`.

A 0/5 result is a **high-risk solver finding, not proof of human impossibility**.

No timer/objective change may be made inside V07 in response to the classification.

No class may remain `SCREENING_FAILURE_NEEDS_CONFIRMATION` after it has a valid five-trial aggregate.

## Gate E — complete V07 report

Create new immutable:
- `M17_CANONICAL_CONFIRMATION_V07.json`;
- `M17_CANONICAL_CONFIRMATION_V07.md`.

The report must include:
- canonical and source-report hashes;
- all 100 level records;
- all 45 class records;
- the 3 V06-R02 solver-feasible classes clearly carried forward;
- the 42 candidate classes with exactly 5-trial aggregate evidence;
- per-class completion/danger/timeout/abort counts;
- seeds and source provenance for all five trials;
- telemetry summaries and action-log validity;
- final solver-feasible class count;
- final high-risk 0/5 class count and exact IDs/representatives;
- `0/25` post-V05 forced captures and `25/25` surplus paths;
- explicit interpretation limits.

The report must not call a class mathematically impossible solely because the solver is 0/5.

## Gate F — source integrity and runner behavior

Any V07 tool must be evidence-only and must:
- validate all imported V06-R02 trial records before reuse;
- validate every new trial with the established harness telemetry validator;
- validate action logs;
- reject duplicate seeds;
- reject missing/extra candidate classes;
- reject trial counts other than 5 for confirmation candidates;
- return non-zero on report-integrity failure.

No post-failure bookkeeping repair path is allowed. If the required V07 runner fails, stop and publish a truthful blocked log.

## Gate G — preserved VIP semantics

The V05 reserve rule remains authoritative.

V07 must independently preserve:
- forced captures on minimal mandatory paths: `0/25`;
- surplus VIP paths: `25/25`;
- no VIP cost added to normal timers.

Any regression here is a material FAIL.

## Gate H — regression suite

After the V07 direct confirmation runner passes, run and record:
- V07 parse/direct run;
- V06 analytical probe;
- V05 optionality probe;
- M17 difficulty validation twice;
- M16 Sunny Cove content;
- M15 VIP/boosters/economy;
- M14 GameplaySessionBridge;
- M02 physics regression;
- report integrity inspection;
- `git diff --check`.

Any required failure stops the batch.

## Gate I — handoff and scope truth

CODEX must publish a single immutable `CODEX_LOG_V07.md` containing:
- start/end HEAD;
- branch/remote;
- exact sync evidence;
- files changed;
- exact commands and results;
- source and output hashes;
- candidate list/count;
- new-trial count (must be 168);
- aggregate five-trial count for the 42 candidates;
- final classifications;
- regression results;
- proof `TASKS.md` was untouched;
- final HEAD/origin/remote equality;
- limitations.

Final marker:

`AWAITING_M17_AUDIT_V07`

Any failed or unverified material criterion is `CHANGES_REQUIRED`. M17-008 canonical tuning and M18 remain blocked pending independent ChatGPT audit of V07.
