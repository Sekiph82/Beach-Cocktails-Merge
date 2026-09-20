from __future__ import annotations

import csv
import hashlib
import json
import subprocess
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "ui_assets"
START_HEAD = "0aea98839438dd95e096cf764b9586ad76fe3cd7"
PROTECTED = ["assets/cocktails", "assets/environment", "assets/effects", "assets/ui", "scripts/game_manager.gd", "TASKS.md"]


def git(*args):
    return subprocess.run(["git", *args], cwd=ROOT, text=True, capture_output=True, check=False)


def fail(message):
    raise AssertionError(message)


def main():
    manifest_path = OUT / "ASSET_MANIFEST.json"
    dimensions_path = OUT / "ASSET_DIMENSIONS.csv"
    geometry_path = OUT / "tables" / "table_geometry_v1.json"
    assert manifest_path.exists(), "manifest missing"
    assert dimensions_path.exists(), "dimensions CSV missing"
    assert geometry_path.exists(), "table geometry missing"
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    assets = data["assets"]
    assert len(assets) >= 300, f"unexpectedly small manifest: {len(assets)}"
    dimensions = {}
    with dimensions_path.open(encoding="utf-8") as handle:
        for row in csv.DictReader(handle):
            dimensions[row["path"]] = (int(row["width"]), int(row["height"]), row["mode"], row["alpha_expected"] == "True")

    decoded = 0
    for item in assets:
        path = ROOT / item["path"]
        assert path.exists(), f"missing manifest asset: {item['path']}"
        assert item["path"] in dimensions, f"missing CSV row: {item['path']}"
        image = Image.open(path)
        image.load()
        decoded += 1
        expected = item["dimensions"]
        assert (image.width, image.height) == (expected["width"], expected["height"]), f"manifest dimension mismatch: {item['path']}"
        csv_size = dimensions[item["path"]]
        assert (image.width, image.height, image.mode) == csv_size[:3], f"CSV dimension/mode mismatch: {item['path']}"
        if item["alpha_expected"]:
            assert image.mode in {"RGBA", "LA"}, f"missing alpha channel: {item['path']}"
            alpha = image.getchannel("A")
            assert alpha.getextrema()[1] > 0, f"empty alpha: {item['path']}"
        assert hashlib.sha256(path.read_bytes()).hexdigest() == item["sha256"], f"checksum drift: {item['path']}"

    geometry = json.loads(geometry_path.read_text(encoding="utf-8"))
    assert geometry["viewport_width"] == 720 and geometry["viewport_height"] == 1280
    assert geometry["raster_edge_coordinates"]["front_left"] == [0, 1280]
    assert geometry["raster_edge_coordinates"]["front_right"] == [720, 1280]
    assert geometry["raster_edge_coordinates"]["rear_left"] == [130, 398]
    assert geometry["raster_edge_coordinates"]["rear_right"] == [590, 398]
    assert geometry["raster_edge_coordinates"]["rear_width_px"] == 460
    assert geometry["normalized"]["rear_width"] == 0.64
    assert geometry["canonical_launch_y"] == 947 and geometry["canonical_danger_y"] == 900

    table_paths = sorted(OUT.glob("campaign/islands/*/gameplay_table.png"))
    assert len(table_paths) == 10, f"expected 10 gameplay tables, found {len(table_paths)}"
    masks = []
    for path in table_paths:
        image = Image.open(path).convert("RGBA")
        assert image.size == (720, 1280), f"table canvas mismatch: {path}"
        alpha = image.getchannel("A")
        assert alpha.getpixel((0, 1279)) > 0, f"front-left corner not occupied: {path}"
        assert alpha.getpixel((719, 1279)) > 0, f"front-right raster corner not occupied: {path}"
        masks.append(alpha)
    for mask in masks[1:]:
        assert ImageChops.difference(masks[0], mask).getbbox() is None, "table alpha silhouettes differ"

    protected_diffs = git("diff", "--name-only", START_HEAD, "--", *PROTECTED).stdout.strip().splitlines()
    assert not any(path.startswith(tuple(PROTECTED[:4])) or path in PROTECTED[4:] for path in protected_diffs), f"protected path changed: {protected_diffs}"
    print(f"PASS manifest-existence: {len(assets)} assets present")
    print(f"PASS png-decode-dimensions-alpha: {decoded} decoded; CSV and manifest agree")
    print("PASS table-canvas: 10 x 720x1280")
    print("PASS table-alpha-silhouette: 10 identical masks")
    print("PASS geometry: corners [0,1280]/[720,1280], rear [130,398]-[590,398], target 0.64")
    print("PASS protected-scope: no changes under runtime asset folders, game manager, or TASKS.md")


if __name__ == "__main__":
    main()
