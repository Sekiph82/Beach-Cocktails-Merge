# BCM-M21-001-R09 — Locked Criteria: World Map Real-Input Regression Closure

Status: **LOCKED BEFORE EXECUTION**

Authority:
`coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/CHATGPT_R08_AUDIT.md`

## Scope

Close only the three inherited V05 production-navigation/input failures.

Freeze:
- R08 Home frontier behavior;
- accepted Home art/layout;
- R07 Sunny Cove full 720×1280 background;
- R07 landmark positions;
- Island Map LV/stars/title/mastery thresholds;
- gameplay;
- economy draft.

Root `TASKS.md` is read-only to Codex.

## Mandatory diagnosis

Reproduce the current V05 probe unchanged first and retain full stdout/exit.

Instrument each failing step independently.

### A. Island Map Back

Using the real production node:
`IslandMapHeader/BackToWorldMap`

Record:
- global rect;
- visibility;
- disabled state if applicable;
- mouse_filter;
- z_index;
- all Controls under pointer at its center if practical;
- emitted `return_requested`;
- `CampaignNavigationController.current_view` before/after;
- World Map visibility before/after.

Then send actual mouse press/release to the real center.

PASS:
- exactly one logical return;
- current view becomes WORLD_MAP;
- one World Map and one Island Map instance remain;
- World Map visible, Island Map hidden.

### B. Sunny Cove touch path

Using the real Sunny Cove entry center:
- record project touch/mouse emulation settings/default behavior;
- send actual `InputEventScreenTouch` press/release;
- count `island_selected`, `island_map_requested`, and `island_map_entered`;
- record resulting current view and active island.

PASS:
- one user touch produces one logical Sunny Cove navigation;
- no duplicate selection/request/enter;
- Island Map visible with 100 levels.

If Godot's test-injected `InputEventScreenTouch` does not synthesize GUI activation under current project/runtime semantics, do not fake PASS. Prove the correct production mobile path using an equal-or-stronger input harness and document why the old probe was stale.

### C. World Map Back

Using real:
`Header/BackButton`

Record:
- global rect;
- visibility;
- mouse_filter;
- z_index;
- emitted `return_requested`;
- navigation `main_menu_requested`;
- ApplicationShell current view/visibility before and after.

PASS:
- real pointer input returns to MAIN_MENU;
- campaign navigation becomes hidden;
- no duplicate shell/navigation instance is created.

## Product-vs-test decision

For each failure classify exactly one:
- PRODUCT_DEFECT
- STALE_PROBE
- HARNESS_LIMITATION

Classification requires evidence.

Forbidden:
- deleting the check;
- weakening it to helper-only calls;
- arbitrary sleeps until green;
- tolerance inflation;
- bypassing real controls by directly emitting signals as the only proof.

## Required final regression

All exit 0:
- corrected/current V05 World Map production real-input probe;
- R08 Home frontier production-path probe;
- R07 page-focus probe;
- R07 node visual probe;
- M20 ApplicationShell probe;
- full-background R01 probe;
- M18 star contract;
- asset validator;
- Godot import/parse/boot;
- `git diff --check`.

Run V05 twice consecutively to exclude flaky timing.

## Evidence

Create:
`coordination/sessions/BCM-M21-WORLD-MAP-INPUT-R09/evidence/`

Include:
- unchanged initial V05 failure;
- per-step diagnostics A/B/C;
- final V05 run 1;
- final V05 run 2;
- real-input state/signal report;
- final sync proof.

## Log

Create:
`docs/codex-logs/CODEX_LOG_M21_WORLD_MAP_INPUT_R09.md`

Do not edit root `TASKS.md`.

Final marker exactly:

`AWAITING_GPT_M21_WORLD_MAP_INPUT_AUDIT_R09`
