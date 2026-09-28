# BCM-M17 Owner Observation V03A — Fixed-Lane Baseline Failure Mode

Status: **OWNER-OBSERVED / AUTHORITATIVE BEFORE V03 EXECUTION**

Owner observation date: 2026-09-28

The owner directly observed the prior baseline bot running in-game and reported that it repeatedly launched cocktails straight ahead from effectively the same horizontal position without meaningful lateral retargeting.

This observation explains why the V02 weak-policy cohort cannot be treated as a gameplay-skill model:
- it does not visibly react to board state;
- it does not visibly aim toward existing same-level cocktails;
- it does not visibly move away from congested lanes;
- it behaves primarily as a repeatable physics probe.

Therefore the V03 qualification policy must prove **actual board-state-responsive horizontal targeting**, not merely contain code paths named lane selection or merge-aware.

## Required evidence

For the stronger policy:

1. Every action log entry must include:
   - selected `x_position`;
   - deterministic `decision_reason`;
   - whether a same-level target was found;
   - selected target instance ID or a null/none marker;
   - selected lane index or equivalent horizontal bucket.

2. Focused board-state fixtures must prove:
   - same spawned cocktail + matching target on left => left-shifted action;
   - same spawned cocktail + matching target on right => right-shifted action;
   - same spawned cocktail + no match + left congestion => policy prefers a safer non-left lane;
   - identical board state repeated => identical action.

3. Qualification-cohort action-log validation:
   - for every trial with at least 5 shots, the report must calculate `unique_x_positions`;
   - a trial with all shots at one identical x is **not acceptable as evidence of merge-aware play** unless every action includes a specific deterministic rationale showing why the same target/lane remained optimal;
   - across the 30-trial qualification cohort, at least **80% of trials with >=5 shots must use at least 2 distinct x positions**;
   - across each tested level with >=5-shot trials, at least one trial must use at least 2 distinct x positions.

4. The V03 report must include:
   - unique x-position count per trial;
   - percentage of qualifying trials with lateral variation;
   - counts of decision reasons, such as `same_level_target`, `objective_priority`, `low_congestion_lane`, or equivalent;
   - explicit `FIXED_LANE_FAILURE = true/false`.

5. If the lateral-variation gate fails:
   - verdict must be `SOLVER_NOT_QUALIFIED`;
   - no M17-007 classification;
   - no M17-008 tuning.

This observation supplements and supersedes any weaker interpretation of the earlier V03 "merge-aware" requirement.
