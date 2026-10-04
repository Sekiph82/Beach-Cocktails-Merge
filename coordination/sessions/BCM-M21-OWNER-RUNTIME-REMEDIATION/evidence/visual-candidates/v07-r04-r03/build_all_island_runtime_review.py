from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageFilter


ROOT = Path(__file__).resolve().parents[6]
EVIDENCE = Path(__file__).resolve().parent
SIZE = (720, 1280)
ISLANDS = [
    ("sunny_cove", "Sunny Cove"),
    ("tiki_island", "Tiki Island"),
    ("azure_bay", "Azure Bay"),
    ("coconut_beach", "Coconut Beach"),
    ("sunset_island", "Sunset Island"),
    ("party_beach", "Party Beach"),
    ("frozen_paradise", "Frozen Paradise"),
    ("volcano_bay", "Volcano Bay"),
    ("billionaire_island", "Billionaire Island"),
    ("final_island", "Final Island"),
]
GEOMETRY = [
    (192, 392), (528, 392), (541, 413), (554, 445), (573, 490), (592, 545),
    (612, 610), (632, 680), (653, 755), (674, 832), (694, 914), (706, 960),
    (706, 978), (14, 978), (14, 960), (26, 914), (46, 832), (67, 755),
    (88, 680), (108, 610), (128, 545), (147, 490), (166, 445), (179, 413),
]
BODY_WIDTHS = [690, 725, 627, 759, 545, 700, 575, 615, 650, 625, 610, 710]
RADII = [20, 23, 27, 31, 36, 42, 49, 56, 64, 72, 80, 90]
PROGRESSION_CENTERS_X = [232.5, 389, 544.5, 699.5, 854.5, 1009.5, 1163.5, 1318.5, 1473.5, 1628.5, 1784, 1941]
FONT_PATH = r"C:\Windows\Fonts\arialbd.ttf"


def image(path: str) -> Image.Image:
    return Image.open(ROOT / path).convert("RGBA")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fitted_asset(canvas: Image.Image, path: str, rect: tuple[float, float, float, float]) -> None:
    art = image(path)
    x, y, width, height = rect
    scale = min(width / art.width, height / art.height)
    art = art.resize((round(art.width * scale), round(art.height * scale)), Image.Resampling.LANCZOS)
    canvas.alpha_composite(art, (round(x + (width - art.width) / 2), round(y + (height - art.height) / 2)))


def drink_sprite(level: int, max_dimension: int) -> Image.Image:
    art = image(f"assets/cocktails/L{level:02}.png")
    bounds = art.getchannel("A").getbbox()
    if bounds:
        art = art.crop(bounds)
    art.thumbnail((max_dimension, max_dimension), Image.Resampling.LANCZOS)
    return art


def draw_drink(canvas: Image.Image, level: int, center: tuple[int, int], height: int) -> None:
    art = drink_sprite(level, height)
    x, y = center
    foot_y = y + art.height // 2
    shadow = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(shadow)
    half_width = max(15, round(art.width * 0.34))
    draw.ellipse((x - half_width, foot_y - 3, x + half_width, foot_y + 9), fill=(48, 25, 12, 110))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(2.5)))
    canvas.alpha_composite(art, (round(x - art.width / 2), round(y - art.height / 2)))


def center_text(draw: ImageDraw.ImageDraw, point: tuple[int, int], text: str, size: int, color: tuple[int, int, int, int]) -> None:
    draw.text(point, text, font=ImageFont.truetype(FONT_PATH, size), fill=color, anchor="mm", stroke_width=2, stroke_fill=(50, 24, 9, 190))


def rail_bounds(y: float) -> tuple[float, float]:
    left = right = 0.0
    found: list[float] = []
    for index, (ax, ay) in enumerate(GEOMETRY):
        bx, by = GEOMETRY[(index + 1) % len(GEOMETRY)]
        if ay == by:
            if y == ay:
                found.extend((ax, bx))
        elif min(ay, by) <= y <= max(ay, by):
            found.append(ax + (bx - ax) * ((y - ay) / (by - ay)))
    if len(found) < 2:
        raise ValueError(f"No polygon span at y={y}")
    return min(found), max(found)


