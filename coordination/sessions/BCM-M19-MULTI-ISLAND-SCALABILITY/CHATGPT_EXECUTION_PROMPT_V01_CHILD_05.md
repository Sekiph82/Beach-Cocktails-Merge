# BCM-M19-005 — Per-Island Theme / Asset Hooks

Execute only after Child 04 PASS.

Define data-driven theme hooks for all ten canonical islands using only existing approved assets under:
`assets/ui_assets/campaign/islands/<island_id>/`

At minimum expose gameplay background, gameplay table, gameplay table shadow, table edge overlay, launch zone and island-map background paths. Validate paths and pass the resolved immutable theme through the existing campaign/session boundary.

Do not regenerate assets. Do not alter physics/table rails/HUD. Preserve fallback behavior for fixture/legacy island definitions without theme metadata. If renderer consumption is added, it may change texture assignment only.

Add focused theme-resolution tests.

Log to `CODEX_LOG_V01_CHILD_05.md`. Stop on failure before Child 06.
