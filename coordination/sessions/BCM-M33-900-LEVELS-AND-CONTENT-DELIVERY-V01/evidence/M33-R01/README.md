# BCM-M33-R01 Physics Qualification Evidence

## Scope and result

This is a bounded, partial production-physics qualification for BCM-M33-R01. The matrix covers all 899 candidate IDs (102–1000), with global 101 recorded as the Tiki regression control. The run executed 14 trial rows: one control and 13 candidate trials across 11 candidate levels. Eleven candidates are `NOT_COMPLETED_WITHIN_BUDGET`; the other 888 remain `NOT_RUN/ERROR`. No candidate is classified as impossible or reachable. The bounded samples do not justify generated-content changes.

The recorded candidate trials used Godot 4.7.2, `MERGE_AWARE_V01`, physics scale 1.0, no level timer, at most 60 shots, and a 30-second per-trial wall cap. Control levels 101–103 were run with 30 shots and a 15-second cap. The first candidate batch used a 360-second global cap; its additional seed batch used 120 seconds. The trial rows record their budgets, seed, shots, wall and simulated time, To-Go/VIP state, move usage, stars, and action-log hash. Total evidence is 384 shots, 402.75 simulated seconds, and 410.309 seconds of recorded trial wall time.

These caps are too short to assess full level reachability. The cross-island samples stopped at 31 shots after roughly 33 seconds in the 30-second trials; the static validator reports per-island median theoretical normal-order shot counts from 100 to 816. Exhausting a sampled seed or time budget is not evidence that a level is impossible. Human playability and owner visual/mobile acceptance remain separate gates.

## Files

- `qualification_trials.jsonl` — append-only per-trial evidence, including the Tiki control and candidate seeds.
- `coverage_matrix.json` — exact 899-level status matrix and per-island counts.
- `representative_traces.jsonl` — one first-action trace for each island represented by the trials.
- `run_metadata.json` — identity and settings of the most recent batch; per-trial settings for all batches are preserved in the JSONL rows.

## Reproduce or resume

Run from the repository root after Godot has imported the project and the project identity points to an isolated user-data directory:

```powershell
godot_console.exe --headless --path . --script res://tools/campaign/m33_r01_physics_qualification.gd -- --level-list=201,1000 --trials=2 --seed-base=33040100 --max-shots=60 --per-trial-wall-sec=30 --global-budget-sec=120 --output=res://coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R01/qualification_trials.jsonl --traces=res://coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R01/representative_traces.jsonl
python tools/campaign/summarize_m33_r01_physics.py coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R01/qualification_trials.jsonl coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R01/coverage_matrix.json
```

The runner writes each finished trial before proceeding and resumes matching runner, level, seed, shot cap, per-trial wall cap, content manifest, and gameplay policy keys. Use a new output file if changing the runner or qualification configuration in a way that should create a separate evidence series. Keep batches sequential; do not launch concurrent instances against the same files or sandbox.

## Validation evidence

- `python tools/validate_m33_campaign_content.py` — `PASS_STATIC_CANDIDATE_CHECKS_PHYSICS_NOT_CERTIFIED`; 900 campaign records, 12 preserved M32 Tiki records, 888 generated records, globally unique full recipes, Sunny Cove checksum preserved.
- `godot_console.exe --headless --path . --script res://tests/m33_tiki_compatibility_probe.gd` — `M33_TIKI_COMPAT_RESULT=PASS`; Tiki L1 production physics and campaign/world-map/results/retry/save-reload checks passed.
- `godot_console.exe --headless --path . --script res://tests/m17_vip_optionality_probe.gd` — `M17_VIP_OPTIONALITY_RESULT=PASS`; normal-order priority, mandatory reserve, VIP optionality/rewards checks passed.
- The R01 runner's Godot `--check-only` parse, matrix generation, and `git diff --check` passed after the final checkpoint change.

The full editor import on this host stalled while importing the large project cache. Qualification therefore ran in a managed worktree with its own unique Godot project identity and actual `user://` location. Only the required generated import sidecars/cache entries were copied from the existing canonical import cache; no owner save data was used or changed. This evidence does not claim a clean full-project import or owner device acceptance.
