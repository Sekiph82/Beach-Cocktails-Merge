# BCM-R09-RUNTIME-RECOVERY — Execution Prompt V01

Status: **ISSUED**

This task is a runtime recovery and root-cause correction. Do not treat previous green probes as acceptance proof.

## Read first
- `AGENTS.md`
- `coordination/AUDIT_POLICY.md`
- `TASKS.md`
- `coordination/sessions/BCM-M06-R08/CODEX_LOG_V01.md`
- `coordination/sessions/BCM-M07-R08/CODEX_LOG_V01.md`
- `coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CHATGPT_AUDIT_CRITERIA_V01.md`

## Owner-observed failures
The current local Godot run has two serious failures:

1. With no owner input, cocktails repeatedly appear, fly into To-Go Orders and score keeps increasing.
2. Cocktails still stop too far from the actual visible rear tabletop edge.

Your job is to diagnose and fix the root causes, not to patch symptoms or merely make tests green.

---

# Phase A — uncommanded runtime generation / scoring

Before changing gameplay code, inspect the LOCAL workspace state, especially the file that prior logs repeatedly reported as dirty:

`project.godot`

Compare local `project.godot` byte/content state with `origin/main:project.godot` and document every difference.

Also inspect:
- normal `run/main_scene`;
- autoloads/plugins/run configuration;
- test/probe scripts that instantiate `scenes/main.tscn`;
- any R08 probe that calls `GameManager.spawn_drink()`;
- any path by which such a probe could be running in a normal F5/project run.

Important repository facts to verify rather than assume:
- tracked `project.godot` currently points normal gameplay at `res://scenes/main.tscn`;
- tracked `scenes/main.tscn` contains only the normal `GameManager` root;
- `tests/m06_r08_rear_tangency_probe.gd` intentionally spawns L01-L12 synthetic settled drinks for test evidence;
- production To-Go logic may auto-collect a legitimate already-existing stored matching drink and then award the order reward.

Determine whether the owner's local dirty `project.godot` or another local run configuration causes a probe/test to execute alongside or instead of normal gameplay. If so, correct the local/project configuration safely and commit only repository changes that should actually be canonical.

Do not remove the intended player-created stocked-target behavior simply to hide test leakage.

Add/retain an isolated no-input runtime regression proving that during a normal game run with no player input for at least 30 seconds:
- score remains 0;
- no To-Go order completes;
- there is exactly one intended HELD preview drink;
- there are zero non-held gameplay drinks;
- no merge occurs;
- no synthetic test/probe drink appears.

---

# Phase B — actual rear tabletop boundary

The R08 formula is conceptually correct. Do not replace it with hardcoded per-level rear targets.

Mandatory invariant for every L01-L12:

```text
body_half_extent_y = current physical/visible glass-container vertical half-extent
rear_target_center_y = actual_visible_rear_table_y + body_half_extent_y
visible_glass_body_top_y = rear_target_center_y - body_half_extent_y
visible_glass_body_top_y == actual_visible_rear_table_y
```

If the active circular collider is an accurate representation of the glass/container vertical half-extent:

```text
body_half_extent_y = collider_radius
rear_target_center_y = actual_visible_rear_table_y + collider_radius
```

The known R08 failure is that production used the first R07 side-polyline sample (`source y=472`) as `rear_table_y`. Do not assume that value is the actual visible rear edge merely because the old dataset says so.

Independently inspect/measure the active owner-approved background/runtime render and determine the actual visible rear tabletop boundary that the owner expects cocktails to touch.

Then make the normal gameplay TopRail/clamp/rear solver use that same real boundary consistently.

Do not derive the expected value from `GameManager.rear_table_y`, `TABLE_LEFT_EDGE_SOURCE_POINTS`, or production helper output. The expected rear boundary used for validation must be independent of the implementation under test.

Evidence must make the result visually obvious for representative L01/L06/L12 and cover rear-left, rear-center and rear-right where appropriate:
- no artificial rear dead strip;
- glass/container body top touches actual visible rear wood edge;
- body does not cross onto beach/background;
- all levels share the same actual rear edge; only center Y differs by body half-extent.

---

# Preserve

Do not regress:
- owner-approved held-drink baseline/X/halo alignment;
- R08 To-Go panel visual placement unless required to correct an actual regression;
- BEST/SCORE layout unless required to correct an actual regression;
- NEXT;
- baked 2x6 progression;
- launch speed 700 px/s;
- deceleration 180 px/s²;
- collision and momentum transfer;
- merge/combo/scoring/To-Go economy contracts;
- persistence;
- Game Over/restart;
- rapid launch.

Do not modify canonical PNGs.
Do not add guide_line.
Do not start M08+.
Do not edit `TASKS.md` or ChatGPT-owned files.
Do not self-audit.

## Required log
Write:
`coordination/sessions/BCM-R09-RUNTIME-RECOVERY/CODEX_LOG_V01.md`

The log must include:
- exact local vs origin `project.godot` diff;
- root cause of the uncommanded cocktails/score;
- exact production/configuration fix;
- exact reason R08 rear tangency evidence was visually wrong despite PASS;
- independently measured actual rear boundary evidence;
- no-input 30-second regression results;
- full active M01-M07 regression results;
- Godot import/startup and `git diff --check`;
- final commit SHA and push/equality evidence.

Commit and push the intended recovery changes, then return the log URL + implementation SHA + exact final regression result + `AWAITING_AUDIT`, then STOP.
