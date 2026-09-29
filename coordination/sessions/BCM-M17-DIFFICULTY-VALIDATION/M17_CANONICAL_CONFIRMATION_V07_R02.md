# BCM-M17 V07-R02 Five-Trial Canonical Confirmation

Status: **FAIL**; policy: `MERGE_AWARE_V01`; Engine.time_scale: `1.0`; canonical SHA-256: `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`.

V06-R02 source SHA-256: `4A555D786A02EB1041A500316E007DD7F87E1C40DF8A28DE01739FC81B1AAA89`; V05 SHA-256: `5FC6EF353D012C8D37D6FB68E6D2759F010636A2313AC0ED9272CC582F98D218`.

Confirmation candidates: `42`; new trials: `168`; candidate aggregates: `42 x 5`; unique aggregate seeds: `213`; levels: `100`; classes: `45`.

Final solver-feasible: `19` (C01, C02, C03, C04, C05, C06, C07, C08, C10, C11, C13, C15, C20, C21, C23, C27, C28, C30, C36).

Final high-risk 0/5: `26` (C09, C12, C14, C16, C17, C18, C19, C22, C24, C25, C26, C29, C31, C32, C33, C34, C35, C37, C38, C39, C40, C41, C42, C43, C44, C45).

## Interpretation boundary

- The 42 candidate aggregates contain the audited V06-R02 trial plus exactly four new post-V05 MERGE_AWARE_V01 trials at Engine.time_scale = 1.0.
- A completion demonstrates one solver-feasible path, not human difficulty or owner acceptance.
- HIGH_RISK_SOLVER_FAILURE is exact-class 0/5 solver evidence, not proof of human impossibility.
- No timer, normal objective, VIP content, reward, or canonical data tuning is authorized by this report.
- Historical pre-V05 V03A/V04 trials are not counted toward the V07-R02 five-trial threshold.

## Post-V05 VIP semantics

- Forced captures: `0/25`.
- Surplus paths: `25/25`.
- VIP cost added to normal timers: `false`.

## Challenge classes

| Class | Representative | Members | Evidence | Trials | Complete | Danger | Timeout | Abort | Flags |
|---|---:|---|---|---:|---:|---:|---:|---:|---|
| C01 | L1 | L1, L2 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 0 | 4 | 0 | SOLVER_FEASIBLE |
| C02 | L3 | L3, L5 | V06_R02_CARRIED_FORWARD_1_TRIAL | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE |
| C03 | L4 | L4 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 2 | 2 | 0 | SOLVER_FEASIBLE |
| C04 | L6 | L6, L11 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 3 | 1 | 1 | 0 | SOLVER_FEASIBLE |
| C05 | L7 | L7 | V06_R02_CARRIED_FORWARD_1_TRIAL | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE |
| C06 | L8 | L8 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C07 | L9 | L9, L21 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C08 | L10 | L10, L13 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 2 | 2 | 0 | SOLVER_FEASIBLE |
| C09 | L12 | L12, L16 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C10 | L14 | L14 | V06_R02_CARRIED_FORWARD_1_TRIAL | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE |
| C11 | L15 | L15, L17, L19, L22, L25, L31 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C12 | L18 | L18, L23 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C13 | L20 | L20, L28 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C14 | L24 | L24, L32 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C15 | L26 | L26, L33 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C16 | L27 | L27, L35 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C17 | L29 | L29, L34, L37, L39, L42, L51 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C18 | L30 | L30 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C19 | L36 | L36 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C20 | L38 | L38, L45, L54 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C21 | L40 | L40, L52 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C22 | L41 | L41 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C23 | L43 | L43, L61 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 2 | 2 | 1 | 0 | SOLVER_FEASIBLE |
| C24 | L44 | L44 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C25 | L46 | L46 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C26 | L47 | L47, L50, L53, L55, L62, L71 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C27 | L48 | L48 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C28 | L49 | L49, L57 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C29 | L56 | L56, L72 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C30 | L58 | L58, L63, L65, L81 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C31 | L59 | L59, L67, L74 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C32 | L60 | L60 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C33 | L64 | L64 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C34 | L66 | L66, L70, L73, L75, L82, L91 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C35 | L68 | L68, L84 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C36 | L69 | L69, L78, L83, L85 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C37 | L76 | L76, L92 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C38 | L77 | L77 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C39 | L79 | L79, L86, L90, L93, L95, L97 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C40 | L80 | L80 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C41 | L87 | L87, L94 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C42 | L88 | L88 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C43 | L89 | L89, L98, L99 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C44 | L96 | L96 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C45 | L100 | L100 | V06_R02_TRIAL_1_PLUS_V07_R02_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |

## All 100 levels

