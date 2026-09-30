# BCM-M17 V07-R03-R02-V04 Child 01 - Locked Audit Criteria

Child 01 passes only if all of the following are independently verified:

- clean synchronized canonical `main`, with `TASKS.md`, canonical Sunny Cove data, V07-R03 runner/report, and historical evidence unchanged;
- existing V07-R03 direct PASS is preserved by hash and is not rerun or repaired;
- the compatibility smoke check passes without repository-file changes and proves complete capture plus exact native exit;
- V06 analytical, V05 optionality, M17 difficulty validation twice, M16, M15, M14, and M02 regressions run exactly once in the locked order;
- the capture implementation does not use unavailable `ProcessStartInfo.ArgumentList`;
- every command has an exact command line, complete verbatim captured stdout/stderr, required PASS marker, and exit `0`, including both M17 difficulty-validation markers;
- the actual Sunny Cove SHA-256 is recorded as `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`;
- `git diff --check` passes;
- child/master logs contain exact execution-time and post-publication equality, clean-tree proof, protected hashes, limitations, and `TASKS.md` immutability;
- a terminal publication record contains final post-push local/origin/remote equality, clean status, and the final marker;
- master and child logs end with `AWAITING_M17_AUDIT_V07_R03_R02`.

Any failed or unverified item is `CHANGES_REQUIRED`; no later work is accepted.
