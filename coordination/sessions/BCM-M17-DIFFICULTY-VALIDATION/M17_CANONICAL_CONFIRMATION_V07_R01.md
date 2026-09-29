# BCM-M17 V07-R01 Fresh Five-Trial Canonical Confirmation

Status: **FAIL**; policy: `MERGE_AWARE_V01`; Engine.time_scale: `1.0`; canonical SHA-256: `9FEABEE63BE44CFBB2B9DB7527A06B1B0E3F072C6859F4E7B8C6B3D7D9F25495`.

V06-R02 source SHA-256: `4A555D786A02EB1041A500316E007DD7F87E1C40DF8A28DE01739FC81B1AAA89`; V05 SHA-256: `5FC6EF353D012C8D37D6FB68E6D2759F010636A2313AC0ED9272CC582F98D218`.

Fresh confirmation: `42` candidates; `168` new trials; `42 x 5` candidate aggregates; `213` unique aggregate seeds; levels `100`; classes `45`.

Final solver-feasible: `15` (C01, C02, C04, C05, C06, C07, C10, C12, C18, C22, C24, C25, C33, C36, C37).

Final high-risk 0/5: `30` (C03, C08, C09, C11, C13, C14, C15, C16, C17, C19, C20, C21, C23, C26, C27, C28, C29, C30, C31, C32, C34, C35, C38, C39, C40, C41, C42, C43, C44, C45).

## Interpretation boundary

- Each candidate aggregate contains the audited V06-R02 trial plus exactly four fresh post-V05 MERGE_AWARE_V01 trials at Engine.time_scale = 1.0.
- A completion demonstrates one solver-feasible path, not human difficulty or owner acceptance.
- HIGH_RISK_SOLVER_FAILURE is exact-class 0/5 solver evidence, not proof of human impossibility.
- No timer, normal objective, VIP content, reward, or canonical data tuning is authorized by this report.

## Post-V05 VIP semantics

- Forced captures: `0/25`.
- Surplus paths: `25/25`.
- VIP cost added to normal timers: `false`.

## Challenge classes

| Class | Representative | Members | Evidence | Trials | Complete | Danger | Timeout | Abort | Flags |
|---|---:|---|---|---:|---:|---:|---:|---:|---|
| C01 | L1 | L1, L2 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 2 | 0 | 3 | 0 | SOLVER_FEASIBLE |
| C02 | L3 | L3, L5 | V06_R02_CARRIED_FORWARD_1_TRIAL | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE |
| C03 | L4 | L4 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 1 | 4 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C04 | L6 | L6, L11 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C05 | L7 | L7 | V06_R02_CARRIED_FORWARD_1_TRIAL | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE |
| C06 | L8 | L8 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 2 | 3 | 0 | 0 | SOLVER_FEASIBLE |
| C07 | L9 | L9, L21 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 2 | 3 | 0 | 0 | SOLVER_FEASIBLE |
| C08 | L10 | L10, L13 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 2 | 3 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C09 | L12 | L12, L16 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C10 | L14 | L14 | V06_R02_CARRIED_FORWARD_1_TRIAL | 1 | 1 | 0 | 0 | 0 | SOLVER_FEASIBLE |
| C11 | L15 | L15, L17, L19, L22, L25, L31 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C12 | L18 | L18, L23 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 2 | 3 | 0 | 0 | SOLVER_FEASIBLE |
| C13 | L20 | L20, L28 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C14 | L24 | L24, L32 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C15 | L26 | L26, L33 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C16 | L27 | L27, L35 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C17 | L29 | L29, L34, L37, L39, L42, L51 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C18 | L30 | L30 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C19 | L36 | L36 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C20 | L38 | L38, L45, L54 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C21 | L40 | L40, L52 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C22 | L41 | L41 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C23 | L43 | L43, L61 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C24 | L44 | L44 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C25 | L46 | L46 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C26 | L47 | L47, L50, L53, L55, L62, L71 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C27 | L48 | L48 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C28 | L49 | L49, L57 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C29 | L56 | L56, L72 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C30 | L58 | L58, L63, L65, L81 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C31 | L59 | L59, L67, L74 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C32 | L60 | L60 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C33 | L64 | L64 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 3 | 2 | 0 | 0 | SOLVER_FEASIBLE |
| C34 | L66 | L66, L70, L73, L75, L82, L91 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C35 | L68 | L68, L84 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C36 | L69 | L69, L78, L83, L85 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C37 | L76 | L76, L92 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 1 | 4 | 0 | 0 | SOLVER_FEASIBLE |
| C38 | L77 | L77 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C39 | L79 | L79, L86, L90, L93, L95, L97 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C40 | L80 | L80 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C41 | L87 | L87, L94 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C42 | L88 | L88 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C43 | L89 | L89, L98, L99 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C44 | L96 | L96 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |
| C45 | L100 | L100 | V06_R02_TRIAL_1_PLUS_V07_FOUR_TRIALS | 5 | 0 | 5 | 0 | 0 | HIGH_RISK_SOLVER_FAILURE |

