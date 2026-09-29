# BCM-M17 V07-R01 — Locked Remediation Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `OWNER_RULING_V07_SYNC_BLOCKER.md`
- `CHATGPT_AUDIT_V07.md`
- `CODEX_LOG_V07.md`
- `CHATGPT_AUDIT_CRITERIA_V07.md`
- audited V06-R02 evidence.

## Gate A — resolve the local sync blocker safely

Before implementation, CODEX may delete exactly:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_ATTEMPT_20260929_SYNC_BLOCKED.md`

No other local/untracked file may be deleted, moved, staged, reset, stashed, overwritten or cleaned.

After deletion, canonical Desktop checkout must be clean `main`, synchronized `0/0` with `origin/main`.

## Gate B — bounded runner remediation only

Correct only the two V07 integrity defects:
1. typed/generated canonical mappings must be compared semantically to JSON-loaded Variant arrays/dictionaries rather than by incompatible direct typed equality;
2. seed-registry accounting must register and validate every aggregate seed, including the first imported V06-R02 source seed, so the expected unique aggregate total is exactly 213.

No canonical data, gameplay, physics, HUD, economy, progression, VIP content, timer/objective, M18, or historical V07 evidence mutation is allowed.

## Gate C — fresh V07-R01 evidence

Do not promote or rewrite the failed V07 report.

Create a fresh V07-R01 runner/output set:
- `tools/campaign/m17_canonical_confirmation_v07_r01.gd`
- `M17_CANONICAL_CONFIRMATION_V07_R01.json`
- `M17_CANONICAL_CONFIRMATION_V07_R01.md`

Use the same 42 audited confirmation candidates and the audited V06-R02 source trial as aggregate trial 1.

Run four fresh post-V05 trials per candidate using `MERGE_AWARE_V01`, `Engine.time_scale=1.0`, with a new deterministic seed namespace:
`17800000 + representative_level * 100 + trial_index`, where trial_index = 1..4.

Expected:
- 42 candidates;
- 168 new trials;
- exactly 5 post-V05 trials per candidate;
- 213 unique aggregate seeds across 45 source trials + 168 new trials.

## Gate D — classification semantics

For each candidate:
- >=1 completion out of 5 => `SOLVER_FEASIBLE`
- 0/5 => `HIGH_RISK_SOLVER_FAILURE`

The three V06-R02 feasible classes remain carried forward.

No class may remain `SCREENING_FAILURE_NEEDS_CONFIRMATION` after valid 5-trial evidence.

The failed V07 observed 16/29 split is historical failed-run evidence only and must not be copied forward as an assumed V07-R01 result.

## Gate E — VIP and report integrity

Preserve:
- forced `0/25`
- surplus `25/25`
- no VIP cost in normal timers.

V07-R01 report must contain:
- all 100 levels;
- all 45 classes;
- source/canonical hashes;
- provenance and all five seeds for each candidate;
- completion/danger/timeout/abort counts;
- final feasible/high-risk class lists;
- validation errors = none.

Direct runner must return PASS with exit code 0. No repair-after-failure path is allowed.

## Gate F — regressions after direct PASS only

Only after V07-R01 direct PASS:
- V06 analytical probe;
- V05 optionality;
- M17 difficulty validation twice;
- M16;
- M15;
- M14;
- M02;
- report inspection;
- `git diff --check`;
- `TASKS.md` unchanged by CODEX;
- canonical Sunny Cove data unchanged.

Any required failure stops the batch.

## Gate G — handoff

Create immutable:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R01.md`

It must include exact preflight, deletion proof for the one authorized local blocker, changed files, commands, exit codes, hashes, 168-new-trial proof, 213-unique-seed proof, classifications, regressions, final HEAD/origin/remote equality, and limitations.

Final marker:
`AWAITING_M17_AUDIT_V07_R01`

M17-008 canonical tuning and M18 remain blocked until independent ChatGPT audit.
