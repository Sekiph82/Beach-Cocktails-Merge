"""Build editable V04 store-icon candidates from owned project artwork.

Run from the repository root with Pillow installed:
    python tools/release/build_store_icon_v04.py

The inputs remain the project's source art; the output is a new, review-pending
composition and a 512px Play derivative. No low-resolution icon is upscaled.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "docs/release/store_media/icons_v04"
RUNTIME_OUTPUT = ROOT / "assets/ui_assets/brand/beach_cocktails_merge_icon_v04.png"
BACKGROUND = ROOT / "assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v02.png"
BRAND = ROOT / "assets/ui_assets/brand/logo_concept_v03.png"
DRINK = ROOT / "assets/cocktails/L01.png"
SIZE = 1024


def crop_to_square(source: Image.Image) -> Image.Image:
    width, height = source.size
    side = min(width, height)
    left = (width - side) // 2
    top = (height - side) // 2
    return source.crop((left, top, left + side, top + side))


def fit_inside(source: Image.Image, width: int, height: int) -> Image.Image:
    source = source.convert("RGBA")
    source.thumbnail((width, height), Image.Resampling.LANCZOS)
    return source


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)

    background = crop_to_square(Image.open(BACKGROUND).convert("RGB"))
    canvas = background.resize((SIZE, SIZE), Image.Resampling.LANCZOS).convert("RGBA")

    # Keep the real ocean art visible around the framed logo while separating
    # foreground art from the water with a softly feathered navy tint.
    tint = Image.new("RGBA", canvas.size, (4, 40, 61, 54))
    canvas = Image.alpha_composite(canvas, tint)

    frame = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(frame)
    draw.rounded_rectangle((26, 26, SIZE - 27, SIZE - 27), radius=168,
                           fill=(7, 48, 66, 98), outline=(255, 206, 111, 255), width=12)
    draw.rounded_rectangle((43, 43, SIZE - 44, SIZE - 44), radius=151,
                           outline=(113, 224, 209, 230), width=5)
    # Small vector bubbles and glints are part of the new composition, not game UI.
    for x, y, radius, color in [
        (111, 223, 15, (255, 240, 198, 220)),
        (910, 249, 11, (115, 224, 209, 230)),
        (132, 847, 9, (115, 224, 209, 230)),
        (885, 877, 14, (255, 206, 111, 230)),
    ]:
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color)
    canvas = Image.alpha_composite(canvas, frame)

    brand = fit_inside(Image.open(BRAND), 820, 548)
    brand_x = (SIZE - brand.width) // 2
    brand_y = 92
    brand_shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow = Image.new("RGBA", brand.size, (0, 0, 0, 130))
    shadow.putalpha(brand.getchannel("A").point(lambda value: value * 0.60))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    brand_shadow.alpha_composite(shadow, (brand_x + 5, brand_y + 15))
    canvas = Image.alpha_composite(canvas, brand_shadow)
    canvas.alpha_composite(brand, (brand_x, brand_y))

    # The high-resolution L01 cocktail sprite supplies a separate, recognizable
    # game element below the wordmark. It stays within the rounded icon safe area.
    drink = fit_inside(Image.open(DRINK), 290, 302)
    drink_x = (SIZE - drink.width) // 2
    drink_y = 652
    drink_badge = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    badge_draw = ImageDraw.Draw(drink_badge)
    badge_draw.ellipse((316, 632, 708, 989), fill=(6, 48, 64, 190),
                       outline=(255, 206, 111, 245), width=8)
    badge_draw.ellipse((330, 646, 694, 975), outline=(115, 224, 209, 180), width=4)
    canvas = Image.alpha_composite(canvas, drink_badge)
    drink_shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    shadow = Image.new("RGBA", drink.size, (0, 0, 0, 150))
    shadow.putalpha(drink.getchannel("A").point(lambda value: value * 0.62))
    shadow = shadow.filter(ImageFilter.GaussianBlur(10))
    drink_shadow.alpha_composite(shadow, (drink_x + 3, drink_y + 10))
    canvas = Image.alpha_composite(canvas, drink_shadow)
    canvas.alpha_composite(drink, (drink_x, drink_y))

    master_path = OUTPUT / "beach_cocktails_merge_icon_master_v04.png"
    play_path = OUTPUT / "google_play_icon_candidate_512_v04.png"
    RUNTIME_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(master_path, format="PNG", optimize=True)
    canvas.save(RUNTIME_OUTPUT, format="PNG", optimize=True)
    canvas.resize((512, 512), Image.Resampling.LANCZOS).save(play_path, format="PNG", optimize=True)
    print(f"ICON_CANDIDATE_CREATED {master_path.relative_to(ROOT).as_posix()} {canvas.size}")
    print(f"ICON_CANDIDATE_CREATED {RUNTIME_OUTPUT.relative_to(ROOT).as_posix()} {canvas.size}")
    print(f"ICON_CANDIDATE_CREATED {play_path.relative_to(ROOT).as_posix()} 512x512")


if __name__ == "__main__":
    main()
