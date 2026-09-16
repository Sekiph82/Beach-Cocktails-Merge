# BCM-M02 — Physics, Collision, Merge, and Rapid-Launch Hardening V01

## Purpose

Complete all currently actionable M02 work for Beach Cocktails Merge in one Codex session. Convert the owner-accepted v6.7 feel recovered and accepted in M01 into deterministic regression-protected behavior without redesigning gameplay or beginning V7 visual integration.

Do not start M03, M04, M05, or any V7 visual integration work.

## Canonical repository and workspace

- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: `4.7.x`

## Mandatory governance

Read and obey before working:

- `AGENTS.md`
- root `TASKS.md`
- `docs/audits/BCM-M01_MILESTONE_COMPLETION_V01_AUDIT.md`
- `docs/codex-logs/BCM-M01_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- this prompt

Codex must never edit `TASKS.md`.
Codex must not self-approve M02 or advance the tracker.

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

## Accepted gameplay invariants that must not be retuned casually

Preserve unless a direct defect requires a bounded repair:

- launch speed = `700 px/s`;
- slide deceleration = `180 px/s²`;
- no artificial cruise/minimum-speed assist;
- held launch drink remains frozen/non-colliding until release;
- immediate next-held generation after launch;
- multiple moving drinks may coexist;
- stopped drinks remain physically movable when hit;
- collisions must not intentionally rebound drinks toward the player (+Y);
- merge results preserve meaningful forward/lateral momentum;
- L12 is the hard cap;
- Game Over and restart behavior accepted in M01 remains intact.

## M02.01 — Drink body physics

Inspect the actual production `RigidBody2D` setup and verify with deterministic tests where technically possible:

1. body mode/dynamic behavior;
2. mass progression from `data/drinks.json` and how mass affects collisions;
3. freeze/sleep/wake behavior;
4. friction/damping/bounce/restitution-related configuration;
5. collision layers/masks and held/non-physical state transitions;
6. wall and top-boundary interactions;
7. no intentional backward/+Y return after contacts;
8. collision momentum transfer to previously settled drinks;
9. no practical tunneling at the accepted 700 px/s launch speed under representative direct-hit and glancing-hit scenarios;
10. deterministic settling and re-wake behavior.

### Collider vs future V7 sprite criterion

Do **not** integrate V7 sprites in M02. The tracker phrase about collider dimensions matching sprites after V7 sprites are introduced is a cross-milestone requirement whose final visual acceptance belongs to M05.

In M02:

- record the current per-level collider radii and mass table;
- verify collider behavior is internally consistent and stable;
- optionally inspect PNG transparent bounds only as non-integrating evidence if useful;
- do not change collider sizes merely to guess future sprite presentation;
- explicitly mark final sprite-footprint alignment as `DEFERRED TO M05`, not falsely PASS it as a visual integration test.

This deferral is acceptable only if physics regression coverage is otherwise complete and current colliders are not demonstrably broken.

## M02.02 — Merge resolution

Verify and regression-test:

1. merge replacement is deferred outside unsafe physics callbacks;
2. one contact pair cannot merge more than once;
3. same-level pair produces exactly the next level;
4. merged level is capped at L12;
5. L12 + L12 does not disappear and does not create L13;
6. merged result position is physically plausible;
7. merged result preserves meaningful forward/lateral momentum;
8. no duplicate merge/score signal is emitted from a single merge;
9. chain merges remain stable when several drinks are moving;
10. merge processing does not leave stale/invalid body references.

Where possible, count actual merge callbacks/signals and resulting bodies rather than relying only on source inspection.

## M02.03 — Rapid-launch concurrency

Exercise deterministically:

1. launch a drink and launch another while the first remains moving;
2. perform several rapid consecutive launches;
3. verify held/current/next references remain coherent;
4. verify held drink remains non-colliding until release;
5. verify earlier moving drinks continue physical simulation while the new held drink exists;
6. verify restart while several drinks are moving;
7. verify Game Over while several drinks are moving;
8. ensure no stale callbacks, duplicate bodies, orphan merge requests, or invalid references after restart/Game Over.

## Regression harness

Extend/reuse the committed M01 test support rather than discarding it where practical.

Create deterministic M02-focused Godot test/probe support under `tests/` as needed. Tests must exercise production classes/scene behavior rather than reimplementing the game rules in the test itself.

At minimum produce explicit PASS/FAIL evidence for:

- body/held/sliding/settled state transitions;
- settled-body wake and momentum transfer;
- forward-only collision response;
- representative wall/top-boundary contact;
- accepted-speed collision/tunneling check;
- single-pair single-merge guarantee;
- correct next-level merge;
- L12 cap;
- merge momentum;
- moving multi-body chain merge/stress case;
- rapid consecutive launch state integrity;
- restart with multiple moving drinks;
- Game Over with multiple moving drinks.

If a deterministic engine limitation prevents a criterion from being fully automated, record exact source evidence and mark only that criterion `SOURCE-INFERRED` or `UNVERIFIED`; do not fabricate runtime proof.

## Bounded repair policy

M02 is hardening, so production fixes are allowed when a focused test exposes a direct M02 physics/collision/merge/concurrency defect.

For every production fix:

- identify the failing test/evidence first;
- keep the repair minimal;
- do not redesign the accepted feel;
- rerun focused regression tests after the repair;
- rerun M01 contract probe to prove no regression;
- document before/after evidence in the Codex log.

Do not change scoring tables, combo economy, To-Go rewards/selection rules, V7 art, UI composition, audio, menus, exports, or future-milestone behavior.

## Documentation cleanup from M01 audit

Correct the stale `README.txt` statement that says the first To-Go target is L8. Documentation must match current production behavior: target range is L6-L12 and the synchronized implementation starts at L6. This is documentation-only; do not alter production target behavior to match the stale README.

## Godot validation

Use installed Godot 4.7.x and log exact commands/output/exit codes for:

- version;
- import/parse;
- configured main-scene startup;
- M01 regression probe;
- M02 focused regression probe(s).

Use isolated application data for tests that might touch `user://`.

