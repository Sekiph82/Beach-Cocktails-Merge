from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "docs" / "evidence" / "m07"
MASTER = ROOT / "b75ee426-9568-4ed6-b35e-140600a7c995.png"
CASES = ("canonical_720x1280", "taller_720x1440", "shorter_wider_800x1280")

def main() -> int:
    if not MASTER.is_file():
        print("M07_SHEET_FAIL missing master reference")
        return 1
    master = Image.open(MASTER).convert("RGB")
    for case in CASES:
        runtime_path = EVIDENCE / f"{case}.png"
        overlay_path = EVIDENCE / f"{case}_hud_inner_boxes.png"
        visible_path = EVIDENCE / f"{case}_visible_bounds.png"
        if not runtime_path.is_file() or not overlay_path.is_file() or not visible_path.is_file():
            print(f"M07_SHEET_FAIL missing evidence case={case}")
            return 1
        runtime = Image.open(runtime_path).convert("RGB")
        overlay = Image.open(overlay_path).convert("RGB")
        visible = Image.open(visible_path).convert("RGB")
        width = 720
        half_height = 480
        master_thumb = master.copy()
        master_thumb.thumbnail((width, half_height))
        runtime_thumb = runtime.copy()
        runtime_thumb.thumbnail((width, half_height))
        sheet = Image.new("RGB", (width * 2, half_height + 44), (35, 30, 24))
        sheet.paste(master_thumb, (0, 44))
        sheet.paste(runtime_thumb, (width, 44))
        draw = ImageDraw.Draw(sheet)
        draw.text((12, 14), f"owner master reference — {case}", fill=(255, 235, 160))
        draw.text((width + 12, 14), "M07 runtime", fill=(255, 235, 160))
        sheet.save(EVIDENCE / f"{case}_master_side_by_side.png")
        crop_top = max(0, runtime.height - min(330, runtime.height))
        crop = runtime.crop((0, crop_top, runtime.width, runtime.height))
        crop.save(EVIDENCE / f"{case}_progression_closeup.png")
        overlay.crop((0, max(0, overlay.height - min(400, overlay.height)), overlay.width, overlay.height)).save(EVIDENCE / f"{case}_layout_closeup.png")
        visible.crop((0, max(0, visible.height - min(420, visible.height)), visible.width, visible.height)).save(EVIDENCE / f"{case}_visible_bounds_closeup.png")
        print(f"M07_SHEET case={case} side_by_side=PASS progression_closeup=PASS layout_closeup=PASS visible_bounds_closeup=PASS")
    print("M07_SHEET_RESULT=PASS")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
