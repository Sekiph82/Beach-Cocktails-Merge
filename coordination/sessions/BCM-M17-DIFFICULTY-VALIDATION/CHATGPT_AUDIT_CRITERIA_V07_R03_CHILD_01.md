# BCM-M17 V07-R03 Child 01 - Locked Audit Criteria

Child 01 passes only if all of the following are independently verified:

- clean synchronized canonical `main`, with root `TASKS.md`, Sunny Cove data, and V07-R02/V07-R01 evidence unchanged;
- new R03 runner only, with strict numeric-semantic mapping comparison and no bypass/skip/relaxation;
- parse check, commit/push, clean-tree proof, exact runner SHA-256/Git blob proof before direct execution;
- one exact committed direct run with exit `0`, R03 PASS marker, report status `PASS`, and zero validation errors;
- 42 candidates, 168 fresh trials, 42 x 5 aggregates, 213 unique aggregate seeds, `MERGE_AWARE_V01`, time scale `1.0`;
- all 45 source/canonical class mappings pass, including member and signature mappings;
- carried-forward C02/C05/C10 semantics preserved, no candidate remains `SCREENING_FAILURE_NEEDS_CONFIRMATION`;
- VIP forced `0/25`, surplus `25/25`, no VIP timer cost, and no product-data tuning;
- regressions run only after direct PASS and recorded with exact exit codes;
- child log plus master log include final SHA equality, frozen-file proofs, limitations, and `AWAITING_M17_AUDIT_V07_R03`.

Any failed or unverified item is `CHANGES_REQUIRED`; no later work is accepted.
