# BCM-M04-M07-R01 — Single Execution Prompt for Strict Remediation Sequence

Status: **ISSUED**

## Goal

Execute all currently required visual-integration remediations in **one Codex session**, while preserving separate scope, commits and logs for each milestone.

Required order:

1. M04-R01
2. M05-R01
3. M06-R02
4. M07-R01
5. STOP for independent ChatGPT audits

This is one orchestration work order, not one blended implementation.

## Canonical repository/workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: 4.7.x

Canonical owner visual truth:
`/b75ee426-9568-4ed6-b35e-140600a7c995.png`

Explicit later owner override: no dotted/persistent guide line.

## Mandatory first step

Read and obey:

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- root `TASKS.md`

Then read **all** re-audits, remediation prompts and locked criteria before editing:

### M04-R01
- `coordination/sessions/BCM-M04-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M04-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

### M05-R01
- `coordination/sessions/BCM-M05-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M05-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M05-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

### M06-R02
- `coordination/sessions/BCM-M06-R02/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M06-R02/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M06-R02/CHATGPT_AUDIT_CRITERIA_V01.md`

### M07-R01
- `coordination/sessions/BCM-M07-R01/CHATGPT_REAUDIT_V01.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_REMEDIATION_PROMPT_V01.md`
- `coordination/sessions/BCM-M07-R01/CHATGPT_AUDIT_CRITERIA_V01.md`

## Sync and preservation

Run the normal AGENTS sync-first preflight.

Preserve all owner work and the existing M07 implementation. Do not discard it; remediate it in phase 4 after the lower-layer fixes are complete.

Never use `reset --hard`, force push, automatic rebase, destructive checkout, or silent stash.

If local/remote state cannot be preserved safely, stop and log the exact blocker instead of destroying work.

## Phase 1 — M04-R01

Execute the M04 remediation prompt exactly.

Write only M04 evidence to:
`coordination/sessions/BCM-M04-R01/CODEX_LOG_V01.md`

Create one separate bounded M04 remediation commit and push it to `main`.

Key outcome: truthful machine validation + retained independently inspectable asset evidence/manifest/contact sheets, without changing owner source PNG bytes merely to satisfy tests.

Do not self-audit. Continue because this orchestration prompt explicitly sequences the work.

## Phase 2 — M05-R01

Execute the M05 remediation prompt exactly using the remediated M04 evidence.

Write only M05 evidence to:
`coordination/sessions/BCM-M05-R01/CODEX_LOG_V01.md`

Create one separate bounded M05 remediation commit and push it to `main`.

Key outcome: evidence-backed L01-L12 body/pivot/collider mapping plus runtime overlay/contact evidence. Change production scale/offset/radius only where evidence requires. Preserve gameplay/economy contracts.

Do not self-audit. Continue because this orchestration prompt explicitly sequences the work.

## Phase 3 — M06-R02

Execute the M06 remediation prompt exactly using the repaired M04/M05 state.

Write only M06 evidence to:
`coordination/sessions/BCM-M06-R02/CODEX_LOG_V01.md`

Create one separate bounded M06 remediation commit and push it to `main`.

Key outcome: repair the owner-rejected environment/table composition; use owner-master-derived reference/landmark evidence and stronger non-circular geometry validation; retain clean and annotated runtime captures for all required viewport cases.

Do not self-audit. Continue because this orchestration prompt explicitly sequences the work.

## Phase 4 — M07-R01

Execute the M07 remediation prompt exactly on top of the corrected M06 base.

Write only M07 evidence to:
`coordination/sessions/BCM-M07-R01/CODEX_LOG_V01.md`

Create one separate bounded M07 remediation commit and push it to `main`.

Key outcome: reconcile the existing dynamic HUD with corrected M06 composition, retain live production data/shared texture mapping, strengthen layout/slot-fit validation, and generate independently inspectable master-vs-runtime visual evidence for 720x1280, 720x1440 and 800x1280.

Do not start M08 or later work.

## Required regressions

At the appropriate phases and again after final M07 remediation, run the required milestone probes plus:

- M01 gameplay contract
- M02 physics/collision
- M03 economy/To-Go/persistence
- strengthened M04 validation
- strengthened M05 integration validation
- strengthened M06 environment/geometry validation
- strengthened M07 HUD validation
- Godot 4.7.x import/parse
- configured main-scene startup
- `git diff --check`

Do not weaken old tests merely to make new implementation pass. Record any changed test assertion and why it remains stricter/equivalent.

## Absolute governance

- Codex must never edit root `TASKS.md`.
- Codex must never edit any ChatGPT-owned `CHATGPT_REAUDIT`, `CHATGPT_REMEDIATION_PROMPT`, `CHATGPT_AUDIT_CRITERIA`, audit-policy or ChatGPT audit file.
- Codex logs are builder evidence only.
- Codex must not assign `AUDITED_PASS`.
- No M08+ implementation.
- No guide line.
- No destructive editing of owner source PNGs to make tests pass.
- Do not rewrite immutable historical logs; corrections belong in the new remediation logs.

## Final verification

After all four commits:

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

Final local/origin/remote `main` must match.

## Completion response

Return only:

- M04-R01 log URL + remediation commit SHA + `AWAITING_AUDIT`;
- M05-R01 log URL + remediation commit SHA + `AWAITING_AUDIT`;
- M06-R02 log URL + remediation commit SHA + `AWAITING_AUDIT`;
- M07-R01 log URL + remediation commit SHA + `AWAITING_AUDIT`;
- final synchronized `main` SHA;
- confirmation `TASKS.md` untouched;
- confirmation ChatGPT-owned coordination files untouched;
- confirmation M08+ not started.

Then STOP.
