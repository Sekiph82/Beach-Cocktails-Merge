# BCM-M03 — L6/L7 To-Go Reward Values Remediation V01

## Purpose

Close the only remaining M03 acceptance blocker by applying the owner-approved To-Go reward values for L6 and L7, rerunning the M03 economy regression suite, preserving all accepted M01/M02/M03 behavior, and stopping for independent ChatGPT re-audit.

Owner-approved values:

- L6 To-Go reward = `1000`
- L7 To-Go reward = `1800`
- L8 remains `3000`
- L9 remains `5000`
- L10 remains `8000`
- L11 remains `12000`
- L12 remains `18000`

These values are now authoritative for M03. Do not invent alternatives.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: `4.7.x`

## Mandatory governance

Before making changes, read and obey:

- `AGENTS.md`
- root `TASKS.md`
- `docs/audits/BCM-M03_MILESTONE_COMPLETION_V01_AUDIT.md`
- `docs/codex-logs/BCM-M03_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- this prompt

Codex must not edit `TASKS.md`.
Codex must not start M04 or any V7 visual integration work.
Codex must not alter accepted physics, launch, merge, combo percentages, scoring values, target range, target sequencing, persistence rules, danger-line timing, or Game Over/restart behavior except where strictly required to apply and verify the two reward values above.

## Sync-first preflight

Run and retain exact output in the remediation log:

```powershell
git status --short --branch
git remote -v
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git rev-list --left-right --count HEAD...origin/main
```

Safely reconcile remote governance/audit commits while preserving local owner work. Never use destructive reset, force-push, automatic rebase, destructive checkout, or silent stash.

## Required implementation

1. Update the canonical production data source so To-Go rewards are exactly:
   - L6 = 1000
   - L7 = 1800
   - L8 = 3000
   - L9 = 5000
   - L10 = 8000
   - L11 = 12000
   - L12 = 18000
2. Do not change merge scores.
3. Do not change combo rules.
4. Do not change To-Go target range or sequence logic.
5. Do not change L12 behavior.
6. Update deterministic M03 test expectations to assert the complete approved reward table.
7. Verify both newly created matching drinks and stored matching drinks receive the correct reward exactly once for L6 and L7 as well as the already-approved L8-L12 levels.
8. Verify stored-drink delivery still awards only the To-Go reward and does not duplicate merge score or combo bonus.
9. Rerun M01, M02, and M03 regression probes after the change.
10. Run Godot import/parse and configured main-scene startup smoke checks.

## Evidence-first logging

Create one immutable remediation log:

`docs/codex-logs/BCM-M03_REWARD_VALUES_REMEDIATION_V01_CODEX_LOG.md`

The log must contain exact retained evidence, including:

- sync-first Git outputs;
- exact production data diff for L6/L7 reward changes;
- complete final To-Go reward table;
- M03 regression output proving L6=1000 and L7=1800;
- immediate-order and stored-order payout evidence;
- no duplicate score/combo evidence;
- M01 regression result;
- M02 regression result;
- M03 regression result;
- Godot version/import/startup outputs and exit codes;
- files changed;
- `git diff --check` result;
- explicit confirmation that `TASKS.md` was not edited;
- explicit confirmation that M04/V7 integration was not started.

The owner must not be asked to copy terminal output between Codex and ChatGPT. Put retained evidence in the committed log.

## Completion procedure

1. Inspect the full diff and status.
2. Ensure scope is limited to the approved L6/L7 reward implementation, deterministic test expectation updates if required, and the remediation log.
3. Run all M01/M02/M03 probes.
4. Run Godot import/parse/main-scene smoke checks.
5. Commit and push all intended changes to `main`.
6. Fetch `origin/main` again.
7. Confirm no intended work remains uncommitted.
8. Do not edit `TASKS.md`.
9. Do not start M04/V7 integration.
10. STOP for independent ChatGPT re-audit.

## Completion response

Return only:

- remediation log GitHub URL;
- pushed commit SHA;
- one-line regression result or exact blocker;
- confirmation that `TASKS.md` was not edited;
- confirmation that M04/V7 integration was not started.

All detailed evidence must already be inside the committed remediation log.
