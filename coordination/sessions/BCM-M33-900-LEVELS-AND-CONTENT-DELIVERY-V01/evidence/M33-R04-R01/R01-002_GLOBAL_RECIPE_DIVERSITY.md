# R01-002 — Global recipe diversity

**Disposition: BLOCKED — owner design decision required.**

The current R04 generated set contains 888 records, 527 distinct full signatures, 147 repeated-signature groups, and 361 duplicate records. `cross_island_duplicate_examples.csv` enumerates every repeated generated record with its exact signature and both locations.

Under the proposed L6+/T56 ordinary contract, the maximum is 8 canonical normal recipe sets (20 if list ordering is counted as distinct). Counting all optional VIP choices and all order-array permutations as distinct increases the strict upper bound to 100 full signatures. That still falls 779 short of the 879 ordinary records requiring uniqueness, and VIP-only/order-only changes do not add meaningful objective diversity.

The full R04 sample set of 36 actual generated recipes remains available at `../M33-R04/representative_level_examples.csv`. No replacement recipes were generated because there is no feasible package under the current constraints.
