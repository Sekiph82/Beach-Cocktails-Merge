# BCM-M17-008 — V07-R02 Exact-Committed-Runner Remediation + Fresh Confirmation

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `CHATGPT_AUDIT_V07_R01.md`
5. `CHATGPT_AUDIT_CRITERIA_V07_R02.md`
6. `CODEX_LOG_V07_R01_CHILD_01.md`
7. `CODEX_LOG_V07_R01_CHILD_02.md`
8. final committed `m17_canonical_confirmation_v07_r01.gd`
9. audited V06-R02 source evidence.

The locked V07-R02 criteria are authoritative.

## Purpose

V07-R01 produced 168 fresh trials and 213 unique aggregate seeds but failed integrity. The committed failed report contains 168 `duplicate aggregate seed ...` errors that cannot be emitted by the final committed R01 runner. R02 therefore closes both the seed-validation problem and the runner/report provenance gap.

Do not tune gameplay or canonical level data.

## Step 1 — preflight

Require:
- clean `main`;
- `HEAD == origin/main == remote main`;
- no untracked/ambiguous owner files;
- canonical Sunny Cove/V05/V06-R02/V07/V07-R01 evidence unchanged.

Do not edit root `TASKS.md`.

## Step 2 — preserve R01 historical evidence

Do not modify:
- `tools/campaign/m17_canonical_confirmation_v07_r01.gd`
- `M17_CANONICAL_CONFIRMATION_V07_R01.json`
- `M17_CANONICAL_CONFIRMATION_V07_R01.md`
- any V07-R01 logs.

## Step 3 — create R02 runner

Create:
`tools/campaign/m17_canonical_confirmation_v07_r02.gd`

Base it on the final committed R01 runner design.

Use:
- report version `V07-R02`;
- R02 JSON/Markdown output paths;
- fresh seed base `17900000`;
- seed formula `17900000 + representative_level * 100 + trial_index`, trial_index 1..4.

Preserve all strict validation gates. Do not weaken duplicate detection.

## Step 4 — mandatory commit-before-run gate

This step is non-negotiable.

1. Parse-check the new R02 runner.
2. Commit and push the R02 runner **before any direct confirmation run**.
3. Fetch/synchronize.
4. Require clean working tree.
5. Record runner SHA-256 and commit identity.
6. Prove local runner bytes equal the runner bytes at current committed `HEAD`.
7. From this point until direct-run completion, do not edit the runner.

If this proof cannot be established, stop.

## Step 5 — direct fresh R02 run

Execute the exact committed runner.

Required evidence:
- 42 V06-R02 confirmation candidates;
- audited V06-R02 trial as trial 1;
- four fresh R02 trials per candidate;
- 168 new trials;
- 42×5 candidate aggregates;
- 213 unique aggregate seeds total;
- `MERGE_AWARE_V01`;
- `Engine.time_scale=1.0`;
- VIP forced `0/25`;
- VIP surplus `25/25`.

Classification:
- >=1 completion/5 = `SOLVER_FEASIBLE`
- 0/5 = `HIGH_RISK_SOLVER_FAILURE`

Do not inherit the V07 or V07-R01 class counts. Report fresh R02 results only.

## Step 6 — strict stop rule

The exact committed R02 runner must produce PASS / exit 0.

If it fails:
- stop immediately;
- do not edit the runner;
- do not rerun after a repair;
- do not repair reports;
- do not run regressions;
- publish truthful `CODEX_LOG_V07_R02.md` with the failure.

## Step 7 — regressions only after direct PASS

Run:
1. R02 direct/report integrity;
2. V06 analytical;
3. V05 optionality;
4. M17 validation ×2;
5. M16;
6. M15;
7. M14;
8. M02;
9. `git diff --check`;
10. frozen `TASKS.md` proof;
11. frozen canonical Sunny Cove proof;
12. frozen V07/V07-R01 historical evidence proof.

## Frozen scope

No changes to:
- root `TASKS.md`;
- Sunny Cove timers/objectives/content;
- VIP content/rewards;
- gameplay/HUD/physics/colliders;
- score/economy/progression;
- historical V07/V07-R01 evidence;
- M18+.

## Handoff

Create:
`coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R02.md`

Include exact preflight, runner pre-run commit/hash proof, commands/exit codes, trial/seed counts, classification lists, VIP results, regressions and final synchronization.

Finish with exactly:

`AWAITING_M17_AUDIT_V07_R02`

Then stop. No canonical tuning and no M18.
