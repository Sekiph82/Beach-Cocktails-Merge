# BCM-M03 — L6/L7 To-Go Reward Remediation V01

## Purpose

Close the only remaining M03 acceptance gap after the CONDITIONAL M03 audit by implementing the owner-approved To-Go rewards for L6 and L7, updating regression expectations/documentation, rerunning all relevant deterministic tests, and stopping for independent ChatGPT re-audit.

Owner-approved values:

- L6 To-Go reward = `1000`
- L7 To-Go reward = `1800`

These values are final for this remediation unless the owner explicitly changes them later.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target/runtime: `4.7.x`

## Mandatory governance

Read and obey before changing anything:

- `AGENTS.md`
- root `TASKS.md`
- `docs/audits/BCM-M03_MILESTONE_COMPLETION_V01_AUDIT.md`
- `docs/codex-logs/BCM-M03_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- `docs/prompts/BCM-M03_MILESTONE_COMPLETION_V01_PROMPT.md`
- this remediation prompt

Codex must not edit `TASKS.md`.
Codex must not self-approve M03.
Codex must not start M04 or any V7 visual integration work.

## Sync-first preflight

From the canonical local root, run and log exact outputs:

```powershell
git status --short --branch
git remote -v
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git rev-list --left-right --count HEAD...origin/main
```

Preserve owner-local work. Never use destructive reset, force-push, automatic rebase, destructive checkout, or silent stash.

## Required bounded remediation

1. Update `data/drinks.json` so the canonical To-Go reward values are exactly:
   - L6 = `1000`
   - L7 = `1800`
   - L8 = `3000`
   - L9 = `5000`
   - L10 = `8000`
   - L11 = `12000`
   - L12 = `18000`

2. Update any documentation that still omits or contradicts these now-approved L6/L7 values. At minimum inspect `README.txt` and make the To-Go reward table complete and accurate if needed.

3. Update `tests/m03_economy_regression.gd` so it treats L6=1000 and L7=1800 as required final values rather than an unresolved owner decision.

4. Add explicit deterministic runtime evidence that:
   - L6 order completion awards exactly 1000;
   - L7 order completion awards exactly 1800;
   - stored L6/L7 delivery awards only the current To-Go reward and never re-awards merge score or historical combo;
   - all existing L8-L12 reward behavior remains unchanged;
   - duplicate delivery cannot double-pay;
   - target selection remains L6-L12 with immediate-repeat avoidance.

5. Do not change merge-score values, combo percentages/window, physics, launch behavior, target range, target sequencing, persistence model, danger-line timing, visuals, V7 assets, UI composition, or animation timings except if a direct regression prevents the approved reward values from functioning. Any such blocker must be documented and kept minimal.

## Regression requirements

Run with isolated APPDATA/user data where relevant and retain exact outputs in the Codex log:

- Godot version;
- import/parse;
- configured main-scene startup;
- `tests/m01_contract_probe.gd`;
- `tests/m02_physics_regression.gd`;
- updated `tests/m03_economy_regression.gd`.

All must PASS before completion.

The final M03 probe must print the complete final reward table and must no longer print `OWNER DECISION REQUIRED` for L6/L7.

## Evidence-first logging

Create one immutable remediation log:

`docs/codex-logs/BCM-M03_REWARD_REMEDIATION_V01_CODEX_LOG.md`

The log must contain exact retained evidence, including:

- sync-first Git outputs;
- before/after L6/L7 reward values;
- files changed;
- exact final reward table;
- direct L6 and L7 fulfillment outputs;
- stored-delivery/no-double-score evidence;
- M01/M02/M03 regression outputs and exit codes;
- Godot import/parse/startup outputs and exit codes;
- `git diff --check`;
- confirmation `TASKS.md` was not edited;
- confirmation M04/V7 integration was not started.

Do not ask the owner to relay terminal outputs. Put retained evidence in the committed log.

## Completion procedure

1. Inspect full diff/status.
2. Ensure changes are limited to the approved reward remediation, tests/documentation, and the remediation log.
3. Run all required validations.
4. Commit and push to `origin/main`.
5. Fetch `origin/main` again and confirm no intended work remains uncommitted.
6. Do not edit `TASKS.md`.
7. Do not start M04 or V7 integration.
8. STOP for independent ChatGPT re-audit.

## Completion response

Return only:

- remediation log GitHub URL;
- pushed commit SHA;
- one-line statement that M01/M02/M03 regressions PASS or the exact blocker;
- confirmation that `TASKS.md` was not edited;
- confirmation that M04/V7 integration was not started.
