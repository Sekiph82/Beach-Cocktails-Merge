# R09 Real Input Diagnostics

## Island Map Back root cause

- The visible button was enabled at global rect `(18, 18)–(80, 80)`, with `mouse_filter=STOP`; its header was visible with `mouse_filter=PASS`, `z_index=5`.
- The full-screen `ScrollContainer` was `mouse_filter=PASS`, `z_index=2`; its 12,800px-tall `LevelNodes` content was `mouse_filter=PASS`, `z_index=1` and covered the Back coordinates.
- Before the fix, moving to the visible Back center made `LevelNodes` the viewport's hovered Control. A real mouse press/release emitted no `return_requested`; navigation remained `ISLAND_MAP`, World Map hidden, Island Map visible, with exactly two map instances.
- Cause: the long scroll path is hosted in ScrollContainer's embedded viewport and won GUI hit testing over the header. Header draw z did not establish the expected pointer priority.
- Minimal production fix: reparent the same Back Button from the header to the Island Map root input layer and set its z index to 10. Its rect, styling, text, and signal remain the same; no art or map geometry changes.
- After fix, viewport hover at the button center is `BackToWorldMap`; actual mouse input emits one `return_requested`, changes view to `WORLD_MAP`, shows World Map, hides Island Map, and leaves the map instance count at 2.

## Touch navigation

- Project settings recorded: `emulate_touch_from_mouse=false`, `emulate_mouse_from_touch=true`.
- The probe sends `InputEventScreenTouch` press and release through `Viewport.push_input` at Sunny Cove's production control center `(540, 300)`. It does not emit navigation signals directly.
- Each touch entry increments `island_selected`, `island_map_requested`, and `island_map_entered` exactly once, selecting Sunny Cove and showing its 100-level Island Map.
- A second `InputEventScreenTouch` press/release at the visible Back center emits one additional `return_requested` and returns to the same visible World Map instance.

## World Map Back regression trace

- A real mouse press/release on `Header/BackButton` emits one `WorldMapController.return_requested`, then one `CampaignNavigationController.main_menu_requested`.
- `ApplicationShell` becomes `MAIN_MENU` and campaign navigation becomes hidden. No World Map/Home production code was changed.

## Original failing sequence classifications

- Island Map Back: `PRODUCT_DEFECT` (reproduced pointer interception and missing signal; fixed in production).
- Sunny Cove touch entry: `STALE_PROBE` as a downstream failure in the original run; it attempted to enter from World Map while the first failed Back had left Island Map active. The corrected sequence proves genuine touch entry exactly once.
- World Map Back to Home: `STALE_PROBE` as another downstream failure in the original run; the original test attempted World Map Back while navigation still had Island Map active. The corrected real-input chain proves one request per navigation boundary and Home visibility.
