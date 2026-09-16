# BCM-M04-M06-R01 — Single Execution Prompt for Strict Remediation Sequence

Status: **ISSUED**

## Goal

Execute the strict M04, M05 and M06 remediation sequence in **one Codex session**, while keeping each milestone's implementation scope, commit evidence and log separate.

This is one orchestration prompt, not one blended remediation. The required order is:

1. M04-R01
2. M05-R01
3. M06-R02
4. STOP for independent ChatGPT audits

Do **not** resume M07.

## Canonical repository/workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: 4.7.x

## Mandatory first step

Read and obey:

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- root `TASKS.md`

Then read **all** of these before editing anything:

### M04
- `coordination/sessions/BCM-M04-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

### M05
- `coordination/sessions/BCM-M05-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M05-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M05-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

### M06
- `coordination/sessions/BCM-M06-R02/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M06-R02/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M06-R02/CHATGPT_AUDIT_CRITERIA_V01.md`

Canonical owner visual truth:

`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

## Safe sync / M07 preservation

Run the normal AGENTS sync-first preflight before implementation.

M07 was previously issued before these re-audits. Therefore:

- Do not continue M07.
- Do not discard any existing owner/Codex local M07 work.
- If uncommitted M07 work is present locally, preserve it non-destructively in a clearly named safety branch/WIP commit before returning to clean `main` for remediation. Record exactly what you did.
- Never use `reset --hard`, force push, automatic rebase, destructive checkout, or silent stash.
- If the local state cannot be preserved safely, stop and write the exact blocker instead of destroying work.

## Execution phase 1 — M04-R01

Execute the M04 remediation prompt exactly.

Write only M04 execution evidence to:

`coordination/sessions/BCM-M04-R01/CODEX_LOG_V01.md`

Requirements:

- strengthen asset validation truthfulness;
- create retained M04 evidence/manifest/contact sheets;
- preserve owner source PNG bytes;
- no M05/M06 production change in the M04 commit;
- run required Godot/tool checks;
- `git diff --check`;
- verify `TASKS.md` untouched.

Then create a **separate bounded M04 remediation commit** and push it to `main`.

Do not self-audit. Continue to phase 2 only because this master orchestration prompt explicitly sequences the remediation work. M04 still remains `AWAITING_AUDIT` until ChatGPT reviews it.

## Execution phase 2 — M05-R01

Using the now-remediated M04 evidence as input, execute the M05 remediation prompt exactly.

Write only M05 execution evidence to:

`coordination/sessions/BCM-M05-R01/CODEX_LOG_V01.md`

Requirements:

- repair body-measurement provenance;
- create actual runtime collider/pivot/clean/contact evidence for L01-L12;
- review scale/offset/radius against evidence;
- change production values only where evidence requires;
- preserve gameplay/economy contracts;
- rerun M01-M03 plus strengthened M05 checks;
- keep environment/HUD work out of the M05 commit;
- verify `TASKS.md` untouched.

Then create a **separate bounded M05 remediation commit** and push it to `main`.

Do not self-audit. Continue to phase 3 only because this master orchestration prompt explicitly sequences the remediation work.

## Execution phase 3 — M06-R02

Using the remediated M04/M05 state, execute the M06 remediation prompt exactly.

Write only M06 execution evidence to:

`coordination/sessions/BCM-M06-R02/CODEX_LOG_V01.md`

Requirements:

- treat the owner master as canonical environment/table composition truth;
- fix the rejected M06 visual composition;
- re-evaluate canonical aspect/design-space assumptions;
- create master/background/runtime landmark evidence and clean+overlay captures;
- replace circular geometry tests with independent expected-reference comparisons;
- preserve M01-M05 gameplay/economy/sprite contracts;
- do not implement M07 HUD;
- verify `TASKS.md` untouched.

Then create a **separate bounded M06 remediation commit** and push it to `main`.

## Required final verification

After all three commits:

```powershell
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
git rev-list --left-right --count HEAD...origin/main
git status --short --branch
git diff --check
git diff -- TASKS.md
```

The final local/remote main state must be synchronized and clean except for any explicitly documented safe local preservation branch unrelated to `main`.

## Absolute governance

- Codex must not edit `TASKS.md`.
- Codex must not edit any `CHATGPT_REAUDIT`, `CHATGPT_REMEDIATION_PROMPT`, `CHATGPT_AUDIT_CRITERIA`, audit-policy or ChatGPT audit file.
- Codex logs are builder evidence only.
- Codex must not assign `AUDITED_PASS` to M04, M05 or M06.
- Do not start/resume M07, M08 or later work.
- Do not add guide line.
- Do not redesign owner source art to make tests pass.

## Completion response

After all three remediation commits are pushed, return only:

- M04-R01 log URL + commit SHA + `AWAITING_AUDIT`;
- M05-R01 log URL + commit SHA + `AWAITING_AUDIT`;
- M06-R02 log URL + commit SHA + `AWAITING_AUDIT`;
- final synchronized `main` SHA;
- confirmation `TASKS.md` untouched;
- confirmation M07+ not resumed.

Then STOP.