## Evidence-first logging

Create one immutable log:

`docs/codex-logs/BCM-M02_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

The log must contain exact evidence, not summary-only claims, including:

- sync-first Git outputs;
- files/symbols inspected;
- mass/radius/body configuration table;
- collision/wall/top-boundary evidence;
- tunneling test setup and result;
- merge single-resolution/count evidence;
- L12 cap evidence;
- merge momentum evidence;
- chain-merge/stress evidence;
- rapid-launch/current-next integrity evidence;
- restart/Game Over under multi-body motion evidence;
- Godot commands/output/exit codes;
- M01 regression output;
- M02 regression output;
- any defects found and bounded repairs made;
- verified vs source-inferred vs deferred/unverified matrix;
- final sprite-footprint alignment explicitly `DEFERRED TO M05` unless V7 sprites had already been owner-integrated before this task;
- files changed;
- `git diff --check` result;
- confirmation `TASKS.md` was not edited;
- confirmation M03/V7 integration was not started.

The owner must not be asked to copy terminal output between Codex and ChatGPT. Put retained evidence in the committed log.

## Completion procedure

1. Inspect full diff/status.
2. Ensure scope contains only legitimate M02 implementation/tests/documentation plus the log.
3. Run all focused M02 tests.
4. Rerun M01 regression probe after any production code changes.
5. Run Godot import/parse/main-scene smoke checks.
6. Commit and push all intended work to `main`.
7. Fetch `origin/main` once more and ensure no intended work remains uncommitted.
8. Do not edit `TASKS.md`.
9. Do not start M03 or any V7 visual integration.
10. STOP for independent ChatGPT audit.

## Completion response

Return only:

- M02 Codex log GitHub URL;
- pushed commit SHA;
- one-line M02 regression result or exact blocker;
- confirmation that `TASKS.md` was not edited;
- confirmation that M03/V7 integration was not started.

All detailed evidence must already be inside the committed Codex log.