| Level | Class | Cost | Timer | Reachability | Post-V05 VIP | Physical flags |
|---:|---|---:|---:|---|---|---|
| 1 | C01 | 16 | 20.0 | NONE | none | SOLVER_FEASIBLE |
| 2 | C01 | 16 | 20.0 | NONE | none | SOLVER_FEASIBLE |
| 3 | C02 | 32 | 40.0 | NONE | none | SOLVER_FEASIBLE |
| 4 | C03 | 32 | 40.0 | NONE | L5 x1 forced=0 surplus=true | SOLVER_FEASIBLE |
| 5 | C02 | 32 | 40.0 | NONE | none | SOLVER_FEASIBLE |
| 6 | C04 | 48 | 60.0 | NONE | none | SOLVER_FEASIBLE |
| 7 | C05 | 48 | 60.0 | NONE | none | SOLVER_FEASIBLE |
| 8 | C06 | 48 | 60.0 | NONE | L5 x1 forced=0 surplus=true | SOLVER_FEASIBLE |
| 9 | C07 | 64 | 80.0 | NONE | none | SOLVER_FEASIBLE |
| 10 | C08 | 64 | 80.0 | NONE | none | SOLVER_FEASIBLE |
| 11 | C04 | 48 | 60.0 | NONE | none | SOLVER_FEASIBLE |
| 12 | C09 | 64 | 80.0 | NONE | L5 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 13 | C08 | 64 | 80.0 | NONE | none | SOLVER_FEASIBLE |
| 14 | C10 | 64 | 80.0 | NONE | none | SOLVER_FEASIBLE |
| 15 | C11 | 80 | 100.0 | NONE | none | SOLVER_FEASIBLE |
| 16 | C09 | 64 | 80.0 | NONE | L5 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 17 | C11 | 80 | 100.0 | NONE | none | SOLVER_FEASIBLE |
| 18 | C12 | 80 | 100.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 19 | C11 | 80 | 100.0 | NONE | none | SOLVER_FEASIBLE |
| 20 | C13 | 96 | 120.0 | NONE | L5 x2 forced=0 surplus=true | SOLVER_FEASIBLE |
| 21 | C07 | 64 | 80.0 | NONE | none | SOLVER_FEASIBLE |
| 22 | C11 | 80 | 100.0 | NONE | none | SOLVER_FEASIBLE |
| 23 | C12 | 80 | 100.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 24 | C14 | 96 | 120.0 | NONE | L6 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 25 | C11 | 80 | 100.0 | NONE | none | SOLVER_FEASIBLE |
| 26 | C15 | 96 | 120.0 | NONE | none | SOLVER_FEASIBLE |
| 27 | C16 | 96 | 120.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 28 | C13 | 96 | 120.0 | NONE | L5 x2 forced=0 surplus=true | SOLVER_FEASIBLE |
| 29 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 30 | C18 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 31 | C11 | 80 | 100.0 | NONE | none | SOLVER_FEASIBLE |
| 32 | C14 | 96 | 120.0 | NONE | L6 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 33 | C15 | 96 | 120.0 | NONE | none | SOLVER_FEASIBLE |
| 34 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 35 | C16 | 96 | 120.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 36 | C19 | 112 | 140.0 | NONE | L5 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 37 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 38 | C20 | 128 | 160.0 | NONE | none | SOLVER_FEASIBLE |
| 39 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 40 | C21 | 128 | 160.0 | NONE | L6 x1 forced=0 surplus=true | SOLVER_FEASIBLE |
| 41 | C22 | 96 | 120.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 42 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 43 | C23 | 128 | 160.0 | NONE | none | SOLVER_FEASIBLE |
| 44 | C24 | 112 | 140.0 | NONE | L6 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 45 | C20 | 128 | 160.0 | NONE | none | SOLVER_FEASIBLE |
| 46 | C25 | 128 | 160.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 47 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 48 | C27 | 128 | 160.0 | NONE | L5 x2 forced=0 surplus=true | SOLVER_FEASIBLE |
| 49 | C28 | 144 | 180.0 | NONE | none | SOLVER_FEASIBLE |
| 50 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 51 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 52 | C21 | 128 | 160.0 | NONE | L6 x1 forced=0 surplus=true | SOLVER_FEASIBLE |
| 53 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 54 | C20 | 128 | 160.0 | NONE | none | SOLVER_FEASIBLE |
| 55 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 56 | C29 | 160 | 200.0 | NONE | L6 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 57 | C28 | 144 | 180.0 | NONE | none | SOLVER_FEASIBLE |
| 58 | C30 | 160 | 200.0 | NONE | none | SOLVER_FEASIBLE |
| 59 | C31 | 160 | 200.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 60 | C32 | 176 | 220.0 | NONE | L7 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 61 | C23 | 128 | 160.0 | NONE | none | SOLVER_FEASIBLE |
| 62 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 63 | C30 | 160 | 200.0 | NONE | none | SOLVER_FEASIBLE |
| 64 | C33 | 144 | 180.0 | NONE | L5 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 65 | C30 | 160 | 200.0 | NONE | none | SOLVER_FEASIBLE |
| 66 | C34 | 176 | 220.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 67 | C31 | 160 | 200.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 68 | C35 | 176 | 220.0 | NONE | L7 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 69 | C36 | 192 | 240.0 | NONE | none | SOLVER_FEASIBLE |
| 70 | C34 | 176 | 220.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 71 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 72 | C29 | 160 | 200.0 | NONE | L6 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 73 | C34 | 176 | 220.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 74 | C31 | 160 | 200.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 75 | C34 | 176 | 220.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 76 | C37 | 192 | 240.0 | NONE | L7 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 77 | C38 | 176 | 220.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 78 | C36 | 192 | 240.0 | NONE | none | SOLVER_FEASIBLE |
| 79 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 80 | C40 | 192 | 240.0 | NONE | L6 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 81 | C30 | 160 | 200.0 | NONE | none | SOLVER_FEASIBLE |
| 82 | C34 | 176 | 220.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 83 | C36 | 192 | 240.0 | NONE | none | SOLVER_FEASIBLE |
| 84 | C35 | 176 | 220.0 | NONE | L7 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 85 | C36 | 192 | 240.0 | NONE | none | SOLVER_FEASIBLE |
| 86 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 87 | C41 | 192 | 240.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 88 | C42 | 208 | 260.0 | NONE | L6 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 89 | C43 | 224 | 280.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 90 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 91 | C34 | 176 | 220.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 92 | C37 | 192 | 240.0 | NONE | L7 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 93 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 94 | C41 | 192 | 240.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 95 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 96 | C44 | 224 | 280.0 | NONE | L6 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 97 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 98 | C43 | 224 | 280.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 99 | C43 | 224 | 280.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 100 | C45 | 240 | 300.0 | NONE | L7 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |

