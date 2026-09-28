# BCM-M17 V02 Codex Execution Log

Status: **COMPLETE — builder evidence only; awaiting independent ChatGPT audit**

## Scope

- Work item: `BCM-M17` Difficulty Model + Timer Tooling + Telemetry + Seeded Validation Harness, V02 remediation.
- Prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V02.md`.
- Locked criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V02.md`.
- Start HEAD: `c1f6367e4e45f6e4c495d449ffe4e411a4dfb220`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Godot runtime: `4.7.2.stable.official.ed1daf0bf`.

## Sync preflight

- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Initial `git status --short --branch`: clean `main...origin/main`.
- Initial `git remote -v`: canonical GitHub origin configured for `Sekiph82/Beach-Cocktails-Merge`.
- `git fetch origin main`: completed.
- Initial `git rev-list --left-right --count HEAD...origin/main`: `0 5`.
- Clean fast-forward to `origin/main`: completed before implementation.
- Root `TASKS.md`: read only; not edited.

## Implementation

Changed only the active M17 V02 tooling and evidence paths:

- `scripts/campaign/m17_seeded_validation_harness.gd`
  - Separates `TABLE_DANGER`, actual `TIMEOUT`, and bounded `harness_abort` outcomes while preserving `WIN`→`completed`.
  - Adds production-boundary footprint proximity telemetry using GameManager boundary edges.
  - Implements per-drink-instance/per-edge hysteresis: enter at `<= 1.0 px`, release at `> 3.0 px`, count transitions only, and remove stale pairs.
  - Keeps body `contact_count` separate from `rail_contact_count`.
  - Publishes `rail_contact_metric = footprint_proximity_transition_proxy` and threshold metadata.
- `tests/m17_difficulty_validation_probe.gd`
  - Adds production danger-line and production campaign-timer fixtures.
  - Adds controlled rail hysteresis, false-positive, and re-entry fixtures.
- `tools/campaign/m17_baseline_report.gd`
  - Adds versioned V02 report output without overwriting V01.
  - Validates required level IDs, 3 trials per level, outcome totals, `TABLE_DANGER` mapping, seed base, and nonzero rail-proxy evidence.
  - Reports completion, timeout, danger, abort, and rail-event summaries.
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_TELEMETRY_SCHEMA_V02.md`
  - Documents outcome precedence, contact/proximity semantics, hysteresis, stale cleanup, and V02 interpretation boundaries.
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_BASELINE_REPORT_V02.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_BASELINE_REPORT_V02.md`

No canonical level/timer/VIP/reward/HUD/table/physics data was tuned. `TASKS.md` was not modified.

## Commands and exact results

Syntax checks and whitespace:

```text
git diff --check -> PASS (only Git LF/CRLF normalization warnings)
Godot --headless --path . --check-only --script res://tests/m17_difficulty_validation_probe.gd -> PASS
Godot --headless --path . --check-only --script res://tools/campaign/m17_baseline_report.gd -> PASS
```

Focused V02 probe, canonical time scale, run twice:

```text
Godot --headless --path . --script res://tests/m17_difficulty_validation_probe.gd -> exit 0
M17_DIFFICULTY_VALIDATION_RESULT=PASS
Godot --headless --path . --script res://tests/m17_difficulty_validation_probe.gd -> exit 0
M17_DIFFICULTY_VALIDATION_RESULT=PASS
```

The focused probe passed production fixtures for:

- danger-line `TABLE_DANGER` terminal preservation and danger classification;
- production campaign timer `TIMEOUT` terminal preservation and timeout classification, not danger;
- one near-rail transition per drink/edge;
- no repeated count while continuously near;
- no false event for a centered footprint;
- release beyond `3 px` followed by re-entry creating one new event;
- same-seed action-log reproducibility and exact replay;
- canonical Sunny Cove JSON byte-for-byte immutability.

Corrected V02 cohort:

```text
Godot --headless --path . --script res://tools/campaign/m17_baseline_report.gd -- --m17-report-version=V02 --m17-trials=3 --m17-seed-base=17000000 --m17-time-scale=4.0 -> exit 0
M17_BASELINE_REPORT_RESULT=PASS levels=20 trials=60
```

Independent report inspection:

- Required levels: `1,10,11,20,21,30,31,40,41,50,51,60,61,70,71,80,81,90,91,100`.
- Total: `20 × 3 = 60` trials.
- Seed formula: `17000000 + level_id * 1000 + trial_index`.
- Outcome totals: `danger=54`, `timeout=6`, `completed=0`, `harness_abort=0`.
- Terminal reasons: `TABLE_DANGER=54`, `TIMEOUT=6`.
- `TABLE_DANGER` misclassification count: `0`.
- Trials with nonzero `rail_contact_count`: `9`.
- Report metric: `footprint_proximity_transition_proxy`.
- Thresholds: enter `1.0 px`, release `3.0 px`.
- V01 report remains present and was not overwritten.

Required regression probes:

```text
Godot --headless --path . --script res://tests/m16_sunny_cove_content_probe.gd -> exit 0
M16_SUNNY_COVE_CONTENT_RESULT=PASS
Godot --headless --path . --script res://tests/m15_vip_boosters_economy_probe.gd -> exit 0
M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS
Godot --headless --path . --script res://tests/m02_physics_regression.gd -> exit 0
M02_PROBE_RESULT=PASS
```

## Manual checks and unavailable checks

- Read and inspected the active V02 execution prompt and audit criteria.
- Confirmed the repository remained limited to M17 V02 implementation, probe, schema, report, and log paths.
- Confirmed generated Godot translation sidecars were not left in the repository; known generated sidecars were moved to `C:\Users\sekip\.codex\m17-generated-sidecars`.
- No native owner visual acceptance, device acceptance, clean-machine acceptance, or independent audit was performed by Codex.
- The M15 headless run reported its existing `M15_CAPTURE_UNAVAILABLE ... HEADLESS_DISPLAY` notices; the authoritative M15 assertions still passed.
- This log is builder evidence, not a milestone acceptance verdict.

## Known limitations

- The 60-trial cohort uses the prompt-authorized `4.0` accelerated physics time scale for bounded execution; the focused reproducibility probe uses canonical scale `1.0`.
- The deterministic lane-placement bot is not an optimal-human model; danger/timeout frequencies are observations, not tuning decisions.
- Rail telemetry is explicitly a footprint-to-authoritative-boundary transition proxy, not a `body_entered` rail collision callback.

## Publication and final sync

- Intended changes are limited to the files listed above.
- Implementation and evidence are committed together for this V02 handoff.
- Final commit SHA, local/remote equality, and `git ls-remote` proof are recorded below after publication.
- Final status must be clean and the checkout must be synchronized with `origin/main`.
- Independent ChatGPT audit remains required; Codex does not update `TASKS.md` or assign the milestone verdict.
