# BCM-M33 R03 owner difficulty proposal — decision required before recipe edits

**Proposal only.** The current campaign recipes, generator profiles, save/ID map, 4T move rule, star calculation, Sunny Cove, and M32 Tiki L1–L12 remain unchanged. No proposal below is implemented. Please review the decision questions at the end before any later content-design task edits recipe data.

## Finding

The current generated challenge range grows from Tiki Island median normal T 88 (about 151 expected launches) to Final Island median T 672 (about 1,152 expected launches). The candidate-slice median is T 352 (about 604 expected launches). Under the explicitly provisional 1.5–3.0 seconds per expected launch assumption, that is roughly 15–30 minutes of launch cadence at the median before aiming and board-settling overhead. The upper candidates reach 2,743 expected launches. Human duration is not measured, but this workload is large enough to require an owner choice about intended session length.

The three R02 candidate physics trials made some progress and did not complete; this report uses no failed seed as an impossibility claim. The R02 independent audit accepts that calibration's bounded scope and leaves candidate physical reachability and human playability unverified.

## Recommended design direction

Use a **short-session normal-objective envelope** for ordinary levels: aim for normal T 40–56, with a soft ceiling at T=56 (96 expected launches under the current spawn assumption). Keep generated normal To-Go targets at L6 or above so levels 101+ retain the advanced cocktail identity; do not return them to Sunny Cove's introductory recipe style. Control the workload primarily through the number of simultaneous mandatory objectives and their quantities.

Suggested band shape, expressed as normal T rather than level IDs:

| Island | Suggested normal T envelope | Example normal objective mix | Expected launches at envelope maximum |
| --- | ---: | --- | ---: |
| Tiki Island, after frozen L1–L12 | 40–56; first generated band starts at ≥48 | Two distinct L7–L8 orders; optional VIP only after reserve review | 96 |
| Azure Bay | 44–56 | Two or three distinct L6–L8 orders | 96 |
| Coconut Beach | 48–56 | Three distinct L6–L8 orders or two orders with one quantity 2 | 96 |
| Sunset Island | 48–56 | Alternate two- and three-order L6–L8 recipes | 96 |
| Party Beach | 48–56 | Three-order L6–L8 combinations; avoid adding a fourth high-cost order | 96 |
| Frozen Paradise | 48–56 | Raise combination variety and objective order while holding total T | 96 |
| Volcano Bay | 48–56 | Keep normal goals in the L6–L8 envelope; use higher target only by explicit exception | 96 |
| Billionaire Island | 48–56 | Retain higher targets as optional VIP or a rare owner-approved capstone | 96 |
| Final Island | 48–56 | Combine three objectives and reserve-safe optional VIP; do not make L10–L12 routine | 96 |

This keeps the first post-seed levels near the preserved Tiki L12 workload (global 112 is T=48) and does not reset later islands to tutorial cocktail levels. It is a workload envelope, not a locked final design. Island progression can still increase target variety, number of distinct normal objectives, order interactions, and optional VIP decision complexity, but human tests must confirm those variations feel harder without becoming longer or unfair.

An alternative **prestige-capstone** track could permit rare normal T above 56, with explicit labels and expected launch costs. For reference, one L9 objective alone is T=64 (about 110 expected launches); one L10 is T=128 (about 219 launches); L11 is T=256 (about 439 launches); L12 is T=512 (about 878 launches). Each additionally requires any other mandatory objective to be added to T. Those costs are the consequence of the current merge algebra; quantity reduction cannot make a single L12 order short. The owner should choose whether such capstones are intentional long-session challenges or whether L10–L12 remain optional VIP targets.

## Nine before/after concepts

“Current” examples are actual local-level 50 records from each island. “Concept” examples keep every normal target at L6+ and stay at or below the recommended T=56 ordinary workload envelope. The after recipes are sketches for discussion only; they do not specify final IDs, reward values, VIP settings, or a production rewrite.

| Island / current sample | Current normal orders, VIP, and T | Proposal-only concept | Why this is different |
| --- | --- | --- | --- |
| Tiki Island L50 (global 150) | L7×1 + L6×1 + L9×1; no VIP; T=88 | L7×1 + L8×1; T=48 | Keep the post-seed L6+ identity while reducing the three-goal capstone workload. |
| Azure Bay L50 (250) | L9×1 + L8×1; VIP L10×1; T=96 | L6×1 + L7×1 + L8×1; T=56 | Preserve a multi-order entry while reserving the L10 goal for optional VIP. |
| Coconut Beach L50 (350) | L10×1 + L9×2; VIP L7×1; T=256 | L6×1 + L7×1 + L8×1; T=56 | Replace a quantity-heavy high-target bundle with three readable goals. |
| Sunset Island L50 (450) | L11×1 + L8×1; no VIP; T=288 | L6×1 + L7×1 + L8×1; T=56 | Use combinations and level sequencing for difficulty rather than a mandatory L11 cost jump. |
| Party Beach L50 (550) | L11×1 + L8×1 + L7×1; no VIP; T=304 | L6×1 + L7×1 + L8×1; T=56 | Keep three objectives but bound their total launch workload. |
| Frozen Paradise L50 (650) | L11×1 + L9×2 + L7×1; no VIP; T=400 | L6×1 + L7×1 + L8×1; T=56 | Retain combination complexity without a four-order high-level stack. |
| Volcano Bay L50 (750) | L10×1 + L7×2 + L9×1; VIP L12×1; T=224 | L6×1 + L7×1 + L8×1; optional VIP L9 only after reserve check; T=56 | Move the very expensive L12 from routine workload to an opt-in target. |
| Billionaire Island L50 (850) | L10×1 + L12×2 + L8×1; VIP L7×1; T=1,184 | L6×1 + L7×1 + L8×1; rare L12 VIP only; T=56 | Avoid making two L12 drinks mandatory; display any selected L12 capstone cost clearly. |
| Final Island L50 (950) | L8×1 + L10×1 + L7×2; no VIP; T=192 | L6×1 + L7×1 + L8×1; rare high-target prestige capstone only by choice; T=56 | Keep a final-island combination challenge while separating campaign completion from a long-run optional challenge. |

