# BCM-M17 V07-R03-R02 Child 01 - Verbatim Regression Evidence Recapture

## Scope

Close only the missing V07-R03-R01 handoff evidence. Do not edit root `TASKS.md`, the V07-R03 runner, the V07-R03 JSON/Markdown report, canonical data, or historical evidence.

## Required work

1. Complete clean synchronized preflight and record protected-file hashes.
2. Confirm the existing V07-R03 direct PASS by read-only report/hash inspection; do not invoke the V07-R03 confirmation runner.
3. Run the locked sequence in order: report/hash inspection; V06 analytical; V05 optionality; M17 difficulty validation twice; M16; M15; M14; M02; then diff and freeze proofs.
4. For every command, place the exact command, verbatim complete captured stdout/stderr, required PASS marker, and exact exit code into both the child and master logs. Do not replace transcripts with one-line summaries or ellipses.
5. Both M17 runs must include `M17_DIFFICULTY_VALIDATION_RESULT=PASS` and exit `0`.
6. Record exact execution-time local/origin/remote equality in the child and master logs. Publish a terminal record containing final post-push equality, clean status, and the final handoff marker.

If any command fails or any transcript/marker/exit code is missing, stop without rerunning that failed command in the same child.

## Handoff

Write `CODEX_LOG_V07_R03_R02_CHILD_01.md` and `CODEX_LOG_V07_R03_R02.md`, preserve the earlier attempts, publish the terminal handoff record, and stop at `AWAITING_M17_AUDIT_V07_R03_R02`. No M17 tuning or M18 work is authorized.
