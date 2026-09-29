# BCM-M17-DIFFICULTY-VALIDATION — ChatGPT Independent Audit V07-R01

Verdict: **CHANGES_REQUIRED / RUNNER-PROVENANCE-INTEGRITY_FAILURE**

Auditor: ChatGPT  
Builder: CODEX  
Repository: `Sekiph82/Beach-Cocktails-Merge`  
Branch: `main`  
Audit date: 2026-09-29  
Audited handoff HEAD: `6db6e945f928aed3b40f6daf208c1b6f7d4a3cb3`

## 1. What passed

- V07-R01 parse check: PASS / exit 0.
- Fresh confirmation batch executed 42 candidates × 4 new trials = 168 new trials.
- Report contains 42 candidate five-trial aggregates plus the three carried-forward V06-R02 feasible classes.
- Report records exactly 213 unique aggregate seeds.
- Canonical Sunny Cove data remained frozen.
- Root `TASKS.md` was not modified by the direct execution child.
- Stop rule was followed: Child 03/regressions did not run after direct failure.
- V06-R02 and V05 source hashes remained the expected audited values.

## 2. Direct failure

The V07-R01 direct runner exited 1 and the committed report status is `FAIL`.

The report contains exactly 168 validation errors, one for every fresh trial, beginning:

`duplicate aggregate seed 17800101`
`duplicate aggregate seed 17800102`
`duplicate aggregate seed 17800103`
`duplicate aggregate seed 17800104`

and ending with the four `1781000x` seeds.

Observed failed-run classification is builder evidence only:
- solver-feasible classes: 15
- high-risk 0/5 classes: 30

These counts are not accepted because the required direct runner did not pass.

## 3. Critical provenance mismatch

The final committed runner at the audited HEAD cannot emit the report's observed error text `duplicate aggregate seed ...`.

The committed runner's seed-validation error paths are:
- `duplicate V07-R01 seed %d`
- `duplicate %s seed %d`, where the committed direct-run provenance is `V07-R01`.

The committed runner contains no call that supplies provenance `aggregate`, and no literal `duplicate aggregate seed` validation branch.

Therefore the failed report cannot be proven to have been produced by the exact final committed runner bytes now present at the handoff HEAD. This breaks replayability and execution provenance even though the report contains 168 fresh trials and 213 unique seeds.

## 4. Interpretation

This is not evidence that the canonical level data or solver policy is invalid. It is a runner/evidence-governance failure.

The final committed R01 runner appears to contain a corrected registration design, but it was not proven by an exact-committed-SHA direct PASS. The failed R01 JSON/Markdown must remain historical failed evidence and must not be rewritten or promoted.

## 5. Required remediation

V07-R02 must:

1. preserve V07-R01 runner/report/logs byte-for-byte as historical evidence;
2. create a new V07-R02 runner/output set;
3. base R02 on the final committed R01 runner design, changing only R02 version/output identifiers and a fresh deterministic seed namespace unless another defect is proven before execution;
4. **commit the R02 runner before any direct confirmation run**;
5. verify the checkout is clean and the runner bytes/hash equal the committed `HEAD`;
6. execute the exact committed runner without any uncommitted runner edits;
7. use a fresh seed namespace and generate 168 new trials;
8. require direct PASS / exit 0 before regressions;
9. run the locked regression sequence only after direct PASS.

## 6. Scope freeze

No canonical timer/objective/VIP/gameplay/physics/HUD/economy/progression tuning is authorized.

M17-008 remains open. M18 remains blocked.

Final verdict: **CHANGES_REQUIRED / V07-R02 BOUNDED REMEDIATION REQUIRED**.
