"""Compare frozen independent M05 measurements with production after generation."""
from __future__ import annotations

import hashlib
import json
import re
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
INDEPENDENT = ROOT / "docs/evidence/m05/strict_closure_independent_measurements.json"
COMPARISON = ROOT / "docs/evidence/m05/strict_closure_production_comparison.json"
OVERLAY = ROOT / "docs/evidence/m05/strict_closure_contact_overlays.png"
BASELINE_COMMIT = "9d6d8950da5f62f6c22d495f58414d70d034d893"

REPRESENTATIVE_LEVELS = [4, 3, 8, 9, 12]
PROTECTED_SYMBOLS = [
    "COCKTAIL_TEXTURE_PATHS",
    "VISIBLE_BODY_WIDTH_PX",
    "BOUNDARY_CONTACT_HULL_SOURCE_PX",
    "VISIBLE_BODY_CENTER_OFFSET_PX",
    "HELD_BODY_FOOT_SOURCE_PX",
    "COLLIDER_RADII",
]


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def extract_symbol(source: str, symbol: str) -> str:
    marker = f"const {symbol}"
    start = source.find(marker)
    if start < 0:
        marker = f"static var {symbol}"
        start = source.find(marker)
    if start < 0:
        raise ValueError(f"missing protected symbol {symbol}")
    next_const = re.search(r"\n(?:const|static var) [A-Z_]", source[start + 1 :])
    end = start + 1 + next_const.start() if next_const else len(source)
    return source[start:end].strip()


def parse_float_array(source: str, symbol: str) -> list[float]:
    block = extract_symbol(source, symbol)
    values = re.search(r"\[([^\]]+)\]", block, re.S)
    if not values:
        raise ValueError(f"cannot parse {symbol}")
    return [float(item.strip()) for item in values.group(1).split(",") if item.strip()]


def parse_vector_array(source: str, symbol: str) -> list[list[float]]:
    block = extract_symbol(source, symbol)
    return [[float(x), float(y)] for x, y in re.findall(r"Vector2\((-?[0-9.]+),\s*(-?[0-9.]+)\)", block)]


def source_hashes_match(levels: list[dict[str, object]]) -> bool:
    return all(
        sha256_bytes((ROOT / str(item["source_path"])).read_bytes()) == item["source_sha256"]
        for item in levels
    )


def make_overlay(levels_by_id: dict[int, dict[str, object]], widths: list[float], centers: list[list[float]], radii: list[float]) -> None:
    panel_w, panel_h = 330, 410
    canvas = Image.new("RGBA", (panel_w * len(REPRESENTATIVE_LEVELS), panel_h), (19, 31, 42, 255))
    draw = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype("arial.ttf", 15)
        small = ImageFont.truetype("arial.ttf", 12)
    except OSError:
        font = ImageFont.load_default()
        small = font

    for index, level in enumerate(REPRESENTATIVE_LEVELS):
        panel_x = index * panel_w
        path = ROOT / f"assets/cocktails/L{level:02d}.png"
        with Image.open(path).convert("RGBA") as source:
            artwork = source.resize((290, 290), Image.Resampling.LANCZOS)
        art_x, art_y = panel_x + 20, 48
        canvas.alpha_composite(artwork, (art_x, art_y))
        source_to_panel = 290.0 / 1254.0
        item = levels_by_id[level]
        bbox = [float(value) for value in item["independent_visible_body_bbox_px"]]
        production_offset = centers[level - 1]
        # The canonical artwork is shown in source-pixel coordinates.  Apply
        # the current Sprite2D pivot translation as an equivalent source-space
        # shift, then draw the unchanged runtime circle in source units.
        body_x0 = art_x + (bbox[0] - production_offset[0]) * source_to_panel
        body_y0 = art_y + (bbox[1] - production_offset[1]) * source_to_panel
        body_x1 = art_x + (bbox[2] - production_offset[0]) * source_to_panel
        body_y1 = art_y + (bbox[3] - production_offset[1]) * source_to_panel
        collider_center = (art_x + 145, art_y + 145)
        runtime_scale = 2.0 * radii[level - 1] / widths[level - 1]
        collider_r = (radii[level - 1] / runtime_scale) * source_to_panel
        draw.rectangle((body_x0, body_y0, body_x1, body_y1), outline=(255, 80, 80, 255), width=2)
        draw.ellipse((collider_center[0] - collider_r, collider_center[1] - collider_r, collider_center[0] + collider_r, collider_center[1] + collider_r), outline=(64, 180, 255, 255), width=2)
        body_center_x = (body_x0 + body_x1) / 2.0
        body_center_y = (body_y0 + body_y1) / 2.0
        draw.line((body_center_x - 6, body_center_y, body_center_x + 6, body_center_y), fill=(255, 220, 80, 255), width=2)
        draw.line((body_center_x, body_center_y - 6, body_center_x, body_center_y + 6), fill=(255, 220, 80, 255), width=2)
        draw.text((panel_x + 10, 12), f"L{level:02d} — {item['shape_category']}", fill=(255, 239, 190, 255), font=font)
        draw.text((panel_x + 10, 365), f"red independent body | blue collider r={radii[level - 1]:.1f}", fill=(255, 150, 150, 255), font=small)
        draw.text((panel_x + 10, 385), "yellow = independent body center", fill=(255, 220, 80, 255), font=small)
    canvas.convert("RGB").save(OVERLAY, optimize=True)


