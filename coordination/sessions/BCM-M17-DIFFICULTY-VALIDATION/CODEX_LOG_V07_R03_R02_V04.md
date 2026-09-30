# CODEX Execution Log - BCM-M17 V07-R03-R02-V04

Status: `TEMPLATE - NOT EXECUTED`

This is the required immutable master-log template for the authorized single-child V04 evidence retry. CODEX must complete it in a new publication only after executing the locked package; this template is not acceptance evidence.

## Contract

- Work item: `BCM-M17-008` V07-R03-R02-V04 capture-compatible evidence-handoff remediation.
- Master prompt: `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_V04.md`.
- Master criteria: `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_V04.md`.
- Exact ordered package: exactly one child, Child 01; there is no later child.
- Child prompt/criteria: `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01_V04.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01_V04.md`.
- Required completed-batch marker: `AWAITING_M17_AUDIT_V07_R03_R02`.

## Required record sections

CODEX must replace this template with a truthful immutable execution record containing:

1. checkout, branch, remote, and required sync preflight;
2. start and execution-time equality values;
3. protected hashes and read-only V07-R03 PASS inspection;
4. compatibility smoke command, complete stdout/stderr, exact native exit code, and proof of no repository-file changes;
5. each locked regression in exact order with exact command, complete verbatim stdout/stderr, required PASS marker, and exact native exit code;
6. exact Sunny Cove SHA-256 and freeze/protected-file checks;
7. final post-publication equality, clean status, and `git diff --check`;
8. files changed, limitations, explicit `TASKS.md` immutability, evidence URLs, and the final marker.

## Hard boundaries

- Do not rerun or repair the V07-R03 confirmation runner/report.
- Do not edit canonical Sunny Cove data, root `TASKS.md`, or historical attempts.
- Stop immediately on any failed or incomplete capture; do not rerun that command in this child.
- Do not tune M17 or start M18.

Final marker required for a completed batch: `AWAITING_M17_AUDIT_V07_R03_R02`.
