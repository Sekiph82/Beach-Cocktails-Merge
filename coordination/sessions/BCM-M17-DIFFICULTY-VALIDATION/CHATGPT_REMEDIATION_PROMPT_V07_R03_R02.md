# BCM-M17-008 - V07-R03-R02 Complete-Stdout Evidence-Handoff Remediation Master Prompt

This package remediates only the incomplete V07-R03-R01 evidence handoff identified in `CHATGPT_AUDIT_V07_R03_R01.md`. The V07-R03 runner/report and all prior evidence remain immutable PASS or historical evidence.

## Required reading

- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_V07_R03_R01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CODEX_LOG_V07_R03_R02.md`

## Exact ordered package

This remediation has exactly one ordered child:

1. `CHATGPT_REMEDIATION_PROMPT_V07_R03_R02_CHILD_01.md` / `CHATGPT_AUDIT_CRITERIA_V07_R03_R02_CHILD_01.md` / `CODEX_LOG_V07_R03_R02_CHILD_01.md` — complete regression stdout recapture and equality proof.

There is no later child. A missing transcript, marker, exit code, equality value, or final marker blocks the batch.

## Synchronization and preservation rules

- Work only in `C:\Users\sekip\Desktop\Beach Cocktails - Merge` on `main`.
- Run the required status/remote/fetch/divergence preflight and require a clean synchronized checkout before acting.
- Do not reset, clean, stash, rebase, force-push, overwrite owner work, or edit root `TASKS.md`.
- Preserve the V07-R03 runner, V07-R03 JSON/Markdown, V07-R03-R01 V01/V02 logs, V07-R02/V07-R01/V06-R02/V05 evidence, and canonical Sunny Cove data byte-for-byte.
- Do not rerun the V07-R03 confirmation runner, repair its report, or change production/canonical data.

## Evidence-only scope

1. Inspect the existing committed V07-R03 report and hashes read-only; do not rewrite the report.
2. Run the locked regression sequence in its exact order: V06 analytical probe; V05 optionality probe; M17 difficulty-validation probe twice; M16; M15; M14; M02; then diff/freeze/equality proofs.
3. For every command, record in the child and master V07-R03-R02 logs the exact command, verbatim complete captured stdout/stderr transcript without ellipses or summary substitution, the required PASS marker, and the exact process exit code.
4. Both M17 difficulty-validation runs must show `M17_DIFFICULTY_VALIDATION_RESULT=PASS` and exit `0`.
5. Record exact execution-time local/origin/remote equality in the child and master logs. After publication, add a terminal handoff record with the final pushed SHA equality and clean-tree proof.

If any command fails or a required marker/transcript/exit code is absent, stop immediately. Do not rerun a failed evidence command in the same child.

## Handoff

Complete the child and master V07-R03-R02 logs, publish the terminal post-push equality record, preserve the V01/V02 attempts, and end with:

`AWAITING_M17_AUDIT_V07_R03_R02`

Stop. Do not tune M17 canonical data and do not start M18.
