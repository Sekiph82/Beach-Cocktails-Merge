from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[6]
EVIDENCE = Path(__file__).resolve().parent
SOURCE = EVIDENCE / "sunny_cove_master_surface_source_v07_r04_r02.png"
SURFACE = EVIDENCE / "sunny_cove_master_surface_v07_r04_r02_720x1280.png"
REVIEW = EVIDENCE / "sunny_cove_master_review_v07_r04_r02_720x1280.png"
MEASUREMENTS = EVIDENCE / "sunny_cove_master_measurements_v07_r04_r02.json"
SIZE = (720, 1280)


def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(r"C:\Windows\Fonts\arialbd.ttf", size)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fitted_drink(level: int, max_size: tuple[int, int]) -> Image.Image:
    path = ROOT / "assets/cocktails" / f"L{level:02}.png"
    image = Image.open(path).convert("RGBA")
    bounds = image.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError(f"Cocktail has no visible pixels: {path}")
    image = image.crop(bounds)
    image.thumbnail(max_size, Image.Resampling.LANCZOS)
    return image


def overlay_art(canvas: Image.Image, asset: Path, box: tuple[int, int, int, int]) -> None:
    image = Image.open(asset).convert("RGBA")
    bounds = image.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError(f"HUD asset has no visible pixels: {asset}")
    image = image.crop(bounds).resize((box[2], box[3]), Image.Resampling.LANCZOS)
    canvas.alpha_composite(image, (box[0], box[1]))


def overlay_drink(canvas: Image.Image, level: int, center: tuple[int, int], height: int) -> tuple[int, int, int, int]:
    drink = fitted_drink(level, (height, height))
    x = round(center[0] - drink.width / 2)
    y = round(center[1] - drink.height / 2)
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.ellipse((center[0] - height * 0.27, y + drink.height - 2, center[0] + height * 0.27, y + drink.height + 9), fill=(66, 35, 16, 78))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(drink, (x, y))
    return (x, y, drink.width, drink.height)