## Validation

- Validation errors: `["C01 member mapping changed", "C01 signature mapping changed", "C02 member mapping changed", "C02 signature mapping changed", "C03 member mapping changed", "C03 signature mapping changed", "C04 member mapping changed", "C04 signature mapping changed", "C05 member mapping changed", "C05 signature mapping changed", "C06 member mapping changed", "C06 signature mapping changed", "C07 member mapping changed", "C07 signature mapping changed", "C08 member mapping changed", "C08 signature mapping changed", "C09 member mapping changed", "C09 signature mapping changed", "C10 member mapping changed", "C10 signature mapping changed", "C11 member mapping changed", "C11 signature mapping changed", "C12 member mapping changed", "C12 signature mapping changed", "C13 member mapping changed", "C13 signature mapping changed", "C14 member mapping changed", "C14 signature mapping changed", "C15 member mapping changed", "C15 signature mapping changed", "C16 member mapping changed", "C16 signature mapping changed", "C17 member mapping changed", "C17 signature mapping changed", "C18 member mapping changed", "C18 signature mapping changed", "C19 member mapping changed", "C19 signature mapping changed", "C20 member mapping changed", "C20 signature mapping changed", "C21 member mapping changed", "C21 signature mapping changed", "C22 member mapping changed", "C22 signature mapping changed", "C23 member mapping changed", "C23 signature mapping changed", "C24 member mapping changed", "C24 signature mapping changed", "C25 member mapping changed", "C25 signature mapping changed", "C26 member mapping changed", "C26 signature mapping changed", "C27 member mapping changed", "C27 signature mapping changed", "C28 member mapping changed", "C28 signature mapping changed", "C29 member mapping changed", "C29 signature mapping changed", "C30 member mapping changed", "C30 signature mapping changed", "C31 member mapping changed", "C31 signature mapping changed", "C32 member mapping changed", "C32 signature mapping changed", "C33 member mapping changed", "C33 signature mapping changed", "C34 member mapping changed", "C34 signature mapping changed", "C35 member mapping changed", "C35 signature mapping changed", "C36 member mapping changed", "C36 signature mapping changed", "C37 member mapping changed", "C37 signature mapping changed", "C38 member mapping changed", "C38 signature mapping changed", "C39 member mapping changed", "C39 signature mapping changed", "C40 member mapping changed", "C40 signature mapping changed", "C41 member mapping changed", "C41 signature mapping changed", "C42 member mapping changed", "C42 signature mapping changed", "C43 member mapping changed", "C43 signature mapping changed", "C44 member mapping changed", "C44 signature mapping changed", "C45 member mapping changed", "C45 signature mapping changed"]`.
- Report is builder evidence for independent ChatGPT audit, not owner acceptance.
