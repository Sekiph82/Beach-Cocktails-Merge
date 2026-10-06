# BCM-M21-001-R09 — Close V05 World Map Real-Input Regression

Repository:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Branch:
`main`

## Context

Independent R08 audit result:

- R08 Home frontier fix = PASS.
- Overall project gate = still red because the locked production V05 World Map probe fails three real-input/navigation checks.
- The same failures reproduce on the clean pre-R08 baseline, so do NOT revert or change R08.

Your job is to diagnose and close those three failures only.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/CHATGPT_R08_AUDIT.md`
4. `coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/CHATGPT_WORLD_MAP_INPUT_CRITERIA_R09.md`
5. `tests/m21_world_map_production_v05_probe.gd`
6. `scripts/campaign/world_map_controller.gd`
7. `scripts/campaign/island_map_controller.gd`
8. `scripts/campaign/campaign_navigation_controller.gd`
9. `scripts/campaign/application_shell.gd`

Root `TASKS.md` is READ-ONLY.

## 1. Safe sync

Follow AGENTS safe-sync rules.

Preserve the two owner-local critique PNGs.

No destructive reset, clean, rebase, force push, or silent stash.

## 2. Reproduce unchanged first

Run exactly:

`godot_console.exe --path . --script res://tests/m21_world_map_production_v05_probe.gd`

Do not edit anything first.

Retain stdout/stderr and exit code.

Expected current failures from audit:

- Island Map Back to World Map
- ScreenTouch opens Sunny Cove exactly once
- World Map Back to Home

If the unchanged run unexpectedly passes, run it three times before deciding the issue disappeared.

## 3. Diagnose Island Map Back

Instrument the real production Back button.

Do not call `show_world_map()` directly as proof.

Capture:
- button global rect/center;
- visibility;
- mouse filter;
- z index;
- parent header filter/z;
- ScrollContainer filter/z;
- whether any higher Control owns the pointer;
- signal counts for `return_requested`;
- view/visibility state before and after press/release.

Determine whether the click is intercepted, the signal is not emitted, or the routing state check is stale.

Apply the smallest principled correction.

## 4. Diagnose touch navigation

Do not assume `InputEventScreenTouch` automatically drives Button GUI behavior in this runtime.

Inspect actual Godot 4.7 input semantics and current project settings.

Record counts before/after:
- `island_selected`
- `island_map_requested`
- `island_map_entered`

The final test must still prove a genuine touch/mobile-compatible production path.

If the old V05 harness uses an invalid synthetic touch method, replace that portion with an equal-or-stronger harness that exercises the real GUI/input path. Explain the classification in the log.

Do not simply substitute a direct signal emit.

## 5. Diagnose World Map Back

Instrument real `Header/BackButton`.

Trace:

`BackButton.pressed`
→ `WorldMapController.return_requested`
→ `CampaignNavigationController._on_world_map_return_requested`
→ `main_menu_requested`
→ `ApplicationShell._on_navigation_main_menu_requested`
→ `show_main_menu()`

Prove exactly one transition to MAIN_MENU and hidden campaign navigation.

If pointer interception prevents it, fix z/mouse-filter/layout minimally.

If the V05 sequence is invalid/stale after preceding steps, correct the sequence while retaining real pointer proof.

## 6. Preserve all accepted work

Do NOT change:
- R08 frontier authority;
- Home art/layout;
- Sunny Cove 720×1280 background;
- island landmark coordinates;
- title/LV/stars;
- threshold generator/data;
- gameplay;
- economy draft.

## 7. Final V05 proof twice

The final current V05 production input probe must exit 0 twice consecutively.

It must prove:
- Home → World Map real click;
- Sunny Cove mouse entry;
- Island Map Back;
- Sunny Cove touch entry;
- Island Map Back again;
- World Map Back → Home;
- one map pair only.

No helper-only substitution.

## 8. Regressions

Run every check in locked criteria.

All must exit 0.

## 9. Publish

Evidence:
`coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/evidence/`

Log:
`docs/codex-logs/CODEX_LOG_M21_WORLD_MAP_INPUT_R09.md`

Do not edit root `TASKS.md`.

Push to main and stop exactly:

`AWAITING_GPT_M21_WORLD_MAP_INPUT_AUDIT_R09`

Do not start M21-006.