## All 100 levels

| Level | Class | Cost | Timer | Reachability | Post-V05 VIP | Physical flags |
|---:|---|---:|---:|---|---|---|
| 1 | C01 | 16 | 20.0 | NONE | none | SOLVER_FEASIBLE |
| 2 | C01 | 16 | 20.0 | NONE | none | SOLVER_FEASIBLE |
| 3 | C02 | 32 | 40.0 | NONE | none | SOLVER_FEASIBLE |
| 4 | C03 | 32 | 40.0 | NONE | L5 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 5 | C02 | 32 | 40.0 | NONE | none | SOLVER_FEASIBLE |
| 6 | C04 | 48 | 60.0 | NONE | none | SOLVER_FEASIBLE |
| 7 | C05 | 48 | 60.0 | NONE | none | SOLVER_FEASIBLE |
| 8 | C06 | 48 | 60.0 | NONE | L5 x1 forced=0 surplus=true | SOLVER_FEASIBLE |
| 9 | C07 | 64 | 80.0 | NONE | none | SOLVER_FEASIBLE |
| 10 | C08 | 64 | 80.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 11 | C04 | 48 | 60.0 | NONE | none | SOLVER_FEASIBLE |
| 12 | C09 | 64 | 80.0 | NONE | L5 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 13 | C08 | 64 | 80.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 14 | C10 | 64 | 80.0 | NONE | none | SOLVER_FEASIBLE |
| 15 | C11 | 80 | 100.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 16 | C09 | 64 | 80.0 | NONE | L5 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 17 | C11 | 80 | 100.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 18 | C12 | 80 | 100.0 | NONE | none | SOLVER_FEASIBLE |
| 19 | C11 | 80 | 100.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 20 | C13 | 96 | 120.0 | NONE | L5 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 21 | C07 | 64 | 80.0 | NONE | none | SOLVER_FEASIBLE |
| 22 | C11 | 80 | 100.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 23 | C12 | 80 | 100.0 | NONE | none | SOLVER_FEASIBLE |
| 24 | C14 | 96 | 120.0 | NONE | L6 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 25 | C11 | 80 | 100.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 26 | C15 | 96 | 120.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 27 | C16 | 96 | 120.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 28 | C13 | 96 | 120.0 | NONE | L5 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 29 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 30 | C18 | 112 | 140.0 | NONE | none | SOLVER_FEASIBLE |
| 31 | C11 | 80 | 100.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 32 | C14 | 96 | 120.0 | NONE | L6 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 33 | C15 | 96 | 120.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 34 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 35 | C16 | 96 | 120.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 36 | C19 | 112 | 140.0 | NONE | L5 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 37 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 38 | C20 | 128 | 160.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 39 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 40 | C21 | 128 | 160.0 | NONE | L6 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 41 | C22 | 96 | 120.0 | NONE | none | SOLVER_FEASIBLE |
| 42 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 43 | C23 | 128 | 160.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 44 | C24 | 112 | 140.0 | NONE | L6 x1 forced=0 surplus=true | SOLVER_FEASIBLE |
| 45 | C20 | 128 | 160.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 46 | C25 | 128 | 160.0 | NONE | none | SOLVER_FEASIBLE |
| 47 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 48 | C27 | 128 | 160.0 | NONE | L5 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 49 | C28 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 50 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 51 | C17 | 112 | 140.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 52 | C21 | 128 | 160.0 | NONE | L6 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 53 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 54 | C20 | 128 | 160.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 55 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 56 | C29 | 160 | 200.0 | NONE | L6 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 57 | C28 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 58 | C30 | 160 | 200.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 59 | C31 | 160 | 200.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 60 | C32 | 176 | 220.0 | NONE | L7 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 61 | C23 | 128 | 160.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 62 | C26 | 144 | 180.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 63 | C30 | 160 | 200.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 64 | C33 | 144 | 180.0 | NONE | L5 x2 forced=0 surplus=true | SOLVER_FEASIBLE |
| 65 | C30 | 160 | 200.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
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
| 76 | C37 | 192 | 240.0 | NONE | L7 x1 forced=0 surplus=true | SOLVER_FEASIBLE |
| 77 | C38 | 176 | 220.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 78 | C36 | 192 | 240.0 | NONE | none | SOLVER_FEASIBLE |
| 79 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 80 | C40 | 192 | 240.0 | NONE | L6 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 81 | C30 | 160 | 200.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
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
| 92 | C37 | 192 | 240.0 | NONE | L7 x1 forced=0 surplus=true | SOLVER_FEASIBLE |
| 93 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 94 | C41 | 192 | 240.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 95 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 96 | C44 | 224 | 280.0 | NONE | L6 x2 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |
| 97 | C39 | 208 | 260.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 98 | C43 | 224 | 280.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 99 | C43 | 224 | 280.0 | NONE | none | HIGH_RISK_SOLVER_FAILURE |
| 100 | C45 | 240 | 300.0 | NONE | L7 x1 forced=0 surplus=true | HIGH_RISK_SOLVER_FAILURE |

