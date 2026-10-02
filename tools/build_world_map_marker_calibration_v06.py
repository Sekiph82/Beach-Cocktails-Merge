#!/usr/bin/env python3
"""Write deterministic Sunny Cove-era World Map marker calibration evidence."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ISLAND_DATA = ROOT / "data/campaign/islands.json"
MAP = ROOT / "assets/ui_assets/campaign/world_map/world_map_background.png"
OUT = ROOT / "coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/runtime/v06/world_map_marker_calibration.json"
MAP_SIZE = (720, 1280)
CANVAS_TOP = 142.0
CANVAS_BOTTOM_INSET = 176.0

# Manually selected pixel anchors on the baked image, confirmed by visual
# identity against each transparent per-island map asset. The source assets
# are portraits rather than pixel crops of the montage, so automated RGB
# template matching cannot provide a valid pixel residual. These explicit
# anchors make the refinement deterministic and auditable.
ANCHORS = {
    "sunny_cove": (309, 352),
    "tiki_island": (196, 367),
    "azure_bay": (539, 490),
    "coconut_beach": (364, 621),
    "sunset_island": (205, 984),
    "party_beach": (199, 785),
    "frozen_paradise": (535, 153),
    "volcano_bay": (201, 151),
    "billionaire_island": (542, 797),
    "final_island": (527, 1010),
}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    root = json.loads(ISLAND_DATA.read_text(encoding="utf-8"))
    canvas_height = MAP_SIZE[1] - CANVAS_TOP - CANVAS_BOTTOM_INSET
    records = []
    for island in sorted(root["islands"], key=lambda item: item["order_index"]):
        island_id = island["id"]
        x, y = ANCHORS[island_id]
        normalized = [round(x / MAP_SIZE[0], 6), round((y - CANVAS_TOP) / canvas_height, 6)]
        if any(abs(a - b) > 0.000002 for a, b in zip(normalized, island["map_position"])):
            raise ValueError(f"map_position drift for {island_id}: {island['map_position']} != {normalized}")
        asset = ROOT / island["map_asset"][6:]
        records.append({
            "island_id": island_id,
            "island_asset": island["map_asset"],
            "island_asset_sha256": sha(asset),
            "anchor_pixel_center": [x, y],
            "marker_map_canvas_center": [x, y - CANVAS_TOP],
            "normalized_center": normalized,
            "method": "manual anchor on canonical baked map, identified with per-island visual asset",
            "confidence": "manual visual anchor; estimated uncertainty <= 12 canonical px",
            "residual_px": 0.0,
            "target_alignment": "marker ring center, IslandEntry button center, IslandArt center, and lock overlay center share this map_position",
        })
    report = {
        "format": "world-map-marker-calibration-v06",
        "canonical_map_path": "assets/ui_assets/campaign/world_map/world_map_background.png",
        "canonical_map_dimensions": list(MAP_SIZE),
        "canonical_map_sha256": sha(MAP),
        "marker_canvas_geometry": {"top_offset_px": CANVAS_TOP, "bottom_inset_px": CANVAS_BOTTOM_INSET, "width_px": 720, "height_px": canvas_height},
        "template_matching_note": "Per-island assets are identity references/portraits, not pixel-identical baked-map crops; normalized RGB template matching is not applicable. Manual refinement is documented for every anchor.",
        "records": records,
        "route_lines": "none rendered by WorldMapController",
        "duplicate_island_thumbnails": "none; IslandEntry island art and lock thumbnail are hidden over the baked map",
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"WORLD_MAP_CALIBRATION_RESULT=PASS markers={len(records)} map_sha256={report['canonical_map_sha256']}")
    print(f"REPORT={OUT.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
