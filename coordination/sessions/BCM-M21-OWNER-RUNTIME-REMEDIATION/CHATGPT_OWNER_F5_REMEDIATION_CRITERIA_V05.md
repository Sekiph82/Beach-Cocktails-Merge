# BCM-M21 Owner F5 Remediation V05 — Locked Audit Criteria

Status: **LOCKED BEFORE EXECUTION**

Active task IDs:
- BCM-M21-001
- BCM-M21-006

BCM-M21-004 remains closed unless a new gameplay regression is discovered.

Authority:
- `OWNER_F5_RULING_V05.md`
- V04 owner/runtime rulings and accepted V04 implementation;
- current main source.

## A — scope

Fix only the invisible result-layer input blocker and any directly required lifecycle cleanup.

Preserve all V04 PASS behavior:
- 800×1422 debug view;
- no timer;
- real mouse/touch gameplay;
- World Map/Island Map V04 layout;
- +150 px table translation;
- V04 result lifecycle correctness;
- persistence;
- retired +Time.

CODEX must not edit root `TASKS.md`.

## B — result canvas visibility/input lifecycle

On creation:
- `CampaignResultCanvasLayer.visible = false`;
- full-screen root must not consume underlying input while result is hidden;
- prefer `CampaignResultCanvasRoot.mouse_filter = MOUSE_FILTER_IGNORE`.

On actual WIN/LOSE presentation:
- enable/show CanvasLayer immediately before result card presentation;
- result feedback itself remains the input-consuming surface;
- card buttons remain clickable.

On any transition away from a result:
- hide feedback;
- hide CanvasLayer;
- root remains input-ignored.

Transitions include:
- Next Level;
- Retry;
- Island Map;
- World Map;
- Main Menu;
- CampaignNavigation becoming invisible.

CampaignNavigation must synchronize result-layer visibility when its own `visibility_changed` fires.

No hidden CanvasLayer/Control may block ApplicationShell menu controls.

## C — real GUI input smoke

Mandatory production-path GUI test using `Viewport.push_input()` or equivalent real GUI dispatch.

Direct calls to:
- `press_play_continue()`;
- `show_settings()`;
- `close_settings()`;
- result action handlers

do not satisfy the input gate.

Required sequence:

1. launch ApplicationShell to Main Menu;
2. real mouse click PLAY / CONTINUE;
3. verify CampaignNavigation visible and World Map active;
4. return to Main Menu through production Back/Main Menu action;
5. real mouse click SETTINGS;
6. verify Settings visible;
7. real mouse click BACK TO MENU;
8. real mouse click PLAY / CONTINUE again;
9. open Sunny Cove and a level;
10. complete WIN;
11. verify result card visible and result layer active;
12. click Next Level through GUI;
13. verify result layer inactive after transition;
14. return Main Menu;
15. verify PLAY and SETTINGS still work after a prior result.

Acceptance:
- every GUI click succeeds;
- menu click count 100%;
- no direct-method shortcut;
- zero invisible input blocker.

## D — regression

Re-run:
- V04 result lifecycle WIN → Next → WIN → Island Map → LOSE → Retry;
- real gameplay mouse 10/10 and touch 10/10;
- no timer / one-hour survival;
- World Map and Island Map navigation;
- settings persistence;
- save/restart;
- `git diff --check`.

Godot runtime red error count must remain 0 for the combined menu/result flow.

## E — owner evidence

Generate:
1. Main Menu before PLAY;
2. World Map after real PLAY click;
3. Settings after real SETTINGS click;
4. Main Menu after BACK TO MENU;
5. WIN result;
6. Main Menu after returning from a completed result.

Create:
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V05.md`
- `CODEX_LOG_OWNER_F5_REMEDIATION_V05.md`

Technical success marker:
`AWAITING_OWNER_F5_ACCEPTANCE_V05`

Do not claim release-ready.
