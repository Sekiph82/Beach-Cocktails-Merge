# BCM-M17 V07-R02 — Locked Remediation Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Authority:
- `CHATGPT_AUDIT_V07_R01.md`
- `CHATGPT_AUDIT_CRITERIA_V07_R01.md`
- `CODEX_LOG_V07_R01_CHILD_01.md`
- `CODEX_LOG_V07_R01_CHILD_02.md`
- audited V06-R02 evidence.

## Gate A — source/freeze preflight

Start from the canonical Desktop checkout:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Require:
- branch `main`;
- clean working tree;
- `HEAD == origin/main == remote main`;
- root `TASKS.md` read-only for CODEX;
- canonical Sunny Cove data unchanged;
- V05/V06-R02/V07/V07-R01 historical evidence unchanged.

Any ambiguity stops the run.

## Gate B — preserve historical R01 evidence

Do not modify, overwrite, regenerate, or promote:
- `tools/campaign/m17_canonical_confirmation_v07_r01.gd`
- `M17_CANONICAL_CONFIRMATION_V07_R01.json`
- `M17_CANONICAL_CONFIRMATION_V07_R01.md`
- V07-R01 logs.

They remain failed historical evidence.

## Gate C — new R02 runner

Create:
`tools/campaign/m17_canonical_confirmation_v07_r02.gd`

The runner must inherit the final committed R01 validation design and preserve:
- semantic class mapping validation;
- telemetry validation;
- legal action-log validation;
- exact candidate set;
- source representative/member/signature checks;
- exact 213 aggregate unique-seed check;
- VIP `0/25` forced and `25/25` surplus checks;
- five-trial classification semantics.

Use new output paths:
- `M17_CANONICAL_CONFIRMATION_V07_R02.json`
- `M17_CANONICAL_CONFIRMATION_V07_R02.md`

Use fresh seed namespace:
`17900000 + representative_level * 100 + trial_index`, trial_index 1..4.

## Gate D — commit-before-execution provenance

This is mandatory.

Before any direct R02 run:
1. parse-check the R02 runner;
2. commit and push the R02 runner;
3. synchronize;
4. prove the working tree is clean;
5. record the committed runner SHA-256 and Git blob/commit identity;
6. prove the bytes about to execute equal the committed runner bytes at current `HEAD`.

After this proof, **no runner edit is permitted before the direct run**.

The direct run must execute the exact committed runner.

## Gate E — fresh confirmation

Use the exact audited 42 V06-R02 confirmation candidates.

For each candidate:
- reuse the audited V06-R02 source trial as trial 1;
- run exactly four fresh post-V05 trials;
- `MERGE_AWARE_V01`;
- `Engine.time_scale = 1.0`;
- R02 seed namespace defined above.

Expected:
- 42 candidates;
- 168 new trials;
- 210 candidate aggregate trials;
- three carried-forward feasible source classes;
- 213 unique aggregate seeds across all 45 source trials + 168 fresh trials.

## Gate F — classification semantics

For each of the 42 candidates:
- >=1 completion / 5 => `SOLVER_FEASIBLE`
- 0 / 5 => `HIGH_RISK_SOLVER_FAILURE`

C02, C05, C10 remain carried-forward solver-feasible.

No valid candidate may remain `SCREENING_FAILURE_NEEDS_CONFIRMATION`.

Do not copy V07 or V07-R01 class counts. R02 must report only its own fresh evidence.

## Gate G — direct-run stop rule

Required direct result:
- report status `PASS`;
- exit code 0;
- no validation errors;
- runner-emitted PASS marker.

If the direct run fails:
- stop immediately;
- no repair-after-failure;
- no runner edits;
- no report repair;
- no regressions;
- publish truthful blocked log.

## Gate H — regressions after direct PASS only

After direct PASS, run:
1. R02 report/direct integrity;
2. V06 analytical probe;
3. V05 optionality;
4. M17 difficulty validation ×2;
5. M16;
6. M15;
7. M14;
8. M02;
9. `git diff --check`;
10. prove `TASKS.md` unchanged by CODEX;
11. prove canonical Sunny Cove data unchanged;
12. prove historical V07/V07-R01 evidence unchanged.

## Gate I — handoff

Create:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R02.md`

The log must contain:
- preflight;
- frozen hashes;
- R02 runner commit-before-execution proof;
- exact committed runner hash;
- parse and direct-run commands/exit codes;
- 42 candidates / 168 new trials / 42×5 evidence;
- 213 unique seed proof;
- final feasible/high-risk class lists;
- VIP 0/25 and 25/25;
- regression results;
- final HEAD/origin/remote equality;
- explicit statement that R01 historical evidence and TASKS were untouched.

Required final marker:
`AWAITING_M17_AUDIT_V07_R02`

M17 canonical tuning and M18 remain blocked until independent ChatGPT audit.