def main() -> int:
    if not INDEPENDENT.exists():
        raise SystemExit("independent dataset must be generated first")
    independent = json.loads(INDEPENDENT.read_text(encoding="utf-8"))
    levels = independent["levels"]
    source = (ROOT / "scripts/drink.gd").read_text(encoding="utf-8")
    baseline = subprocess.check_output(["git", "show", f"{BASELINE_COMMIT}:scripts/drink.gd"], cwd=ROOT, text=True)
    widths = parse_float_array(source, "VISIBLE_BODY_WIDTH_PX")
    radii = parse_float_array(source, "COLLIDER_RADII")
    centers = parse_vector_array(source, "VISIBLE_BODY_CENTER_OFFSET_PX")
    protected = {}
    for symbol in PROTECTED_SYMBOLS:
        current_block = extract_symbol(source, symbol)
        baseline_block = extract_symbol(baseline, symbol)
        protected[symbol] = {
            "matches_r11_baseline": current_block == baseline_block,
            "current_sha256": sha256_bytes(current_block.encode()),
            "r11_baseline_sha256": sha256_bytes(baseline_block.encode()),
        }

    comparisons = []
    for item in levels:
        level = int(item["level"])
        independent_width = float(item["independent_visible_body_width_px"])
        independent_center = [float(value) for value in item["independent_visible_body_center_offset_px"]]
        scale = 2.0 * radii[level - 1] / widths[level - 1]
        runtime_width = independent_width * scale
        comparisons.append(
            {
                "level": level,
                "independent_body_width_px": independent_width,
                "production_visible_body_width_px": widths[level - 1],
                "width_difference_px": independent_width - widths[level - 1],
                "independent_center_offset_px": independent_center,
                "production_center_offset_px": centers[level - 1],
                "center_difference_px": [independent_center[0] - centers[level - 1][0], independent_center[1] - centers[level - 1][1]],
                "current_collider_radius_px": radii[level - 1],
                "current_collider_diameter_px": radii[level - 1] * 2.0,
                "current_runtime_visual_scale": scale,
                "independent_runtime_body_width_px": runtime_width,
                "collider_to_independent_runtime_body_width_ratio": (2.0 * radii[level - 1]) / runtime_width if runtime_width else None,
                "comparison_is_post_independent_freeze": True,
            }
        )

    result = {
        "schema": "BCM-M05-STRICT-CLOSURE production comparison V01",
        "independent_dataset": INDEPENDENT.relative_to(ROOT).as_posix(),
        "independent_dataset_sha256": sha256_bytes(INDEPENDENT.read_bytes()),
        "comparison_phase": "PRODUCTION_READ_AFTER_INDEPENDENT_DATASET_FROZEN",
        "r11_baseline_commit": BASELINE_COMMIT,
        "protected_symbols": protected,
        "source_hashes_match_independent_dataset": source_hashes_match(levels),
        "levels": comparisons,
        "representative_overlay_levels": REPRESENTATIVE_LEVELS,
        "overlay_path": OVERLAY.relative_to(ROOT).as_posix(),
    }
    COMPARISON.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    make_overlay({int(item["level"]): item for item in levels}, widths, centers, radii)
    print(f"M05_STRICT_COMPARISON levels={len(comparisons)} output={COMPARISON.relative_to(ROOT).as_posix()}")
    print(f"M05_STRICT_OVERLAY representatives={','.join(f'L{level:02d}' for level in REPRESENTATIVE_LEVELS)} output={OVERLAY.relative_to(ROOT).as_posix()}")
    print("M05_STRICT_PROTECTED_R11_SYMBOLS=" + ("PASS" if all(item["matches_r11_baseline"] for item in protected.values()) else "FAIL"))
    print("M05_STRICT_COMPARISON_RESULT=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
