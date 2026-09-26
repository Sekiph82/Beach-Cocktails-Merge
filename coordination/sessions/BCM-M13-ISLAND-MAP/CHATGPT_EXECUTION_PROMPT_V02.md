# BCM-M13 Island Map — Remediation V02

Execute against:
- `coordination/sessions/BCM-M13-ISLAND-MAP/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M13-ISLAND-MAP/CHATGPT_AUDIT_CRITERIA_V02.md`

Fix only the two M13 closure blockers plus the false-green focus test.

## 1. Wire real M12 -> M13 -> M12 navigation

The current M12 boundary is:
`island_map_requested(island_id)`

Add the smallest production runtime navigation layer needed to:
- consume that signal;
- open/configure the single generic IslandMapScene with the exact selected island id;
- preserve one canonical campaign/database authority;
- handle IslandMap back navigation to World Map;
- avoid duplicate map instances after repeated transitions.

Do not launch gameplay. `level_selected` remains an M14 boundary only.

Choose the cleanest existing host/router location after inspecting current scene architecture. Do not force campaign navigation into R11 gameplay/physics code if a bounded campaign navigation host is cleaner.

## 2. Fix first-entry focus semantics

No restoration state:
- compute highest unlocked unfinished level explicitly;
- do not merely inherit CampaignManager.selected_level_id;
- all-complete -> final configured level.

Restoration state:
- restore stored focus instead.

## 3. Restore actual scroll state

`get_restoration_state()` already exposes `scroll_vertical`.

Make re-entry restore the saved scroll value after layout, clamped to valid bounds.

Do not overwrite a restored manual scroll position by immediately auto-centering focus.

## 4. Strengthen tests

Update the M13 probe/integration evidence so it proves:
- actual M12 signal enters IslandMap with exact island id;
- IslandMap back returns to World Map;
- repeated transitions do not duplicate map nodes;
- campaign selection is deliberately set lower than highest unlocked unfinished before first entry, yet focus still chooses highest unlocked unfinished;
- a deliberately non-default manual scroll position survives leave/re-entry;
- selected/focus restoration still works;
- all existing 100-node/state/stars/milestones/summary checks remain.

Run normal Godot 4.7 import bootstrap, M13 twice, then M10/M11/M12.

## Hard boundaries

Do not:
- implement M14 gameplay/session launch;
- implement M16 production levels;
- edit root `TASKS.md`;
- touch R11 physics/merge/table/HUD;
- regenerate accepted visual assets.

## Completion

Write:
`coordination/sessions/BCM-M13-ISLAND-MAP/CODEX_LOG_V02.md`

Return:
- implementation SHA;
- final main HEAD;
- M12->M13 navigation PASS/FAIL;
- back navigation PASS/FAIL;
- exact scroll restoration PASS/FAIL;
- first-entry focus PASS/FAIL;
- M13 run 1/run 2;
- M10/M11/M12 regressions;
- log URL;
- `AWAITING_M13_AUDIT_V02`.

Then STOP.
