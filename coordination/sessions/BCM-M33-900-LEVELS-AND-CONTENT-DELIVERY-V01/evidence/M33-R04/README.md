# BCM-M33 R04 difficulty evidence

This report compares the R03 analytic baseline with the deterministic R04 candidate data for the 888 generated rows only. Sunny Cove 1–100 and Tiki L1–L12 are excluded from the before/after population. Static legality and launch-count estimates are not physics or human-playability certification.

## Summary

- Generated rows: 888; ordinary generated rows with normal T ≤56: 879/879; nine marked level-100 capstones are excluded from that ordinary ceiling.
- Normal T median/p90/max: 352/1040/1600 before; 44/56/80 after (capstones included).
- Planning-only expected normal launches use 12T/7: median duration at 1.5–3 seconds/launch is 1.89–3.77 minutes after. This estimate omits human variance, physics failures, merges, interruptions, and retries.
- The 2–5 minute typical and ≤8 minute p90 human targets remain unmeasured; schedule the playtest below before claiming fairness.
- `move_limit = 4 × inclusive total T` and all three score-star thresholds remain unchanged; optional VIP T remains in the denominator. See examples for its optional budget impact.
- Full recipes are unique within each generated island. Global full-recipe repeats are allowed and explicitly counted in `generation_report.json`; cross-island matches are not treated as intra-island repetition.

## Per-island comparison

See `before_after_island_metrics.csv` for medians, p90, maxima, VIP counts, duplicate counts, step maxima, ordinary ceilings, and capstone T by island. `representative_level_examples.csv` gives generated-entry (Tiki 13; other islands 1), middle (50), late ordinary (90), and capstone (100) examples for all nine islands.

## Bounded human playtest proposal (not performed)

After owner review of the candidate content, recruit 3 players and run three ordinary samples per island (generated-entry, local level 50, and local level 90): 81 level attempts maximum, one attempt per sample/player, no timer or coaching, record wall time, committed shots, wins/losses/retries, objective comprehension, frustration rating, and observed physics dead ends. Stop after 90 minutes per player or any reproducible softlock. Review the 27 sample-level p90 only as exploratory evidence; it is too small to establish population p90. Test the nine marked capstones separately as optional prestige content, one attempt per player per capstone, with no effect on ordinary completion estimates. No human sessions were run for this handoff.

## Limits and open evidence

The analytic conversion 12T/7 derives from the R03 planning model. It is a scenario estimate, not gameplay telemetry. Bounded deterministic physics probes cover a small fixed sample only; neither those probes nor this report certify all 888 recipes or human fairness. Preserve the disclosed 361 cross-island recipe repeats reported by the generator.

See [`qualification_notes.md`](qualification_notes.md) for the Godot content/navigation probe results and bounded production-physics samples, including the per-trial timeouts and their limits.