## Validation

- Validation errors: `["duplicate aggregate seed 17800101", "duplicate aggregate seed 17800102", "duplicate aggregate seed 17800103", "duplicate aggregate seed 17800104", "duplicate aggregate seed 17800401", "duplicate aggregate seed 17800402", "duplicate aggregate seed 17800403", "duplicate aggregate seed 17800404", "duplicate aggregate seed 17800601", "duplicate aggregate seed 17800602", "duplicate aggregate seed 17800603", "duplicate aggregate seed 17800604", "duplicate aggregate seed 17800801", "duplicate aggregate seed 17800802", "duplicate aggregate seed 17800803", "duplicate aggregate seed 17800804", "duplicate aggregate seed 17800901", "duplicate aggregate seed 17800902", "duplicate aggregate seed 17800903", "duplicate aggregate seed 17800904", "duplicate aggregate seed 17801001", "duplicate aggregate seed 17801002", "duplicate aggregate seed 17801003", "duplicate aggregate seed 17801004", "duplicate aggregate seed 17801201", "duplicate aggregate seed 17801202", "duplicate aggregate seed 17801203", "duplicate aggregate seed 17801204", "duplicate aggregate seed 17801501", "duplicate aggregate seed 17801502", "duplicate aggregate seed 17801503", "duplicate aggregate seed 17801504", "duplicate aggregate seed 17801801", "duplicate aggregate seed 17801802", "duplicate aggregate seed 17801803", "duplicate aggregate seed 17801804", "duplicate aggregate seed 17802001", "duplicate aggregate seed 17802002", "duplicate aggregate seed 17802003", "duplicate aggregate seed 17802004", "duplicate aggregate seed 17802401", "duplicate aggregate seed 17802402", "duplicate aggregate seed 17802403", "duplicate aggregate seed 17802404", "duplicate aggregate seed 17802601", "duplicate aggregate seed 17802602", "duplicate aggregate seed 17802603", "duplicate aggregate seed 17802604", "duplicate aggregate seed 17802701", "duplicate aggregate seed 17802702", "duplicate aggregate seed 17802703", "duplicate aggregate seed 17802704", "duplicate aggregate seed 17802901", "duplicate aggregate seed 17802902", "duplicate aggregate seed 17802903", "duplicate aggregate seed 17802904", "duplicate aggregate seed 17803001", "duplicate aggregate seed 17803002", "duplicate aggregate seed 17803003", "duplicate aggregate seed 17803004", "duplicate aggregate seed 17803601", "duplicate aggregate seed 17803602", "duplicate aggregate seed 17803603", "duplicate aggregate seed 17803604", "duplicate aggregate seed 17803801", "duplicate aggregate seed 17803802", "duplicate aggregate seed 17803803", "duplicate aggregate seed 17803804", "duplicate aggregate seed 17804001", "duplicate aggregate seed 17804002", "duplicate aggregate seed 17804003", "duplicate aggregate seed 17804004", "duplicate aggregate seed 17804101", "duplicate aggregate seed 17804102", "duplicate aggregate seed 17804103", "duplicate aggregate seed 17804104", "duplicate aggregate seed 17804301", "duplicate aggregate seed 17804302", "duplicate aggregate seed 17804303", "duplicate aggregate seed 17804304", "duplicate aggregate seed 17804401", "duplicate aggregate seed 17804402", "duplicate aggregate seed 17804403", "duplicate aggregate seed 17804404", "duplicate aggregate seed 17804601", "duplicate aggregate seed 17804602", "duplicate aggregate seed 17804603", "duplicate aggregate seed 17804604", "duplicate aggregate seed 17804701", "duplicate aggregate seed 17804702", "duplicate aggregate seed 17804703", "duplicate aggregate seed 17804704", "duplicate aggregate seed 17804801", "duplicate aggregate seed 17804802", "duplicate aggregate seed 17804803", "duplicate aggregate seed 17804804", "duplicate aggregate seed 17804901", "duplicate aggregate seed 17804902", "duplicate aggregate seed 17804903", "duplicate aggregate seed 17804904", "duplicate aggregate seed 17805601", "duplicate aggregate seed 17805602", "duplicate aggregate seed 17805603", "duplicate aggregate seed 17805604", "duplicate aggregate seed 17805801", "duplicate aggregate seed 17805802", "duplicate aggregate seed 17805803", "duplicate aggregate seed 17805804", "duplicate aggregate seed 17805901", "duplicate aggregate seed 17805902", "duplicate aggregate seed 17805903", "duplicate aggregate seed 17805904", "duplicate aggregate seed 17806001", "duplicate aggregate seed 17806002", "duplicate aggregate seed 17806003", "duplicate aggregate seed 17806004", "duplicate aggregate seed 17806401", "duplicate aggregate seed 17806402", "duplicate aggregate seed 17806403", "duplicate aggregate seed 17806404", "duplicate aggregate seed 17806601", "duplicate aggregate seed 17806602", "duplicate aggregate seed 17806603", "duplicate aggregate seed 17806604", "duplicate aggregate seed 17806801", "duplicate aggregate seed 17806802", "duplicate aggregate seed 17806803", "duplicate aggregate seed 17806804", "duplicate aggregate seed 17806901", "duplicate aggregate seed 17806902", "duplicate aggregate seed 17806903", "duplicate aggregate seed 17806904", "duplicate aggregate seed 17807601", "duplicate aggregate seed 17807602", "duplicate aggregate seed 17807603", "duplicate aggregate seed 17807604", "duplicate aggregate seed 17807701", "duplicate aggregate seed 17807702", "duplicate aggregate seed 17807703", "duplicate aggregate seed 17807704", "duplicate aggregate seed 17807901", "duplicate aggregate seed 17807902", "duplicate aggregate seed 17807903", "duplicate aggregate seed 17807904", "duplicate aggregate seed 17808001", "duplicate aggregate seed 17808002", "duplicate aggregate seed 17808003", "duplicate aggregate seed 17808004", "duplicate aggregate seed 17808701", "duplicate aggregate seed 17808702", "duplicate aggregate seed 17808703", "duplicate aggregate seed 17808704", "duplicate aggregate seed 17808801", "duplicate aggregate seed 17808802", "duplicate aggregate seed 17808803", "duplicate aggregate seed 17808804", "duplicate aggregate seed 17808901", "duplicate aggregate seed 17808902", "duplicate aggregate seed 17808903", "duplicate aggregate seed 17808904", "duplicate aggregate seed 17809601", "duplicate aggregate seed 17809602", "duplicate aggregate seed 17809603", "duplicate aggregate seed 17809604", "duplicate aggregate seed 17810001", "duplicate aggregate seed 17810002", "duplicate aggregate seed 17810003", "duplicate aggregate seed 17810004"]`.
- Report is builder evidence for independent ChatGPT audit, not owner acceptance.
