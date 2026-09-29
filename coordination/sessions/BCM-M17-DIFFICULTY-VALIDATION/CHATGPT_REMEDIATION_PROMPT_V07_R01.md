# BCM-M17-008 — V07-R01 Integrity Remediation + Fresh Five-Trial Confirmation

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `OWNER_RULING_V07_SYNC_BLOCKER.md`
5. `CHATGPT_AUDIT_V07.md`
6. `CODEX_LOG_V07.md`
7. `CHATGPT_AUDIT_CRITERIA_V07_R01.md`
8. audited V06-R02 report/evidence.

The locked V07-R01 criteria are authoritative.

## Exact ordered child batch

Execute the complete remediation batch in this order. A later child is not
accepted when an earlier child fails or is unverified:

1. `CHATGPT_REMEDIATION_PROMPT_V07_R01_CHILD_01.md` - authorized blocker
   deletion, synchronized preflight, source integrity, and frozen-scope proof;
   handoff `CODEX_LOG_V07_R01_CHILD_01.md`.
2. `CHATGPT_REMEDIATION_PROMPT_V07_R01_CHILD_02.md` - bounded runner fixes,
   fresh 42-class confirmation, and report production; handoff
   `CODEX_LOG_V07_R01_CHILD_02.md`.
3. `CHATGPT_REMEDIATION_PROMPT_V07_R01_CHILD_03.md` - required regressions,
   report inspection, and publication; handoff
   `CODEX_LOG_V07_R01_CHILD_03.md` plus the master
   `CODEX_LOG_V07_R01.md`.

The matching locked child criteria are
`CHATGPT_AUDIT_CRITERIA_V07_R01_CHILD_01.md`,
`CHATGPT_AUDIT_CRITERIA_V07_R01_CHILD_02.md`, and
`CHATGPT_AUDIT_CRITERIA_V07_R01_CHILD_03.md`. The child logs and master log
are builder evidence only. Stop at the first failed or unverified child.

## Step 1 — clear only the owner-approved local blocker

The owner explicitly authorizes deletion of exactly:

`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_ATTEMPT_20260929_SYNC_BLOCKED.md`

Delete only that exact untracked file.

Do not use `git clean`, reset, stash, rebase, force operations, destructive checkout, or delete/move any other local material.

Then run the mandatory sync preflight and require clean synchronized `main` with divergence `0 0`. If anything else is dirty/ambiguous, stop and log it.

## Step 2 — fix only the two V07 runner integrity defects

Do not mutate the historical failed V07 runner/report/log evidence.

Create a new:
`tools/campaign/m17_canonical_confirmation_v07_r01.gd`

Fix only:

1. **Mapping validation:** compare JSON-loaded Variant arrays/dictionaries to canonical generated mappings semantically/canonically. Do not use incompatible direct typed equality that falsely rejects equivalent data.

2. **Seed registry:** every imported V06-R02 source seed must be registered, including the first source seed. Then register each fresh V07-R01 seed and reject duplicates. Expected aggregate unique seeds: **213**.

Do not weaken any telemetry, action-log, candidate-set, representative/member, policy, time-scale, VIP, count, or report-integrity checks.

## Step 3 — fresh V07-R01 confirmation run

Do not promote the failed V07 report to PASS.

Create new immutable outputs:

- `M17_CANONICAL_CONFIRMATION_V07_R01.json`
- `M17_CANONICAL_CONFIRMATION_V07_R01.md`

Use:
- exact same 42 V06-R02 confirmation candidates;
- audited V06-R02 source trial as trial 1 for each candidate;
- four **fresh** trials per candidate;
- `MERGE_AWARE_V01`;
- `Engine.time_scale = 1.0`;
- seed formula: `17800000 + representative_level * 100 + trial_index`, trial_index 1..4.

Expected:
- 42 candidates;
- 168 new trials;
- 42×5 aggregate;
- 3 carried-forward feasible classes;
- 213 unique aggregate seeds;
- VIP forced `0/25`;
- VIP surplus `25/25`.

Classification:
- >=1 completion / 5 => `SOLVER_FEASIBLE`
- 0 / 5 => `HIGH_RISK_SOLVER_FAILURE`

Do not assume or copy the failed V07 observed 16/29 split. V07-R01 must report only its own fresh evidence.

## Step 4 — stop rule

The direct V07-R01 runner must itself return PASS / exit 0.

If it returns non-zero or any required integrity condition fails:
- stop immediately;
- do not repair the generated report;
- do not run regressions;
- publish a truthful blocked `CODEX_LOG_V07_R01.md`.

## Step 5 — regressions only after direct PASS

Run:
1. V07-R01 parse/direct run;
2. V06 analytical probe;
3. V05 optionality;
4. M17 difficulty validation ×2;
5. M16;
6. M15;
7. M14;
8. M02;
9. V07-R01 report integrity inspection;
10. `git diff --check`;
11. prove root `TASKS.md` unchanged;
12. prove canonical Sunny Cove data unchanged.

## Frozen scope

Do not change:
- root `TASKS.md`;
- canonical Sunny Cove levels;
- timers/objectives;
- VIP targets/quantities/rewards;
- V04/V05/V06/V06-R01/V06-R02/V07 historical evidence;
- gameplay/HUD/physics/colliders;
- score/economy/progression;
- M18+.

## Required log and handoff

Create:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R01.md`

Use the pre-published master log template and link all three ordered child logs.

Include exact sync/deletion proof, changed files, commands/results, hashes, 168-new-trial proof, 42×5 proof, **213 unique seeds**, final class lists/counts, VIP `0/25` + `25/25`, regressions, final HEAD/origin/remote equality, and confirmation that `TASKS.md` was untouched.

Finish with exactly:

`AWAITING_M17_AUDIT_V07_R01`

Then stop. Do not tune canonical levels and do not start M18.
