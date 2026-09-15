# BCM-M01 — Gameplay Contract Recovery and Playable Baseline Verification V01

## Purpose

Complete all M01 work for Beach Cocktails Merge in one Codex session. Recover the actual accepted v6.7 gameplay contract from the synchronized repository, verify it against runtime behavior, document exact evidence, and stop for independent ChatGPT audit.

Do not start M02 or any V7 visual integration work.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: `4.7.x`

## Mandatory governance

Read and obey before working:

- `AGENTS.md`
- root `TASKS.md`
- `docs/audits/BCM-M00_MILESTONE_COMPLETION_V01_AUDIT.md`
- this prompt

Codex must never edit `TASKS.md`.
Codex must not self-approve M01 or advance the tracker.

## Sync-first preflight

Run and log exact outputs:

```powershell
git status --short --branch
git remote -v
git fetch origin main
git rev-parse HEAD
git rev-parse origin/main
git rev-list --left-right --count HEAD...origin/main
```

Safely reconcile any owner-local work. Never use destructive reset, force-push, automatic rebase, destructive checkout, or silent stash.

## M01 scope

### Scene and runtime contract

1. Inspect `project.godot`, `scenes/main.tscn`, production scripts, physics configuration, viewport/stretch behavior, and runtime node hierarchy.
2. Document the launch-zone geometry, playfield/table coordinate system, wall/top-boundary geometry, danger/deadline boundary, and any relevant collision layers/masks.
3. Verify desktop mouse input route and mobile touch input route from source and runtime evidence where technically possible.
4. Verify a new held/launchable drink appears immediately after firing.
5. Verify the player can fire again while prior drinks are still moving.
6. Verify multiple simultaneously moving drinks remain supported.
7. Verify stopped drinks remain physically movable when hit.
8. Verify restart and Game Over paths.
9. Verify best-score persistence behavior through `user://` where technically practical without destroying owner data. Use a safe isolated test approach if persistence needs runtime validation.
10. Record any mismatch between owner-accepted v6.7 behavior and synchronized implementation as a finding. Do not silently redefine the contract.

### Accepted gameplay constants

Verify from repository source and, where practical, runtime evidence:

- initial launch speed = `700 px/s`;
- slide deceleration = `180 px/s²`;
- no artificial cruise/minimum-speed assist;
- held launch drink is non-colliding/non-physical until released as intended;
- immediate next-drink availability after launch;
- stopped drinks remain movable on impact;
- merge results preserve meaningful forward/lateral momentum;
- collision behavior must not intentionally rebound drinks backward toward the player;
- To-Go target range remains L6-L12;
- L12 remains capped and does not produce L13.

Do not retune these values or gameplay feel in M01 unless a strictly necessary defect prevents faithful verification. If a defect is found, document it and stop for audit/remediation rather than broad redesign.

## Runtime verification

Use Godot 4.7.x. Run deterministic/headless checks where possible and focused runtime instrumentation/tests where necessary. Do not fake interactive evidence.

At minimum:

- confirm project import/parse/main-scene startup remains clean;
- exercise or deterministically verify launch/current/next state transitions;
- exercise or deterministically verify simultaneous-moving-drink behavior;
- verify restart/Game Over code paths;
- verify persistence code path;
- inspect source symbols/constants backing the accepted gameplay values.

If some native interaction cannot be fully automated, mark it clearly `UNVERIFIED` rather than claiming success. Do not ask the owner to manually relay terminal outputs to ChatGPT.

## Evidence-first logging

Create one immutable log:

`docs/codex-logs/BCM-M01_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

The log must contain exact evidence, including:

- sync-first Git outputs;
- files/symbols inspected;
- recovered runtime/scene contract;
- exact gameplay constant locations and values;
- Godot version and validation commands/output/exit codes;
- focused runtime/test commands and exact outputs;
- what was actually verified versus source-inferred versus unverified;
- restart/Game Over/persistence evidence;
- immediate-next and simultaneous-motion evidence;
- any mismatches/findings;
- files changed, if any;
- final pre-commit diff/status checks;
- explicit confirmation `TASKS.md` was not edited;
- explicit confirmation M02/V7 integration was not started.

All evidence that can be retained must be written into the committed log. The owner must not be used as a clipboard between Codex and ChatGPT.

## Change policy

M01 is primarily contract recovery and verification. Avoid production changes unless required for bounded testability or to repair a direct verification blocker. Do not change gameplay tuning, scoring, To-Go economy, visuals, asset composition, or future milestone behavior.

Any test/support files added must be clearly scoped, deterministic, and non-production where appropriate.

## Completion procedure

1. Inspect diff/status.
2. Ensure scope contains only legitimate M01 verification/support/documentation changes plus the log.
3. Commit and push all intended work to `main`.
4. Fetch `origin/main` again.
5. Confirm no intended implementation/evidence remains uncommitted.
6. Do not edit `TASKS.md`.
7. Do not start M02.
8. Do not start V7 visual integration.
9. STOP for independent ChatGPT audit.

## Completion response

Return only:

- M01 Codex log GitHub URL;
- pushed commit SHA;
- one-line M01 verification result or exact blocker;
- confirmation that `TASKS.md` was not edited;
- confirmation that M02/V7 integration was not started.

Detailed evidence must already be inside the committed Codex log.
