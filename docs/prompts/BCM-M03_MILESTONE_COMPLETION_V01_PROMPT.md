# BCM-M03 — Scoring, Combo, To-Go, Persistence, and Game-Over Hardening V01

## Purpose
Complete all currently actionable M03 work for Beach Cocktails Merge in one Codex session. Formalize and regression-protect the accepted score economy, combo system, To-Go Orders behavior, persistence, danger-line failure, Game Over, and restart behavior without beginning V7 visual integration.

Do not start M04, M05, or any V7 visual integration work.

## Canonical repository and workspace
- Repository: `https://github.com/Sekiph82/Beach-Cocktails-Merge`
- Branch: `main`
- Local root: `C:\Users\sekip\Desktop\Beach Cocktails - Merge`
- Godot target: `4.7.x`

## Mandatory governance
Read and obey before working:
- `AGENTS.md`
- root `TASKS.md`
- `docs/audits/BCM-M02_MILESTONE_COMPLETION_V01_AUDIT.md`
- `docs/codex-logs/BCM-M02_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- this prompt

Codex must never edit `TASKS.md`, self-approve M03, or advance the tracker.

## Sync-first preflight
Run and retain exact outputs for status, remotes, fetch, HEAD, origin/main, and divergence. Preserve any owner-local work. Never use destructive reset, force-push, automatic rebase, destructive checkout, or silent stash.

## Accepted invariants to preserve
Do not retune accepted M01/M02 gameplay feel. In particular preserve launch speed `700 px/s`, deceleration `180 px/s²`, immediate-next behavior, simultaneous motion, forward-only contact behavior, merge momentum, L12 cap, and the accepted M02 deferred merge-request repair.

## M03.01 — Merge score table
Verify source and runtime behavior for resulting-level merge scores exactly:
- L2 = 20
- L3 = 50
- L4 = 100
- L5 = 200
- L6 = 350
- L7 = 600
- L8 = 1000
- L9 = 1600
- L10 = 2500
- L11 = 4000
- L12 = 6500

Produce deterministic evidence that one merge awards the resulting level score exactly once and that no duplicate callback can double-pay it.

## M03.02 — Combo rules
Verify and regression-test:
- combo window = 1.5 seconds;
- x1 = +0%;
- x2 = +25%;
- x3 = +50%;
- x4 = +75%;
- x5 = +100%;
- x6+ capped at +125%;
- each valid merge refreshes the window;
- expiration resets deterministically;
- combo bonus applies only to the current merge score;
- stored later To-Go delivery never receives historical combo again.

Test boundary timing where practical, including inside-window continuation and post-window reset.

## M03.03 — To-Go Orders
Verify and regression-test production behavior:
- target levels span L6-L12;
- synchronized implementation starts at L6;
- one active order requests one level;
- immediate repeat avoidance works according to production contract;
- a newly created matching drink can fulfill the active order;
- a matching L6-L12 drink already on the table can satisfy a later order;
- exactly one stored matching drink is consumed per order;
- additional matching drinks remain on the table;
- a stored drink receives only the To-Go reward when delivered later, never its old merge score or old combo again;
- L12 remains on the table when not ordered and can satisfy a future L12 order;
- no order fulfillment can score twice.

## M03.04 — To-Go rewards and unresolved L6/L7 decision
Canonical approved rewards are:
- L8 = 3000
- L9 = 5000
- L10 = 8000
- L11 = 12000
- L12 = 18000

L6 and L7 have not been owner-approved as non-zero rewards. Current source data may contain `0`; do NOT interpret that as owner approval for a final economy decision and do NOT invent values.

For L6/L7:
- preserve current production values during M03;
- test that the current source behavior is internally deterministic and does not duplicate other score components;
- clearly record `OWNER DECISION REQUIRED FOR FINAL L6/L7 REWARD VALUES` in the M03 log;
- do not block testing of the rest of M03;
- do not silently change these values.

## M03.05 — Persistence, danger line, Game Over, restart
Regression-test:
- best score persists through `user://save.cfg`;
- missing save loads safe defaults;
- corrupt/invalid save input fails safely without crashing where technically practical;
- danger-line threshold and 1.0-second tolerance are deterministic;
- Game Over stops shooting, freezes the run, clears unsafe pending merge work, shows overlay, and persists best score;
- restart clears session score/state and restores a playable scene while preserving best score;
- behavior remains safe when multiple drinks are moving at Game Over/restart.

Use isolated application data so owner save data is never altered by tests.

## Regression harness
Reuse and extend the committed M01 and M02 probes. Add `tests/m03_economy_regression.gd` or similarly bounded deterministic support. Exercise production classes and source behavior, not reimplemented copies of the rules.

At minimum retain explicit evidence for:
- every merge-score level L2-L12;
- combo x1-x6+ calculation and cap;
- combo timeout/reset;
- immediate active-order fulfillment;
- stored-drink later fulfillment;
- only-one-of-multiple matches consumed;
- L12 stored/future-order behavior;
- no duplicate merge/order payout;
- best-score persistence;
- missing/corrupt save safety;
- danger-line timeout;
- Game Over/restart state integrity;
- M01 and M02 regression probes still passing after any production change.

## Bounded repair policy
Production fixes are allowed only if focused M03 evidence exposes a direct M03 defect. Identify failing evidence first, keep fixes minimal, rerun M03 plus M01/M02 regression, and document before/after evidence. Do not alter visuals, assets, physics feel, exports, audio, menus, or future-milestone behavior.

## Godot validation
Use installed Godot 4.7.x and log exact commands/output/exit codes for version, import/parse, main-scene startup, M01 regression, M02 regression, and M03 focused regression.

## Evidence-first logging
Create:
`docs/codex-logs/BCM-M03_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

The log must contain retained exact evidence for sync, score table, combo calculations/timing, To-Go target/reward data, stored-delivery behavior, duplicate-payment protection, persistence, danger line, Game Over/restart, all regression probes, any defects/repairs, changed files, diff checks, and verified/source-inferred/unverified items.

The owner must not be used as a clipboard between Codex and ChatGPT.

Explicitly state:
- `TASKS.md` was not edited;
- M04/V7 integration was not started;
- L6/L7 reward values remain owner-unapproved if still unresolved.

## Completion
Inspect scope, run all tests, commit/push intended M03 work plus log to `main`, fetch once more, ensure no intended work remains uncommitted, then STOP for independent ChatGPT audit.

Completion response should contain only the log URL, pushed commit SHA, one-line M03 regression result or blocker, confirmation `TASKS.md` was not edited, confirmation M04/V7 was not started, and whether L6/L7 reward values remain owner-decision-required.
