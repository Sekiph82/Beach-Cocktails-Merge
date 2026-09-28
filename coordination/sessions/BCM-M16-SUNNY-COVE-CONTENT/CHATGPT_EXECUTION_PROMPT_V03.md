# BCM-M16 VIP Crown Marker Remediation — Execution Prompt V03

Execute only this bounded visual remediation against:

- `coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_V02.md`
- `coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CHATGPT_AUDIT_CRITERIA_V03.md`
- `coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/OWNER_RULING_V02.md`

Before implementation:
- obey `AGENTS.md`;
- synchronize `C:\Users\sekip\Desktop\Beach Cocktails - Merge`;
- confirm root `TASKS.md` authorizes Codex.

## Goal

Fix the Island Map VIP marker so it actually reads as **VIP + crown** at a glance.

All V02 VIP content/reward/replay logic is already technically accepted and must remain unchanged.

## 1. Replace the marker asset

In production LevelButton marker code, replace:

`res://assets/ui_assets/screens/prelevel/vip_badge.png`

with:

`res://assets/ui_assets/ui/gameplay/vip_badge.png`

Do not generate or modify artwork.

The replacement asset already contains:
- gold crown;
- readable VIP lettering;
- tropical decoration.

## 2. Marker size

Set the runtime marker display size to exactly:

`36 × 36 px`

at the canonical 720×1280 reference viewport.

Preserve aspect ratio.

Do not stretch or squash the asset.

## 3. Marker placement

Keep the marker adjacent to the upper-right edge of the reusable level button.

Requirements:
- does not cover the level number;
- does not cover stars;
- does not cover OPEN/CURRENT/LOCKED/COMPLETE text;
- does not cover milestone marker;
- remains inside the 720px Island Map content bounds for both alternating left/right node positions.

You may make a small bounded `position` adjustment only for the marker.

Do not move the whole level-node path or rewrite Island Map layout.

## 4. Preserve data-driven behavior

Keep production visibility derived from:

`level_database.get_level(island_id, level_id).vip.enabled`

No hard-coded production VIP-level list.

VIP marker must remain visible in:
- COMPLETE
- OPEN
- CURRENT
- LOCKED

and hidden on non-VIP levels.

## 5. Frozen V02 contracts

Do not change:
- `data/campaign/levels/sunny_cove.json`;
- the 25 VIP levels;
- targets/quantities;
- +Time/Upgrade rewards;
- workload ratios;
- replay-later persistence;
- reward idempotency;
- normal objectives/timers;
- M15 To-Go/VIP HUD;
- scoring/economy semantics;
- R11 physics/table/colliders.

## 6. Runtime screenshots

Commit actual Windows/OpenGL Island Map evidence under:

`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/evidence/v03/`

Required:

- `vip_complete.png`
- `vip_open.png`
- `vip_current.png`
- `vip_locked.png`
- `non_vip_control.png`

Each screenshot must show enough context to judge:
- crown/VIP readability;
- relation to the level node;
- no overlap with level number/stars/state/milestone;
- no clipping at map edges.

Do not use synthetic/mock screenshots.

## 7. Tests

Update focused M16 marker assertions to verify:
- exact production asset path is `res://assets/ui_assets/ui/gameplay/vip_badge.png`;
- marker size = 36×36;
- VIP state visibility remains correct;
- non-VIP remains hidden.

Run:
- M16 focused probe twice;
- M13 Island Map regression;
- M15 regression;
- `git diff --check`.

## Hard boundaries

Do not:
- edit root `TASKS.md`;
- alter any canonical Sunny Cove level data;
- alter VIP reward/replay logic;
- alter M15 HUD;
- start M17;
- create a GitHub branch;
- create Desktop clones/worktrees.

## Completion

Write:

`coordination/sessions/BCM-M16-SUNNY-COVE-CONTENT/CODEX_LOG_V03.md`

Include:
- old/new marker resource path;
- final marker size/position;
- screenshot paths;
- M16/M13/M15 results;
- diff-check result;
- final sync proof.

Push to `main`, sync canonical Desktop, then return:

- implementation SHA;
- final main/canonical SHA;
- correct crown+VIP asset PASS/FAIL;
- 36×36 marker PASS/FAIL;
- no-overlap/clipping PASS/FAIL;
- all-state visibility PASS/FAIL;
- non-VIP hidden PASS/FAIL;
- frozen VIP/normal data PASS/FAIL;
- tests;
- evidence paths;
- log URL;
- `AWAITING_M16_AUDIT_V03`.

Then STOP. Do not start M17.
