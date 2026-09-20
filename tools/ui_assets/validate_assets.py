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
PRESERVED_LOGO_SHA256 = "B8B828FF49288E80DC9E6CA62ECA95173BCEAC3DB5B8217765D9970158160B42"
SEMANTIC_PATHS = [
    "ui/global/home_icon.png", "ui/global/settings_icon.png", "ui/global/map_icon.png", "ui/global/info_icon.png",
    "ui/global/help_icon.png", "screens/settings/sound_icon.png", "screens/settings/music_icon.png",
    "screens/settings/haptic_icon.png", "screens/settings/language_icon.png", "screens/settings/privacy_icon.png",
    "screens/settings/accessibility_icon.png", "screens/social/share_icon.png", "screens/social/friend_icon.png",
    "screens/results/video_ad_icon.png", "ui/global/play_icon.png", "ui/global/pause_icon.png",
    "ui/global/restart_icon.png", "ui/global/lock_icon.png", "ui/global/check_icon.png", "ui/global/close_x.png",
    "ui/global/back_arrow.png", "ui/global/next_arrow.png", "ui/global/previous_arrow.png",
    "ui/boosters/booster_time.png", "ui/boosters/booster_hammer.png", "ui/boosters/booster_upgrade.png", "ui/boosters/booster_shuffle.png",
]
ISLAND_PATHS = [f"campaign/islands/{island}/world_icon.png" for island in [
    "sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island",
    "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island"
]]


def git(*args):
    return subprocess.run(["git", *args], cwd=ROOT, text=True, capture_output=True, check=False)


def fail(message):
    raise AssertionError(message)


def signature(path):
    image = Image.open(path).convert("RGBA").resize((24, 24), Image.Resampling.BILINEAR)
    return [channel for pixel in image.getdata() for channel in pixel]


def distance(left, right):
    return sum(abs(a - b) for a, b in zip(left, right)) / (len(left) * 255)


def write_uniqueness_report(name, paths):
    signatures = {path: signature(OUT / path) for path in paths}
    pairs = []
    for index, left in enumerate(paths):
        for right in paths[index + 1:]:
            pairs.append((distance(signatures[left], signatures[right]), left, right))
    pairs.sort()
    report = {
        "asset_family": name,
        "asset_count": len(paths),
        "minimum_pair_distance": pairs[0][0] if pairs else None,
        "near_duplicate_threshold": 0.01,
        "near_duplicate_pairs": [{"distance": d, "left": l, "right": r} for d, l, r in pairs if d <= 0.01],
    }
    (OUT / f"{name.upper()}_UNIQUENESS_REPORT.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    assert not report["near_duplicate_pairs"], f"near-duplicate {name} assets: {report['near_duplicate_pairs'][:3]}"
    return report


def main():
    manifest_path = OUT / "ASSET_MANIFEST.json"
    dimensions_path = OUT / "ASSET_DIMENSIONS.csv"
    geometry_path = OUT / "tables" / "table_geometry_v1.json"
    assert manifest_path.exists(), "manifest missing"
    assert dimensions_path.exists(), "dimensions CSV missing"
    assert geometry_path.exists(), "table geometry missing"
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    assets = data["assets"]
    assert len(assets) >= 390, f"unexpectedly small manifest: {len(assets)}"
    generator_source = (ROOT / "tools" / "ui_assets" / "generate_assets.py").read_text(encoding="utf-8")
    assert "No explicit renderer for final asset" in generator_source, "catch-all fallback guard missing"
    assert 'stem.replace("_", " ").upper()' not in generator_source, "filename label fallback remains"
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

    logo_path = OUT / "brand" / "logo_beach_cocktails_merge.png"
    assert hashlib.sha256(logo_path.read_bytes()).hexdigest().upper() == PRESERVED_LOGO_SHA256, "canonical owner logo changed"
    semantic_report = write_uniqueness_report("semantic", SEMANTIC_PATHS)
    island_report = write_uniqueness_report("island", ISLAND_PATHS)

    protected_diffs = git("diff", "--name-only", START_HEAD, "--", *PROTECTED).stdout.strip().splitlines()
    assert not any(path.startswith(tuple(PROTECTED[:4])) or path in PROTECTED[4:] for path in protected_diffs), f"protected path changed: {protected_diffs}"
    print(f"PASS manifest-existence: {len(assets)} assets present")
    print(f"PASS png-decode-dimensions-alpha: {decoded} decoded; CSV and manifest agree")
    print("PASS table-canvas: 10 x 720x1280")
    print("PASS table-alpha-silhouette: 10 identical masks")
    print("PASS geometry: corners [0,1280]/[720,1280], rear [130,398]-[590,398], target 0.64")
    print(f"PASS canonical-logo: preserved SHA256 {PRESERVED_LOGO_SHA256}")
    print(f"PASS semantic-uniqueness: {semantic_report['asset_count']} assets; minimum distance {semantic_report['minimum_pair_distance']:.4f}")
    print(f"PASS island-uniqueness: {island_report['asset_count']} assets; minimum distance {island_report['minimum_pair_distance']:.4f}")
    print("PASS final-renderer-guard: explicit renderers only; no filename/stem fallback")
    print("PASS protected-scope: no changes under runtime asset folders, game manager, or TASKS.md")


if __name__ == "__main__":
    main()
