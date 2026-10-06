# BCM-M21-006-R04 — Publish Missing Final Release Evidence

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Branch:
`main`

## Mission

R03 product/test closure is substantially accepted.

Do NOT redo the project.

The only blocker is that the mandatory R03 command evidence was kept in ignored local `.log` files and was not published to GitHub.

This is an EVIDENCE-ONLY closure.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/CHATGPT_FINAL_RELEASE_AUDIT_R03.md`
4. `coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/CHATGPT_FINAL_RELEASE_EVIDENCE_CRITERIA_R04.md`
5. R03 builder log
6. R03 local evidence directory.

Root TASKS.md is READ-ONLY.

## 1. Safe sync

Use AGENTS safe-sync rules.

Do not delete:
- owner critique PNGs;
- historical stashes.

Do not reset/clean/rebase/force.

## 2. Freeze product

No production code changes.

No test assertion/tolerance changes.

No asset changes.

No campaign/economy/save semantic changes.

No M22.

## 3. Recover the R03 logs

Inspect:
`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/evidence/`

The builder log says many `.log` files exist locally, but `.gitignore` excludes `*.log`.

For every required run in the locked R04 criteria:

### If the original local log exists
Copy it byte-for-byte to:

`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/evidence/<same_meaningful_name>.txt`

Compute SHA-256 of:
- original .log;
- copied .txt.

They must match.

### If it no longer exists
Rerun only that exact required command and capture stdout/stderr plus exit code directly into a .txt file.

Do not manually rewrite test output.

## 4. M08 is a hard gate

Publish two consecutive M08 runs.

Each must visibly contain:
- PASS marker;
- EXIT=0 or equivalent explicit exit record;
- no access violation;
- no SCRIPT ERROR;
- no teardown ERROR.

If either fails now, STOP and report the actual failure. Do not hide it.

## 5. R09 V05 hard gate

Publish two consecutive V05 real-input passes with:
- mouse PASS;
- touch PASS;
- exit 0.

## 6. Publish all other required regression evidence

Publish committed text evidence for every item listed in the R04 criteria.

Use .txt so .gitignore does not swallow it.

## 7. Correct project.godot evidence metadata

R03 currently contains two different SHA-256 claims for canonical project.godot.

Calculate the current canonical tracked file hash.

Use that one exact value consistently in R04 evidence.

Do not alter project.godot if it is already clean.

## 8. Correct release SHA metadata

Create:
`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R04/evidence/release_manifest_r04.json`

Distinguish:
- frozen product baseline SHA;
- R03 implementation/evidence SHA `c2ef88d772c8a5ae38a99f9c1b24e92eb09af2fe`;
- R03 builder handoff SHA `7a00da5e5163e0e31e7e6a7ed621ce845413890d`;
- R04 evidence closure publication identity.

Keep:
- no export preset = no distributable;
- physical device/native install/signing = unverified.

## 9. Final repo evidence

Publish a final text file containing:
- git status;
- local HEAD;
- origin/main;
- remote main;
- ahead/behind;
- project.godot diff status;
- remaining untracked critique PNGs;
- stash list.

Do not silently drop historical stashes.

State whether any stash is required to reproduce the current working tree. Required answer should be NO if the working tree is already canonical.

## 10. Final log / push

Create:
`docs/codex-logs/CODEX_LOG_M21_FINAL_RELEASE_CLOSURE_R04.md`

Do not edit TASKS.md.

Push evidence-only changes to main.

Stop exactly:

`AWAITING_GPT_M21_FINAL_RELEASE_AUDIT_R04`

Do not start M22.
