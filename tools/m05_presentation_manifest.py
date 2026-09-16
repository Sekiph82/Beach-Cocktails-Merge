"""Build the retained M05 presentation manifest from manual glass-body measurements."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs/evidence/m05/presentation_manifest.json"
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
RADII = [20.0, 23.0, 27.0, 31.0, 36.0, 42.0, 49.0, 56.0, 64.0, 72.0, 80.0, 90.0]
MASSES = [1.0 + 0.3 * level for level in range(12)]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_bbox(path: Path) -> list[int] | None:
    with Image.open(path) as image:
        bbox = image.convert("RGBA").getchannel("A").getbbox()
        return list(bbox) if bbox else None


def main() -> int:
    levels = []
    for level in range(1, 13):
        path = ROOT / f"assets/cocktails/L{level:02d}.png"
        with Image.open(path) as image:
            width, height = image.size
        x0, y0, x1, y1 = BODY_BOXES[level]
        body_width = x1 - x0
        body_height = y1 - y0
        body_center = [(x0 + x1) / 2.0 - width / 2.0, (y0 + y1) / 2.0 - height / 2.0]
        scale = 2.0 * RADII[level - 1] / body_width
        levels.append({
            "level": level,
            "texture_path": f"res://assets/cocktails/L{level:02d}.png",
            "source_sha256": sha256(path),
            "source_dimensions": [width, height],
            "source_alpha_bbox": alpha_bbox(path),
            "visible_body_bbox_px": [x0, y0, x1, y1],
            "visible_body_width_px": body_width,
            "visible_body_height_px": body_height,
            "visible_body_center_offset_px": body_center,
            "measurement_method": "MANUAL_VISUAL_MEASUREMENT_GLASS_BODY",
            "measurement_scope": "glass/container body only; straw, fruit, leaves, flowers and garnish extremes excluded",
            "runtime_visual_scale": scale,
            "runtime_visual_offset_px": [-body_center[0] * scale, -body_center[1] * scale],
            "runtime_collider_radius": RADII[level - 1],
            "runtime_mass": MASSES[level - 1],
        })
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps({
        "schema": "BCM-M05-R01 presentation evidence V01",
        "provenance": "Manual visual body-region measurements recorded from the canonical PNGs; not inferred from M04 whole-image alpha bounds.",
        "runtime_api": {
            "texture": "Drink.texture_for_level(level)",
            "scale": "Drink.visual_scale_for_level(level)",
            "offset": "Drink.visual_offset_for_level(level)",
            "collider": "Drink.collider_radius_for_level(level)",
        },
        "levels": levels,
        "visual_evidence": [
            "all_levels_collider_overlay.png",
            "all_levels_clean.png",
            "touching_pairs.png",
            "merge_continuity.png",
        ],
    }, indent=2) + "\n", encoding="utf-8")
    print(f"M05_MANIFEST levels={len(levels)} output={OUTPUT.relative_to(ROOT).as_posix()}")
    print("M05_MANIFEST_METHOD=MANUAL_VISUAL_MEASUREMENT_GLASS_BODY")
    print("M05_MANIFEST_RADII=" + ",".join(str(value) for value in RADII))
    print("M05_MANIFEST_RESULT=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

