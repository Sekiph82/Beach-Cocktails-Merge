# R01-001 — L6+ ordinary targets under T56

**Disposition: BLOCKED — owner design decision required.**

The current owner-approved R04 contract caps ordinary normal T at 56 and reserves L9–L12 from routine mandatory objectives. R01 now requires every ordinary target to be L6 or higher. Production shot costs are `T(Ln) = 2^(n-3)`: L6=8, L7=16, L8=32, and L9=64. Therefore L9 and above cannot be a mandatory normal target in any ordinary recipe under T56.

Exhaustive enumeration of the existing profile bands, with 2–3 distinct normal target levels and quantities 1–2, yields only 8 canonical normal objective sets when display order is ignored, or 20 signatures if order-array permutations are counted separately. The requested 879 ordinary generated records cannot be unique under this combination space. The R04 baseline currently contains at least one L5 in 717 of the 879 ordinary generated records; all 879 currently remain at or below T56.

No generated data or profile was changed. The requested L5 rejection cannot be shipped coherently while preserving the additional R01 global uniqueness rule and the 879-record scope; doing so would require repetitive recipes or exhaustion of the existing per-island uniqueness search. Await an owner decision on the options in `design_space_and_baseline_audit.json` before changing the recipe contract.
