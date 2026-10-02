# BCM-M21-001 + BCM-M21-006 — Owner F5 Remediation V06

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `OWNER_F5_RULING_V06.md`
5. `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V06.md`
6. V05 audit/log for behavior that must remain PASS.

## Owner architectural decision

Stop trying to independently align:
- background;
- table;
- table shadow;
- edge overlay;
- launch-zone art;
- table Y offset;
- physics rails.

For Sunny Cove, replace that with:

**one 720×1280 composite gameplay_surface.png + one playable_geometry profile measured from that exact image.**

## 1. Build Sunny Cove gameplay_surface.png

Create a deterministic composition script/tool.

Use the currently accepted Sunny Cove source art.

Commit:
`assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.png`

Record all source hashes/transforms/layer order.

Do not delete source assets.

## 2. Migrate Sunny Cove runtime presentation

When active island = sunny_cove:
- render only gameplay_surface as the static scene;
- do not instantiate separate table/shadow/edge/launch/decor art nodes.

Dynamic Drinks/HUD/To-Go/result remain separate.

Keep legacy layered fallback for non-migrated islands only.

## 3. Define Sunny Cove playable_geometry

Add canonical pixel geometry to island data.

Calibrate against the final composite image, not against old R11 coordinates.

Use one profile for:
- walls;
- rail bounds;
- projection/clamping;
- spawn;
- launch;
- death.

Remove Sunny Cove dependence on `table_y_offset_canonical`.

Do not change physics behavior algorithms unnecessarily. Change the geometry source of truth.

## 4. Prove alignment

Generate a debug overlay on the composite showing:
- polygon;
- launch line;
- spawn;
- death line;
- 12-glass stress layout.

Run actual gameplay/crowded-state capture.

No drink may visually fall behind/below the table artwork because of mismatched coordinate systems.

## 5. Fix World Map marker alignment

Use the actual World Map image, not old normalized guesses.

Calibrate all ten island marker centers against the baked island bodies.

Prefer deterministic image/template matching using the per-island map assets, with documented manual refinement only where necessary.

Marker/name/lock/click target must share one exact center.

No yellow route lines.
No duplicate island thumbnails.

## 6. Do not touch Sunny Cove Island Map layout

The owner now accepts the current layout.

Do not move the level nodes.
Do not restore connector lines.

## 7. Preserve V05 PASS behavior

Must remain PASS:
- PLAY / CONTINUE;
- SETTINGS;
- BACK TO MENU;
- post-result menu input;
- result lifecycle;
- no timer;
- mouse/touch gameplay;
- pause/resume;
- persistence.

## Handoff

Do not edit root `TASKS.md`.

Create:
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V06.md`
- `CODEX_LOG_OWNER_F5_REMEDIATION_V06.md`

Finish exactly:
`AWAITING_OWNER_F5_ACCEPTANCE_V06`

Then stop. Owner F5 acceptance remains mandatory.
