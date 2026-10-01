# BCM-M21-001 + BCM-M21-004 + BCM-M21-006 — Owner F5 Remediation V03

Work only in:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`

Repository: `Sekiph82/Beach-Cocktails-Merge`
Branch: `main`

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/AUDIT_POLICY.md`
4. `OWNER_F5_RULING_V03.md`
5. `CHATGPT_OWNER_F5_REMEDIATION_CRITERIA_V03.md`
6. prior owner-runtime V01/V02 evidence and logs.

## Fix the five owner-visible failures in one batch

### 1. Godot debug size

Keep canonical 720×1280.

Set:
- `window_width_override=800`
- `window_height_override=1422`

### 2. World Map routes + Sunny Cove position

The background already contains white dotted routes.

Remove/disable the runtime yellow `IslandRoute` Line2D entirely.

Do not replace it with another runtime route line.

Stop using hard-coded `BAKED_ISLAND_CENTERS` as canonical placement.

Use each island's `islands.json.map_position`.

Sunny Cove must resolve from `[0.16,0.83]` and appear lower-left.

Keep selection ring/lock/click target centered there. Keep duplicate island thumbnail hidden.

### 3. Sunny Cove Island Map

Replace the generic flat-blue canonical Island Map background with the selected island's:

`island_theme.island_map_background`

Sunny Cove must show:
`res://assets/ui_assets/campaign/islands/sunny_cove/map_background.png`

Keep level path/nodes/scroll above it.

### 4. Sunny Cove table unobscured

Owner screenshot proves the correct wooden table exists but another layer covers it.

Production Sunny Cove must render only the approved five theme layers:
- gameplay_background
- gameplay_table_shadow
- gameplay_table
- table_edge_overlay
- launch_zone

Do not render:
- decor_left
- decor_right
- decor_back

Instrument the runtime and identify every visible texture path/z-order before first shot.

If the actual occluding node is another legacy texture, identify it explicitly and disable only that visual layer.

Do not move/change R11 physics rails/contact geometry.

Success is visual: the wooden `sunny_cove/gameplay_table.png` must be clearly visible and not covered by the giant pool/decor composition shown in the owner FAIL screenshot.

### 5. WIN result cleanup

Current terminal logic only freezes Drink nodes. That is insufficient.

Before showing WIN/LOSE:
- hide all active Drink nodes;
- hide/remove held shot object;
- clear/hide merge feedback and delivery trails;
- prevent post-terminal score/delivery changes.

Move campaign result feedback to a dedicated topmost CanvasLayer so no world/HUD sprite can render above it.

The owner WIN capture must show a clean modal with zero cocktails on top.

## Preserve existing PASS items

Must remain PASS:
- Main Menu → PLAY → World Map;
- Sunny Cove → Level 1;
- real gameplay input;
- no timer / no TIME UP;
- Pause → Resume;
- restart persistence;
- +Time retired.

## Evidence

Generate 720×1280 captures:
1. World Map with Sunny Cove lower-left and no yellow runtime route line;
2. Sunny Cove Island Map with its real map background;
3. Sunny Cove gameplay showing unobscured wooden table;
4. WIN result with no cocktail sprites over modal.

Also create machine-readable reports for:
- hotspot centers;
- gameplay visible texture/z inventory;
- terminal visible Drink/effect count.

## Handoff

Do not edit root `TASKS.md`.

Create:
- `OWNER_F5_ACCEPTANCE_CHECKLIST_V03.md`
- `CODEX_LOG_OWNER_F5_REMEDIATION_V03.md`

Finish exactly:

`AWAITING_OWNER_F5_ACCEPTANCE_V03`

Then stop. Owner manual F5 acceptance remains mandatory.
