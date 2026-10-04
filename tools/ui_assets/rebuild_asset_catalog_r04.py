from __future__ import annotations

import csv
import hashlib
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "ui_assets"
ISLANDS = {
    "azure_bay", "billionaire_island", "coconut_beach", "final_island",
    "frozen_paradise", "party_beach", "sunny_cove", "sunset_island",
    "tiki_island", "volcano_bay",
}


def main() -> None:
    manifest_path = OUT / "ASSET_MANIFEST.json"
    old_manifest = json.loads(manifest_path.read_text(encoding="utf-8")) if manifest_path.exists() else {"assets": []}
    old_by_path = {item["path"]: item for item in old_manifest.get("assets", [])}
    manifest = []
    dimensions = []
    for path in sorted(OUT.rglob("*.png")):
        relative = path.relative_to(ROOT).as_posix()
        with Image.open(path) as image:
            image.load()
            width, height, mode = image.width, image.height, image.mode
        previous = old_by_path.get(relative, {})
        island_id = next((island for island in ISLANDS if f"/islands/{island}/" in f"/{relative}"), None)
        source_copy = path.name == "gameplay_surface.png" and island_id is not None
        item = {
            "path": relative,
            "category": previous.get("category", path.parent.relative_to(OUT).as_posix()),
            "intended_screen_use": "canonical runtime copy of island R04 gameplay surface" if source_copy else previous.get("intended_screen_use", path.stem.replace("_", " ")),
            "dimensions": {"width": width, "height": height},
            "alpha_expected": mode in {"RGBA", "LA"},
            "island_id": island_id,
            "table_geometry_version": None,
            "generation_source_method": "byte-identical copy of owner-selected per-island gameplay_surface_v07_r04.png" if source_copy else previous.get("generation_source_method", "existing canonical asset; metadata inventory refreshed"),
            "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
        }
        manifest.append(item)
        dimensions.append((relative, width, height, mode, item["alpha_expected"]))
    manifest_path.write_text(json.dumps({"manifest_version": 1, "base_viewport": [720, 1280], "assets": manifest}, indent=2) + "\n", encoding="utf-8")
    with (OUT / "ASSET_DIMENSIONS.csv").open("w", encoding="utf-8", newline="") as handle:
        writer = csv.writer(handle)
        writer.writerow(["path", "width", "height", "mode", "alpha_expected"])
        writer.writerows(dimensions)
    print(f"R04_ASSET_CATALOG=PASS current_pngs={len(manifest)} dimensions={len(dimensions)}")


if __name__ == "__main__":
    main()
