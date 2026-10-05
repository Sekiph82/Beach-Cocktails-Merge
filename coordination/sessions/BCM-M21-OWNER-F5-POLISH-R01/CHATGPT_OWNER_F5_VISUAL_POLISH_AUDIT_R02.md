# BCM-M21-001-R02 — Independent GPT Owner F5 Polish Audit

Date: 2026-10-06

## Verdict

**CHANGES_REQUIRED / REGRESSION_AND_CLEAN_STATE_CLOSURE**

The requested R02 product changes are substantially implemented and source-level inspection finds the intended architecture in place. However, the locked R02 acceptance contract is not satisfied because mandatory regressions did not all exit PASS and the canonical Desktop worktree was not clean at handoff.

BCM-M21-001 remains open. BCM-M21-006 remains blocked.

## Audited range

Baseline:
`36c6b9bdde4ce7ba402f0453ba0a941f43d0b2f0`

Implementation:
`cd4f5604a73eadc1702f92f0fe38402494a0eece`

Final handoff:
`92c34f7c6d243b719921241751111f98653c2cf1`

The handoff is 3 commits ahead of the locked baseline and does not modify root `TASKS.md`.

## Product-scope findings

### Island Map node/header work

**SOURCE PASS**

Verified:
- LOCKED → `level_node_locked.png`
- OPEN → `level_node_unlocked.png`
- CURRENT → `level_node_finale.png`
- COMPLETE 0-star → `level_node_completed.png`
- COMPLETE 1-star → `level_node_current.png`
- COMPLETE 2-star → `level_node_two_star.png`
- COMPLETE 3-star → `level_node_milestone.png`
- milestone marker remains separate from the earned-star skin;
- LevelButton remains the semantic Button/input authority;
- overlay labels/markers ignore pointer input;
- new two-star asset is registered as 320×180 RGBA in canonical asset metadata;
- large teal Island Map header is replaced by a compact plaque/header construction;
- `island_name_panel.png` is the visible island-name plaque;
- old subtitle is absent and summary telemetry is hidden rather than becoming visual UI;
- Back remains a real Button;
- scroll top moved from the old 178 px reservation to 112 px.

### To-Go/VIP +25%

**SOURCE PASS**

Verified:
- width changed from `170.0 * ui_scale` to `212.5 * ui_scale`;
- resulting 1132×1698 aspect-ratio height is 318.75 at canonical scale;
- normal and VIP target cocktails use the same enlarged policy;
- panel-local progress/reward labels receive 1.25 scale;
- panel remains centered at y=0;
- no table/playable/physics geometry change is present in the R02 diff.

### Home redesign

**SOURCE PASS**

Verified:
- Home production background uses `main_menu_background.png`;
- canonical logo and Main Menu asset family are used;
- PLAY/CONTINUE and WORLD MAP are separate actions;
- WORLD MAP calls the production World Map route;
- PLAY/CONTINUE calls `continue_campaign()`;
- continue label is derived from real campaign state;
- valid current selection launches through the existing session/navigation authority;
- Shop and Daily are disabled rather than wired to invented product systems;
- Settings remains functional;
- decorative Home TextureRects ignore pointer input.

## Blocking findings

### BLOCKER 1 — mandatory M07 regression gate did not pass

Locked R02 Gate M required the M07 HUD/layout regression set to PASS.

Builder log reports:
- `tests/m07_r06_owner_layout_probe.gd` overall FAIL because score glyph-center assertions fail;
- `tests/m07_hud_composition_probe.gd` FAIL on stale logo/progression expectations and missing `_launch_zone`;
- `tests/m07_r04_focused_probe.gd` FAIL on prior To-Go sizing / removed APIs;
- `tests/m07_r05_hud_adaptation_probe.gd` FAIL on prior To-Go sizing / removed APIs.

The implementation changed only the R06 To-Go expected box and did not establish a fully passing current M07 regression authority.

Independent source review indicates at least part of the R06 score-center failure may be a probe coordinate-system defect across responsive viewports: the probe compares scaled runtime panel geometry to fixed unscaled local expected boxes. This must be proven by baseline/current measurement before changing production.

Historical probes that reference removed production APIs may indeed be stale, but a builder cannot convert mandatory FAILs into PASS by narrative. They must be reconciled explicitly and truthfully.

### BLOCKER 2 — M08 process exited with crash code

Builder log reports:
- `tests/m08_to_go_delivery_probe.gd` printed `M08_TO_GO_DELIVERY_RESULT=PASS`;
- the process then exited with Windows code `-1073741819`.

A PASS marker followed by an access-violation/non-zero process exit does not satisfy a locked PASS regression gate.

The remediation must determine whether this is:
- a test teardown/lifetime defect;
- a production teardown defect;
- a Godot/editor process defect.

Do not mask the crash by accepting stdout while ignoring the process exit code.

### BLOCKER 3 — final worktree not clean

The R02 prompt required:
`git status --short` empty.

Builder explicitly reports a retained local modification:
`project.godot`

The log describes it as the local GameFeelFlow autoload using a UID-form path.

The owner previously established a clean canonical local↔GitHub state and requires all intended project state to be synchronized. Therefore this remaining tracked diff must be reconciled, not carried indefinitely as a generic owner-local exception.

If the diff is proven to be only a machine-local Godot UID rewrite semantically equivalent to the canonical portable repo path, restore the canonical tracked form. If it contains any other owner-intent change, stop and report rather than discarding it.

## Non-blocking evidence note

Nine evidence PNGs and the focused R02 probe are committed. The focused R02 probe reports the intended visual/state/navigation contracts. Owner-native final visual acceptance is still pending and must occur only after this technical remediation passes.

## Tracker integrity

PASS:
- Codex did not modify root `TASKS.md`;
- BCM-M21-001 was not falsely closed;
- BCM-M21-006 was not started.

## Final result

**CHANGES_REQUIRED / REGRESSION_AND_CLEAN_STATE_CLOSURE**

Required next package:
`BCM-M21-001-R03`

R03 is bounded to:
1. reconcile M07 regression authority without weakening genuine current contracts;
2. eliminate the M08 non-zero crash;
3. reconcile the local `project.godot` diff and end with a genuinely clean/synchronized checkout;
4. rerun the locked relevant regression matrix.

Do not redesign the owner-requested R02 product visuals unless a real regression defect requires a minimal correction.
