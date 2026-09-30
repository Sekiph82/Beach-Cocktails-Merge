# CODEX Execution Log - BCM-M17 V07-R03-R02

Status: `TEMPLATE - AWAITING CODEX`

This is the immutable master execution-record template for the complete authorized single-child evidence-handoff remediation. CODEX must not edit root `TASKS.md` or the locked ChatGPT prompt/criteria.

## Contract

- Work item: `BCM-M17-008` V07-R03-R02 complete-stdout evidence-handoff remediation.
- Master prompt: `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02.md`.
- Master criteria: `CHATGPT_AUDIT_CRITERIA_V07_R03_R02.md`.
- Ordered child: `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01.md`.
- Required final marker: `AWAITING_M17_AUDIT_V07_R03_R02`.

## Required evidence to populate

- Exact preflight, start/end HEAD, branch, remote, fetch, divergence, protected hashes, and final local/origin/remote equality.
- Read-only confirmation that the V07-R03 direct PASS/report/hashes were preserved and the runner was not rerun.
- The locked regression commands in order, each with exact command, verbatim complete stdout/stderr transcript, required marker, and exact exit code.
- `git diff --check`, clean-tree proof, `TASKS.md` freeze proof, scope limits, limitations, and final handoff marker.

## Ordered-child record

Child 01: **AWAITING CODEX**. Do not populate this template with acceptance claims; record builder evidence only.

## Final repository state

To be populated by CODEX with the execution-time state and terminal publication record. No production/canonical/tracker files may be changed.

## Final marker

`AWAITING_M17_AUDIT_V07_R03_R02`
