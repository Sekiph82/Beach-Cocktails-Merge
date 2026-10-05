"""Create the 2-star Island Map node from canonical local campaign art."""

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
FAMILY = ROOT / "assets/ui_assets/campaign/island_map"
BASE = FAMILY / "level_node_unlocked.png"
STAR = FAMILY / "star_small_filled.png"
OUTPUT = FAMILY / "level_node_two_star.png"


def main() -> None:
    node = Image.open(BASE).convert("RGBA")
    star = Image.open(STAR).convert("RGBA").resize((42, 42), Image.Resampling.LANCZOS)

    # Replace the single center jewel with a glass inset holding two stars.
    draw = ImageDraw.Draw(node)
    draw.ellipse((117, 46, 203, 132), fill=(8, 139, 174, 255), outline=(255, 210, 100, 255), width=5)
    draw.ellipse((123, 52, 197, 126), fill=(16, 186, 203, 255), outline=(255, 245, 207, 255), width=2)
    node.alpha_composite(star, (132, 68))
    node.alpha_composite(star, (166, 68))
    node.save(OUTPUT, format="PNG", optimize=True)


if __name__ == "__main__":
    main()
