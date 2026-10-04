# BCM-M21-001 — World Map 720×1280 Layout Diagnostic & Closure V01

Work in the canonical checkout:
`C:\Users\sekip\Desktop\Beach Cocktails - Merge`
Branch: `main`.

## Read first

1. `AGENTS.md`
2. root `TASKS.md`
3. `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_R04_REPOSITORY_HYGIENE_AUDIT_V01.md`
4. `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/CHATGPT_M21_WORLD_MAP_LAYOUT_CRITERIA_V01.md`
5. `tests/m12_world_map_probe.gd`
6. `scripts/campaign/world_map_controller.gd`
7. `scripts/campaign/island_entry.gd`
8. `data/campaign/islands.json`

Root `TASKS.md` is read-only.

## Important owner state

BCM-M21-007 cleanup is accepted. Do NOT restore deleted obsolete assets/evidence.

All ten current R04 gameplay surfaces/geometries are owner-approved and frozen.

This task is ONLY the remaining World Map 720×1280 regression closure.

## 1. Sync safely

Follow the generalized owner-local safe-sync procedure in AGENTS.md.

Preserve:
- project.godot;
- scenes/main.tscn;
- addons/godot_ai/;
- addons/game_feel_flow/;
- addons/saltmire_spark/;
- known translation sidecars;
- any other path-disjoint owner-local work.

## 2. Reproduce before editing

Run current:
`tests/m12_world_map_probe.gd`

Capture full output and exact exit code.

Instrument or add a temporary diagnostic harness that records for every island:
- semantic map_position;
- calibrated center;
- entry Control rect;
- selection-ring rect;
- visible label rects;
- map canvas rect;
- header rect;
- status/navigation rects;
- clipping/overlap flags.

Do not make a layout change before this evidence is committed or otherwise safely captured.

## 3. Do NOT assume the marker positions are wrong

The cleanup did not change `world_map_controller.gd`.

The M12 test changed only to remove obsolete `map_background` fixture keys.

Current top-edge semantic centers existed before cleanup.

Therefore first determine whether the failure is:
A. a stale/overbroad report/assertion; or
B. a real visible 720×1280 overlap/clipping defect.

## 4. Use actual GUI + Godot AI

Headless screenshots are not enough.

Launch a renderer-capable 720×1280 World Map and use Godot AI/runtime inspection.

Save real screenshots for:
- full fresh World Map;
- top area with Frozen Paradise / Volcano Bay and header/title;
- bottom area;
- locked selection;
- current/selected island.

Visually inspect them.

## 5. Minimum correct fix only

If pixels are clean:
- fix the layout report/test so it measures the correct visible/interactable geometry;
- split horizontal vs vertical clipping semantics if needed;
- allow only intentional safe edge bleed;
- keep map centers unchanged.

If pixels show actual collision with header/navigation:
- fix the smallest presentation geometry issue;
- prefer marker footprint/label/ring safe placement or map/header bounds;
- change semantic map_position only if evidence proves the center itself must change.

Forbidden:
- blanket coordinate retuning;
- deleting the test;
- hardcoding PASS;
- weakening touch hitboxes;
- changing gameplay R04 assets/geometries;
- changing campaign unlock logic;
- editing TASKS.md.

## 6. Validate

Run every test in locked criteria.

M12 must PASS twice consecutively without intervening file changes.

Produce renderer-capable post-fix screenshots and compare against pre-fix.

## 7. Publish

Create:
- `coordination/sessions/BCM-M21-R04-REPOSITORY-HYGIENE/evidence/world-map-layout-v01/` evidence package;
- `docs/codex-logs/CODEX_LOG_M21_WORLD_MAP_LAYOUT_CLOSURE_V01.md`.

Commit/push only intended remediation/evidence paths.

Verify local HEAD = origin/main = remote main.

Finish exactly:

`AWAITING_GPT_M21_WORLD_MAP_LAYOUT_AUDIT_V01`
