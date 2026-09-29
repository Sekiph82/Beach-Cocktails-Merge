# BCM-M17 V07-R03 - Locked Remediation Audit Criteria

Status: **LOCKED BEFORE REMEDIATION**

Authority: `CHATGPT_AUDIT_V07_R02.md`, the V07-R02 locked criteria, and the audited V06-R02 evidence.

## Master gates

### A - governance and freeze

The canonical checkout is clean synchronized `main`; `HEAD == origin/main == remote main`; root `TASKS.md` is untouched by CODEX; and canonical Sunny Cove, V05, V06-R02, V07, and V07-R01 evidence retain their baseline bytes/hashes.

### B - exactly one ordered child

Child 01 is the only child. It must complete the runner correction, exact commit-before-run provenance, fresh confirmation, and required post-PASS regressions. No later child or M17 tuning may start.

### C - bounded runner correction

Only a new R03 evidence runner and R03 outputs may be added. Numeric Variant representations that are semantically equal in source/canonical member and signature mappings may be normalized for comparison, but the comparison must remain strict for values, keys, arrays, representatives, and structure. A bypass, unconditional equality, skipped class, or altered source evidence fails this criterion.

### D - exact committed provenance

The R03 runner is parse-checked, committed and pushed before direct execution. The executed file's SHA-256 and Git blob/commit identity equal current committed `HEAD`, the tree is clean, and no runner edit occurs before direct completion.

### E - fresh confirmation

The exact R03 run uses the audited V06-R02 42-candidate set, carries each audited source trial as trial 1, runs exactly four new trials per candidate under `18000000 + representative*100 + trial_index`, uses `MERGE_AWARE_V01` at time scale `1.0`, and records 42 candidates, 168 new trials, 42 x 5 aggregates, and 213 unique aggregate seeds.

### F - classification and report integrity

The direct report is `V07-R03`, status `PASS`, has zero validation errors, emits the R03 PASS marker, exits `0`, preserves the three carried-forward feasible source classes, classifies each five-trial candidate as feasible when completion count is at least one or high-risk when zero, and leaves no candidate marked `SCREENING_FAILURE_NEEDS_CONFIRMATION`.

### G - preserved VIP and scope semantics

VIP forced captures are `0/25`, surplus paths are `25/25`, no VIP cost is added to normal timers, and no canonical timer/objective/VIP/gameplay/HUD/physics/economy/progression data changes.

### H - stop gate and regressions

If the exact direct run fails, stop immediately: no report repair, no rerun, and no regressions. If and only if direct PASS occurs, run the locked R03 regression sequence and record exact exits.

### I - handoff

Child and master logs contain exact preflight, frozen hashes, commit-before-run proof, commands/exits, report counts, mapping-validation result, class lists, VIP results, regression results, final SHA equality, explicit TASKS/R01/R02 freeze statements, and the final marker `AWAITING_M17_AUDIT_V07_R03`.

Any material FAIL or UNVERIFIED item is `CHANGES_REQUIRED`; M17 tuning and M18 remain blocked.
