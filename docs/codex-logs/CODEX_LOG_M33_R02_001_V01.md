# Codex Execution Log — BCM-M33-R02 V01

Status: IMPLEMENTATION COMPLETE — AWAITING INDEPENDENT AUDIT

## Scope

Diagnose BCM-M33 R01 qualification limits, calibrate a small deterministic stratified production-physics pilot within the locked 15-minute total execution ceiling, and publish a cost/feasibility report with a resumable path. Do not edit root `TASKS.md`, alter content/gameplay, or claim impossibility from failed trials.

## Start state

- Start HEAD: `44adda7d69cf6ea83adfa5697c761da2a0072703` (`origin/main` after sync).
- Canonical Desktop safe sync: seven tracked owner-local files preserved by tracked-only stash `owner-local-safe-sync-bbd7cd1`; untracked owner files left untouched; incoming paths were disjoint.
- Implementation checkout: existing managed worktree outside Desktop at `C:\Users\sekip\.codex\worktrees\bcm-m33-r01-physics\Beach Cocktails - Merge`, fast-forwarded from `bbd7cd1` to start HEAD.
- Branch: `codex/m33-r01-physics`; remote: `origin` → `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Active prompt: `coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/CHATGPT_M33_R02_CALIBRATION_MASTER_PROMPT_V01.md`.

## Findings and evidence

### Source-derived qualification model

- `scripts/campaign/m17_difficulty_model.gd` computes cocktail cost as `2^(level - 1)`; normal order cost is the sum of level cost times quantity. `scripts/campaign/level_database.gd` derives L3-equivalent `T = sum(2^(target_level - 3) * quantity)` and requires move limit `4 * (normal T + enabled VIP T)`.
- Production `scripts/shot_controller.gd` launches levels 1–3, `scripts/drink.gd` merges equal levels up to L12, and `M17CanonicalScreeningModel.reachable_closure` includes levels 1–12. These establish necessary arithmetic/merge closure only, not physical placement reachability.
- `GameManager` uses `M17VipOptionalityModel` mandatory-reserve checks before optional VIP capture. The 307 flagged recipes are conservative higher-order intermediate heuristics, not demonstrated forced VIP interceptions.
- Static scan checked globals 102–1000 (899 generated candidates), plus global 101 control. Result: 0 invalid inputs/policies/merge closure/4T/timer records; 434 enabled VIPs; 307 conservative VIP-intermediate flags. Normal T: min 4, median 352, p90 1040, max 1600.

### Pilot

- Fixed sequential sample: global 101 Tiki control, 202 Azure Bay (EXPERT_ENTRY), 304 Coconut Beach (EXPERT_PLUS_ENTRY), 479 Sunset Island (MASTER_CAPSTONE). Physics scale 1.0, `MERGE_AWARE_V01`, single concurrency, deterministic seeds, no timer, and a 900-second total hard cap with 2-second flush reserve.
- Normal launch budget was `ceil(12*T/7)`, derived as the expected L1-equivalent cost under a uniform L1/L2/L3 spawn mix; global 101 had a 12-launch floor based on its prior 11-launch completion. Trial wall allowance was bounded by remaining global wall time and 1.12 seconds per launch (20-second minimum for the control).
- Candidate outcomes: global 202 T=80, budget 138, 16 T progress, 78 merges, 140.077 wall seconds; global 304 T=80, budget 138, 16 T progress, 80 merges, 140.259 seconds; global 479 T=256, budget 439, 64 T progress, 216 merges, 445.268 seconds. All three ended `NOT_COMPLETED_WITHIN_BUDGET`; none is classified impossible.
- First global-101 control seed 33060200 exhausted 12 shots without completion. Known R01 successful seed 33050200 replayed successfully: 11/12 launches, T=4/4, 11 moves, 6 merges, 10.267 simulated seconds and 10.895 wall seconds. It is a bounded reproducibility control.
- Main initial batch Godot elapsed 739.998 seconds, wrapper elapsed 742.214 seconds, measured child CPU 518.391 seconds. Full runner including 12.894-second control replay and ~1.6-second resume check stayed below 900 seconds. Main-batch largest sampled WorkingSet64 was 263,950,336 bytes (sampled, not continuous high-water). Pilot raw evidence listed in summary totals 337,719 bytes. A pre-existing ~431 MB `.godot` cache was reused, not committed.
- Three candidates had 0 completions out of 3 distinct recipes and one seed each. An IID/exchangeable one-sided 95% binomial upper reference is 0.6316, but assumptions do not apply; no campaign-wide success-rate confidence interval is claimed.
- All 899 candidate normal T values sum to 414,524. One-seed expected-spawn budget totals 710,994 launches (per-level median 604). Observed launch rates project 200.43–211.03 hours for one seed per candidate and 601.28–633.09 hours for three seeds. This excludes placement/strategy failures, retries, and human play; it is not a completion-time guarantee. Since no candidate completed at its budget, physical run time may be larger.

### Changed files

- `scripts/campaign/m17_seeded_validation_harness.gd`: add per-action normal-T progress, completed order/VIP snapshots, merge count, move count, and progress-per-move curve for qualification evidence. This is instrumentation only; production gameplay was not modified.
- `tools/campaign/m33_r02_calibration_pilot.gd`: bounded resumable production-harness pilot, deterministic seeds, per-level budgets, single concurrency, hard wall cap, JSONL output, and source-hash metadata.
- `tools/campaign/m33_r02_static_diagnosis.gd`: canonical all-candidate structural diagnosis through the runtime level database and screening models.
- `tools/campaign/summarize_m33_r02_calibration.py`: aggregate trial, static, projection, confidence caveat, source hashes, and resource evidence.
- `coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R02/`: immutable pilot outputs, summaries, metadata, console captures, and evidence README.
- This log. Root `TASKS.md` is unchanged. No content recipe, gameplay logic, physics tuning, or V05 tutorial file was edited.

### Commands and results

Run from the repository root; `godot_console.exe` was Godot 4.7.2 stable. Pilot arguments after `--` are Godot user arguments. The primary initial run used default `[101,202,304,479]` and the locked 900-second cap; outputs were stored in the evidence directory under isolated project identity `CocktailMerge-M33-R02-Calibration-44adda7-20261013`.

```powershell
godot_console.exe --headless --path . --script res://tools/campaign/m33_r02_static_diagnosis.gd
godot_console.exe --headless --path . --script res://tools/campaign/m33_r02_calibration_pilot.gd -- --global-budget-sec=900
godot_console.exe --headless --path . --script res://tools/campaign/m33_r02_calibration_pilot.gd -- --level-list=101 --output=res://coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R02/known_control.jsonl --global-budget-sec=45
python tools/validate_m33_campaign_content.py
godot_console.exe --headless --path . --script res://tests/m33_tiki_compatibility_probe.gd
godot_console.exe --headless --path . --script res://tests/m17_vip_optionality_probe.gd
git diff --check
```

Results: static diagnosis `PASS candidates=899 invalid=0 vip=434 conservative_vip_intermediate_flags=307`; campaign validator `PASS_STATIC_CANDIDATE_CHECKS_PHYSICS_NOT_CERTIFIED` for 900 total records (12 preserved M32 Tiki + 888 generated), 900 unique full recipes, Sunny Cove source hash preserved. Tiki compatibility and VIP optionality probes both passed. Both probes printed scene UID fallback warnings that resolved via text resource paths. Pilot execution and per-trial outcomes are recorded in `pilot_console_initial_v1_0_0.txt`, `known_control_console.txt`, JSONL, metadata, and summary. The first pilot's raw console captured a blank-line JSON parser warning; v1.0.2 fixed blank-line handling and status classification. Resume check with same output identity returned zero new rows; bytes remained 5,393 and one line. Final source/test hash sets and digests are in `calibration_summary.json` and both run metadata files.

Godot `--check-only` parsing was also run for both new `.gd` tools before the runtime pilot and passed. After the pilot, the temporary `project.godot` application-name change was restored; no matching M33 R02 Godot process remained. `git diff --check` passed. Final commit and parity proof are recorded below after publication.

### Recommendation and limits

No objective infeasibility was found by necessary structural checks, and the pilot did not prove any candidate unreachable. The physical cost projection makes broad mass qualification uninformative within the requested 15-minute window. Stop at the analytic/content-design gate and request a separately scoped focused study if additional empirical evidence is desired. Do not infer difficulty, human fairness, broad playability, or content change from this pilot. Owner/native visual review was not in scope; independent ChatGPT audit remains pending.

### Final repository evidence

- Implementation/evidence commit: `fd0bbeff7356db8f4ff0b98dcdf07854b9fa70de` (`Add bounded BCM-M33 R02 calibration evidence`). Initial publication/log commit: `73b09ba2f56f685801f9de665f4fb4872d9d7a8a` (`Record BCM-M33 R02 calibration execution log`).
- Initial publication parity proof: `git rev-parse HEAD` = `73b09ba2f56f685801f9de665f4fb4872d9d7a8a`; `git rev-parse origin/main` = the same; `git ls-remote origin refs/heads/main` returned the same SHA. A final closeout log amendment follows this initial proof; the final pushed SHA is reported in the closing response.
- `TASKS.md` worktree SHA-256: `5BF6F1E22A534FB0036226B2929DFDA2169836FB710797FC2BCC477E4F64E4EB`; no edit made.
- Branch/remote: existing `codex/m33-r01-physics` worktree branch; publish to existing `origin/main`, no new branch.
- Canonical Desktop post-push sync: fast-forwarded `44adda7d69cf6ea83adfa5697c761da2a0072703` to `73b09ba2f56f685801f9de665f4fb4872d9d7a8a`. The seven tracked owner changes were reapplied from the uniquely named `owner-local-safe-sync-44adda7` stash and hash-verified against its tree. All five untracked owner paths remained present. The stash was retained, no owner paths were staged/committed, and the canonical checkout shows `main...origin/main` with expected owner-local modifications only.

## Stop marker

`AWAITING_GPT_M33_R02_AUDIT`
