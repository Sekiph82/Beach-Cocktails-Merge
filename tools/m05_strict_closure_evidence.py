"""Generate independent M05 strict-closure measurements from canonical pixels.

This phase intentionally runs before any production comparison.  It reads only
the canonical cocktail PNGs and the independent visual-review windows below;
it does not import, parse, or reference production constants or helpers.
"""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs/evidence/m05/strict_closure_independent_measurements.json"

# Independently selected review windows in canonical texture pixels.  These are
# visual-review regions for the glass/container only, selected from the PNGs
# before production comparison.  They are not copied from production boxes or
# production hulls.  The pixel scan below derives the final body bounds from
# alpha pixels inside each review window.
INDEPENDENT_BODY_WINDOWS = {
    1: [260, 300, 950, 1135],
    2: [300, 380, 955, 1138],
    3: [315, 275, 905, 1215],
    4: [270, 390, 1000, 1235],
    5: [370, 465, 925, 1202],
    6: [300, 380, 935, 1210],
    7: [420, 315, 850, 1168],
    8: [375, 420, 925, 1205],
    9: [275, 430, 1005, 1130],
    10: [370, 435, 965, 1205],
    11: [390, 420, 975, 1165],
    12: [245, 430, 975, 1165],
}

SHAPE_REVIEW = {
    1: {
        "category": "tumbler / rocks glass",
        "rationale": "Short straight-sided vessel with a broad cylindrical rim and thick bottom; the lemon and straw are outside the container body.",
    },
    2: {
        "category": "tumbler / rocks glass",
        "rationale": "Short straight-sided red vessel with a broad rim and thick base; the cherry/straw decoration is excluded.",
    },
    3: {
        "category": "highball / tall glass",
        "rationale": "Tall rectangular cylindrical glass with long parallel sides and a narrow base; mint and lime garnish are excluded.",
    },
    4: {
        "category": "martini / coupe",
        "rationale": "Conical bowl on a narrow stem and foot; flowers and fruit around the rim are not part of the container body.",
    },
    5: {
        "category": "goblet / rounded tropical glass",
        "rationale": "Rounded bowl tapering into a short stem and foot; pineapple, citrus, flower and straw decorations are excluded.",
    },
    6: {
        "category": "martini / coupe",
        "rationale": "Wide conical bowl, narrow stem and foot; the cherry, flower and straw are decorative extremes.",
    },
    7: {
        "category": "highball / tall glass",
        "rationale": "Very tall straight-sided cylindrical glass with a thick lower base; orange slice, leaves and straw are excluded.",
    },
    8: {
        "category": "goblet / rounded glass",
        "rationale": "Rounded blue bowl narrowing into a stem and foot; flower, leaves, citrus and straw are excluded.",
    },
    9: {
        "category": "coconut / special container",
        "rationale": "Rounded coconut shell container with a broad curved body and flat lower contact region; leaves, flower and straw are excluded.",
    },
    10: {
        "category": "goblet / rounded glass",
        "rationale": "Rounded pink bowl with a narrow stem and wide foot; hibiscus, fruit and straw are excluded.",
    },
    11: {
        "category": "highball / tall glass",
        "rationale": "Tall straight-sided red highball with a thick transparent base; cherry, citrus and straw are excluded.",
    },
    12: {
        "category": "pineapple / special container",
        "rationale": "Pineapple-shaped vessel with a broad textured body and tapered top; leaves and straw are excluded.",
    },
}


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def alpha_body_bbox(image: Image.Image, window: list[int]) -> tuple[list[int], int]:
    rgba = image.convert("RGBA")
    alpha = rgba.getchannel("A")
    x0, y0, x1, y1 = window
    pixels = alpha.load()
    points: list[tuple[int, int]] = []
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if pixels[x, y] >= 32:
                points.append((x, y))
    if not points:
        raise ValueError(f"no visible alpha pixels inside independent window {window}")
    min_x = min(point[0] for point in points)
    min_y = min(point[1] for point in points)
    max_x = max(point[0] for point in points)
    max_y = max(point[1] for point in points)
    return [min_x, min_y, max_x, max_y], len(points)


def main() -> int:
    levels: list[dict[str, object]] = []
    for level in range(1, 13):
        path = ROOT / f"assets/cocktails/L{level:02d}.png"
        with Image.open(path) as image:
            width, height = image.size
            bbox, visible_pixels = alpha_body_bbox(image, INDEPENDENT_BODY_WINDOWS[level])
        min_x, min_y, max_x, max_y = bbox
        body_width = max_x - min_x + 1
        body_height = max_y - min_y + 1
        texture_center = [(width - 1) / 2.0, (height - 1) / 2.0]
        body_center = [(min_x + max_x) / 2.0, (min_y + max_y) / 2.0]
        center_offset = [body_center[0] - texture_center[0], body_center[1] - texture_center[1]]
        levels.append(
            {
                "level": level,
                "source_path": f"assets/cocktails/L{level:02d}.png",
                "source_sha256": sha256(path),
                "source_dimensions": [width, height],
                "independent_review_window_px": INDEPENDENT_BODY_WINDOWS[level],
                "independent_visible_body_bbox_px": bbox,
                "independent_visible_body_width_px": body_width,
                "independent_visible_body_height_px": body_height,
                "independent_visible_body_center_offset_px": center_offset,
                "independent_visible_alpha_pixels": visible_pixels,
                "alpha_threshold": 32,
                "transparent_garnish_exclusion": "The review window excludes visible garnish/straw regions; final bounds are the alpha-positive pixels within that independently selected body window.",
                "ambiguity_notes": "Semi-transparent glass highlights and rim pixels are retained when alpha >= 32; decorative pixels outside the review window are excluded.",
                "shape_category": SHAPE_REVIEW[level]["category"],
                "shape_rationale": SHAPE_REVIEW[level]["rationale"],
            }
        )

    dataset = {
        "schema": "BCM-M05-STRICT-CLOSURE independent body measurements V01",
        "measurement_phase": "INDEPENDENT_PIXEL_MEASUREMENT_BEFORE_PRODUCTION_COMPARISON",
        "independence": {
            "source": "canonical PNG pixels only",
            "production_constants_read_before_output": False,
            "production_helpers_imported": False,
            "production_files_read": [],
            "method": "independent visual-review window followed by deterministic alpha-pixel bounding-box extraction",
            "alpha_threshold": 32,
            "coordinate_convention": "inclusive source-pixel bounds; center offsets are relative to ((width-1)/2, (height-1)/2)",
        },
        "shape_review": SHAPE_REVIEW,
        "levels": levels,
    }
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(dataset, indent=2) + "\n", encoding="utf-8")
    print(f"M05_STRICT_INDEPENDENT levels={len(levels)} output={OUTPUT.relative_to(ROOT).as_posix()}")
    print("M05_STRICT_INDEPENDENT production_constants_read_before_output=false")
    print("M05_STRICT_INDEPENDENT_RESULT=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
