# BCM-M17 V03A Codex Execution Log

Status: **COMPLETE — builder evidence only; awaiting independent ChatGPT audit**

## Scope

- Work item: `M17-007` Merge-Aware Solver + Anti-Fixed-Lane Qualification.
- Prompt: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_EXECUTION_PROMPT_V03A.md`.
- Locked criteria: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/CHATGPT_AUDIT_CRITERIA_V03A.md`.
- Owner observation: `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/OWNER_OBSERVATION_V03A.md`.
- Start HEAD: `2c8e2d8431df9db4bca192afe430f37bea25d34b`.
- Branch: `main`.
- Remote: `https://github.com/Sekiph82/Beach-Cocktails-Merge.git`.
- Godot runtime: `4.7.2.stable.official.ed1daf0bf`.

## Sync preflight

- Canonical checkout: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`.
- Initial `git status --short --branch`: clean `main...origin/main`.
- Initial `git remote -v`: canonical GitHub origin configured for `Sekiph82/Beach-Cocktails-Merge`.
- `git fetch origin main`: completed; remote advanced from the previous local HEAD.
- Initial `git rev-list --left-right --count HEAD...origin/main`: `0 10`.
- Clean behind-only fast-forward to `origin/main`: completed before implementation.
- Root `TASKS.md`: read only; not edited. The synchronized working-tree hash matched the start-HEAD `TASKS.md` hash.

## Implementation

Changed only the active M17 V03A solver, validation, report, and evidence paths:

- `scripts/campaign/m17_seeded_validation_harness.gd`
  - Preserves the V02 weak policy as named `WEAK_V02` for overlap comparison.
  - Adds named `MERGE_AWARE_V01` policy selection without changing production spawn, merge, physics, timer, or RNG behavior.
  - Observes only the current spawned level, non-held board drinks, positions, motion states, mandatory objective, timer/danger state, and authoritative GameManager geometry.
  - Prioritizes a same-level board target, selecting the lower-board target and deterministic stable-instance tie break; otherwise scores legal lanes using deterministic lower-board congestion weighting and stable center/lane tie breaks.
  - Derives legal launch buckets from the authoritative GameManager playable boundary using a detached Drink footprint probe.
  - Records `x`, lane index, `decision_reason`, same-level-target boolean, and target instance ID/null for every stronger-policy action.
  - Assigns deterministic logical IDs to merged results so same-seed action logs remain exact across replay runs.
  - Extends trial telemetry with policy name, unique horizontal positions, lateral-variation eligibility/result, and decision-reason counts.
- `tests/m17_difficulty_validation_probe.gd`
  - Adds pure policy fixtures for left-target shift, right-target shift, left-congestion avoidance, identical-state determinism, forbidden future-RNG exclusion, and legal-lane output.
  - Keeps the V02 danger/timeout classification and rail-proximity fixtures.
  - Validates canonical 1.0 time scale, exact same-seed action logs, logical replay outcome, decision evidence, and canonical JSON immutability.
- `tools/campaign/m17_solver_qualification.gd`
  - Runs exactly 30 trials: levels `1, 10, 11, 50, 51, 100`, five trials each.
  - Uses seed formula `17300000 + level_id * 1000 + trial_index` at canonical `Engine.time_scale = 1.0`.
  - Emits machine-readable `FIXED_LANE_FAILURE` and the qualification verdict.
  - Performs V02 weak-policy overlap diagnostics and 1x/4x spot replays.
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_SOLVER_QUALIFICATION_V03.json`
- `coordination/sessions/BCM-M17-DIFFICULTY-VALIDATION/M17_SOLVER_QUALIFICATION_V03.md`

No canonical level/timer/VIP/reward/HUD/table/physics data was tuned. `TASKS.md` was not modified. M17-008 was not started.

## Commands and exact results

Syntax and whitespace checks:

```text
git diff --check -> PASS (only Git LF/CRLF normalization warnings)
Godot --headless --path . --script res://tests/m17_difficulty_validation_probe.gd --check-only -> PASS
Godot --headless --path . --script res://tools/campaign/m17_solver_qualification.gd --check-only -> PASS
Generated qualification JSON parsed with PowerShell ConvertFrom-Json -> PASS
```

Focused M17 probe, canonical time scale, run twice:

```text
Godot --headless --path . --script res://tests/m17_difficulty_validation_probe.gd -> exit 0
M17_DIFFICULTY_VALIDATION_RESULT=PASS
Godot --headless --path . --script res://tests/m17_difficulty_validation_probe.gd -> exit 0
M17_DIFFICULTY_VALIDATION_RESULT=PASS
```

The focused probe passed:

- same-level left and right target movement;
- left-side congestion avoidance;
- identical board-state determinism;
- no future-RNG input and legal horizontal bucket;
- production danger-line classification as `TABLE_DANGER`;
- production campaign timer classification as `TIMEOUT`, not danger;
- rail transition hysteresis and centered-footprint false-positive protection;
- same-seed exact action-log reproduction;
- same-seed logical outcome and exact action-log replay;
- required decision evidence fields;
- canonical Sunny Cove JSON byte-for-byte immutability.

Canonical 30-trial qualification:

```text
Godot --headless --path . --script res://tools/campaign/m17_solver_qualification.gd -> exit 0
M17_SOLVER_QUALIFICATION_RESULT=SOLVER_QUALIFIED_FOR_M17_007
```

Independent report inspection:

- Total: `30` trials; levels `1,10,11,50,51,100`; five each.
- Seed base/formula: `17300000`; `base + level_id * 1000 + trial_index`.
- Canonical qualification scale: `1.0`.
- No harness aborts: `0`.
- Completion gates: L1 `3/5`; L10 `1/5`; L11 `3/5`.
- Anti-fixed-lane gate: `30/30` eligible trials varied laterally; fraction `1.0`; minimum `0.80`; every tested level had variation; `FIXED_LANE_FAILURE=false`.
- Focused fixtures: responsive `true`; same-seed action log `true`; logical replay `true`; telemetry valid `true`.
- Machine verdict: `SOLVER_QUALIFIED_FOR_M17_007`.

Time-scale fidelity spot checks:

- L1 seed `17301000`: action log replayed identically; outcome remained timeout, but 1x/4x merge count differed (`8` vs `2`).
- L50 seed `17350000`: action log replayed identically; 1x reached `TABLE_DANGER` while 4x timed out, with differing merge counts (`28` vs `25`).
- The report marks historical 4x telemetry as `telemetry_only_not_decision_grade=true`; the qualification cohort and decision evidence are canonical 1x only.

V02 weak-policy overlap comparison was recorded for all six tested levels as a small diagnostic only; the report explicitly states that five trials per level are not statistically significant. The stronger policy changes the observed completion/merge/occupancy profile and is not treated as a statistical balance claim.

Required regression probes:

```text
Godot --headless --path . --script res://tests/m16_sunny_cove_content_probe.gd -> exit 0
M16_SUNNY_COVE_CONTENT_RESULT=PASS
Godot --headless --path . --script res://tests/m15_vip_boosters_economy_probe.gd -> exit 0
M15_VIP_BOOSTERS_ECONOMY_RESULT=PASS
Godot --headless --path . --script res://tests/m02_physics_regression.gd -> exit 0
M02_PROBE_RESULT=PASS
```

The M15 headless run emitted only its expected `M15_CAPTURE_UNAVAILABLE ... HEADLESS_DISPLAY` notices; all functional assertions and the authoritative result passed.

## Manual checks and unavailable checks

- Read and inspected the active V03A execution prompt, locked audit criteria, owner observation, `AGENTS.md`, and root `TASKS.md` after synchronization.
- Confirmed the worktree contains only active M17 V03A implementation/evidence changes before publication.
- Confirmed no generated Godot translation sidecars remained in the repository after validation.
- No native owner visual acceptance, device acceptance, clean-machine acceptance, or independent ChatGPT audit was performed by Codex.
- This log is builder evidence, not a milestone acceptance verdict.

## Known limitations

- The merge-aware policy is a deterministic validation policy, not an optimal-human model; qualification frequencies are evidence for M17-007 and not a balance-tuning decision.
- The rail metric remains the V02 footprint-proximity transition proxy, not a `body_entered` rail collision callback.
- The 4x spot replay demonstrates historical time-scale divergence and is intentionally excluded from decision-grade qualification.
- No M17-008 tuning or tracker transition was performed.

## Publication and final sync

- Intended changes are limited to the five implementation/report paths above plus this immutable execution log.
- Implementation/evidence publication commit SHA: `202e2e913974976c519e662bbeca7c78a82a795c`.
- Post-push synchronization proof before this evidence-log finalization:
  - `git rev-parse HEAD`: `202e2e913974976c519e662bbeca7c78a82a795c`.
  - `git rev-parse origin/main`: `202e2e913974976c519e662bbeca7c78a82a795c`.
  - `git ls-remote origin refs/heads/main`: `202e2e913974976c519e662bbeca7c78a82a795c`.
  - `git rev-list --left-right --count HEAD...origin/main`: `0 0`.
  - `git status --short --branch`: clean `main...origin/main` before this log finalization edit.
- The evidence-log finalization commit SHA will be reported in the final handoff because a commit cannot contain its own SHA.
- Independent ChatGPT audit remains required; Codex does not update `TASKS.md` or assign the milestone verdict.
