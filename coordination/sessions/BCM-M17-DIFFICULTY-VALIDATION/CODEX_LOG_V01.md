# BCM-M17 V01 Codex Log

Status: `AWAITING_M17_AUDIT_V01`. Builder evidence only; independent audit and tracker transition remain with ChatGPT.

## Scope and authority

- Work item: BCM-M17 Difficulty Model + Seeded Validation Harness, M17-001..006 only.
- Prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V01.md`.
- Locked criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V01.md`.
- Start HEAD: `dda223f6624c9f0df6781a6f1ed930d29e9644d8`.
- Branch/remote: `main` / `origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Root `TASKS.md`: read only and byte-for-byte unchanged.

## Sync-first preflight

```text
git status --short --branch       -> ## main...origin/main
git remote -v                     -> origin https://github.com/Sekiph82/Beach-Cocktails-Merge.git
git fetch origin main             -> updated origin/main dda223f
git rev-list --left-right --count HEAD...origin/main -> 0 7
git merge --ff-only origin/main   -> fast-forward to dda223f6624c9f0df6781a6f1ed930d29e9644d8
```

The checkout was clean and behind-only. No reset, rebase, stash, force-push, branch creation, Desktop clone, or Desktop worktree was used.

## Implementation

New files:

- `scripts/campaign/m17_difficulty_model.gd`
- `scripts/campaign/m17_seeded_validation_harness.gd`
- `tools/campaign/m17_baseline_report.gd`
- `tests/m17_difficulty_validation_probe.gd`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_TELEMETRY_SCHEMA_V01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_BASELINE_REPORT_V01.md`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_BASELINE_REPORT_V01.json`

The single reusable model implements `cost(Ln)=2^(n-1)`, normal objective cost, separate VIP cost, L1/L2/L3 values 1/2/4, expected `7/3`, expected spawn count, named overrideable `DEFAULT_SECONDS_PER_LAUNCH=1.5`, raw production time, ×2 planning target, canonical timer delta, and deterministic R7 percentiles.

The harness drives production `GameManager.spawn_drink`, `Drink.launch_up` at 700 px/s, `Drink`, `MergeQueue`, and Godot physics frames through a bounded test hook. It does not call completion APIs to fake physical difficulty. The deterministic bot uses an existing same-level body position where available and a fixed central fallback lane; every spawn level/lane/x action is recorded for replay. Telemetry definitions and bounded proxies are documented in `M17_TELEMETRY_SCHEMA_V01.md`.

## Baseline cohort

- Required levels: `1,10,11,20,21,30,31,40,41,50,51,60,61,70,71,80,81,90,91,100`.
- 3 trials per level, 60 total; report has exactly 20 unique required IDs.
- Seed formula: `17000000 + level_id * 1000 + trial_index`.
- Canonical-scale L1 timeout: approximately 20 seconds wall time for one trial; 10×20 was impractical.
- Used the prompt-authorized minimum 3 trials per level with explicit physics time scale `4.0`; focused reproducibility uses canonical scale `1.0`.
- Retained cohort run segments: 17.5 + 197.2 + 220.7 + 265.9 + 259.1 + 171.4 = approximately 1,131.8 seconds (18m51.8s). The interrupted long run is not counted.
- Reports: `M17_BASELINE_REPORT_V01.md` and `M17_BASELINE_REPORT_V01.json`.

Weak-bot outcomes are labeled `baseline outlier; needs further validation`; no M17-007/008 impossibility or tuning decision is made.

## Commands and results

```text
godot_console.exe --headless --path . --check-only --script res://scripts/campaign/m17_difficulty_model.gd -> PASS
godot_console.exe --headless --path . --check-only --script res://scripts/campaign/m17_seeded_validation_harness.gd -> PASS
godot_console.exe --headless --path . --check-only --script res://tests/m17_difficulty_validation_probe.gd -> PASS
godot_console.exe --headless --path . --check-only --script res://tools/campaign/m17_baseline_report.gd -> PASS
git diff --check -> PASS
```

Focused M17 probe twice at canonical scale:

```text
M17_DIFFICULTY_VALIDATION_RESULT=PASS
M17_DIFFICULTY_VALIDATION_RESULT=PASS
```

Regressions:

```text
M16_SUNNY_COVE_CONTENT_RESULT=PASS, exit 0
M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS, exit 0
M02_PROBE_RESULT=PASS, exit 0
```

The separate `tests/r10_runtime_physics_closure_probe.gd` had pre-existing type-inference parse errors at lines 99/100. Supplementary `tests/r10_v10_visual_hull_containment_probe.gd` exited 1 with existing left/rear geometry failures. Neither was modified or hidden; M02 is the passing authoritative physics regression for this tooling-only change.

## Frozen data and safety

- `data/campaign/levels/sunny_cove.json` was hashed before/after the focused run; the probe reported byte-for-byte unchanged.
- Report anchors: L1 cost 16; L100 cost 240.
- No canonical objective, timer, VIP, reward, scoring, HUD, R11 table/collider, or gameplay production file changed.
- M15 regression rewrote four tracked evidence PNGs. Generated versions were archived outside the repository under `.codex`; exact paths were restored to synchronized HEAD bytes. Generated Godot translation sidecars were also moved outside the repository and not committed.
- `TASKS.md` was not modified.

## Publication

- Implementation commit SHA: to be recorded after the bounded implementation commit.
- Final commit SHA: to be recorded after the immutable log commit.
- Final sync proof after push:
```text
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
```
- Final handoff marker: `AWAITING_M17_AUDIT_V01`.
