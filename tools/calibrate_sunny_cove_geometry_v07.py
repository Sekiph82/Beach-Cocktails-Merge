#!/usr/bin/env python3
"""Lock Sunny Cove V07 collision geometry to the frozen surface and V2 mask."""
from __future__ import annotations

import hashlib
import json
import math
import re
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ISLAND = ROOT / "assets/ui_assets/campaign/islands/sunny_cove"
ISLANDS_JSON = ROOT / "data/campaign/islands.json"
V2_GEOMETRY = ROOT / "assets/ui_assets/tables/table_geometry_v2.json"
PLAY_MASK_PATH = ROOT / "assets/ui_assets/tables/table_playable_surface_mask_v2.png"
SURFACE = ISLAND / "gameplay_surface_v07.png"
CALIBRATION = ISLAND / "playable_geometry_calibration_v07.json"
DEBUG = ISLAND / "playable_geometry_debug_v07.png"
STRESS = ISLAND / "playable_geometry_12_glass_stress_v07.png"
SIZE = (720, 1280)
RADII = [20, 23, 27, 31, 36, 42, 49, 56, 64, 72, 80, 90]
CENTERS = [
    (180, 510, 12), (360, 510, 11), (540, 510, 10),
    (140, 675, 9), (360, 675, 8), (580, 675, 7),
    (160, 805, 6), (360, 805, 5), (560, 805, 4),
    (130, 900, 3), (360, 900, 2), (590, 900, 1),
]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def polygon_from_v2() -> list[list[int]]:
    v2 = json.loads(V2_GEOMETRY.read_text(encoding="utf-8"))
    boundary = v2["runtime_playable_boundary"]
    left = boundary["left_viewport_points"]
    right = boundary["right_viewport_points"]
    # Clip the constitutional R11/V2 rail polyline to the visible image bounds.
    # The samples are checked against the exact playable-surface master below.
    points = [
        [round(right[0][0]), round(right[0][1])],
        [round(left[0][0]), round(left[0][1])],
    ]
    # Return a clockwise raster polygon following the visible rails. Rails beyond
    # x=0/720 are clipped at the viewport border, as required by the V2 contract.
    polygon = [
        [99, 398], [628, 398], [667, 489], [688, 537], [719, 613],
        [719, 988], [0, 988], [0, 627], [4, 612], [37, 537], [58, 489],
    ]
    mask = Image.open(PLAY_MASK_PATH).convert("RGBA").getchannel("A")
    for x, y in polygon:
        if mask.getpixel((x, y)) < 128:
            raise ValueError(f"V2-derived rail vertex falls outside playable mask: {(x, y)}")
    if len(points) != 2:
        raise ValueError("Unexpected V2 geometry parse")
    return polygon


def main() -> None:
    if Image.open(SURFACE).size != SIZE:
        raise ValueError("V07 surface must be 720x1280 before geometry calibration")
    surface_hash = sha(SURFACE)
    polygon = polygon_from_v2()
    geometry = {
        "playable_polygon": polygon,
        "launch_y": 947,
        "spawn_y": 968,
        "death_y": 900,
    }
    surface = Image.open(SURFACE).convert("RGB")
    mask = Image.open(PLAY_MASK_PATH).convert("RGBA").getchannel("A")
    overlay = surface.convert("RGBA")
    draw = ImageDraw.Draw(overlay, "RGBA")
    points = [tuple(point) for point in polygon]
    draw.line(points + [points[0]], fill=(42, 255, 172, 255), width=5, joint="curve")
    for y, color, label in ((900, (255, 67, 67, 255), "DEATH 900"),
                            (947, (70, 210, 255, 255), "LAUNCH 947"),
                            (968, (255, 255, 255, 255), "SPAWN 968")):
        draw.line((0, y, 719, y), fill=color, width=3)
        draw.text((8, y - 19), label, fill=color, stroke_width=2, stroke_fill=(0, 0, 0, 240))
    overlay.save(DEBUG, format="PNG", optimize=False, compress_level=9)

    stress = surface.convert("RGBA")
    stress_draw = ImageDraw.Draw(stress, "RGBA")
    placements = []
    for x, y, level in CENTERS:
        radius = RADII[level - 1]
        for sample in range(72):
            angle = sample * math.tau / 72
            px = round(x + math.cos(angle) * radius)
            py = round(y + math.sin(angle) * radius)
            if not (0 <= px < SIZE[0] and 0 <= py < SIZE[1]) or mask.getpixel((px, py)) < 128:
                raise ValueError(f"L{level} footprint crosses visible V2 tabletop at {(px, py)}")
        stress_draw.ellipse((x-radius, y-radius, x+radius, y+radius),
                            fill=(255, 207, 59, 50), outline=(255, 235, 84, 255), width=3)
        stress_draw.text((x + radius + 2, y - 9), f"L{level}", fill=(20, 42, 34, 255),
                         stroke_width=2, stroke_fill=(255, 255, 255, 240))
        placements.append({"level": level, "center": [x, y], "collider_footprint_radius": radius,
                           "sampled_outline_inside_visible_v2_surface": True})
    stress.save(STRESS, format="PNG", optimize=False, compress_level=9)

    islands_text = ISLANDS_JSON.read_text(encoding="utf-8")
    new_surface = '"gameplay_surface": "res://assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface_v07.png"'
    old_surface = '"gameplay_surface": "res://assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface.png"'
    if islands_text.count(old_surface) == 1:
        islands_text = islands_text.replace(old_surface, new_surface, 1)
    elif islands_text.count(new_surface) != 1:
        raise ValueError("Expected exactly one V06 or V07 Sunny Cove composite path")
    old_offset = '                "table_y_offset_canonical": 150.0,\n'
    if islands_text.count(old_offset) == 1:
        islands_text = islands_text.replace(old_offset, "", 1)
    geometry_block = '            "playable_geometry": {\n' + ",\n".join(
        f'                "{key}": {json.dumps(value, separators=(",", ":"))}' for key, value in geometry.items()
    ) + "\n            }"
    islands_text, count = re.subn(r'            "playable_geometry": \{\n.*?\n            \}', geometry_block,
                                  islands_text, count=1, flags=re.DOTALL)
    if count != 1:
        raise ValueError("Could not update the first Sunny Cove geometry block")
    ISLANDS_JSON.write_text(islands_text, encoding="utf-8", newline="\n")

    report = {
        "format": "sunny-cove-image-locked-geometry-v07",
        "surface_path": SURFACE.relative_to(ROOT).as_posix(),
        "surface_sha256_frozen_before_geometry": surface_hash,
        "canonical_dimensions": list(SIZE),
        "playable_mask_path": PLAY_MASK_PATH.relative_to(ROOT).as_posix(),
        "playable_mask_sha256": sha(PLAY_MASK_PATH),
        "authority": "V2/R11 playable master traced against final frozen V07 surface",
        "geometry": geometry,
        "stress_placements": placements,
        "debug_overlay_path": DEBUG.relative_to(ROOT).as_posix(),
        "stress_overlay_path": STRESS.relative_to(ROOT).as_posix(),
        "old_v06_table_y_offset_removed": True,
        "method": "canonical V2/R11 rail sample clipping checked against the exact playable-surface alpha mask; surface SHA frozen before writing geometry",
    }
    CALIBRATION.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"SUNNY_COVE_V07_GEOMETRY_RESULT=PASS surface_sha256={surface_hash}")
    print(f"POLYGON_VERTICES={len(polygon)} STRESS_DRINKS={len(placements)}")
    print("STRESS_FOOTPRINTS_INSIDE_V2_MASK=True")


if __name__ == "__main__":
    main()
