#!/usr/bin/env python3
"""Deterministically bake Sunny Cove's accepted static gameplay art and evidence."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
ISLANDS_JSON = ROOT / "data/campaign/islands.json"
ISLAND_DIR = ROOT / "assets/ui_assets/campaign/islands/sunny_cove"
OUT = ISLAND_DIR / "gameplay_surface.png"
PROVENANCE = ISLAND_DIR / "gameplay_surface.provenance.json"
CALIBRATION = ISLAND_DIR / "playable_geometry_calibration.json"
DEBUG = ISLAND_DIR / "playable_geometry_debug.png"
SIZE = (720, 1280)
TABLE_TRANSLATION = (0, 150)
LAYER_ORDER = [
    "gameplay_background",
    "gameplay_table_shadow",
    "gameplay_table",
    "table_edge_overlay",
]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def res_path(path: str) -> Path:
    if not path.startswith("res://"):
        raise ValueError(f"Expected res:// path: {path}")
    return ROOT / path[6:]


def read_geometry() -> dict:
    root = json.loads(ISLANDS_JSON.read_text(encoding="utf-8"))
    island = next(i for i in root["islands"] if i["id"] == "sunny_cove")
    return island["playable_geometry"]


def compose() -> tuple[Image.Image, list[dict]]:
    root = json.loads(ISLANDS_JSON.read_text(encoding="utf-8"))
    island = next(i for i in root["islands"] if i["id"] == "sunny_cove")
    theme = island["theme"]
    sources = []
    canvas = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    for key in LAYER_ORDER:
        path = res_path(theme[key])
        im = Image.open(path).convert("RGBA")
        transform = {"operation": "identity"}
        if key == "gameplay_background":
            if im.size != SIZE:
                raise ValueError(f"Background must be {SIZE}, got {im.size}")
        else:
            if im.size != SIZE:
                raise ValueError(f"Static layer must be {SIZE}, got {im.size}: {path}")
            transform = {"operation": "translate_pixels", "x": 0, "y": TABLE_TRANSLATION[1], "clip": "720x1280 canvas"}
            translated = Image.new("RGBA", SIZE, (0, 0, 0, 0))
            translated.alpha_composite(im, TABLE_TRANSLATION)
            im = translated
        canvas.alpha_composite(im)
        sources.append({
            "theme_key": key,
            "path": path.relative_to(ROOT).as_posix(),
            "sha256": sha(path),
            "source_dimensions": list(Image.open(path).size),
            "transform": transform,
        })
    return canvas.convert("RGB"), sources


def generate() -> None:
    image, sources = compose()
    image.save(OUT, format="PNG", optimize=False, compress_level=9)
    geometry = read_geometry()
    polygon = [tuple(map(int, point)) for point in geometry["playable_polygon"]]
    overlay = image.convert("RGBA")
    draw = ImageDraw.Draw(overlay, "RGBA")
    draw.line(polygon + [polygon[0]], fill=(30, 255, 140, 255), width=5, joint="curve")
    # Coordinates of twelve approved Sunny Cove cocktail sprites at gameplay scale.
    stress = [(x, y, level) for y, levels in ((690, range(1, 7)), (850, range(7, 13))) for x, level in zip((130, 222, 314, 406, 498, 590), levels)]
    radii = [20, 23, 27, 31, 36, 42, 49, 56, 64, 72, 80, 90]
    for x, y, level in stress:
        radius = radii[level - 1]
        draw.ellipse((x-radius, y-radius, x+radius, y+radius), fill=(255, 211, 46, 55), outline=(255, 232, 65, 245), width=3)
        draw.text((x+radius+2, y-8), f"L{level}", fill=(20, 35, 18, 255), stroke_width=2, stroke_fill=(255, 255, 255, 230))
    for y, color, label in [
        (int(geometry["launch_y"]), (80, 220, 255, 255), "LAUNCH"),
        (int(geometry["spawn_y"]), (255, 255, 255, 255), "SPAWN"),
        (int(geometry["death_y"]), (255, 65, 65, 255), "DEATH"),
    ]:
        draw.line((0, y, SIZE[0]-1, y), fill=color, width=3)
        draw.text((8, y-20), label, fill=color, stroke_width=2, stroke_fill=(0, 0, 0, 240))
    overlay.save(DEBUG, format="PNG", optimize=False, compress_level=9)

    result_hash = sha(OUT)
    provenance = {
        "format": "sunny-cove-gameplay-surface-provenance-v1",
        "canonical_dimensions": list(SIZE),
        "output_path": OUT.relative_to(ROOT).as_posix(),
        "output_sha256": result_hash,
        "builder_path": Path(__file__).relative_to(ROOT).as_posix(),
        "composition": {
            "layer_order_back_to_front": LAYER_ORDER,
            "background_fit": "exact 720x1280 identity placement",
            "table_layer_fit": "exact 720x1280 identity placement, translated by (0,150) canonical pixels and clipped to canvas",
            "blend": "Pillow RGBA alpha_composite in listed order; final RGB PNG",
            "sources": sources,
        },
    }
    PROVENANCE.write_text(json.dumps(provenance, indent=2) + "\n", encoding="utf-8")
    calibration = {
        "format": "sunny-cove-playable-geometry-calibration-v1",
        "composite_path": OUT.relative_to(ROOT).as_posix(),
        "composite_sha256": result_hash,
        "canonical_dimensions": list(SIZE),
        **geometry,
        "stress_placements": [{"level": level, "center": [x, y], "collider_footprint_radius": radii[level-1]} for x, y, level in stress],
        "debug_overlay_path": DEBUG.relative_to(ROOT).as_posix(),
        "method": "manual pixel tracing on the committed composite; coordinates are canonical image pixels",
    }
    CALIBRATION.write_text(json.dumps(calibration, indent=2) + "\n", encoding="utf-8")
    print(f"SUNNY_COVE_COMPOSITE_RESULT=PASS size={SIZE[0]}x{SIZE[1]} sha256={result_hash}")
    print(f"PROVENANCE={PROVENANCE.relative_to(ROOT).as_posix()}")
    print(f"GEOMETRY_DEBUG={DEBUG.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    generate()
