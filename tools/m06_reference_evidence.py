"""Create non-destructive M06 reference landmark evidence."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/evidence/m06"
MASTER = ROOT / "b75ee426-9568-4ed6-b35e-140600a7c995.png"
BACKGROUND = ROOT / "assets/environment/game_board_background.png"
POINTS = {
    "far_left": (292, 464),
    "far_right": (732, 464),
    "near_left": (104, 1208),
    "near_right": (920, 1208),
    "danger_y": 1100,
    "launch_y": 1144,
}


def font():
    try:
        return ImageFont.truetype("arial.ttf", 28)
    except OSError:
        return ImageFont.load_default()


def annotate(source: Path, destination: Path, title: str) -> None:
    image = Image.open(source).convert("RGBA")
    draw = ImageDraw.Draw(image)
    color = (255, 225, 70, 255)
    red = (255, 92, 92, 255)
    cyan = (86, 231, 255, 255)
    draw.text((24, 24), title, fill=(255, 246, 210, 255), font=font())
    draw.line([POINTS["far_left"], POINTS["near_left"]], fill=color, width=6)
    draw.line([POINTS["far_right"], POINTS["near_right"]], fill=color, width=6)
    draw.line([POINTS["far_left"], POINTS["far_right"]], fill=cyan, width=5)
    draw.line([(80, POINTS["danger_y"]), (944, POINTS["danger_y"])], fill=red, width=5)
    draw.line([(512, POINTS["launch_y"] - 20), (512, POINTS["launch_y"] + 20)], fill=cyan, width=5)
    for name in ("far_left", "far_right", "near_left", "near_right"):
        x, y = POINTS[name]
        draw.ellipse((x - 9, y - 9, x + 9, y + 9), fill=color)
        draw.text((x + 12, y - 32), name, fill=color, font=font())
    draw.text((90, POINTS["danger_y"] - 38), "danger reference Y=1100", fill=red, font=font())
    draw.text((530, POINTS["launch_y"] - 58), "launch reference Y=1144", fill=cyan, font=font())
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination)


def main() -> int:
    annotate(MASTER, OUT / "master_table_landmarks.png", "Owner master — M06 table landmarks")
    annotate(BACKGROUND, OUT / "background_table_landmarks.png", "Canonical background — M06 table landmarks")
    print("M06_REFERENCE_EVIDENCE generated=2")
    print("M06_REFERENCE_SOURCE_MASTER=b75ee426-9568-4ed6-b35e-140600a7c995.png")
    print("M06_REFERENCE_SOURCE_BACKGROUND=assets/environment/game_board_background.png")
    print("M06_REFERENCE_RESULT=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
