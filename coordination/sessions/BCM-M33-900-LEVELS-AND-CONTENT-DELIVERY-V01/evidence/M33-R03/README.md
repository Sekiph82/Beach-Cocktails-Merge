# BCM-M33 R03 analytic difficulty review

## Scope and conclusion

This is a read-only analysis of the 1,000 packaged campaign levels and a necessary-condition screen of global levels 102–1000 (899 records). That slice contains 11 frozen M32 Tiki records, global 102–112; the full packaged campaign has 12 preserved Tiki levels at 101–112 and 888 new generated recipes. Sunny Cove and the accepted M32 seed levels were analyzed in place and not modified.

The screen found 0 structural data errors among 1,000 levels and 899/899 `CERTIFIED_DATA_LEGAL` records in the requested candidate slice. It reproduces the R02 count of 307 conservative VIP-intermediate flags. The workload heuristics mark 865 candidates `ANALYTICALLY_SUSPICIOUS`; this means review the objective load or optional-VIP interaction, not that a level is impossible. All 899 candidates remain `PHYSICS_UNVERIFIED` and `HUMAN_FAIRNESS_UNVERIFIED`.

The current candidate slice has normal T median 352, p90 1,040, and max 1,600. At the documented uniform L1/L2/L3 spawn assumption (mean L1-equivalent value 7/3), that is a median 604 expected launches and a max 2,743. Of 899 candidates, 864 are at 100+ expected normal launches, 532 at 500+, and 286 at 1,000+. At the explicitly provisional 1.5–3.0 seconds per expected launch, the median planning-only estimate is about 15–30 minutes before aiming, settling, menu, retry, or strategy overhead. These are workload estimates, not measured human results and not physics completion predictions.

## Aggregate view

| Island | Normal T median | Expected launches median | p90 launches | Max launches | Median planning minutes | 100+ levels | 500+ levels | 1,000+ levels | VIP levels | Normal-template repeat rate |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Sunny Cove | 32 | 55 | 89 | 103 | 1.37–2.74 | 1 | 0 | 0 | 25 | 71% |
| Tiki Island | 88 | 151 | 247 | 302 | 3.77–7.54 | 68 | 0 | 0 | 29 | 18% |
| Azure Bay | 192 | 329 | 494 | 603 | 8.23–16.46 | 98 | 10 | 0 | 36 | 18% |
| Coconut Beach | 304 | 521 | 768 | 1,371 | 13.03–26.06 | 100 | 51 | 4 | 52 | 18% |
| Sunset Island | 400 | 686 | 1,426 | 2,085 | 17.14–34.29 | 100 | 66 | 36 | 44 | 6% |
| Party Beach | 416 | 713 | 1,536 | 2,304 | 17.83–35.66 | 99 | 75 | 37 | 51 | 8% |
| Frozen Paradise | 560 | 960 | 1,783 | 2,743 | 24.00–48.00 | 100 | 83 | 41 | 52 | 8% |
| Volcano Bay | 544 | 933 | 1,810 | 2,304 | 23.31–46.63 | 100 | 75 | 44 | 56 | 8% |
| Billionaire Island | 640 | 1,097 | 2,030 | 2,688 | 27.43–54.86 | 99 | 88 | 62 | 48 | 9% |
| Final Island | 672 | 1,152 | 2,085 | 2,661 | 28.80–57.60 | 100 | 84 | 62 | 66 | 3% |

Island medians include the 12 preserved Tiki seed levels. Each island has 100 player-facing levels; candidate-only counts are in the JSON report. The CSV contains every level, including exact ordered To-Go objectives, optional VIP, T, expected-launch estimate, 4T limit, star ceilings, hypothetical planning duration, and review labels.

## Model and labels

- Cocktail L1-equivalent cost is `2^(level-1)`. For normal To-Go objectives, `T = sum(2^(target_level-3) * quantity)`; enabled VIP T is calculated separately.
- The production database sets the total launch move allowance to `4 * (normal T + enabled VIP T)`. The production session bridge awards 1 star for completion by 4T, 2 stars by 3T−1, and 3 stars by 2T−1. Score and optional VIP completion do not change this calculation. Because VIP T is included in the denominator even when VIP is optional, VIP can enlarge both the move allowance and the star denominator; this is existing behavior, reported for owner review only.
- Expected normal launches assume independently uniform random L1, L2, or L3 launches, with mean L1-equivalent value 7/3. The script reports the non-rounded expectation and a separate ceiling as a planning budget. It excludes random variance, merge placement, board congestion, missed strategy, retries, and player skill.
- The 1.5–3.0 second duration interval uses the provisional `M17DifficultyModel` 1.5-second launch cadence and its 1×–2× planning multiplier. It excludes aiming and settling and is not human-test evidence.
- `CERTIFIED_DATA_LEGAL` means target levels are inside production and island policies, quantities are positive integers, merge-cost arithmetic is representable, IDs are stable, the timer remains disabled, and any stored T / 4T fields agree. Legacy Sunny Cove rows may omit derived T and move-limit fields; those are calculated with the production formula and checked only when stored fields exist.
- `ANALYTICALLY_SUSPICIOUS` marks workload thresholds (normal T≥64 or ≥100 expected launches), a 50% adjacent-level T jump, or a conservative VIP reserve/target-intersection heuristic. No suspicion flag is a physical impossibility proof.
- Every generated candidate receives `PHYSICS_UNVERIFIED` and `HUMAN_FAIRNESS_UNVERIFIED`. No 899-level physics simulation was run.

## Progression and recipe findings

The analysis computes all 999 adjacent global level transitions, separated into 990 within-island transitions and nine island boundaries. It records absolute and percentage T movement, expected-launch movement, difficulty-band changes, and largest within-island steps. Some adjacent steps multiply workload several-fold; the top list in `all_level_difficulty_analysis.json` includes global 903→904 (T 96→1,024), 810→811 (80→768), and 974→975 (144→1,312). These are direct recipe-data observations, not claims that a player will experience exactly that duration.

The 899-record candidate slice has 899 unique complete ordered recipes when VIP is included, but only 571 unique ordered normal templates (328 repeat records). The 888 newly generated records have 888 unique full recipes and 560 unique normal templates. This matches the content generator's distinction between varied full challenge recipes and repeated normal objective templates. Per-island full/normal diversity and maximum repetition are recorded in the all-island JSON.

The 307 VIP warnings use the same conservative rule as R02: higher mandatory normal objectives can create VIP-level intermediates. Each affected candidate is labeled `RESERVE_SENSITIVE_RUNTIME_CHECK_REQUIRED`. The production `M17VipOptionalityModel` reserves mandatory normal objective capacity before optional VIP interception. The warning identifies a recipe that merits reserve-path testing; it is not proof of forced VIP delivery.

## Proposal and reproduction

See `owner_difficulty_redesign_proposal.md` for the nine-island proposal-only before/after concepts, budget options, bounded human playtest, proposed narrow physics follow-up gate, and explicit owner decision questions. No level data, generation profile, 4T rule, star formula, IDs, save state, or gameplay source was changed.

From repository root:

```powershell
python tools/campaign/m33_r03_difficulty_analytics.py
python -m unittest discover -s tests -p test_m33_r03_difficulty_analytics.py -v
python tools/validate_m33_campaign_content.py
```

`execution_metadata.json` records the analysis source/input hashes, exact source/input bytes, wall time, process CPU time, and output file sizes. The run is static Python only: no Godot process, `user://` data, physics trial, or network/store activity was used. Raw outputs are deterministic for unchanged sources; runtime timing fields vary by machine/run.
