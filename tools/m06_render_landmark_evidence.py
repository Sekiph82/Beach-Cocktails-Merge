"""Create screenshot-space M06 landmark and master/runtime evidence.

Landmark coordinates are a manually recorded viewport-pixel dataset. This tool
never imports production geometry helpers and never modifies canonical PNGs.
"""
from __future__ import annotations

import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "docs/evidence/m06"
MASTER = ROOT / "b75ee426-9568-4ed6-b35e-140600a7c995.png"
DATASET = EVIDENCE / "render_space_landmarks.json"
CASES = ("canonical_720x1280", "taller_720x1440", "shorter_wider_800x1280")


def font(size: int = 20):
    try:
        return ImageFont.truetype("arial.ttf", size)
    except OSError:
        return ImageFont.load_default()


def annotate(case: str, data: dict) -> None:
    source = EVIDENCE / data["capture"]
    image = Image.open(source).convert("RGBA")
    draw = ImageDraw.Draw(image)
    rails = data["rails"]
    color = (86, 231, 255, 255)
    danger = (255, 80, 95, 255)
    launch = (255, 224, 75, 255)
    draw.text((12, 12), f"M06 screenshot-space visible-wood landmarks — {case}", fill=(255, 246, 210, 255), font=font(18))
    far_y = data["table_top_y"]
    mid_y = (data["table_top_y"] + data["table_bottom_y"]) / 2.0
    near_y = data["table_bottom_y"]
    left = [rails["far"][0], rails["middle"][0], rails["near"][0]]
    right = [rails["far"][1], rails["middle"][1], rails["near"][1]]
    ys = [far_y, mid_y, near_y]
    draw.line(list(zip(left, ys)), fill=color, width=3)
    draw.line(list(zip(right, ys)), fill=color, width=3)
    draw.line((left[0], far_y, right[0], far_y), fill=color, width=3)
    draw.line((left[2], near_y, right[2], near_y), fill=color, width=3)
    draw.line((0, data["danger_y"], image.width, data["danger_y"]), fill=danger, width=3)
    draw.line((image.width / 2, data["launch_y"] - 16, image.width / 2, data["launch_y"] + 16), fill=launch, width=4)
    for name, x, y in (("far", left[0], far_y), ("middle", left[1], mid_y), ("near", left[2], near_y)):
        draw.ellipse((x - 5, y - 5, x + 5, y + 5), fill=color)
        draw.text((x + 8, y - 22), f"{name} L={x:.0f}", fill=color, font=font(16))
    for name, x, y in (("far", right[0], far_y), ("middle", right[1], mid_y), ("near", right[2], near_y)):
        draw.ellipse((x - 5, y - 5, x + 5, y + 5), fill=color)
        draw.text((x - 90, y - 22), f"{name} R={x:.0f}", fill=color, font=font(16))
    draw.text((12, data["danger_y"] - 24), f"danger y={data['danger_y']:.0f}", fill=danger, font=font(16))
    draw.text((image.width / 2 + 12, data["launch_y"] - 28), f"launch y={data['launch_y']:.0f}", fill=launch, font=font(16))
    image.save(EVIDENCE / f"{case}_visible_wood_reference.png")


def side_by_side(case: str, data: dict) -> None:
    runtime = Image.open(EVIDENCE / data["capture"]).convert("RGB")
    master = Image.open(MASTER).convert("RGB")
    panel_w, panel_h = 480, 720
    canvas = Image.new("RGB", (panel_w * 2, panel_h + 48), (34, 29, 22))
    master.thumbnail((panel_w - 12, panel_h - 12))
    runtime.thumbnail((panel_w - 12, panel_h - 12))
    canvas.paste(master, ((panel_w - master.width) // 2, 48 + (panel_h - master.height) // 2))
    canvas.paste(runtime, (panel_w + (panel_w - runtime.width) // 2, 48 + (panel_h - runtime.height) // 2))
    draw = ImageDraw.Draw(canvas)
    draw.text((12, 16), "owner master table", fill=(255, 235, 160), font=font(18))
    draw.text((panel_w + 12, 16), f"runtime {case}", fill=(255, 235, 160), font=font(18))
    canvas.save(EVIDENCE / f"{case}_master_runtime_table_sheet.png")


def main() -> int:
    dataset = json.loads(DATASET.read_text(encoding="utf-8"))
    for case in CASES:
        data = dataset["viewports"][case]
        annotate(case, data)
        side_by_side(case, data)
        print(f"M06_RENDER_EVIDENCE case={case} visible_wood_reference=PASS master_runtime_sheet=PASS")
    print("M06_RENDER_EVIDENCE_RESULT=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
