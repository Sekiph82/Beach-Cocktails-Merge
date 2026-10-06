# BCM-M21-006-R03 — Final Release Closure Criteria

Status: **LOCKED BEFORE EXECUTION**

Date: 2026-10-06

## Purpose

Perform the final technical/release closure for the current Beach Cocktails Merge v1 campaign after owner acceptance of BCM-M21-001.

This is not a redesign task.

Freeze all owner-accepted current visuals and gameplay semantics.

## Mandatory closure items

### 1. Repository cleanliness / project.godot

Resolve the repeatedly preserved tracked local `project.godot` drift.

- compare local vs canonical GitHub main;
- if the difference is only Godot-generated UID/path normalization with identical semantics, restore canonical tracked bytes;
- if there is any owner-authored semantic change, STOP with:
  `OWNER_PROJECT_GODOT_RECONCILIATION_REQUIRED`.

Final required Git state:
- no tracked local modifications;
- no preservation stash needed;
- local HEAD = origin/main = remote main;
- ahead/behind 0/0.

Owner-local untracked critique screenshots may remain only if they are clearly outside product/release inputs and documented.

### 2. M07 HUD regression authority

The older M07 probes previously produced stale/contradictory HUD assertions.

Re-run current M07 HUD authority and reconcile any stale historical probe against current accepted production geometry.

Requirements:
- no tolerance inflation;
- no deletion/commenting-out of safety assertions;
- do not reintroduce retired production APIs just for old tests;
- if a historical probe is obsolete, classify it explicitly and replace it with equal-or-stronger current coverage.

Final current HUD regression set must exit 0.

### 3. M08 process crash closure

A previous M08 command printed PASS but exited with Windows nonzero/access-violation behavior.

Run the current M08 delivery/economy/session regression twice consecutively.

PASS requires BOTH runs:
- expected PASS marker;
- process exit 0;
- no access violation;
- no SCRIPT ERROR / ERROR indicating teardown failure.

If still reproducible, fix the actual teardown/process defect minimally.

### 4. Current M21 navigation/progression closure

Run and retain green evidence for:
- R08 Home frontier production path;
- R09 V05 World Map real-input chain twice;
- R07 Island Map page-focus;
- R07 node visual/stars;
- full Sunny Cove 720×1280 background;
- M18 star/replay/cumulative reward behavior;
- M20 ApplicationShell;
- full fresh-save Sunny Cove L1→L100 progression/Tiki unlock;
- performance/stability profile;
- accepted gameplay regression;
- asset validator;
- Godot import/parse/boot;
- `git diff --check`.

### 5. Save/persistence

Verify:
- current save schema remains readable;
- owner progression is not reset by the closure work;
- restart persists campaign frontier, stars, best score, coins/boosters and current canonical state;
- no test/debug progression bypass is active in production.

Do not implement the inactive Economy Draft V01.

### 6. Export/release configuration

Re-verify:
- production main scene;
- 720×1280 canonical viewport;
- export presets;
- package/build configuration available in the current environment.

If a real distributable can be produced with the available toolchain, generate it and record SHA-256.

If export/signing toolchain is unavailable, report it truthfully. Do not fabricate a release artifact or signed status.

### 7. Owner acceptance consolidation

Record these owner-accepted surfaces/behaviors as frozen:
- Home;
- World Map;
- Sunny Cove Island Map;
- Sunny Cove Back;
- Island Map automatic page focus;
- stars/mastery;
- gameplay R04 surface;
- untimed campaign;
- To-Go/VIP accepted layout;
- navigation round trip.

No new visual review is required unless this closure changes production bytes affecting those surfaces.

### 8. Release evidence

Create:
`coordination/sessions/BCM-M21-FINAL-RELEASE-CLOSURE-R03/evidence/`

Include:
- final SHA/ref proof;
- Git cleanliness proof;
- project.godot reconciliation;
- M07 closure;
- M08 run 1 and run 2;
- current navigation regressions;
- progression/performance;
- save/restart proof;
- release/export manifest;
- final known limitations.

### 9. Log

Create:
`docs/codex-logs/CODEX_LOG_M21_FINAL_RELEASE_CLOSURE_R03.md`

Root `TASKS.md` is read-only to Codex.

Final builder marker exactly:

`AWAITING_GPT_M21_FINAL_RELEASE_AUDIT_R03`

Do not start M22.
