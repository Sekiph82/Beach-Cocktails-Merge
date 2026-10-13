#!/usr/bin/env python3
"""Build hash-backed galleries and a linked review index for R05-R02 captures."""

from __future__ import annotations

import hashlib
import json
from collections import Counter
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SESSION = ROOT / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01"
EVIDENCE = SESSION / "evidence/M33-R05-R02"
ISLANDS = [
    "tiki_island", "azure_bay", "coconut_beach", "sunset_island", "party_beach",
    "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]
SIZES = [(390, 844), (432, 960)]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def gallery(size: tuple[int, int]) -> Path:
    width, height = size
    folder = EVIDENCE / "screenshots" / f"{width}x{height}"
    tile_w, tile_h, margin, gap = 520, 410, 28, 18
    canvas = Image.new("RGB", (margin * 2 + tile_w * 3 + gap * 2, 94 + margin * 2 + tile_h * 3 + gap * 2), "#f5e5c2")
    draw = ImageDraw.Draw(canvas)
    font = ImageFont.load_default()
    draw.text((margin, 24), f"R05-R02 current production captures - {width} x {height}", fill="#173a43", font=font)
    for index, island in enumerate(ISLANDS):
        row, col = divmod(index, 3)
        x, y = margin + col * (tile_w + gap), 94 + margin + row * (tile_h + gap)
        draw.rounded_rectangle((x, y, x + tile_w, y + tile_h), radius=12, fill="#fffaf0", outline="#bd8d4b", width=2)
        draw.text((x + 10, y + 8), island.replace("_", " ").title(), fill="#173a43", font=font)
        names = sorted(p for p in folder.glob(f"{island}_L*_*.png") if "contrast" not in p.name)
        if island == "tiki_island":
            names = [folder / f"{island}_L001_empty.png", folder / f"{island}_L013_populated.png"]
        for j, path in enumerate(names[:2]):
            image = Image.open(path).convert("RGB")
            image.thumbnail((236, 360), Image.Resampling.LANCZOS)
            px = x + 12 + j * 246 + (236 - image.width) // 2
            py = y + 32 + (360 - image.height) // 2
            canvas.paste(image, (px, py))
            draw.text((x + 12 + j * 246, y + 392), path.stem, fill="#173a43", font=font)
    out = EVIDENCE / f"gallery_{width}x{height}.jpg"
    canvas.save(out, quality=90, optimize=True)
    return out


def main() -> None:
    records = []
    starter_levels: Counter[int] = Counter()
    for source in sorted((ROOT / "data/campaign/levels").glob("*.json")):
        data = json.loads(source.read_text(encoding="utf-8"))
        for level in data.get("levels", []):
            for starter in level.get("initial_tabletop_drinks", []):
                starter_levels[int(starter["cocktail_level"])] += 1

    for width, height in SIZES:
        folder = EVIDENCE / "screenshots" / f"{width}x{height}"
        paths = sorted(folder.glob("*.png"))
        if len(paths) != 19:
            raise SystemExit(f"Expected 19 screenshots at {width}x{height}, found {len(paths)}")
        for path in paths:
            with Image.open(path) as image:
                if image.size != (width, height):
                    raise SystemExit(f"Unexpected screenshot size for {path}: {image.size}")
                records.append({"path": path.relative_to(EVIDENCE).as_posix(), "viewport": [width, height], "sha256": sha(path), "bytes": path.stat().st_size})
        manifest = json.loads((folder.parent / f"capture_manifest_{width}x{height}.json").read_text(encoding="utf-8"))
        if manifest.get("result") != "PASS" or len(manifest.get("captures", [])) != 19:
            raise SystemExit(f"Capture manifest did not pass for {width}x{height}")

    if len(records) != 38:
        raise SystemExit(f"Expected 38 total screenshots, found {len(records)}")
    (EVIDENCE / "screenshot_sha256_manifest.json").write_bytes((json.dumps({"result": "PASS", "capture_count": len(records), "captures": records}, indent=2) + "\n").encode("utf-8"))
    (EVIDENCE / "starter_level_distribution.json").write_bytes((json.dumps({"result": "PASS", "scope": "all campaign level JSON files", "preplaced_starter_counts_by_cocktail_level": {str(k): starter_levels[k] for k in sorted(starter_levels)}, "tiers_present": sorted(starter_levels), "tiers_absent": [level for level in range(1, 13) if level not in starter_levels]}, indent=2) + "\n").encode("utf-8"))

    galleries = [gallery(size) for size in SIZES]
    lines = [
        "# BCM-M33-R05-R02 visual review index", "",
        "Builder evidence only. Awaiting independent GPT and owner visual review.", "",
        "## Galleries", "",
    ]
    for path in galleries:
        lines.append(f"![{path.stem}]({path.name})")
        lines.append("")
    lines += ["## Tiki one-starter and two-starter contrast", ""]
    for width, height in SIZES:
        contrast = f"screenshots/{width}x{height}/tiki_island_L027_contrast_two_drinks.png"
        lines.append(f"### {width} x {height}")
        lines.append("")
        lines.append(f"![Tiki two-starter tabletop contrast at {width} x {height}]({contrast})")
        lines.append("")
    lines += ["## Same-level L6 scale comparison", ""]
    for width, height in SIZES:
        name = f"comparison/same_level_{width}x{height}"
        lines.append(f"- [Godot frame ({width} x {height})]({name}.png) - [telemetry]({name}.json)")
    lines += ["", "## Full-resolution original captures", ""]
    for width, height in SIZES:
        lines += [f"### {width} x {height}", ""]
        for record in [r for r in records if r["viewport"] == [width, height]]:
            lines.append(f"- [{Path(record['path']).name}]({record['path']}) — SHA-256 `{record['sha256']}`")
        lines.append("")
    lines += [
        "## Manifests and boundaries", "",
        "- [390×844 Godot capture manifest](screenshots/capture_manifest_390x844.json)",
        "- [432×960 Godot capture manifest](screenshots/capture_manifest_432x960.json)",
        "- [Screenshot SHA-256 manifest](screenshot_sha256_manifest.json)",
        "- [Preplaced starter tier distribution](starter_level_distribution.json)",
        "- [Generation report](generation_report.json)",
        "", "Current generated campaign contains L5 and L6 preplaced starters; no L7 or L8 starter entries exist to compare. The direct same-level production comparison covers an actual L6 starter at Azure Bay L8. Original capture PNGs are linked unchanged; galleries are derived overview images.",
        "", "Stop marker: `AWAITING_GPT_AND_OWNER_R05_R02_VISUAL_REVIEW`", "",
    ]
    (EVIDENCE / "visual_review_index.md").write_bytes("\n".join(lines).encode("utf-8"))
    print(f"R05-R02 review pack PASS: {len(records)} screenshots, {len(galleries)} galleries")


if __name__ == "__main__":
    main()
