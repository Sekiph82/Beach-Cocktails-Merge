from __future__ import annotations

import csv
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "ui_assets"
TABLE_ROOT = OUT / "tables"
ISLANDS = ["azure_bay", "billionaire_island", "coconut_beach", "final_island", "frozen_paradise", "party_beach", "sunny_cove", "sunset_island", "tiki_island", "volcano_bay"]
REMEDIATED = set(ISLANDS) - {"azure_bay", "billionaire_island"}
SHADOW_ALLOWLIST_REASON = "V2 table shadow master is intentionally shared by every island family."


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def expected_overlay(table: Image.Image, edge_alpha: Image.Image) -> Image.Image:
    alpha = ImageChops.multiply(table.getchannel("A"), edge_alpha)
    output = Image.new("RGBA", table.size, (0, 0, 0, 0))
    output.paste(table, (0, 0), alpha)
    return output


def main() -> None:
    manifest_path = OUT / "ASSET_MANIFEST.json"
    dimensions_path = OUT / "ASSET_DIMENSIONS.csv"
    geometry = json.loads((TABLE_ROOT / "table_geometry_v2.json").read_text(encoding="utf-8"))
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assets = manifest["assets"]
    assert len(assets) == 398, f"expected exactly 398 manifest entries, found {len(assets)}"

    dimensions: dict[str, tuple[int, int, str, bool]] = {}
    with dimensions_path.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            dimensions[row["path"]] = (int(row["width"]), int(row["height"]), row["mode"], row["alpha_expected"] == "True")

    decoded = 0
    for item in assets:
        path = ROOT / item["path"]
        assert path.exists(), f"missing manifest asset: {item['path']}"
        assert item["path"] in dimensions, f"missing dimensions row: {item['path']}"
        with Image.open(path) as image:
            image.load()
            decoded += 1
            expected = item["dimensions"]
            assert image.size == (expected["width"], expected["height"]), f"manifest dimensions: {item['path']}"
            csv_size = dimensions[item["path"]]
            assert (image.width, image.height, image.mode) == csv_size[:3], f"CSV dimensions/mode: {item['path']}"
            if item["alpha_expected"]:
                assert "A" in image.getbands(), f"missing alpha: {item['path']}"
                assert image.getchannel("A").getextrema()[1] > 0, f"empty alpha: {item['path']}"
        assert digest(path) == item["sha256"], f"manifest checksum drift: {item['path']}"

    assert geometry["geometry_version"] == 2 and geometry["status"] == "OWNER_CONSTITUTIONAL"
    assert geometry["v2_converted_islands"] == ISLANDS
    assert abs(geometry["runtime_playable_boundary"]["rear_viewport_y"] - 398.333) < 0.01
    assert abs(geometry["visual_table_layout"]["tabletop_front_art_transition_y"] - 988.333) < 0.01
    assert geometry["visual_table_layout"]["visible_front_legs_required"] == 2

    playable = Image.open(TABLE_ROOT / "table_playable_surface_mask_v2.png").convert("RGBA")
    structure = Image.open(TABLE_ROOT / "table_structure_mask_v2.png").convert("RGBA")
    edge_alpha = Image.open(TABLE_ROOT / "table_edge_extraction_mask_v2.png").convert("RGBA").getchannel("A")
    shadow_master = Image.open(TABLE_ROOT / "table_shadow_master_v2.png").convert("RGBA")
    target_alpha = ImageChops.lighter(playable.getchannel("A"), structure.getchannel("A"))
    converted_results = {}
    for island in ISLANDS:
        base = OUT / "campaign" / "islands" / island
        table = Image.open(base / "gameplay_table.png").convert("RGBA")
        overlay = Image.open(base / "table_edge_overlay.png").convert("RGBA")
        shadow = Image.open(base / "gameplay_table_shadow.png").convert("RGBA")
        assert table.size == overlay.size == shadow.size == (720, 1280), f"table canvas: {island}"
        if island in REMEDIATED:
            assert ImageChops.difference(table.getchannel("A"), target_alpha).getbbox() is None, f"V2 alpha geometry: {island}"
        assert ImageChops.difference(overlay, expected_overlay(table, edge_alpha)).getbbox() is None, f"overlay derivation: {island}"
        assert table.tobytes() != overlay.tobytes(), f"overlay is full-table duplicate: {island}"
        assert ImageChops.difference(shadow, shadow_master).getbbox() is None, f"shadow master pixels: {island}"
        assert digest(base / "gameplay_table_shadow.png") == digest(TABLE_ROOT / "table_shadow_master_v2.png"), f"shadow master bytes: {island}"
        converted_results[island] = {"overlay_derived": True, "shadow_exact": True, "frozen_or_masked_geometry": True}

    groups: dict[str, list[str]] = {}
    for item in assets:
        groups.setdefault(item["sha256"], []).append(item["path"])
    duplicate_groups = []
    invalid = 0
    for sha, paths in groups.items():
        if len(paths) < 2:
            continue
        table_shadow_group = all(path.endswith("/gameplay_table_shadow.png") for path in paths)
        if table_shadow_group:
            classification = "intentional semantic reuse"
            reason = SHADOW_ALLOWLIST_REASON
        else:
            classification = "invalid semantic reuse"
            reason = "Distinct canonical semantic roles share identical bytes."
            invalid += 1
        duplicate_groups.append({"sha256": sha, "paths": paths, "classification": classification, "allowlist_reason": reason})
    report = {"manifest_count": len(assets), "duplicate_groups": duplicate_groups, "invalid_semantic_duplicate_count": invalid}
    (OUT / "SEMANTIC_DUPLICATE_REPORT.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    assert invalid == 0, f"invalid semantic duplicate groups: {invalid}"

    print(f"PASS manifest-checksums: {decoded}/398")
    print(f"PASS v2-tables: {len(converted_results)}/10")
    print(f"PASS semantic-duplicates: {len(duplicate_groups)} intentional groups; invalid=0")


if __name__ == "__main__":
    main()
