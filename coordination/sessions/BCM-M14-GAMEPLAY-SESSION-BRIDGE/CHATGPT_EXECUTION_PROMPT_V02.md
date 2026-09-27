# BCM-M14 Gameplay Session Bridge — Remediation V02

Execute against:
- `coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CHATGPT_AUDIT_V01.md`
- `coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CHATGPT_AUDIT_CRITERIA_V02.md`

Fix only the three M14 closure blockers.

## 1. Compose the real executable campaign flow

M13 V02 explicitly deferred this to M14.

Current project boot still goes directly to:
`res://scenes/main.tscn`

Change the production app entry composition so a normal project launch enters the campaign navigation shell/router and gameplay is instantiated only after an unlocked M13 level selection.

Requirements:
- M12 World Map -> M13 Island Map -> M14 gameplay must be reachable in the actual app flow;
- keep one CampaignNavigationController authority;
- keep one LevelDatabase/CampaignManager authority;
- reuse the existing `scenes/main.tscn` gameplay scene;
- do not duplicate per-level gameplay scenes.

Choose the smallest clean app-shell/main-scene composition.

## 2. Correct stars

Implement the locked design exactly:
- 1 star: normal completion;
- 2 stars: VIP completed OR configured 2-star mastery reached;
- 3 stars: VIP completed AND configured 3-star score mastery reached.

Examples that must be tested:
- high score + VIP incomplete => 2, not 3;
- VIP complete + insufficient 3-star score => 2;
- VIP complete + 3-star score => 3;
- plain normal completion => 1.

Preserve monotonic replay behavior in CampaignManager.

## 3. Wire real pause/background lifecycle

Bridge APIs already exist. Connect them to production.

Implement a bounded production-facing gameplay pause/resume hook.

Also connect Godot application background/pause/resume lifecycle to the active bridge.

Required behavior:
- gameplay pause freezes timer;
- gameplay resume restores it appropriately;
- application background freezes timer;
- application resume resumes only a session paused by background;
- if the player/session was already paused before backgrounding, app resume must leave it paused;
- terminal sessions remain terminal.

Do not use wall-clock time as gameplay truth.

## 4. Strengthen M14 tests

Update `tests/m14_gameplay_session_bridge_probe.gd` and/or add a bounded app-flow probe to prove:
- actual configured app entry uses the campaign shell;
- real M12 -> M13 -> M14 traversal;
- production gameplay pause hook freezes/resumes timer;
- production application background handler freezes/resumes timer correctly;
- pre-existing user pause survives app background/resume;
- corrected 1/2/3-star matrix;
- all previous M14 behavior remains green.

## 5. Regressions

Run normal Godot 4.7 import/bootstrap.

Then:
- M14 run 1;
- M14 run 2 with no intervening changes;
- M10;
- M11;
- M12;
- M13;
- M02;
- M03;
- M08;
- any new focused app-entry/lifecycle probe.

Do not rewrite superseded historical R10 probes just to turn them green.

## Hard boundaries

Do not:
- edit root `TASKS.md`;
- implement M15 rewards/boosters/economy;
- author M16 Sunny Cove L1-L100 production content;
- retune R11 physics/table/colliders/HUD;
- regenerate accepted visual assets.

## Completion

Write:
`coordination/sessions/BCM-M14-GAMEPLAY-SESSION-BRIDGE/CODEX_LOG_V02.md`

Return:
- implementation SHA;
- final main HEAD;
- real app-entry campaign flow PASS/FAIL;
- corrected star matrix PASS/FAIL;
- gameplay pause lifecycle PASS/FAIL;
- app background lifecycle PASS/FAIL;
- M14 run1/run2;
- M10/M11/M12/M13/M02/M03/M08 regressions;
- log URL;
- `AWAITING_M14_AUDIT_V02`.

Then STOP.
