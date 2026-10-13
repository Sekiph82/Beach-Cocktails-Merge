# BCM-M33 R02 calibration evidence

## Result

The static screen found no objective-input, equal-level merge-closure, To-Go target-policy, no-timer, or canonical 4T move-limit violations among 899 generated candidates. It found 307 conservative VIP-intermediate heuristic flags among 434 VIP-enabled candidates. These flags are not proof that VIP delivery is forced: production `GameManager` applies `M17VipOptionalityModel` reserve checks before optional VIP capture.

The capped real-physics pilot completed three stratified candidate trials and two global-101 controls. Candidate trials completed 0/3 within their deterministic per-level launch budgets. This is evidence only for those seeds and the `MERGE_AWARE_V01` policy; no level is classified impossible. One known previously successful control seed completed its normal objective in 11 launches out of 12. A second control seed exhausted 12 launches without completing.

## Pilot design and equations

- Normal theoretical T is `sum(2^(target_level - 3) * quantity)` over normal To-Go orders. VIP T is reported separately.
- The production move-limit invariant checked was `4 * (normal T + enabled VIP T)`.
- A planning lower-bound launch budget was `ceil(12*T/7)`, derived from the expected L1-equivalent cost of a random L1/L2/L3 launch mix (mean value 7/3). The global-101 control floor was 12 launches, based on the prior 11-launch successful R01 seed.
- Candidates used deterministic seed `33050100 + global_level_id * 100`; global 101 used known successful seed `33050200` for the confirmation control. The separate exploratory control seed was `33060200`.
- Physics scale was 1.0, concurrency 1, policy `MERGE_AWARE_V01`, and no timer was enabled. The runner had a hard 900-second wall cap with a 2-second shutdown/flush reserve.
- Per-trial wall allowance used the smaller of remaining global time (minus reserve) and 1.12 seconds per budgeted launch, with a 20-second minimum for the control.

| Global level | Island / band | Normal T | Launch budget | Result | T progress | Trial wall |
| ---: | --- | ---: | ---: | --- | ---: | ---: |
| 202 | Azure Bay / EXPERT_ENTRY | 80 | 138 | Not completed within budget | 16/80 | 140.077 s |
| 304 | Coconut Beach / EXPERT_PLUS_ENTRY | 80 | 138 | Not completed within budget | 16/80 | 140.259 s |
| 479 | Sunset Island / MASTER_CAPSTONE | 256 | 439 | Not completed within budget | 64/256 | 445.268 s |

The candidate results show useful live progress but no completed candidate qualification. A third repeat per level, more policy runs, or broad physical qualification cannot fit the requested time envelope.

## Cost and confidence limits

Across 899 candidates, total normal T is 414,524. The sum of one-seed expected-spawn budgets is 710,994 launches; median per-level budget is 604. At the observed rates this projects to 200.43 hours using the R02 candidate rate or 211.03 hours using the R01 aggregate rate for one seed per candidate; three seeds project to 601.28–633.09 hours. This is only a budget projection: it excludes placement overhead, strategy failures, retries, and human play, and the pilot did not complete a candidate at these budgets.

There were 0/3 candidate completions across distinct stratified recipes with one seed each. Although 0/3 has a one-sided 95% binomial upper reference of 0.6316 under identical independent trials, those assumptions do not hold for this intentionally heterogeneous sample. No campaign-wide success-rate interval is supported.

## Recommended next step

Stop broad physics qualification at the analytic/content-design decision gate. Use the all-candidate static report plus the sampled progress curves to identify which difficulty bands or recipe features merit a separately authorized focused study. If additional empirical calibration is approved, make it a small sequential experiment with a fixed wall budget, several seeds per selected recipe, a declared completion definition, and shot budgets informed by observed progress per launch. Do not use the current data to rewrite candidate levels, lower difficulty, or label levels impossible. The current evidence supports no content or gameplay change.

## Evidence files

- `static_diagnosis.json` — all-candidate structural screen and aggregate T/VIP counts.
- `calibration_trials.jsonl` — the initial bounded pilot with per-action progress telemetry.
- `known_control.jsonl` — successful R01-seed confirmation replay under the final runner.
- `calibration_summary.json` — pilot outcomes, cost projections, confidence caveat, source/test hashes, and resource accounting.
- `run_metadata_initial_740_sec_pilot.json` and `run_metadata_known_control.json` — runner identity, seed/policy/cap configuration, source hashes, and isolated Godot user-data identity.
- `pilot_console_initial_v1_0_0.txt`, `pilot_stderr_initial_v1_0_0.txt` — initial pilot console evidence. The initial runner's resume parser logged a blank-line parse warning; v1.0.2 corrected blank-line handling and the final control replay used that version.
- `known_control_console.txt`, `known_control_stderr.txt` — final known-control run.
- `resume_check_console.txt`, `resume_check_stderr.txt` — identical resume key appended no duplicate row; output remained 5,393 bytes and one line.

The initial pilot used runner v1.0.0; its raw log and metadata are retained. The control replay and resume check used v1.0.2 after fixing the blank-line parser and status-classification ordering. All output was written under a unique Godot app-user-data identity derived from this worktree and date. The large `.godot` import cache was pre-existing in the worktree and reused. The sampled peak working set was 263,950,336 bytes; this is the largest periodic sample, not a continuous high-water measurement. The main batch used 518.391 CPU seconds and 742.214 wrapper wall seconds; its Godot-reported elapsed time was 739.998 seconds. The complete pilot evidence listed in the summary occupies 337,719 bytes.

## Reproduction and validation

From repository root, with Godot 4.7.2 and Python available:

```powershell
godot_console.exe --headless --path . --script res://tools/campaign/m33_r02_static_diagnosis.gd
godot_console.exe --headless --path . --script res://tools/campaign/m33_r02_calibration_pilot.gd -- --global-budget-sec=900
python tools/validate_m33_campaign_content.py
godot_console.exe --headless --path . --script res://tests/m33_tiki_compatibility_probe.gd
godot_console.exe --headless --path . --script res://tests/m17_vip_optionality_probe.gd
```

For a bounded control-only replay, pass `-- --level-list=101 --output=res://.../known_control.jsonl --global-budget-sec=45`. The pilot-level selection defaults to `[101,202,304,479]`; total execution time clamps to 900 seconds. To resume, reuse the same output path; rows are keyed by runner version, source digest, seed, shot budget, and policy, and duplicate rows are skipped. The complete executed command lines and results are recorded in the execution log and console evidence.

The Python static validator result was `PASS_STATIC_CANDIDATE_CHECKS_PHYSICS_NOT_CERTIFIED` (900 total records: 12 preserved M32 Tiki records and 888 generated candidates). The Tiki compatibility probe and VIP optionality probe both passed. Godot emitted scene UID fallback warnings in those probes; they resolved to text resource paths and did not fail the probes. These are builder checks only. Owner/native visual acceptance and independent ChatGPT audit remain pending.
