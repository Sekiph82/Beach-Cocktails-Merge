# BCM-M21 World Map hotspot calibration V01

The production background is the canonical 720×1280 `world_map_background.png`.
The ten `IslandEntry` controls now use the integer pixel centers in the JSON
artifact and draw only state/click treatment. Their duplicate `map_asset`
thumbnail is retained as a compatibility node but is hidden, so the baked
island remains the only island artwork.

`WorldMapController` converts these canonical pixel centers into the current
viewport and uses the same centers for entry placement and route-line points.
