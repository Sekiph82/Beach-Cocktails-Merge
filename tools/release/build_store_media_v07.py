"""Build a clearly labeled store composition from a genuine V07 Godot capture."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
CAPTURE_DIR = ROOT / "docs/release/store_media/captures_v07"
COMPOSITION_DIR = ROOT / "docs/release/store_media/compositions_v07"
PROFILE_DIR = ROOT / ".godot/bcm_sandboxes/bcm_m34_v07_20261021_01/r/Godot/app_userdata/CocktailMerge"
CAPTURE_NAME = "desktop_candidate_02_campaign"
OUTPUT_NAME = "04_gameplay_google_play_candidate_v07"
TITLE = "Plan your next shot"
FOOTER = "REAL GAME CAPTURE  •  DESKTOP CANDIDATE  •  DEVICE REVIEW PENDING"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_font(size: int) -> ImageFont.FreeTypeFont:
    candidates = [
        Path("C:/Windows/Fonts/segoeuib.ttf"),
        Path("C:/Windows/Fonts/arialbd.ttf"),
    ]
    for candidate in candidates:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default()


def main() -> None:
    source_png = CAPTURE_DIR / f"{CAPTURE_NAME}.png"
    source_json = CAPTURE_DIR / f"{CAPTURE_NAME}.json"
    tutorial_path = PROFILE_DIR / "gameplay_tutorial_state.json"
    if not source_png.is_file() or not source_json.is_file():
        raise SystemExit("V07 genuine gameplay capture or sidecar is missing")
    source_meta = json.loads(source_json.read_text(encoding="utf-8"))
    if source_meta.get("classification") != "DESKTOP_GAMEPLAY_CANDIDATE":
        raise SystemExit("Source capture is not classified as a desktop gameplay candidate")
    if source_meta.get("runtime_version", "").split(" ")[0] != "4.7.2-stable":
        raise SystemExit("Unexpected runtime version for V07 capture")
    if not tutorial_path.is_file():
        raise SystemExit("Isolated tutorial-completion record is missing")
    tutorial = json.loads(tutorial_path.read_text(encoding="utf-8"))
    if tutorial.get("completed") is not True:
        raise SystemExit("Gameplay tutorial was not completed in the isolated profile")

    source_hash = sha256(source_png)
    tutorial_hash = sha256(tutorial_path)
    source_meta["capture_sha256"] = source_hash
    source_meta["tutorial_status"] = "COMPLETED_IN_PROFILE"
    source_meta["tutorial_state_sha256"] = tutorial_hash
    source_json.write_bytes((json.dumps(source_meta, ensure_ascii=False, indent=2) + "\n").encode("utf-8"))

    with Image.open(source_png) as opened:
        if opened.size != (720, 1280):
            raise SystemExit(f"Expected 720x1280 live viewport; got {opened.size}")
        viewport = opened.convert("RGB")

    canvas = Image.new("RGB", (1080, 1920), "#062538")
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((34, 24, 1046, 145), radius=34, fill="#103d52", outline="#73e0d1", width=3)
    title_font = load_font(49)
    title_box = draw.textbbox((0, 0), TITLE, font=title_font)
    title_x = (1080 - (title_box[2] - title_box[0])) // 2
    draw.text((title_x, 53), TITLE, font=title_font, fill="#fff0c6")

    viewport = viewport.resize((972, 1728), Image.Resampling.LANCZOS)
    canvas.paste(viewport, (54, 168))
    footer_font = load_font(18)
    footer_box = draw.textbbox((0, 0), FOOTER, font=footer_font)
    footer_x = (1080 - (footer_box[2] - footer_box[0])) // 2
    draw.text((footer_x, 1897), FOOTER, font=footer_font, fill="#73e0d1")

    COMPOSITION_DIR.mkdir(parents=True, exist_ok=True)
    output_png = COMPOSITION_DIR / f"{OUTPUT_NAME}.png"
    canvas.save(output_png, format="PNG", optimize=True)
    output_meta = {
        "work_item": "BCM-M34-006/007 V07",
        "kind": "captioned_composition_from_actual_godot_runtime_capture",
        "title": TITLE,
        "source_capture": str(source_png.relative_to(ROOT)).replace("\\", "/"),
        "source_capture_sha256": source_hash,
        "source_capture_resolution": [720, 1280],
        "tutorial_status": "COMPLETED_IN_PROFILE",
        "tutorial_state_sha256": tutorial_hash,
        "composition_resolution": [1080, 1920],
        "capture_classification": "DESKTOP_GAMEPLAY_CANDIDATE",
        "device_review_status": "DEVICE_REVIEW_PENDING",
        "owner_visual_approval": "PENDING",
        "store_device_capture": False,
        "content_modified": False,
        "footer": FOOTER,
        "composition_sha256": sha256(output_png),
    }
    output_png.with_suffix(".json").write_bytes(
        (json.dumps(output_meta, ensure_ascii=False, indent=2) + "\n").encode("utf-8")
    )
    print(json.dumps(output_meta, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