The concepts deliberately show the workload trade-off, not a final recipe map. The “after” column keeps To-Go goals at L6–L8 to satisfy the proposed short-session envelope. If the owner wants mandatory L9–L12 objectives to remain common, select the prestige-capstone alternative and accept the per-level launch and duration estimates rather than silently shrinking other rules.

## Difficulty band and objective rules to consider

1. Preserve campaign ordering and all canonical IDs. No shuffle, reset, or level deletion.
2. For generated levels 101+, keep normal targets at L6 or above; Tiki L1–L12 remain frozen as owner-approved M32 seed content.
3. Use normal T as the workload budget. Start ordinary post-seed recipes near the last preserved Tiki seed workload and raise the envelope gradually across islands; avoid single adjacent-level jumps above 50% unless they are named capstones and tested as such.
4. Prefer distinct objectives with quantity 1; use quantity 2 sparingly and count it fully in T. Repeated normal templates may exist for authored pacing, but track intentional repeats and avoid relying on near-identical recipes as perceived progression.
5. Keep VIP optional. Run the production reserve checker on every recipe with VIP-intermediate flags; a warning needs proof that mandatory normal capacity stays protected, not an assumption that the VIP is forced.
6. Keep the current 4T rule and star thresholds frozen until the owner decides whether optional VIP T should continue to enlarge both the move limit and the star denominator. This report does not authorize changing that rule.
7. Treat L10–L12 normal orders as explicit long-session content. Publish their expected launch cost beside the authored recipe. Under current algebra these cannot be made low-workload merely by reducing quantity to one.

## Bounded human playtest proposal

Run only after the owner chooses an envelope and the content owner produces a frozen prototype set. This proposal runs no tests and creates no recipes.

- First pass: 9 levels, one from each generated island, stratified near the proposed entry workload; three testers per level (27 sessions maximum). Each tester plays one level once, with standard instructions and no coaching after start.
- Second pass, only if the first passes its decision gates: 9 additional levels, one combination-heavy or capstone-like sample per island, with three testers per level (another 27 sessions). Keep normal-completion set separate from optional VIP completion.
- Record attempts, elapsed wall time, launches, board resets/retries, normal objective completion, move count, star result, VIP status, self-reported difficulty (1–5), frustration/quit point, and open-ended confusion. Capture version, device, and session conditions; do not infer population-level fairness from 3 testers per level.
- Predeclare an owner-approved target time. Recommended pilot discussion range: median 2–5 minutes for ordinary levels, 90th percentile ≤8 minutes, no softlock, no unexplained mandatory VIP interception, and ≥2/3 testers finish the normal objective within 4T. These are proposed gates for owner approval, not existing acceptance criteria.
- If a normal recipe misses its time/completion gate, revise the prototype under owner direction and retest that small stratum; do not expand to campaign-wide simulation.

## Conditions for a later narrow physics run

Only request a physics run after: (a) owner selects the normal-T and capstone direction, (b) prototype recipes are frozen and static-data-legal, (c) deterministic unit checks verify 4T/stars and VIP reserve behavior, (d) human pilot identifies a small risk set, and (e) each run has a fixed seed count, shot cap, wall cap, isolated app-user-data identity, and evidence path. Limit the initial later sample to at most one ordinary and one flagged/high-target level per island, two deterministic seeds each (18 levels / 36 trials maximum), with a user-approved wall budget. Stop on repeated no-progress curves or budget exhaustion. Never infer global solvability from that sample.

## Owner decisions requested

1. Choose the ordinary normal-T envelope: recommended **T≤56** (≤96 expected launches), or a higher **T≤72** (≤124 expected launches).
2. Should L9–L12 remain mandatory normal goals in routine levels, or be limited to rare owner-approved prestige capstones / optional VIP targets?
3. Approve, revise, or reject the proposed human test time and completion gates before any human study.
4. Confirm the existing 4T denominator continues to include optional VIP T for both move budget and stars, or authorize a future separate rule-design task. No rule change is included here.

Until those decisions are recorded, retain the existing candidate recipes and treat this proposal as unapproved design evidence.
