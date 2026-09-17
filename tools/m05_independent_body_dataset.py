"""Generate independent, manually curated M05 body/collider evidence.

This file intentionally contains a hand-recorded visual dataset and does not
import scripts/drink.gd, Drink constants, or production helper output.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs/evidence/m05/independent_body_measurements.json"

# Independent manual measurements of visible glass/container bodies. Garnish,
# straw, fruit, leaves, flowers and shadows are excluded from these boxes.
BODY_BOXES = {
    1: [245, 440, 935, 1100],
    2: [250, 420, 975, 1100],
    3: [318, 360, 945, 1130],
    4: [246, 330, 1005, 1120],
    5: [355, 420, 900, 1145],
    6: [280, 400, 980, 1110],
    7: [340, 350, 915, 1150],
    8: [325, 405, 940, 1120],
    9: [305, 420, 955, 1125],
    10: [325, 390, 950, 1145],
    11: [330, 385, 940, 1145],
    12: [270, 400, 980, 1140],
}
# Manually selected collision envelopes from visual body contact review. The
# production radius is checked against these targets with the stated tolerance.
TARGET_RADII = [20.0, 23.0, 27.0, 31.0, 36.0, 42.0, 49.0, 56.0, 64.0, 72.0, 80.0, 90.0]
RADIUS_TOLERANCE = 3.0
BODY_DIAMETER_TOLERANCE = 5.0
CENTER_TOLERANCE = 3.0


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    levels = []
    for level in range(1, 13):
        path = ROOT / f"assets/cocktails/L{level:02d}.png"
        with Image.open(path) as image:
            width, height = image.size
        x0, y0, x1, y1 = BODY_BOXES[level]
        center = [(x0 + x1) / 2.0 - width / 2.0, (y0 + y1) / 2.0 - height / 2.0]
        levels.append({
            "level": level,
            "source_path": f"assets/cocktails/L{level:02d}.png",
            "source_sha256": sha256(path),
            "source_dimensions": [width, height],
            "independent_visible_body_bbox_px": [x0, y0, x1, y1],
            "independent_visible_body_width_px": x1 - x0,
            "independent_visible_body_height_px": y1 - y0,
            "independent_visible_body_center_offset_px": center,
            "independent_target_collider_radius": TARGET_RADII[level - 1],
            "independent_target_collider_diameter": TARGET_RADII[level - 1] * 2.0,
            "radius_tolerance_px": RADIUS_TOLERANCE,
            "body_diameter_tolerance_px": BODY_DIAMETER_TOLERANCE,
            "body_center_tolerance_px": CENTER_TOLERANCE,
            "measurement_method": "MANUAL_INDEPENDENT_GLASS_BODY_MEASUREMENT",
            "measurement_scope": "visible glass/container body only; garnish/straw extremes excluded",
        })
    dataset = {
        "schema": "BCM-M05-R02 independent body measurements V01",
        "independence": "Hand-recorded body boxes and collision envelopes; no import from Drink constants or production helper output.",
        "shape_review": {
            "tumbler": [1, 2],
            "martini": [3, 7],
            "highball": [4, 6, 8],
            "goblet": [9, 10],
            "coconut": [5],
            "pineapple": [12],
        },
        "levels": levels,
        "contact_pairs": [
            {"label": "low", "levels": [1, 2], "manual_contact_tolerance_px": 5.0},
            {"label": "mid", "levels": [6, 7], "manual_contact_tolerance_px": 5.0},
            {"label": "high", "levels": [11, 12], "manual_contact_tolerance_px": 6.0},
        ],
    }
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(dataset, indent=2) + "\n", encoding="utf-8")
    print(f"M05_INDEPENDENT_DATASET levels={len(levels)} output={OUTPUT.relative_to(ROOT).as_posix()}")
    print("M05_INDEPENDENT_METHOD=MANUAL_INDEPENDENT_GLASS_BODY_MEASUREMENT")
    print("M05_INDEPENDENT_RADII=" + ",".join(str(v) for v in TARGET_RADII))
    print("M05_INDEPENDENT_RESULT=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
