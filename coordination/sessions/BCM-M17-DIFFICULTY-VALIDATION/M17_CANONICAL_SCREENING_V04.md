# M17 V04 Full Canonical Sunny Cove Screening

Policy: `MERGE_AWARE_V01`; physics scale: `1.0x`; canonical data SHA-256: `9feabee63be44cfbb2b9db7527a06b1b0e3f072c6859f4e7b8c6b3d7d9f25495`. V04 is flagging evidence only; no tuning is authorized.

Levels: `100`; challenge classes: `45`; reused V03A trials: `30`; new V04 trials: `39`.

## Screening interpretation

- One successful qualified-solver completion proves one solver-feasible path, not human difficulty.
- One failed seed does not prove impossibility; one-trial failures require confirmation.
- 0/5 qualified-solver evidence is high-risk evidence, not proof no human can win.
- Historical 4x results are excluded from V04 classifications.
- V04 authorizes no timer, objective, VIP, physics, or canonical data change.

## Challenge classes

| Class | Representative | Members | Evidence | Trials | Complete | Danger | Timeout | Abort | Flags |
|---|---:|---|---|---:|---:|---:|---:|---:|---|
| C01 | L1 | L1, L2 | V03A_5_TRIAL | 5 | 3 | 0 | 2 | 0 | SOLVER_FEASIBLE |
| C02 | L3 | L3, L5 | V04_SINGLE_TRIAL_SCREEN | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C03 | L4 | L4 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 0 | 1 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C04 | L6 | L6, L11 | V03A_5_TRIAL | 5 | 3 | 1 | 1 | 0 | SOLVER_FEASIBLE, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C05 | L7 | L7 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C06 | L8 | L8 | V04_SINGLE_TRIAL_SCREEN | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C07 | L9 | L9, L21 | V04_SINGLE_TRIAL_SCREEN | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C08 | L10 | L10, L13 | V03A_5_TRIAL | 5 | 1 | 3 | 1 | 0 | SOLVER_FEASIBLE, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C09 | L12 | L12, L16 | V04_SINGLE_TRIAL_SCREEN | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C10 | L14 | L14 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C11 | L15 | L15, L17, L19, L22, L25, L31 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C12 | L18 | L18, L23 | V04_SINGLE_TRIAL_SCREEN | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C13 | L20 | L20, L28 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C14 | L24 | L24, L32 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C15 | L26 | L26, L33 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C16 | L27 | L27, L35 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C17 | L29 | L29, L34, L37, L39, L42, L51 | V03A_5_TRIAL | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C18 | L30 | L30 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C19 | L36 | L36 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C20 | L38 | L38, L45, L54 | V04_SINGLE_TRIAL_SCREEN | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C21 | L40 | L40, L52 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C22 | L41 | L41 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C23 | L43 | L43, L61 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C24 | L44 | L44 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C25 | L46 | L46 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C26 | L47 | L47, L50, L53, L55, L62, L71 | V03A_5_TRIAL | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C27 | L48 | L48 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C28 | L49 | L49, L57 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C29 | L56 | L56, L72 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C30 | L58 | L58, L63, L65, L81 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 0 | 1 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C31 | L59 | L59, L67, L74 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C32 | L60 | L60 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C33 | L64 | L64 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C34 | L66 | L66, L70, L73, L75, L82, L91 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 0 | 1 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C35 | L68 | L68, L84 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C36 | L69 | L69, L78, L83, L85 | V04_SINGLE_TRIAL_SCREEN | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C37 | L76 | L76, L92 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C38 | L77 | L77 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C39 | L79 | L79, L86, L90, L93, L95, L97 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C40 | L80 | L80 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C41 | L87 | L87, L94 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION, SPATIAL_MIX_OUTLIER_CANDIDATE |
| C42 | L88 | L88 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C43 | L89 | L89, L98, L99 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C44 | L96 | L96 | V04_SINGLE_TRIAL_SCREEN | 1 | 0 | 1 | 0 | 0 | SCREENING_FAILURE_NEEDS_CONFIRMATION |
| C45 | L100 | L100 | V03A_5_TRIAL | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |

## Required classification tables

### Mathematically unreachable levels

NONE

### Analytical timer-ratio outliers

NONE

### VIP-interception-risk levels

L4, L8, L12, L16, L20, L24, L28, L32, L36, L40, L44, L48, L52, L56, L60, L64, L68, L72, L76, L80, L84, L88, L92, L96, L100

### Solver-feasible classes

C01 (rep L1), C02 (rep L3), C04 (rep L6), C06 (rep L8), C07 (rep L9), C08 (rep L10), C09 (rep L12), C12 (rep L18), C20 (rep L38), C36 (rep L69)

### High-risk 0/5 classes

C17 (rep L29), C26 (rep L47), C45 (rep L100)

### One-trial failures needing confirmation

C03 (rep L4), C05 (rep L7), C10 (rep L14), C11 (rep L15), C13 (rep L20), C14 (rep L24), C15 (rep L26), C16 (rep L27), C18 (rep L30), C19 (rep L36), C21 (rep L40), C22 (rep L41), C23 (rep L43), C24 (rep L44), C25 (rep L46), C27 (rep L48), C28 (rep L49), C29 (rep L56), C30 (rep L58), C31 (rep L59), C32 (rep L60), C33 (rep L64), C34 (rep L66), C35 (rep L68), C37 (rep L76), C38 (rep L77), C39 (rep L79), C40 (rep L80), C41 (rep L87), C42 (rep L88), C43 (rep L89), C44 (rep L96)

## Spatial-mix outlier candidates

| Class A | Class B | Cost | Timer | Feasibility difference | Danger-rate difference | Interpretation |
|---|---|---:|---:|---|---:|---|
| C02 | C03 | 32 | 40 | true | 0.00 | candidate signal only; sample sizes are small and not statistical proof |
| C04 | C05 | 48 | 60 | true | 0.80 | candidate signal only; sample sizes are small and not statistical proof |
| C05 | C06 | 48 | 60 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C07 | C08 | 64 | 80 | false | 0.60 | candidate signal only; sample sizes are small and not statistical proof |
| C07 | C10 | 64 | 80 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C08 | C09 | 64 | 80 | false | 0.60 | candidate signal only; sample sizes are small and not statistical proof |
| C08 | C10 | 64 | 80 | true | 0.40 | candidate signal only; sample sizes are small and not statistical proof |
| C09 | C10 | 64 | 80 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C11 | C12 | 80 | 100 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C20 | C21 | 128 | 160 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C20 | C23 | 128 | 160 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C20 | C25 | 128 | 160 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C20 | C27 | 128 | 160 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C29 | C30 | 160 | 200 | false | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C30 | C31 | 160 | 200 | false | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C32 | C34 | 176 | 220 | false | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C34 | C35 | 176 | 220 | false | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C34 | C38 | 176 | 220 | false | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C36 | C37 | 192 | 240 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C36 | C40 | 192 | 240 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |
| C36 | C41 | 192 | 240 | true | 1.00 | candidate signal only; sample sizes are small and not statistical proof |

## VIP precedence fixtures

- L4: forced captures `1`; normal-first `true`; VIP-second `true`; consistent `true`.
- L60: forced captures `1`; normal-first `true`; VIP-second `true`; consistent `true`.
- L100: forced captures `1`; normal-first `true`; VIP-second `true`; consistent `true`.

## Timer scan

Cohort median timer/cost ratio: `1.250000`; outlier threshold: absolute deviation `>5%`.

## Validation

- Report integrity: `true`
- Validation errors: `[]`
- Canonical-data SHA is recorded; the focused V04 probe separately proves byte-for-byte immutability.
