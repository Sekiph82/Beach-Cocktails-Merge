from __future__ import annotations

import csv
import hashlib
import json
import subprocess
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "ui_assets"
START_HEAD = "58a3a33"
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
STATEFUL_GROUPS = [
    ("stars", [
        "campaign/island_map/star_small_empty.png", "campaign/island_map/star_small_filled.png",
        "ui/rewards/star_empty.png", "ui/rewards/star_filled.png", "ui/rewards/star_large_empty.png", "ui/rewards/star_large_filled.png",
    ], 0.02),
    ("chests", [
        "ui/rewards/small_chest_closed.png", "ui/rewards/small_chest_open.png", "ui/rewards/big_chest_closed.png", "ui/rewards/big_chest_open.png",
        "ui/rewards/premium_chest_closed.png", "ui/rewards/premium_chest_open.png", "screens/milestones/milestone_chest_closed.png", "screens/milestones/milestone_chest_open.png",
    ], 0.02),
    ("toggle", ["screens/settings/toggle_off.png", "screens/settings/toggle_on.png"], 0.02),
    ("level_nodes", ["campaign/island_map/level_node_locked.png", "campaign/island_map/level_node_unlocked.png", "campaign/island_map/level_node_current.png", "campaign/island_map/level_node_completed.png"], 0.02),
    ("tabs", ["ui/global/tab_inactive.png", "ui/global/tab_active.png"], 0.02),
    ("daily_reward_states", ["screens/daily_reward/daily_day_locked.png", "screens/daily_reward/daily_day_current.png", "screens/daily_reward/daily_day_claimed.png"], 0.015),
    ("booster_states", ["ui/boosters/booster_locked.png", "ui/boosters/booster_selected.png", "ui/boosters/booster_time.png"], 0.015),
    ("route_markers", ["campaign/world_map/route_marker.png", "campaign/world_map/route_marker_current.png", "campaign/world_map/route_marker_complete.png"], 0.015),
]


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


def validate_stateful_report():
    report_path = OUT / "STATEFUL_PAIR_REPORT.json"
    contact_path = OUT / "CONTACT_SHEET_STATEFUL_UI.png"
    assert report_path.exists(), "stateful pair report missing"
    assert contact_path.exists(), "stateful contact sheet missing"
    report = json.loads(report_path.read_text(encoding="utf-8"))
    by_name = {group["name"]: group for group in report["groups"]}
    results = {}
    for name, paths, threshold in STATEFUL_GROUPS:
        assert name in by_name, f"stateful group missing: {name}"
        entry = by_name[name]
        assert entry["minimum_required_distance"] == threshold, f"threshold drift: {name}"
        hashes = [hashlib.sha256((OUT / path).read_bytes()).hexdigest() for path in paths]
        signatures = {path: signature(OUT / path) for path in paths}
        distances = [distance(signatures[left], signatures[right]) for index, left in enumerate(paths) for right in paths[index + 1:]]
        assert min(distances) >= threshold, f"insufficient state differentiation: {name} min={min(distances):.4f} threshold={threshold:.4f}"
        report_hashes = [asset["sha256"] for asset in entry["assets"]]
        assert report_hashes == hashes, f"stateful report checksum drift: {name}"
        assert entry["status"] == "PASS", f"stateful report failed: {name}"
        results[name] = min(distances)
    return results


def worktree_blob(path):
    result = git("hash-object", "--", path).stdout.strip()
    assert result, f"missing worktree blob hash: {path}"
    return result


def head_blob(path):
    result = git("rev-parse", f"{START_HEAD}:{path}").stdout.strip()
    assert result, f"missing start-commit blob hash: {path}"
    return result