def main() -> None:
    source = Image.open(SOURCE).convert("RGB")
    surface = ImageOps.fit(source, SIZE, method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
    surface.save(SURFACE, format="PNG", optimize=True)

    review = surface.convert("RGBA")
    # Use the five real current-design assets and their current R03 visible
    # bounds; the rejected R03 board/scenery is not used as source artwork.
    overlay_art(review, ROOT / "assets/ui/logo_beach_cocktails_merge.png", (137, 6, 135, 90))
    overlay_art(review, ROOT / "assets/ui/panel_to_go_orders.png", (277, 0, 170, 210))
    overlay_art(review, ROOT / "assets/ui/panel_best_score.png", (14, 166, 190, 107))
    overlay_art(review, ROOT / "assets/ui/panel_score.png", (518, 198, 190, 107))
    overlay_art(review, ROOT / "assets/ui/panel_next.png", (564, 6, 140, 181))

    ui_draw = ImageDraw.Draw(review, "RGBA")
    ui_draw.rounded_rectangle((20, 18, 136, 76), radius=14, fill=(16, 61, 82, 255), outline=(247, 212, 123, 255), width=2)
    ui_draw.text((78, 47), "PAUSE", font=font(16), fill=(255, 240, 198, 255), anchor="mm")
    ui_draw.text((109, 250), "321", font=font(18), fill=(255, 240, 198, 255), anchor="mm", stroke_width=2, stroke_fill=(46, 22, 8, 210))
    ui_draw.text((613, 282), "0", font=font(18), fill=(255, 240, 198, 255), anchor="mm", stroke_width=2, stroke_fill=(46, 22, 8, 210))
    ui_draw.text((400, 84), "0/1", font=font(16), fill=(77, 43, 23, 255), anchor="mm")
    ui_draw.text((403, 119), "0", font=font(16), fill=(77, 43, 23, 255), anchor="mm")
    to_go_icon = fitted_drink(1, (32, 36))
    review.alpha_composite(to_go_icon, (326 - to_go_icon.width // 2, 80 - to_go_icon.height // 2))
    next_icon = fitted_drink(1, (42, 48))
    review.alpha_composite(next_icon, (634 - next_icon.width // 2, 130 - next_icon.height // 2))

    # A crowded but legible representative board state; all drinks are current
    # canonical L01-L12 assets, placed only in this review composite.
    crowd = [
        (188, 548, 2, 60), (302, 526, 4, 58), (426, 554, 3, 66),
        (535, 594, 7, 72), (126, 646, 1, 76), (245, 662, 5, 78),
        (365, 642, 8, 82), (492, 678, 3, 86), (174, 742, 6, 92),
        (306, 736, 4, 94), (442, 748, 9, 90), (548, 730, 2, 88),
    ]
    crowd_boxes = []
    for x, y, level, size in crowd:
        crowd_boxes.append({"level": f"L{level:02}", "bbox_px": overlay_drink(review, level, (x, y), size)})

    # One thin, clearly horizontal deadline. No directional or aiming marks.
    draw = ImageDraw.Draw(review, "RGBA")
    draw.line((42, 854, 678, 854), fill=(62, 34, 19, 235), width=4)

    # Held cocktail is forward of the deadline with only a small oval marker.
    draw.ellipse((332, 982, 388, 992), fill=(75, 41, 18, 55), outline=(245, 196, 95, 135), width=2)
    held_bbox = overlay_drink(review, 1, (360, 938), 112)

    # One horizontal 12-cell progression assembly attached directly below the
    # table's player-facing edge. This UI is not baked into the clean surface.
    panel_box = (8, 1018, 712, 1186)
    panel_shadow = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    panel_draw = ImageDraw.Draw(panel_shadow)
    panel_draw.rounded_rectangle((6, 1022, 714, 1192), radius=22, fill=(45, 25, 12, 95))
    review.alpha_composite(panel_shadow)
    draw = ImageDraw.Draw(review, "RGBA")
    draw.rounded_rectangle(panel_box, radius=20, fill=(112, 58, 23, 255), outline=(255, 197, 97, 255), width=4)
    draw.rounded_rectangle((14, 1024, 706, 1180), radius=15, fill=(183, 105, 42, 255), outline=(88, 43, 19, 255), width=3)
    draw.rounded_rectangle((19, 1029, 701, 1175), radius=12, fill=(226, 164, 91, 255), outline=(255, 214, 139, 230), width=2)

    cell_left = 22
    cell_top = 1038
    cell_width = 56
    cell_gap = 0
    cell_height = 128
    progression_boxes = []
    label_font = font(12)
    for level in range(1, 13):
        x = cell_left + (level - 1) * (cell_width + cell_gap)
        draw.rounded_rectangle((x, cell_top, x + cell_width - 2, cell_top + cell_height), radius=8, fill=(255, 239, 205, 255), outline=(126, 66, 26, 255), width=2)
        drink = fitted_drink(level, (48, 78))
        px = x + (cell_width - drink.width) // 2 - 1
        py = cell_top + 9 + (78 - drink.height) // 2
        review.alpha_composite(drink, (px, py))
        label = f"L{level:02}"
        label_box = draw.textbbox((0, 0), label, font=label_font, stroke_width=0)
        label_x = x + (cell_width - (label_box[2] - label_box[0])) // 2 - 1
        draw.text((label_x, cell_top + 96), label, font=label_font, fill=(71, 38, 18, 255), stroke_width=0)
        progression_boxes.append({"level": label, "bbox_px": [x, cell_top, cell_width - 2, cell_height]})

    review = review.convert("RGB")
    review.save(REVIEW, format="PNG", optimize=True)

    data = {
        "task": "BCM-M21-001 + BCM-M21-006",
        "version": "V07-R04-R02",
        "resolution_px": [720, 1280],
        "clean_surface_file": SURFACE.name,
        "review_composite_file": REVIEW.name,
        "source_art_file": SOURCE.name,
        "sha256": {"clean_surface": digest(SURFACE), "review_composite": digest(REVIEW)},
        "measurements": {
            "rear_table_edge_y_px_approx": 405,
            "rear_table_edge_width_px_approx": 424,
            "player_facing_table_edge_y_px_approx": 1009,
            "player_facing_table_edge_width_px_approx": 720,
            "visible_tabletop_depth_px_approx": 604,
            "deadline_bbox_px": [42, 852, 636, 4],
            "held_cocktail_center_px": [360, 938],
            "held_cocktail_bbox_px": list(held_bbox),
            "progression_strip_bbox_px": [panel_box[0], panel_box[1], panel_box[2] - panel_box[0], panel_box[3] - panel_box[1]],
            "progression_cells": progression_boxes,
            "frozen_current_hud_bboxes_px": {
                "logo": [137, 6, 135, 90],
                "to_go_orders": [277, 0, 170, 210],
                "best_score": [14, 166, 190, 107],
                "score": [518, 198, 190, 107],
                "next": [564, 6, 140, 181],
                "pause_preserved_from_review_composite": [20, 18, 116, 58],
            },
            "representative_crowded_tabletop_drinks": crowd_boxes,
            "table_leg_boxes": [],
            "bottom_fascia_bbox_px": None,
            "notes": [
                "Approximate visual measurements from the clean 720x1280 art; not production collision geometry.",
                "Deadline and held cocktail are review-only overlays; the held drink sits player-forward of the deadline.",
                "Progression cells and representative tabletop cocktails use current canonical assets and are not baked into the clean surface.",
                "Frozen HUD elements use the current project's real logo/panel assets and the V07-R03 measured placement boxes, not the master reference.",
                "No vertical guide, arrow path, target ray, launch zone, or visible table legs are present.",
            ],
        },
        "scope": {
            "production_geometry_changed": False,
            "production_surface_binding_changed": False,
            "gameplay_or_campaign_logic_changed": False,
            "owner_visual_acceptance": "pending",
        },
    }
    MEASUREMENTS.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"surface={SURFACE} size={Image.open(SURFACE).size} sha256={digest(SURFACE)}")
    print(f"review={REVIEW} size={Image.open(REVIEW).size} sha256={digest(REVIEW)}")
    print(f"measurements={MEASUREMENTS}")


if __name__ == "__main__":
    main()
