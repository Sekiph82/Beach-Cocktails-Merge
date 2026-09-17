"""Deterministic M04 asset-contract validator and non-destructive evidence generator."""

from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
EVIDENCE = ROOT / "docs" / "evidence" / "m04"
COCKTAILS = [Path("assets/cocktails") / f"L{level:02d}.png" for level in range(1, 13)]
ENVIRONMENT = [Path("assets/environment/game_board_background.png")]
UI = [
    Path("assets/ui/logo_beach_cocktails_merge.png"),
    Path("assets/ui/panel_best_score.png"),
    Path("assets/ui/panel_score.png"),
    Path("assets/ui/panel_to_go_orders.png"),
    Path("assets/ui/panel_next.png"),
    Path("assets/ui/progression_strip.png"),
    Path("assets/ui/launch_zone.png"),
    Path("assets/ui/danger_line.png"),
]
EFFECTS = [
    Path("assets/effects/merge_glow.png"),
    Path("assets/effects/sparkle.png"),
    Path("assets/effects/splash.png"),
    Path("assets/effects/to_go_trail.png"),
]
CANONICAL = COCKTAILS + ENVIRONMENT + UI + EFFECTS
TRANSPARENT_REQUIRED = set(COCKTAILS + UI + EFFECTS)
EFFECT_CLASSIFICATION = {
    Path("assets/effects/merge_glow.png"): "APPROVED_DEFERRED_EFFECT_ASSET_M08",
    Path("assets/effects/sparkle.png"): "APPROVED_DEFERRED_EFFECT_ASSET_M08",
    Path("assets/effects/splash.png"): "APPROVED_DEFERRED_EFFECT_ASSET_M08",
    Path("assets/effects/to_go_trail.png"): "APPROVED_M04_EFFECT_ASSET",
}
EVIDENCE_SHEETS = {
    "cocktails": "cocktails_contact_sheet.png",
    "ui": "ui_contact_sheet.png",
    "environment": "environment_reference.png",
    "effects": "effects_contact_sheet.png",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def png_color_type(path: Path) -> int:
    with path.open("rb") as stream:
        signature = stream.read(8)
        length = int.from_bytes(stream.read(4), "big")
        chunk_type = stream.read(4)
        ihdr = stream.read(length)
    if signature != b"\x89PNG\r\n\x1a\n" or chunk_type != b"IHDR" or len(ihdr) < 10:
        raise ValueError("invalid PNG signature or IHDR")
    return ihdr[9]


def metrics(path: Path) -> dict[str, object]:
    with Image.open(path) as image:
        image.load()
        rgba = image.convert("RGBA")
        alpha = rgba.getchannel("A")
        histogram = alpha.histogram()
        total = rgba.width * rgba.height
        transparent = histogram[0]
        opaque = histogram[255]
        bbox = alpha.getbbox()
        return {
            "bytes": path.stat().st_size,
            "sha256": sha256(path),
            "dimensions": [rgba.width, rgba.height],
            "mode": image.mode,
            "png_color_type": png_color_type(path),
            "alpha": "present" if "A" in image.getbands() or image.mode == "P" else "absent",
            "transparent_pixels": transparent,
            "transparent_percent": round(100.0 * transparent / total, 4),
            "nontransparent_pixels": total - transparent,
            "nontransparent_percent": round(100.0 * (total - transparent) / total, 4),
            "opaque_pixels": opaque,
            "semi_transparent_pixels": total - transparent - opaque,
            "alpha_bbox": list(bbox) if bbox is not None else None,
            "fully_opaque": opaque == total,
        }


def tracked(path: Path) -> bool:
    result = subprocess.run(
        ["git", "ls-files", "--error-unmatch", "--", path.as_posix()],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    return result.returncode == 0 and result.stdout.strip() == path.as_posix()


def actual_pngs(directory: Path) -> set[Path]:
    return {
        path.relative_to(ROOT).as_posix()
        for path in directory.glob("*.png")
        if path.is_file()
    }


def font() -> ImageFont.ImageFont:
    try:
        return ImageFont.truetype("arial.ttf", 22)
    except OSError:
        return ImageFont.load_default()


def composite_thumb(path: Path, box: tuple[int, int]) -> Image.Image:
    with Image.open(ROOT / path) as source:
        rgba = source.convert("RGBA")
        thumb = ImageOps.contain(rgba, (box[0] - 20, box[1] - 42))
    canvas = Image.new("RGBA", box, (39, 51, 61, 255))
    checker = Image.new("RGBA", (box[0] - 20, box[1] - 42), (226, 226, 218, 255))
    checker_draw = ImageDraw.Draw(checker)
    tile = 16
    for y in range(0, checker.height, tile):
        for x in range(0, checker.width, tile):
            if (x // tile + y // tile) % 2:
                checker_draw.rectangle((x, y, x + tile, y + tile), fill=(184, 192, 193, 255))
    x = (box[0] - thumb.width) // 2
    y = 30 + (box[1] - 42 - thumb.height) // 2
    canvas.alpha_composite(checker, (10, 30))
    canvas.alpha_composite(thumb, (x, y))
    draw = ImageDraw.Draw(canvas)
    draw.text((10, 7), path.stem, fill=(255, 246, 210, 255), font=font())
    return canvas


def contact_sheet(paths: Iterable[Path], output: Path, columns: int, cell: tuple[int, int]) -> None:
    paths = list(paths)
    rows = (len(paths) + columns - 1) // columns
    sheet = Image.new("RGBA", (columns * cell[0], rows * cell[1]), (21, 29, 38, 255))
    for index, path in enumerate(paths):
        x = (index % columns) * cell[0]
        y = (index // columns) * cell[1]
        sheet.alpha_composite(composite_thumb(path, cell), (x, y))
    sheet.convert("RGB").save(output)


def make_progression_evidence(source: Path, output: Path) -> list[dict[str, object]]:
    with Image.open(ROOT / source) as image:
        rgba = image.convert("RGBA")
        width, height = rgba.size
        canvas = rgba.copy()
    draw = ImageDraw.Draw(canvas)
    slots: list[dict[str, object]] = []
    for index in range(12):
        center_x = int(width * (index + 0.5) / 12.0)
        center_y = int(height * 0.50)
        box = [center_x - int(width / 30), center_y - int(height / 3.4), center_x + int(width / 30), center_y + int(height / 3.4)]
        draw.rectangle(box, outline=(255, 232, 106, 255), width=5)
        label = str(index + 1)
        draw.text((center_x - 7, 10), label, fill=(255, 232, 106, 255), font=font())
        slots.append({"slot": index + 1, "center": [center_x, center_y], "annotation_box": box})
    canvas.save(output)
    return slots


def make_references() -> None:
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    contact_sheet(COCKTAILS, EVIDENCE / "cocktails_contact_sheet.png", 4, (320, 330))
    contact_sheet(UI, EVIDENCE / "ui_contact_sheet.png", 2, (640, 390))
    contact_sheet(EFFECTS, EVIDENCE / "effects_contact_sheet.png", 2, (700, 390))
    shutil.copyfile(ROOT / ENVIRONMENT[0], EVIDENCE / "environment_reference.png")
    shutil.copyfile(ROOT / "b75ee426-9568-4ed6-b35e-140600a7c995.png", EVIDENCE / "master_reference.png")
    slots = make_progression_evidence(
        Path("assets/ui/progression_strip.png"),
        EVIDENCE / "progression_strip_12_slots.png",
    )
    return slots


def main() -> int:
    failures: list[str] = []
    print(f"M04_PATH_SET required=25 cocktails={len(COCKTAILS)} environment={len(ENVIRONMENT)} ui={len(UI)} effects={len(EFFECTS)}")

    expected_cocktails = {path.as_posix() for path in COCKTAILS}
    expected_environment = {path.as_posix() for path in ENVIRONMENT}
    expected_ui = {path.as_posix() for path in UI}
    expected_effects = {path.as_posix() for path in EFFECTS}
    observed_cocktails = actual_pngs(ROOT / "assets" / "cocktails")
    observed_environment = actual_pngs(ROOT / "assets" / "environment")
    observed_ui = actual_pngs(ROOT / "assets" / "ui")
    observed_effects = actual_pngs(ROOT / "assets" / "effects")
    print(f"M04_REPO_PATH_SET cocktails={len(observed_cocktails)}/{len(expected_cocktails)} environment={len(observed_environment)}/{len(expected_environment)} ui={len(observed_ui)}/{len(expected_ui)} effects={len(observed_effects)}/{len(expected_effects)}")
    for scope, observed, expected in [
        ("cocktails", observed_cocktails, expected_cocktails),
        ("environment", observed_environment, expected_environment),
        ("ui", observed_ui, expected_ui),
        ("effects", observed_effects, expected_effects),
    ]:
        unexpected = sorted(observed - expected)
        missing = sorted(expected - observed)
        if unexpected or missing:
            failures.append(f"{scope} path set mismatch")
            print(f"M04_REPO_PATH_SET FAIL scope={scope} missing={missing} unexpected={unexpected}")
        else:
            print(f"M04_REPO_PATH_SET PASS scope={scope} exact=true")
    if any("guide_line" in path.as_posix().lower() for path in (ROOT / "assets").rglob("*")):
        failures.append("guide_line asset present")
        print("M04_GUIDE_LINE FAIL present=true")
    else:
        print("M04_GUIDE_LINE PASS present=false")

    records: dict[str, dict[str, object]] = {}
    for path in CANONICAL:
        absolute = ROOT / path
        if not absolute.is_file():
            failures.append(f"missing {path.as_posix()}")
            print(f"M04_ASSET FAIL path={path.as_posix()} missing=true")
            continue
        if not tracked(path):
            failures.append(f"untracked {path.as_posix()}")
            print(f"M04_ASSET FAIL path={path.as_posix()} tracked=false")
            continue
        try:
            result = metrics(absolute)
        except Exception as error:
            failures.append(f"invalid {path.as_posix()}: {error}")
            print(f"M04_ASSET FAIL path={path.as_posix()} error={error}")
            continue
        result["path"] = path.as_posix()
        if path in EFFECT_CLASSIFICATION:
            result["effect_classification"] = EFFECT_CLASSIFICATION[path]
        if result["bytes"] <= 0 or result["dimensions"][0] <= 0 or result["dimensions"][1] <= 0:
            failures.append(f"empty {path.as_posix()}")
        if path in TRANSPARENT_REQUIRED:
            result["alpha_policy"] = "transparent-required"
            alpha_ok = result["alpha"] == "present" and result["transparent_pixels"] > 0 and result["alpha_bbox"] is not None
            result["alpha_result"] = "PASS" if alpha_ok else "FAIL"
            if not alpha_ok:
                failures.append(f"alpha contract {path.as_posix()}")
        else:
            result["alpha_policy"] = "opaque-allowed"
            result["alpha_result"] = "PASS"
        print(
            f"M04_ASSET {'PASS' if result['alpha_result'] == 'PASS' else 'FAIL'} "
            f"path={path.as_posix()} tracked=true bytes={result['bytes']} dimensions={result['dimensions'][0]}x{result['dimensions'][1]} "
            f"alpha={result['alpha']} transparent={result['transparent_pixels']}({result['transparent_percent']}%) "
            f"nontransparent={result['nontransparent_pixels']}({result['nontransparent_percent']}%) "
            f"bbox={result['alpha_bbox']} alpha_policy={result['alpha_policy']} alpha_result={result['alpha_result']} "
            f"sha256={result['sha256']}"
        )
        if path in EFFECT_CLASSIFICATION:
            print(f"M04_EFFECT_CLASSIFICATION path={path.as_posix()} class={EFFECT_CLASSIFICATION[path]}")
        records[path.as_posix()] = result

    best = records.get("assets/ui/panel_best_score.png")
    score = records.get("assets/ui/panel_score.png")
    if best and score:
        delta = [best["dimensions"][0] - score["dimensions"][0], best["dimensions"][1] - score["dimensions"][1]]
        print(f"M04_PANEL_DIMENSIONS best={best['dimensions'][0]}x{best['dimensions'][1]} score={score['dimensions'][0]}x{score['dimensions'][1]} match={delta == [0, 0]} delta={delta}")
    slots = make_references()
    print(f"M04_VISUAL_EVIDENCE generated=7 progression_slots_annotated={len(slots)} classification=MANUAL_VISUAL_EVIDENCE")

    for path, sheet in EVIDENCE_SHEETS.items():
        pass
    manifest = {
        "schema": "BCM-M04-R02 evidence manifest V01",
        "owner_master": "b75ee426-9568-4ed6-b35e-140600a7c995.png",
        "source_assets": records,
        "evidence": {
            "cocktails_contact_sheet.png": {"source_paths": [p.as_posix() for p in COCKTAILS], "classification": "MANUAL_VISUAL_EVIDENCE"},
            "ui_contact_sheet.png": {"source_paths": [p.as_posix() for p in UI], "classification": "MANUAL_VISUAL_EVIDENCE"},
            "environment_reference.png": {"source_paths": [p.as_posix() for p in ENVIRONMENT], "classification": "MANUAL_VISUAL_EVIDENCE"},
            "effects_contact_sheet.png": {"source_paths": [p.as_posix() for p in EFFECTS], "classification": "MANUAL_VISUAL_EVIDENCE"},
            "master_reference.png": {"source_paths": ["b75ee426-9568-4ed6-b35e-140600a7c995.png"], "classification": "OWNER_MASTER_REFERENCE"},
            "progression_strip_12_slots.png": {"source_paths": ["assets/ui/progression_strip.png"], "slots": slots, "classification": "MANUAL_VISUAL_EVIDENCE"},
        },
    }
    (EVIDENCE / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    result = "PASS" if not failures else f"FAIL failures={'; '.join(failures)}"
    print(f"M04_PYTHON_RESULT={result}")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