def render(island_id: str) -> Image.Image:
    canvas = image(f"assets/ui_assets/campaign/islands/{island_id}/gameplay_surface_v07_r04.png")

    # Current approved HUD assets and positions, matching GameManager's 720x1280 layout.
    fitted_asset(canvas, "assets/ui/panel_best_score.png", (14, 190, 190, 190 * 941 / 1671))
    fitted_asset(canvas, "assets/ui/panel_score.png", (518, 190, 190, 190 * 941 / 1671))
    fitted_asset(canvas, "assets/ui_assets/brand/logo_beach_cocktails_merge.png", (42, 0, 136, 188))
    fitted_asset(canvas, "assets/ui/panel_to_go_vip_orders.png", (275, 0, 170, 170 * 1698 / 1132))
    fitted_asset(canvas, "assets/ui/panel_next.png", (543, 0, 140, 140 * 1426 / 1103))

    ui = ImageDraw.Draw(canvas, "RGBA")
    center_text(ui, (109, 252), "321", 20, (255, 240, 198, 255))
    center_text(ui, (613, 252), "0", 20, (255, 240, 198, 255))
    center_text(ui, (393, 89), "0/1", 15, (72, 39, 20, 255))
    center_text(ui, (393, 124), "0", 15, (72, 39, 20, 255))
    center_text(ui, (393, 177), "0/0", 15, (72, 39, 20, 255))
    center_text(ui, (393, 212), "0", 15, (72, 39, 20, 255))
    normal = drink_sprite(1, 34)
    canvas.alpha_composite(normal, (round(328 - normal.width / 2), round(87 - normal.height / 2)))
    vip = drink_sprite(3, 34)
    canvas.alpha_composite(vip, (round(328 - vip.width / 2), round(175 - vip.height / 2)))
    next_drink = drink_sprite(1, 48)
    canvas.alpha_composite(next_drink, (round(613 - next_drink.width / 2), 75))

    # Representative settled pieces, with contact shadows at their bases.
    crowd = [
        (174, 512, 2, 57), (291, 504, 4, 56), (410, 526, 3, 61), (532, 554, 7, 68),
        (117, 616, 1, 68), (242, 620, 5, 72), (365, 620, 8, 75), (492, 651, 3, 78),
        (171, 723, 6, 84), (304, 717, 4, 85), (437, 726, 9, 82), (548, 713, 2, 80),
    ]
    for x, y, level, height in crowd:
        draw_drink(canvas, level, (x, y), height)

    # Danger line is the approved horizontal PNG fitted to the measured usable rail span.
    left, right = rail_bounds(846)
    danger_width = right - left - 48
    fitted_asset(canvas, "assets/ui/danger_line.png", ((left + right - danger_width) / 2, 846 - danger_width * 724 / 2172 / 2, danger_width, danger_width * 724 / 2172))

    # Held L01, its soft contact shadow, and the approved gold launch halo.
    launch = image("assets/ui/launch_zone.png")
    scale = 76 / launch.width
    launch = launch.resize((76, 76), Image.Resampling.LANCZOS)
    canvas.alpha_composite(launch, (322, 969 - 38))
    draw_drink(canvas, 1, (360, 912), 104)

    # Exact owner-supplied 12-slot progression art; cocktails are runtime overlays.
    strip = image("assets/ui/progression_strip.png").resize((720, 240), Image.Resampling.LANCZOS)
    strip_top = 1012
    canvas.alpha_composite(strip, (0, strip_top))
    for level, source_x in enumerate(PROGRESSION_CENTERS_X, 1):
        art = drink_sprite(level, 44)
        center_x = round(source_x * 720 / 2172)
        canvas.alpha_composite(art, (round(center_x - art.width / 2), round(strip_top + 340 * 240 / 724 - art.height / 2)))

    # Pause remains a working control position at the bottom-left.
    ui = ImageDraw.Draw(canvas, "RGBA")
    ui.rounded_rectangle((14, 1208, 126, 1266), radius=13, fill=(16, 61, 82, 248), outline=(247, 212, 123, 255), width=2)
    center_text(ui, (70, 1237), "PAUSE", 15, (255, 240, 198, 255))
    return canvas.convert("RGB")


def main() -> None:
    previews = []
    manifest = {
        "task": "BCM-M21-001 + BCM-M21-006 V07-R04-R03",
        "resolution_px": list(SIZE),
        "review_type": "asset-composited review matching the production layout; not a Godot engine capture",
        "islands": [],
        "approved_ui_assets": {},
    }
    for asset in [
        "assets/ui_assets/brand/logo_beach_cocktails_merge.png",
        "assets/ui/panel_best_score.png",
        "assets/ui/panel_score.png",
        "assets/ui/panel_to_go_vip_orders.png",
        "assets/ui/panel_next.png",
        "assets/ui/progression_strip.png",
        "assets/ui/launch_zone.png",
        "assets/ui/danger_line.png",
    ]:
        manifest["approved_ui_assets"][asset] = hashlib.sha256((ROOT / asset).read_bytes()).hexdigest()
    for island_id, label in ISLANDS:
        output = EVIDENCE / f"{island_id}_runtime_review_v07_r04_r03.png"
        preview = render(island_id)
        preview.save(output, format="PNG", optimize=True)
        manifest["islands"].append({"id": island_id, "name": label, "file": output.name, "sha256": digest(output), "dimensions_px": list(preview.size)})
        previews.append((label, preview))

    contact = Image.new("RGB", (950, 700), (22, 30, 38))
    draw = ImageDraw.Draw(contact)
    label_font = ImageFont.truetype(FONT_PATH, 13)
    for index, (label, preview) in enumerate(previews):
        x = index % 5 * 190 + 5
        y = index // 5 * 350 + 4
        contact.paste(preview.resize((180, 320), Image.Resampling.LANCZOS), (x, y + 22))
        draw.text((x, y + 3), label, fill=(250, 245, 230), font=label_font)
    contact_path = EVIDENCE / "all_islands_runtime_contact_v07_r04_r03.png"
    contact.save(contact_path, format="PNG", optimize=True)
    manifest["contact_sheet"] = {"file": contact_path.name, "sha256": digest(contact_path), "dimensions_px": list(contact.size)}
    manifest["shared_gameplay_geometry_px"] = GEOMETRY
    manifest["gameplay_markers"] = {"death_line_y": 846, "held_spawn_y": 963, "progression_image_top": 1012, "progression_cell_center_y": 1125}
    manifest["geometry_fit"] = "shared playable polygon follows the visible inner tabletop rails in all ten same-format island surfaces; rear footprint inset is 12 px and side footprint clearance remains zero"
    (EVIDENCE / "runtime_review_manifest_v07_r04_r03.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Rendered {len(previews)} 720x1280 island reviews; contact={contact_path}")


if __name__ == "__main__":
    main()
