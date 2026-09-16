# BCM-M01 — Milestone Completion V01 Independent Audit

## 1. VERDICT

**PASS**

BCM-M01-001 and the M01 gameplay-contract recovery milestone are accepted. Repository evidence, the focused Godot runtime probe, and the bounded production change are consistent with the authoritative M01 work order.

## 2. CONTRACT RECOVERY

The accepted v6.7 contract was recovered from synchronized source and runtime evidence: portrait 720x1280 logical viewport, 700 px/s launch speed, 180 px/s² slide deceleration, immediate next-held creation, simultaneous moving drinks, movable settled drinks, forward-only/no intentional +Y rebound behavior, merge momentum preservation, L12 cap, L6-L12 To-Go target range, Game Over/restart flow, and best-score persistence through `user://save.cfg`.

## 3. BRANCH / HEAD / DIFF SCOPE

Audited implementation commit: `0b4a18e7638eb6f58eb1524db34530f8d0f8e38c` on `main`.

Compared with accepted M00/tracker baseline `75c10c3464d39deea798f330ff2cc1a2865bc9e5`, the M01 commit changes only:

- `scripts/game_manager.gd`
- `tests/m01_contract_probe.gd`
- `docs/codex-logs/BCM-M01_MILESTONE_COMPLETION_V01_CODEX_LOG.md`

No V7 asset/integration file, M02 implementation, or `TASKS.md` was changed by Codex.

## 4. ACCEPTANCE CRITERIA MATRIX

- Project/main-scene/runtime hierarchy inspection: **PASS**
- Playfield/wall/death-line/launch geometry recovery: **PASS**
- Desktop mouse input route: **PASS**
- Touch input route at engine-event level: **PASS**
- Immediate next held drink after launch: **PASS**
- Multiple simultaneous moving drinks: **PASS**
- Stopped drink movable after impact: **PASS**
- Restart and Game Over paths: **PASS**
- Best-score persistence across restart: **PASS**
- Launch speed 700 px/s: **PASS**
- Deceleration 180 px/s²: **PASS**
- No artificial cruise/minimum-speed assist: **PASS**
- Held drink non-colliding until release: **PASS**
- Merge momentum preservation: **PASS**
- No intentional backward/+Y rebound: **PASS**
- To-Go target range L6-L12: **PASS**
- L12 cap / no L13: **PASS**
- Godot import/parse/main-scene startup: **PASS**
- Native-device touch/export validation: **UNVERIFIED**, correctly deferred to later milestones.

## 5. BUILDER CLAIMS VS REPOSITORY TRUTH

The claimed focused persistence repair is present. `_game_over()` now calls `_save_best_score()` unconditionally after the live `best_score` has already been maintained by score updates. The change is bounded and does not alter scoring values, physics, To-Go economy, visual layout, or launch tuning.

The runtime probe is committed as non-production support and reports `M01_PROBE_RESULT=PASS` with `PROBE_EXIT_CODE=0`, covering launch/current/next, multiple-moving state, deceleration, forward-only behavior, settled-body wake/movement, merge level/momentum, L12 cap, Game Over, persistence, restart, and restoration.

## 6. FILE / SYMBOL EVIDENCE

Repository evidence confirms the accepted production constants and behavior described by the Codex log. The persistence implementation in `scripts/game_manager.gd` writes `records/best` to `user://save.cfg` at terminal state and reloads it on scene startup.

## 7. FOCUSED TEST EVIDENCE

Godot 4.7.2 import/parse and configured main-scene startup both exited with code 0. The isolated runtime probe also exited with code 0 and used redirected APPDATA, avoiding mutation of the owner's normal save data.

## 8. REGRESSION EVIDENCE

The M01 diff does not alter `project.godot`, `scenes/main.tscn`, `data/drinks.json`, `scripts/drink.gd`, `scripts/merge_queue.gd`, `scripts/shot_controller.gd`, or V7 asset files. The accepted M00 baseline therefore remains intact except for the bounded best-score persistence repair.

## 9. SECURITY / SAFETY REVIEW

No secrets, credentials, destructive Git operations, owner save-file mutation, or unrelated software installation are evidenced. The persistence test used an isolated application-data path.

## 10. ARCHITECTURE CONSISTENCY

The production runtime remains centered on `GameManager`, `ShotController`, `Drink`, and `MergeQueue`. The added probe is test support and does not alter production scene wiring.

## 11. TRACKER / LOG / DOCUMENTATION TRUTHFULNESS

`TASKS.md` remained unchanged by Codex as required. The Codex log distinguishes verified, source-inferred, and unverified claims rather than presenting native-device evidence that was not performed.

One documentation inconsistency remains: `README.txt` states that the first To-Go target is L8, while synchronized production logic selects L6 initially and rotates through L6-L12. This is a **MINOR documentation finding**, not a gameplay-contract failure, because the M01 log records the discrepancy and the authoritative task requires the L6-L12 range rather than an L8 initial target.

## 12. FINAL REPOSITORY STATE

M01 implementation evidence is committed on GitHub `main` at `0b4a18e7638eb6f58eb1524db34530f8d0f8e38c` before this audit/tracker transition.

## 13. OPEN CROSS-MILESTONE FINDINGS

- Correct the stale README claim that the first To-Go target is L8 when documentation is next touched. Do not alter production target behavior merely to match the stale text.
- Native touchscreen, export, dense long-duration play feel, and visual acceptance remain intentionally deferred.

## 14. DEFECTS BY SEVERITY

- BLOCKER: none.
- MAJOR: none.
- MINOR: stale README initial-target statement.
- NOTE: device-native behavior is not part of M01 acceptance.

## 15. TECHNICAL DEBT / UPGRADE OPPORTUNITIES

The deterministic M01 probe provides a useful foundation for M02 physics/collision/rapid-launch regression coverage and should be reused or extended rather than discarded.

## 16. UNVERIFIED ITEMS

Native touch hardware, Android/iOS exports, dense long-duration manual play feel, device safe areas, and owner-native visual acceptance.

## 17. REGRESSION RISK

**LOW**

## 18. AUDIT CONFIDENCE

**HIGH**

## 19. FINAL VERDICT

**PASS**

M01 may be closed and the project may advance to BCM-M02-001.
