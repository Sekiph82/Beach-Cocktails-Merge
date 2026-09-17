# BCM-M07-R02 — ChatGPT Strict Audit V01

Verdict: **CHANGES_REQUIRED**

## Scope audited

- `coordination/sessions/BCM-M07-R02/CODEX_LOG_V01.md`
- `docs/evidence/m07/independent_inner_content_layout.json`
- `tests/m07_hud_composition_probe.gd`
- current production HUD code/state inherited from M07-R01 V02
- historical locked M07 V02 criteria and R03 requirements

## What materially improved

M07-R02 adds real visible-bound calculations rather than relying only on node centers:

- text bounds use active Godot font metrics and shadow offsets;
- cocktail bounds use imported texture alpha `get_used_rect()` transformed by the live Sprite2D scale/pivot;
- To-Go target/name/reward and NEXT visible bounds are checked against explicit content boxes;
- progression alpha bounds are checked for containment and neighbor overlap;
- the production layout remains the improved tropical M07 direction rather than reverting to the old prototype look.

The bounded production change moving the To-Go target from `0.41` to `0.39` of panel height is also appropriately small and evidence-driven in intent.

## Blocking findings

### F-M07-R02-001 — Progression 'independent' cells mirror production formulas — BLOCKER

The R03 requirement explicitly says authoritative content boxes must be independent from the assertions/production layout they test.

However, `independent_inner_content_layout.json` defines progression rows/cells using the same ratios as production:

- width = `1/6`;
- top row y = `0.08`, height = `0.34`;
- bottom row y = `0.54`, height = `0.34`.

Production `_build_progression_icons()` uses the same structure: six equal columns, cell y `0.08 + row*0.46`, cell height `0.34`. The test's `_relative_cell_rect()` then reconstructs those same cell rectangles from the dataset.

That proves the icons fit the production-authored cell geometry, but it does not independently prove the chosen 2x6 regions are the correct visible blank regions of the decorated progression artwork. This fails the independence requirement for progression content boxes.

### F-M07-R02-002 — Current final PNG pixels remain independently unverified — BLOCKER

The strict M07 criteria require independent visual inspection of the fresh clean screenshots, visible-bounds overlays, master/runtime sheets, and progression close-ups. The GitHub connector exposes current PNG paths/hashes but does not expose their binary pixels to this audit.

Therefore material visual items such as actual frame/garnish clipping, aesthetic centering, master-relative balance, and whether the 2x6 composition looks intentional rather than mechanically fitted remain `UNVERIFIED`. Under the locked audit policy this blocks `AUDITED_PASS`.

## Passing areas from source/test inspection

- Score/Best/To-Go/NEXT remain live production values.
- One To-Go and one NEXT presentation remain.
- shared `Drink.texture_for_level()` mapping remains in use.
- To-Go/NEXT checks now use alpha/text visible bounds, which is materially stronger than R01.
- score/best text bounds use actual font measurement and shadow offsets.
- no guide line is present.
- danger/launch geometry remains synchronized with M06 values.
- 2x6 level order remains top L07-L12 and bottom L01-L06 with no L13.
- R03 regression markers are reported passing.

## Final verdict

**CHANGES_REQUIRED**.

M07-R02 is technically much stronger than the previous pass and the visible-bound machinery is useful. The remaining hard blocker is that the progression acceptance boxes are still derived from the same production layout ratios, plus the locked requirement for independent inspection of the final evidence pixels remains unmet.
