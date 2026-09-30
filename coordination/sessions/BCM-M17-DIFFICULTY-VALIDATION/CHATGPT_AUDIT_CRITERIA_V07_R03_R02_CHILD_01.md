# BCM-M17 V07-R03-R02 Child 01 - Locked Audit Criteria

Child 01 passes only if all of the following are independently verified:

- clean synchronized canonical `main`, with `TASKS.md`, canonical Sunny Cove data, V07-R03 runner/report, and historical evidence unchanged;
- existing V07-R03 direct PASS is preserved by hash and is not rerun or repaired;
- V06 analytical, V05 optionality, M17 difficulty validation twice, M16, M15, M14, and M02 regressions run in the locked order;
- every command has an exact command line, verbatim complete captured stdout/stderr transcript, required PASS marker, and exit `0`, including both M17 difficulty-validation markers;
- `git diff --check` passes;
- child/master logs contain exact execution-time equality, clean-tree proof, protected hashes, limitations, and `TASKS.md` immutability;
- a terminal publication record contains final post-push local/origin/remote equality and the final marker;
- master and child logs end with `AWAITING_M17_AUDIT_V07_R03_R02`.

Any failed or unverified item is `CHANGES_REQUIRED`; no later work is accepted.
