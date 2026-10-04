from __future__ import annotations

import csv
import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "ui_assets"
ISLAND_ROOT = OUT / "campaign" / "islands"
ISLANDS = [
    "azure_bay", "billionaire_island", "coconut_beach", "final_island",
    "frozen_paradise", "party_beach", "sunny_cove", "sunset_island",
    "tiki_island", "volcano_bay",
]
RETAINED_ISLAND_IMAGES = {
    "complete_badge.png", "map_background.png", "map_title.png",
    "theme_badge.png", "world_icon.png", "gameplay_surface.png",
    "gameplay_surface_v07_r04.png",
}


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    manifest_path = OUT / "ASSET_MANIFEST.json"
    dimensions_path = OUT / "ASSET_DIMENSIONS.csv"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assets = manifest["assets"]
    manifest_paths = {item["path"] for item in assets}
    current_paths = {path.relative_to(ROOT).as_posix() for path in OUT.rglob("*.png")}
    assert manifest_paths == current_paths, (
        f"manifest coverage mismatch: missing={sorted(current_paths - manifest_paths)} "
        f"stale={sorted(manifest_paths - current_paths)}"
    )

    dimensions: dict[str, tuple[int, int, str, bool]] = {}
    with dimensions_path.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            dimensions[row["path"]] = (
                int(row["width"]), int(row["height"]), row["mode"],
                row["alpha_expected"] == "True",
            )
    assert set(dimensions) == current_paths, "dimensions catalog does not exactly cover current PNG inventory"

    for item in assets:
        path = ROOT / item["path"]
        assert path.is_file(), f"missing manifest asset: {item['path']}"
        assert item["path"] in dimensions, f"missing dimensions row: {item['path']}"
        with Image.open(path) as image:
            image.load()
            expected = item["dimensions"]
            assert image.size == (expected["width"], expected["height"]), f"manifest dimensions: {item['path']}"
            row = dimensions[item["path"]]
            assert (image.width, image.height, image.mode) == row[:3], f"CSV dimensions/mode: {item['path']}"
            if item["alpha_expected"]:
                assert "A" in image.getbands() and image.getchannel("A").getextrema()[1] > 0, f"alpha: {item['path']}"
        assert digest(path) == item["sha256"], f"manifest checksum drift: {item['path']}"

    campaign = json.loads((ROOT / "data" / "campaign" / "islands.json").read_text(encoding="utf-8"))
    campaign_by_id = {item["id"]: item for item in campaign["islands"]}
    assert set(campaign_by_id) == set(ISLANDS), "campaign island inventory differs from R04 families"
    shared_geometry = None
    duplicate_allowlist: dict[str, set[str]] = {}
    surface_count = 0
    for island_id in ISLANDS:
        base = ISLAND_ROOT / island_id
        present = {path.relative_to(base).as_posix() for path in base.rglob("*.png")}
        assert present == RETAINED_ISLAND_IMAGES, f"retired or missing island art: {island_id}: {sorted(present)}"
        source = base / "gameplay_surface_v07_r04.png"
        runtime = base / "gameplay_surface.png"
        profile_path = base / "playable_geometry_r04.json"
        profile = json.loads(profile_path.read_text(encoding="utf-8"))
        source_hash = digest(source)
        runtime_hash = digest(runtime)
        assert source_hash == runtime_hash, f"runtime image is not byte-identical to R04 source: {island_id}"
        with Image.open(source) as image:
            assert image.size == (720, 1280) and image.mode == "RGB", f"R04 source format: {island_id}"
        assert profile["island_id"] == island_id and profile["schema_version"] == 1
        assert profile["surface_path"] == f"res://assets/ui_assets/campaign/islands/{island_id}/gameplay_surface.png"
        assert profile["surface_sha256"] == runtime_hash
        assert profile["r04_source_sha256"] == source_hash
        assert profile["r04_source_path"] == f"assets/ui_assets/campaign/islands/{island_id}/gameplay_surface_v07_r04.png"
        geometry = profile["geometry"]
        assert set(("playable_polygon", "launch_y", "spawn_y", "death_y", "surface_sha256")) <= set(geometry)
        assert geometry["surface_sha256"] == runtime_hash
        signature = {key: value for key, value in geometry.items() if key != "surface_sha256"}
        if shared_geometry is None:
            shared_geometry = signature
        else:
            assert signature == shared_geometry, f"gameplay boundary drift: {island_id}"
        theme = campaign_by_id[island_id]["theme"]
        assert theme["gameplay_surface"] == profile["surface_path"]
        assert theme["playable_geometry_profile"] == f"res://assets/ui_assets/campaign/islands/{island_id}/playable_geometry_r04.json"
        assert campaign_by_id[island_id]["playable_geometry_profile"] == theme["playable_geometry_profile"]
        assert "playable_geometry" not in campaign_by_id[island_id]
        assert "island_map_background" in theme

        evidence = ROOT / profile["debug_overlay_path"]
        assert evidence.is_file() and digest(evidence) == profile["debug_overlay_sha256"], f"debug evidence identity: {island_id}"
        fit_evidence = ROOT / profile["cocktail_fit_proof_path"]
        assert fit_evidence.is_file() and digest(fit_evidence) == profile["cocktail_fit_proof_sha256"], f"cocktail fit evidence identity: {island_id}"
        shadow_evidence = ROOT / profile["embedded_shadow_identity_proof_path"]
        assert shadow_evidence.is_file() and digest(shadow_evidence) == profile["embedded_shadow_identity_proof_sha256"], f"embedded shadow identity evidence: {island_id}"
        assert profile["embedded_table_shadow"]["separate_shadow_asset"] is False
        assert profile["embedded_table_shadow"]["surface_sha256"] == runtime_hash
        with Image.open(runtime) as source_image, Image.open(evidence) as debug_image:
            assert source_image.size == debug_image.size == (720, 1280), f"debug evidence canvas: {island_id}"
            assert ImageChops.difference(source_image.convert("RGB"), debug_image.convert("RGB")).getbbox() is not None, f"debug overlay is empty: {island_id}"
        with Image.open(runtime) as source_image, Image.open(fit_evidence) as fit_image:
            assert source_image.size == fit_image.size == (720, 1280), f"cocktail fit canvas: {island_id}"
            assert ImageChops.difference(source_image.convert("RGB"), fit_image.convert("RGB")).getbbox() is not None, f"cocktail fit overlay is empty: {island_id}"
        with Image.open(runtime) as source_image, Image.open(shadow_evidence) as shadow_image:
            assert source_image.size == shadow_image.size == (720, 1280), f"embedded shadow identity canvas: {island_id}"
            assert ImageChops.difference(source_image.convert("RGB"), shadow_image.convert("RGB")).getbbox() is not None, f"embedded shadow proof overlay is empty: {island_id}"

        source_rel = source.relative_to(ROOT).as_posix()
        runtime_rel = runtime.relative_to(ROOT).as_posix()
        duplicate_allowlist.setdefault(runtime_hash, set()).update({source_rel, runtime_rel})
        surface_count += 1

    groups: dict[str, list[str]] = {}
    for item in assets:
        groups.setdefault(item["sha256"], []).append(item["path"])
    invalid_groups = []
    intentional_groups = 0
    for sha, paths in groups.items():
        if len(paths) < 2:
            continue
        if set(paths) == duplicate_allowlist.get(sha, set()) and len(paths) == 2:
            intentional_groups += 1
        else:
            invalid_groups.append({"sha256": sha, "paths": paths})
    assert not invalid_groups, f"unexpected semantic duplicate PNGs: {invalid_groups}"
    report = {
        "authority": "GAMEPLAY_SURFACE_V07_R04",
        "manifest_count": len(assets),
        "island_surface_count": surface_count,
        "intentional_source_runtime_duplicate_groups": intentional_groups,
        "invalid_semantic_duplicate_count": 0,
    }
    (OUT / "SEMANTIC_DUPLICATE_REPORT.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"PASS manifest-checksums: {len(assets)}/{len(assets)} current PNGs")
    print(f"PASS R04-surface-authority: {surface_count}/10 per-island source/runtime/profile/evidence families")
    print(f"PASS retired-island-gameplay-art: absent from all {len(ISLANDS)} island packs")
    print(f"PASS semantic-duplicates: {intentional_groups} source/runtime identity groups; invalid=0")


if __name__ == "__main__":
    main()