def main():
    manifest_path = OUT / "ASSET_MANIFEST.json"
    dimensions_path = OUT / "ASSET_DIMENSIONS.csv"
    geometry_path = OUT / "tables" / "table_geometry_v2.json"
    assert manifest_path.exists(), "manifest missing"
    assert dimensions_path.exists(), "dimensions CSV missing"
    assert geometry_path.exists(), "table geometry missing"
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    assets = data["assets"]
    assert len(assets) >= 390, f"unexpectedly small manifest: {len(assets)}"
    generator_source = (ROOT / "tools" / "ui_assets" / "generate_assets.py").read_text(encoding="utf-8")
    assert "No explicit renderer for final asset" in generator_source, "catch-all fallback guard missing"
    assert "generic_element" not in generator_source, "legacy generic renderer name remains"
    assert 'stem.replace("_", " ").upper()' not in generator_source, "filename label fallback remains"
    assert all("fallback" not in item.get("generation_source_method", "").lower() for item in assets), "fallback source recorded in manifest"
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
    assert geometry["geometry_version"] == 2, "table geometry is not V2"
    assert geometry["status"] == "OWNER_CONSTITUTIONAL", "V2 geometry status drift"
    assert geometry["viewport"] == {"width": 720, "height": 1280}
    runtime = geometry["runtime_playable_boundary"]
    visual = geometry["visual_table_layout"]
    progression = geometry["progression"]
    assert runtime["left_source_points"][0] == [199, 478]
    assert runtime["right_source_points"][0] == [833, 478]
    assert runtime["left_source_points"][-1] == [8, 1186]
    assert runtime["right_source_points"][-1] == [1016, 1186]
    assert abs(runtime["rear_viewport_y"] - 398.333) < 0.01
    assert abs(runtime["danger_viewport_y"] - 900.0) < 0.01
    assert abs(runtime["launch_viewport_y"] - 946.667) < 0.01
    assert runtime["rear_edge_margin_px"] == 12
    assert visual["canvas"] == [720, 1280]
    assert visual["transparent_background"] is True
    assert abs(visual["tabletop_front_art_transition_y"] - 988.333) < 0.01
    assert visual["visible_front_apron_required"] is True
    assert visual["visible_front_legs_required"] == 2
    assert progression["layer"] == "HUD CanvasLayer"
    assert progression["panel_rect"] == [12, 1039.465, 696, 232.535]

    table_paths = sorted(OUT.glob("campaign/islands/*/gameplay_table.png"))
    assert len(table_paths) == 10, f"expected 10 gameplay tables, found {len(table_paths)}"
    for path in table_paths:
        image = Image.open(path).convert("RGBA")
        assert image.size == (720, 1280), f"table canvas mismatch: {path}"
        alpha = image.getchannel("A")
        assert alpha.getbbox() is not None, f"empty table alpha: {path}"
        lower_structure = alpha.crop((0, 989, 720, 1280))
        assert lower_structure.getbbox() is not None, f"missing V2 lower apron/leg structure: {path}"

    logo_path = OUT / "brand" / "logo_beach_cocktails_merge.png"
    assert hashlib.sha256(logo_path.read_bytes()).hexdigest().upper() == PRESERVED_LOGO_SHA256, "canonical owner logo changed"
    assert worktree_blob("assets/ui_assets/brand/logo_beach_cocktails_merge.png") == head_blob("assets/ui_assets/brand/logo_beach_cocktails_merge.png"), "canonical logo blob changed from start"
    semantic_report = write_uniqueness_report("semantic", SEMANTIC_PATHS)
    island_report = write_uniqueness_report("island", ISLAND_PATHS)
    stateful_results = validate_stateful_report()

    protected_diffs = git("diff", "--name-only", START_HEAD, "--", *PROTECTED).stdout.strip().splitlines()
    assert not any(path.startswith(tuple(PROTECTED[:4])) or path in PROTECTED[4:] for path in protected_diffs), f"protected path changed: {protected_diffs}"
    print(f"PASS manifest-existence: {len(assets)} assets present")
    print(f"PASS png-decode-dimensions-alpha: {decoded} decoded; CSV and manifest agree")
    print("PASS table-canvas: 10 x 720x1280")
    print("PASS table-v2-lower-structure: 10 tables contain non-playable apron/leg-region pixels")
    print("PASS geometry-v2: R11 rails preserved; rear=398.333, danger=900, launch=946.667, tabletop-front=988.333")
    print(f"PASS canonical-logo: preserved SHA256 {PRESERVED_LOGO_SHA256}")
    print("PASS canonical-logo: start-commit blob unchanged; V1 table mask is legacy")
    print(f"PASS semantic-uniqueness: {semantic_report['asset_count']} assets; minimum distance {semantic_report['minimum_pair_distance']:.4f}")
    print(f"PASS island-uniqueness: {island_report['asset_count']} assets; minimum distance {island_report['minimum_pair_distance']:.4f}")
    print(f"PASS stateful-stars: minimum distance {stateful_results['stars']:.4f}")
    print(f"PASS stateful-chests: minimum distance {stateful_results['chests']:.4f}")
    print(f"PASS stateful-toggle: minimum distance {stateful_results['toggle']:.4f}")
    print(f"PASS stateful-level-nodes: minimum distance {stateful_results['level_nodes']:.4f}")
    print(f"PASS stateful-tabs: minimum distance {stateful_results['tabs']:.4f}")
    print(f"PASS stateful-daily-route-booster: daily={stateful_results['daily_reward_states']:.4f}, route={stateful_results['route_markers']:.4f}, booster={stateful_results['booster_states']:.4f}")
    print("PASS final-renderer-guard: explicit renderers only; no filename/stem fallback")
    print("PASS protected-scope: no changes under runtime asset folders, game manager, or TASKS.md")


if __name__ == "__main__":
    main()
