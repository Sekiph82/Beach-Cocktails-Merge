# BCM-M03 — Milestone Completion V01 Independent Audit

## Verdict

**CONDITIONAL — implementation/regression evidence passes; one owner economy decision remains required before M03 can close.**

## Repository evidence audited

- Codex log: `docs/codex-logs/BCM-M03_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- Builder commit: `fb780d429e4df86e4cb50d5daa6cf124f967127f`
- Baseline/tracker commit before builder work: `2233b1d08da89cfaff1afea306103dee6ade3972`
- Changed scope verified by GitHub compare:
  - `scripts/game_manager.gd`
  - `tests/m03_economy_regression.gd`
  - `docs/codex-logs/BCM-M03_MILESTONE_COMPLETION_V01_CODEX_LOG.md`
- `TASKS.md` was not modified by Codex.

## PASS findings

1. Merge score table L2-L12 is deterministically verified at exactly 20, 50, 100, 200, 350, 600, 1000, 1600, 2500, 4000, 6500.
2. Combo window/cap behavior is deterministically verified: 1.5 s; x1 0%, x2 25%, x3 50%, x4 75%, x5 100%, x6+ 125% capped at x6; expiration resets deterministically and a post-window merge restarts at x1.
3. To-Go target range remains L6-L12, initial target is L6, and immediate repeats are avoided.
4. Immediate matching-order fulfillment passes.
5. Stored matching-drink fulfillment passes and awards only the current To-Go reward, without replaying historical merge/combo score.
6. Multiple stored matches consume exactly one drink per order.
7. L12 remains stored when not ordered and can satisfy a later L12 order.
8. Duplicate merge/order payout protection passes.
9. Missing/corrupt save files load safe defaults without crashing.
10. Best-score persistence, restart behavior, danger-line one-second tolerance, and Game Over state integrity pass deterministic runtime checks.
11. M01 and M02 probes were rerun after M03 production repairs and both still PASS.
12. Godot 4.7.2 import/parse and main-scene startup remain clean apart from the previously accepted non-fatal nested reference-project warning.
13. Two production defects exposed by the first M03 probe were repaired in bounded scope: deterministic combo timer reset and the invalid To-Go tween callback binding/reference path. No scoring values, combo percentages, physics tuning, target range, or V7 assets were retuned.

## Blocking owner decision

The canonical tracker explicitly requires L6 and L7 To-Go bonus values to be owner-approved if absent from accepted source. Current repository data still contains:

- L6 = 0
- L7 = 0

Codex correctly did **not** invent or change these values. Therefore M03 cannot receive unconditional PASS until the owner chooses the final L6/L7 reward values and a bounded remediation updates `data/drinks.json` plus the M03 deterministic regression expectations/evidence.

## Audit disposition

All M03 criteria other than the two owner-defined reward values are accepted as complete. No broad rework is required. Once L6/L7 values are approved, only a bounded reward-table remediation and regression rerun are needed before final M03 closure.
