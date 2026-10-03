"""Derive the V07-R02 Sunny Cove profile from its frozen, visible table art.

Inputs are limited to the final static surface. The traced vertices below were
measured against that image after its SHA-256 was recorded.
"""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SURFACE = ROOT / "assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface_v07_r02.png"
PROFILE = ROOT / "assets/ui_assets/campaign/islands/sunny_cove/playable_geometry_calibration_v07_r02.json"
DEBUG = ROOT / "assets/ui_assets/campaign/islands/sunny_cove/playable_geometry_debug_v07_r02.png"
STRESS = ROOT / "assets/ui_assets/campaign/islands/sunny_cove/playable_geometry_12_glass_stress_v07_r02.png"

# Inset trace of the visible wood boundary in the frozen 720x1280 surface.
# Clockwise from the rear-left tabletop edge; points follow the visible inner rim.
PLAYABLE_POLYGON = [
    [130, 390], [590, 390], [617, 404], [640, 451], [658, 512],
    [673, 590], [687, 680], [699, 775], [684, 802], [36, 802],
    [21, 775], [33, 680], [47, 590], [62, 512], [80, 451], [103, 404],
]

# Representative visible footprints for a geometric illustration only.
STRESS_CENTERS = [
    [205, 455], [360, 455], [515, 455],
    [160, 555], [300, 555], [440, 555], [580, 555],
    [135, 655], [285, 655], [435, 655], [585, 655],
    [360, 750],
]
STRESS_RADIUS = 27


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    image = Image.open(SURFACE).convert("RGB")
    if image.size != (720, 1280):
        raise ValueError(f"Expected frozen 720x1280 surface, got {image.size}")

    frozen_art_hash = sha256(SURFACE)
    geometry_created_utc = datetime.now(timezone.utc).isoformat(timespec="seconds")
    profile = {
        "schema_version": 1,
        "profile_id": "sunny_cove_v07_r02_art_first",
        "viewport": [720, 1280],
        "playable_polygon": PLAYABLE_POLYGON,
        "launch_y": 770,
        "spawn_y": 790,
        "death_y": 850,
        "derivation": {
            "method": "Manual pixel trace inset along the visible tabletop inner rim.",
            "surface_path": "assets/ui_assets/campaign/islands/sunny_cove/gameplay_surface_v07_r02.png",
            "surface_sha256": frozen_art_hash,
            "surface_frozen_before_geometry": True,
            "geometry_created_utc": geometry_created_utc,
            "shape_control_inputs": [
                "frozen gameplay_surface_v07_r02.png",
                "PLAYABLE_POLYGON pixel trace in this calibration source",
            ],
            "legacy_geometry_or_mask_inputs_used": [],
        },
    }
    PROFILE.write_text(json.dumps(profile, indent=2) + "\n", encoding="utf-8")

    debug = image.convert("RGBA")
    draw = ImageDraw.Draw(debug, "RGBA")
    closed = PLAYABLE_POLYGON + [PLAYABLE_POLYGON[0]]
    draw.line(closed, fill=(255, 32, 48, 240), width=4, joint="curve")
    for index, point in enumerate(PLAYABLE_POLYGON):
        x, y = point
        draw.ellipse((x - 5, y - 5, x + 5, y + 5), fill=(255, 236, 64, 255))
        draw.text((x + 7, y - 12), str(index + 1), fill=(30, 20, 10, 255))
    DEBUG.parent.mkdir(parents=True, exist_ok=True)
    debug.save(DEBUG, optimize=True)

    stress = image.convert("RGBA")
    draw = ImageDraw.Draw(stress, "RGBA")
    draw.line(closed, fill=(255, 32, 48, 230), width=3, joint="curve")
    for index, (x, y) in enumerate(STRESS_CENTERS, start=1):
        r = STRESS_RADIUS
        draw.ellipse((x-r, y-r, x+r, y+r), fill=(30, 190, 255, 80), outline=(5, 45, 75, 255), width=3)
        draw.text((x-4, y-7), str(index), fill=(0, 0, 0, 255))
    stress.save(STRESS, optimize=True)

    profile["derivation"]["debug_overlay_sha256"] = sha256(DEBUG)
    profile["derivation"]["illustrative_stress_overlay_sha256"] = sha256(STRESS)
    PROFILE.write_text(json.dumps(profile, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({
        "surface_sha256": frozen_art_hash,
        "profile_sha256": sha256(PROFILE),
        "debug_sha256": sha256(DEBUG),
        "stress_sha256": sha256(STRESS),
        "geometry_created_utc": geometry_created_utc,
    }, indent=2))


if __name__ == "__main__":
    main()
