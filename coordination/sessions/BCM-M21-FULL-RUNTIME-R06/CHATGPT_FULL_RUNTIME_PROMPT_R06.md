# BCM-M21-001-R06 — Freeze Approved Home and Prepare Full Godot Runtime Review

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

GitHub:
`https://github.com/Sekiph82/Beach-Cocktails-Merge`

Branch:
`main`

## OWNER DECISION

The Home screen is now APPROVED.

Do not change its visual composition anymore.

Accepted Home baseline:
`d265865f67770be34e3c45f83ea07141feb3c5ca`

The owner now wants the current complete game fully integrated and opened in Godot so they can test the latest real build.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/OWNER_HOME_ACCEPTANCE_R06.md`
4. `coordination/sessions/BCM-M21-FULL-RUNTIME-R06/CHATGPT_FULL_RUNTIME_CRITERIA_R06.md`
5. current `HOME_TARGET_LAYOUT_R04.json`
6. current `scripts/campaign/application_shell.gd`
7. current `project.godot`

Root `TASKS.md` is READ-ONLY.

## 1. Sync safely

Start by recording:

```
git status --short --branch
git rev-parse HEAD
git fetch origin main
git rev-list --left-right --count HEAD...origin/main
git diff -- project.godot
```

The Home assets/layout may already be canonical on GitHub.

Do not reset, clean, rebase, or force.

Do not lose owner work.

## 2. Resolve the lingering project.godot dirty state

A tracked local `project.godot` modification has been preserved through multiple tasks.

We no longer want the canonical project to remain dirty.

Compare the local file with GitHub main byte-for-byte and semantically.

The canonical GitHub project currently uses portable repository-relative autoloads:

```
Spark="*res://addons/saltmire_spark/spark.gd"
GameFeelFlow="*res://addons/game_feel_flow/core/game_feel_flow.gd"
_mcp_game_helper="*res://addons/godot_ai/runtime/game_helper.gd"
```

and:

```
run/main_scene="res://scenes/campaign/ApplicationShellScene.tscn"
```

If the local diff is ONLY Godot UID/path normalization for the same addon:
- restore canonical GitHub `project.godot`;
- verify all three plugins/autoloads still load.

If there is ANY additional owner-authored semantic change:
STOP and report:
`OWNER_PROJECT_GODOT_RECONCILIATION_REQUIRED`

Do not silently discard it.

## 3. Freeze the approved Home

The Home is visually FINAL for this cycle.

Do NOT alter:
- bar positions/sizes;
- number positions;
- plus positions;
- Continue position;
- Play;
- World Map;
- Settings;
- bottom buttons;
- background;
- Home assets;
- Home layout.

Hash:
- `HOME_TARGET_LAYOUT_R04.json`;
- all `assets/ui_assets/screens/home/*.png`;
- `scripts/campaign/application_shell.gd`.

Record hashes before/after.

They must remain unchanged unless an actual nonvisual technical startup defect requires a code-only correction.

No visual correction is authorized.

## 4. Verify this is the real game startup

Confirm:

`project.godot → run/main_scene → ApplicationShellScene.tscn`

Normal F5 must enter the real current game through ApplicationShell.

Do not change main scene to a test.

Do not clear the owner's save.

Do not reset campaign progress.

Do not reset onboarding state.

The owner's current progression must remain intact.

## 5. Verify current Home behavior

On the real Home:

- Level value reflects current campaign level.
- `CONTINUE LEVEL N` uses that same level.
- coin value uses real economy.
- accepted current Energy/Gems display behavior stays as-is.
- PLAY opens/resumes the player's current valid campaign level.
- WORLD MAP opens the real production World Map.
- SETTINGS opens Settings.

Use real pointer input in the focused automation.

## 6. Run latest complete-game smoke path

Use production scenes and navigation.

Verify:

```
HOME
→ WORLD MAP
→ SUNNY COVE
→ ISLAND MAP
→ CURRENT PLAYABLE LEVEL
→ GAMEPLAY
→ PAUSE
→ RESUME
→ CURRENT RESULT/BACK FLOW
→ ISLAND MAP
→ WORLD MAP
→ HOME
```

Check visually/technically along the way:

### Home
owner-approved final Home unchanged.

### World Map
owner-approved V04/V05 current composition unchanged.

### Island Map
latest accepted PNG node/header work present.

### Gameplay
owner-approved R04 gameplay surface present.

To-Go/VIP panel stays at the +25% accepted scale.

No timer.
No `TIME UP`.
No `+Time`.

Do not redesign anything during this test.

## 7. Run automated checks

Run all commands in the locked R06 criteria.

Every current R06 gate must exit 0.

Important:
The older M07 historical-regression reconciliation and M08 post-PASS process-crash finding still exist from the earlier independent audit.

Do not pretend those are closed.

Do not spend this task redesigning their systems.

Record them as deferred carry-forward technical findings after the owner runtime review unless they directly block normal startup.

## 8. Make local + GitHub truly synchronized

After any justified technical integration changes:

```
git status --short
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
git rev-list --left-right --count HEAD...origin/main
```

Required:
- clean status;
- local = origin/main = remote main;
- ahead/behind 0/0.

No lingering tracked `project.godot` modification.

## 9. OPEN GODOT FOR THE OWNER

This is important.

After all checks are complete:

1. open the project in the installed Godot 4.7.2 GUI;
2. run the project using the normal main-scene/F5 flow;
3. show the owner the real latest build starting from the actual application flow;
4. if possible, leave the Godot editor and running project open for manual owner testing.

Do not run only headless tests and stop.

Do not launch a probe instead of the actual game.

If your execution environment cannot leave GUI processes open, say that clearly and provide the exact launch command you successfully used.

## 10. Evidence/log

Create:

`coordination/sessions/BCM-M21-FULL-RUNTIME-R06/evidence/`

Create:

`docs/codex-logs/CODEX_LOG_M21_FULL_RUNTIME_R06.md`

Do not edit root `TASKS.md`.

Push any justified integration/evidence/log commits.

## STOP

When the latest real game is ready for the owner to test, finish exactly:

`AWAITING_OWNER_FULL_GAME_RUNTIME_REVIEW_R06`

Do not start BCM-M21-006.
