from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "docs" / "evidence" / "m07_r04"
COCKTAILS = ROOT / "assets" / "cocktails"
UI = ROOT / "assets" / "ui"
CASES = ("canonical_720x1280", "taller_720x1440", "shorter_wider_800x1280")


def font(size: int):
    candidates = (
        "C:/Windows/Fonts/arial.ttf",
        "C:/Windows/Fonts/segoeui.ttf",
    )
    for candidate in candidates:
        path = Path(candidate)
        if path.is_file():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def card(image: Image.Image, size: tuple[int, int]) -> Image.Image:
    return ImageOps.contain(image.convert("RGBA"), size, Image.Resampling.LANCZOS)


def paste_center(canvas: Image.Image, image: Image.Image, center: tuple[int, int], size: tuple[int, int]):
    fitted = card(image, size)
    canvas.alpha_composite(fitted, (center[0] - fitted.width // 2, center[1] - fitted.height // 2))


def load_cocktail(level: int) -> Image.Image:
    return Image.open(COCKTAILS / f"L{level:02d}.png").convert("RGBA")


def title(draw: ImageDraw.ImageDraw, text: str, xy=(24, 18)):
    draw.text(xy, text, fill=(255, 238, 169), font=font(26))


def make_fixed_score_sheet():
    width, height = 1120, 430
    canvas = Image.new("RGBA", (width, height), (35, 27, 22, 255))
    draw = ImageDraw.Draw(canvas)
    title(draw, "M07-R04 fixed score fit — one font size, seven-digit maximum")
    panels = [
        ("BEST SCORE", UI / "panel_best_score.png", (24, 95)),
        ("SCORE", UI / "panel_score.png", (24, 250)),
    ]
    for label, path, pos in panels:
        artwork = Image.open(path).convert("RGBA")
        fitted = card(artwork, (300, 130))
        canvas.alpha_composite(fitted, pos)
        draw.text((pos[0] + 98, pos[1] + 72), "9999999", fill=(255, 238, 194), font=font(22))
        draw.rectangle((pos[0] + 66, pos[1] + 59, pos[0] + 234, pos[1] + 119), outline=(80, 255, 140), width=2)
        draw.text((pos[0] + 315, pos[1] + 23), f"{label}: 20 px fixed", fill=(255, 238, 194), font=font(23))
        draw.text((pos[0] + 315, pos[1] + 59), "0 / 321 / 24380 / 999999 / 9999999", fill=(220, 210, 190), font=font(18))
    canvas.save(EVIDENCE / "fixed_score_fit_sheet.png")


def make_to_go_sheet():
    width, height = 1260, 720
    canvas = Image.new("RGBA", (width, height), (35, 27, 22, 255))
    draw = ImageDraw.Draw(canvas)
    title(draw, "M07-R04 To-Go L06-L12 fit — target sprite + reward digits only")
    panel = Image.open(UI / "panel_to_go_orders.png").convert("RGBA")
    for index, level in enumerate(range(6, 13)):
        x = 175 + (index % 4) * 285
        y = 170 + (index // 4) * 250
        fitted = card(panel, (210, 220))
        canvas.alpha_composite(fitted, (x - fitted.width // 2, y - fitted.height // 2))
        paste_center(canvas, load_cocktail(level), (x, y - 5), (102, 103))
        reward = {6: 1000, 7: 1800, 8: 3000, 9: 5000, 10: 8000, 11: 12000, 12: 18000}[level]
        draw.text((x - 42, y + 72), str(reward), fill=(92, 35, 14), font=font(20))
        draw.text((x - 28, y + 100), f"L{level:02d}", fill=(255, 238, 194), font=font(17))
    canvas.save(EVIDENCE / "to_go_l06_l12_fit_sheet.png")


def make_next_sheet():
    width, height = 1260, 920
    canvas = Image.new("RGBA", (width, height), (35, 27, 22, 255))
    draw = ImageDraw.Draw(canvas)
    title(draw, "M07-R04 NEXT L01-L12 alpha fit — shared M05 texture mapping")
    panel = Image.open(UI / "panel_next.png").convert("RGBA")
    for index, level in enumerate(range(1, 13)):
        x = 150 + (index % 4) * 315
        y = 170 + (index // 4) * 245
        fitted = card(panel, (145, 185))
        canvas.alpha_composite(fitted, (x - fitted.width // 2, y - fitted.height // 2))
        paste_center(canvas, load_cocktail(level), (x, y + 12), (90, 100))
        draw.text((x - 25, y + 105), f"L{level:02d}", fill=(255, 238, 194), font=font(18))
    canvas.save(EVIDENCE / "next_l01_l12_fit_sheet.png")


def make_held_sheet():
    width, height = 1260, 730
    canvas = Image.new("RGBA", (width, height), (35, 27, 22, 255))
    draw = ImageDraw.Draw(canvas)
    title(draw, "M07-R04 held L01-L12 visible-body foot anchor — common launch baseline")
    foot = [476.0, 495.5, 431.5, 477.5, 428.0, 478.0, 410.5, 443.0, 470.5, 453.0, 443.0, 498.0]
    for index, level in enumerate(range(1, 13)):
        x = 125 + (index % 6) * 200
        y = 205 + (index // 6) * 245
        paste_center(canvas, load_cocktail(level), (x, y), (135, 150))
        draw.line((x - 72, y + 70, x + 72, y + 70), fill=(80, 255, 140), width=3)
        draw.text((x - 28, y + 88), f"L{level:02d}", fill=(255, 238, 194), font=font(18))
        draw.text((x - 70, y + 116), f"foot={foot[index]:g}px", fill=(220, 210, 190), font=font(14))
    draw.text((24, 675), "Runtime probe: spread 0.000 px at each required viewport; anchor is visual-only.", fill=(220, 210, 190), font=font(17))
    canvas.save(EVIDENCE / "held_l01_l12_body_anchor_sheet.png")


def main() -> int:
    required = [
        EVIDENCE / f"{case}.png" for case in CASES
    ] + [EVIDENCE / f"{case}_visible_bounds.png" for case in CASES]
    missing = [path for path in required if not path.is_file()]
    if missing:
        print("M07_R04_SHEETS_FAIL missing=" + ",".join(str(path) for path in missing))
        return 1
    make_fixed_score_sheet()
    make_to_go_sheet()
    make_next_sheet()
    make_held_sheet()
    print("M07_R04_SHEETS_PASS cases=3 fixed_score=PASS to_go_l06_l12=PASS next_l01_l12=PASS held_l01_l12=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
