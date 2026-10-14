# M34-005 bounded cleanup inventory R01

The scan inventoried 398 tracked image, audio, and font assets under `assets/`, plus one aggregate row for current `.import` metadata. It searched literal file paths and basenames in tracked production scripts/scenes/data, tests, tools, `project.godot`, current UI contracts, root `TASKS.md`, and the active M34 owner prompts.

| Disposition | Rows | Meaning |
|---|---:|---|
| KEEP | 372 | A literal current-runtime/test/tool/contract reference was found. |
| REVIEW | 26 | No literal match was found; this does not establish obsolescence. |
| DELETE | 0 | No candidate passed complete runtime, data-driven, visual, provenance, and future-use proof. |

The tracked asset inventory and each reference path are in `cleanup_inventory_r01.csv`. All 400 discovered `assets/**/*.import` sidecars (393,127 aggregate bytes) are recorded as `KEEP` and were left untouched. The task-owned `godot-user-data/` profile and live `.godot` cache also remain untouched. No owner-local or canonical Desktop files were read or changed.

The 26 review rows need dynamic loading and visual/provenance review before any cleanup decision. This bounded scan did not inspect ignored caches, remove assets, compare release export sizes, or change the previous deletion history. The earlier removal of `data/campaign/shop_catalog.json` remains recorded in the prior M34-005 inventory and cleanup summary.
