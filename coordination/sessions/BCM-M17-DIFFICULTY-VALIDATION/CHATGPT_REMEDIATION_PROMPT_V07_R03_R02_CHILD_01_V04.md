# BCM-M17 V07-R03-R02-V04 Child 01 - Capture-Compatible Regression Evidence

## Scope

Close only the missing V07-R03-R02 evidence handoff. Do not edit root `TASKS.md`, the V07-R03 runner, V07-R03 JSON/Markdown, canonical data, or historical evidence. Attempts 01, 02, and V03 remain immutable.

## Required work

1. Complete clean synchronized preflight and record protected-file hashes, including the actual Sunny Cove hash from the master criteria.
2. Confirm the existing V07-R03 direct PASS by read-only report/hash inspection; do not invoke its confirmation runner.
3. Run one bounded wrapper compatibility smoke check against a harmless local command. Capture complete stdout/stderr and its native exit code, prove that the wrapper waits for completion, and prove that no repository file changed.
4. Only after the smoke check passes, run exactly once and in order: V06 analytical probe; V05 optionality probe; M17 difficulty-validation probe twice; M16; M15; M14; M02; then diff/freeze/equality proofs.
5. Use a runtime-compatible capture path that does not call `ProcessStartInfo.ArgumentList`. For every command, record the exact command line, complete verbatim stdout/stderr without ellipses, required PASS marker, and exact native exit code in both logs.
6. Both M17 runs must include `M17_DIFFICULTY_VALIDATION_RESULT=PASS` and exit `0`. A partial stream, missing marker, missing exit code, or wrapper failure is a stop condition; do not rerun that command in this child.
7. Record execution-time and final post-push local/origin/remote equality, clean status, and `git diff --check` in the child and master logs, then publish the terminal record.

## Handoff

Write `CODEX_LOG_V07_R03_R02_CHILD_01_V04.md` and `CODEX_LOG_V07_R03_R02_V04.md`, preserve the earlier attempts, and stop with:

`AWAITING_M17_AUDIT_V07_R03_R02`

No M17 tuning or M18 work is authorized.
