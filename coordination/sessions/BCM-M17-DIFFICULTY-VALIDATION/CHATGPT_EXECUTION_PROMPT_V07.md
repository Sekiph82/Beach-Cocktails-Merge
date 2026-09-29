# BCM-M17 V07 Five-Trial Confirmation — CODEX Execution Prompt

Execute this task only after synchronizing the canonical Desktop repository:

`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`

## Required reading before any edit

Read in this order:

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V06_R02.md`
5. `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07.md`
6. `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V06_R02.json`
7. `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_SCREENING_V06_R02.md`
8. V05 optionality evidence and the current qualified `MERGE_AWARE_V01` harness.

The locked V07 audit criteria are authoritative. Do not relax or reinterpret them.

## Goal

Resolve the 42 V06-R02 `SCREENING_FAILURE_NEEDS_CONFIRMATION` classes to the already-defined exact-class five-trial threshold **without changing canonical level data**.

V06-R02 established one valid post-V05 canonical-scale trial per class.

For each of the 42 failed classes, reuse that audited V06-R02 trial as trial 1 and run **four additional fresh trials**. This produces exactly five post-V05 trials per confirmation candidate.

The three V06-R02 solver-feasible classes C02, C05 and C10 require no additional physical trials.

This is an evidence/confirmation task only. Do not tune levels in this task.

## Mandatory synchronization

From the canonical Desktop checkout:

```powershell
git status --short --branch
git remote -v
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
```

If clean and behind-only, fast-forward to current `origin/main`.

Never reset, stash, rebase, force-push, discard owner work, create another Desktop clone, or create a GitHub branch.

If synchronization is ambiguous or unsafe, stop and publish the exact blocker. Do not continue.

## Frozen scope

Do not edit:
- root `TASKS.md`;
- `data/campaign/levels/sunny_cove.json`;
- any canonical timer or normal objective;
- VIP target, quantity or reward data;
- V04/V05/V06/V06-R01/V06-R02 JSON/Markdown evidence;
- M15 HUD;
- score/economy/progression;
- table art or geometry;
- gameplay physics/colliders;
- M18 or later milestone implementation.

Do not modify historical V06-R02 evidence to make V07 pass.

Prefer a new evidence-only runner:
`tools/campaign/m17_canonical_confirmation_v07.gd`

Do not repurpose the historical V06-R02 runner unless absolutely necessary. If you discover that a prior file must change, stop and explain why rather than expanding scope silently.

## Exact candidate set

Derive it programmatically from V06-R02 and assert it equals exactly:

`C01,C03,C04,C06,C07,C08,C09,C11,C12,C13,C14,C15,C16,C17,C18,C19,C20,C21,C22,C23,C24,C25,C26,C27,C28,C29,C30,C31,C32,C33,C34,C35,C36,C37,C38,C39,C40,C41,C42,C43,C44,C45`

Expected count: **42**.

The three already feasible classes are:
- C02, representative L3;
- C05, representative L7;
- C10, representative L14.

Do not hand-author a replacement class map. Validate representatives/members against V06-R02.

## Trial acquisition contract

For each of the 42 candidates:

1. Load and validate the exact V06-R02 trial as aggregate trial 1.
2. Run exactly four new trials on that class representative.
3. Policy: `MERGE_AWARE_V01`.
4. Engine time scale: `1.0`.
5. Preserve the established flat telemetry and action-log schema.
6. Use distinct deterministic seeds in a new namespace that cannot collide with V06-R02.

Use this required seed scheme for the four new trials:

`17700000 + representative_level * 100 + new_trial_index`

where `new_trial_index` is exactly `1,2,3,4`.

This produces **168 new trials** total.

Do not count any pre-V05 V03A/V04 physical trial toward V07's five-trial threshold.

## Classification contract

After aggregating one V06-R02 trial plus four new V07 trials:

- completion count >= 1 of 5 => `SOLVER_FEASIBLE`
- completion count = 0 of 5 => `HIGH_RISK_SOLVER_FAILURE`

No 5-trial candidate may remain `SCREENING_FAILURE_NEEDS_CONFIRMATION`.

`HIGH_RISK_SOLVER_FAILURE` means high-risk solver evidence only. It is not proof of human impossibility.

Do not change timers or objectives based on the result. Tuning comes only after independent ChatGPT audit.

## VIP semantics

Preserve and re-check:
- post-V05 forced captures = `0/25`;
- post-V05 surplus paths = `25/25`;
- VIP cost is not added to normal timers.

A VIP semantics regression is a hard stop.

## Required outputs

Create new immutable evidence only:

- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_CANONICAL_CONFIRMATION_V07.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07.md`

The report must include all 100 levels and all 45 classes, not only the 42 candidates.

For each candidate class record:
- V06-R02 source trial provenance and seed;
- four V07 trial seeds;
- exact 5-trial aggregate;
- completion/danger/timeout/abort counts;
- telemetry summary;
- final flag.

Global report summary must include:
- 100 levels;
- 45 classes;
- 42 confirmation candidates;
- 168 new V07 trials;
- 3 carried-forward feasible classes;
- final count/list of `SOLVER_FEASIBLE`;
- final count/list of `HIGH_RISK_SOLVER_FAILURE`;
- forced `0/25`;
- surplus `25/25`;
- validation errors.

## Required integrity behavior

The V07 runner must return non-zero if any of these fail:
- V06-R02 source hash/schema validation;
- exact candidate set/count;
- representative/member mapping;
- policy or time scale;
- expected four new trials per candidate;
- expected 168 new-trial total;
- exactly five aggregate trials per candidate;
- telemetry validation;
- legal action log validation;
- duplicate seed detection;
- 100-level / 45-class final report shape;
- V05 forced/surplus semantics;
- report serialization/integrity.

There must be **no repair-after-failure runner**. If the direct required V07 runner fails, stop and publish a truthful blocked `CODEX_LOG_V07.md`. Do not patch the generated report after a failed required run and continue.

## Required regression sequence

Only after the direct V07 runner passes:

1. V07 runner parse check.
2. V07 direct confirmation run.
3. V06 analytical probe.
4. V05 optionality probe.
5. M17 difficulty validation run 1.
6. M17 difficulty validation run 2.
7. M16 Sunny Cove content probe.
8. M15 VIP/boosters/economy probe.
9. M14 GameplaySessionBridge probe.
10. M02 physics regression probe.
11. V07 JSON/Markdown independent shape/integrity inspection.
12. `git diff --check`.
13. Verify root `TASKS.md` diff is empty.
14. Verify canonical Sunny Cove data diff is empty.

If any required check fails, stop. Do not continue to a green final handoff.

## CODEX log requirements

`CODEX_LOG_V07.md` must record:

- prompt and criteria paths;
- start HEAD and final HEAD;
- branch and remote;
- sync preflight;
- files changed;
- V06-R02 source hash;
- canonical data hash;
- exact candidate list and representative map;
- exact commands;
- exact process exit codes;
- 168-new-trial proof;
- 42×5 aggregate proof;
- final classification counts and IDs;
- `0/25` forced and `25/25` surplus;
- regression results;
- `git diff --check`;
- confirmation that root `TASKS.md` was unchanged;
- confirmation that canonical data was unchanged;
- limitations;
- final local HEAD / `origin/main` / remote-main equality;
- commit SHA and GitHub URL.

Finish with exactly:

`AWAITING_M17_AUDIT_V07`

Then stop. Do not start canonical tuning and do not start M18.
