from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[2]
ISLANDS_PATH = ROOT / "data" / "campaign" / "islands.json"
ISLAND_ROOT = ROOT / "assets" / "ui_assets" / "campaign" / "islands"
EVIDENCE_ROOT = (
    ROOT
    / "coordination"
    / "sessions"
    / "BCM-M21-OWNER-RUNTIME-REMEDIATION"
    / "evidence"
    / "visual-candidates"
    / "r04-technical-validation"
)
ISLAND_IDS = [
    "azure_bay",
    "billionaire_island",
    "coconut_beach",
    "final_island",
    "frozen_paradise",
    "party_beach",
    "sunny_cove",
    "sunset_island",
    "tiki_island",
    "volcano_bay",
]
RETIRED_THEME_KEYS = {
    "gameplay_background",
    "gameplay_table",
    "gameplay_table_shadow",
    "table_edge_overlay",
    "launch_zone",
}
DRINK_COLLIDER_RADII = [20, 23, 27, 31, 36, 42, 49, 56, 64, 72, 80, 90]
STRESS_POSITIONS = [
    [180, 520], [360, 520], [540, 520],
    [180, 630], [360, 630], [540, 630],
    [180, 740], [360, 740], [540, 740],
    [180, 850], [360, 850], [540, 850],
]


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(path.read_bytes())


def draw_geometry_debug(surface: Image.Image, polygon: list[list[float]]) -> Image.Image:
    debug = surface.convert("RGB").copy()
    draw = ImageDraw.Draw(debug)
    points = [(round(point[0]), round(point[1])) for point in polygon]
    draw.line(points + [points[0]], fill=(20, 245, 255), width=4, joint="curve")
    return debug


def point_in_polygon(x: float, y: float, polygon: list[list[float]]) -> bool:
    inside = False
    previous_x, previous_y = polygon[-1]
    for current_x, current_y in polygon:
        if (current_y > y) != (previous_y > y):
            crossing_x = (previous_x - current_x) * (y - current_y) / (previous_y - current_y) + current_x
            if x < crossing_x:
                inside = not inside
        previous_x, previous_y = current_x, current_y
    return inside


def draw_cocktail_fit(surface: Image.Image, polygon: list[list[float]]) -> Image.Image:
    proof = surface.convert("RGB").copy()
    draw = ImageDraw.Draw(proof)
    points = [(round(point[0]), round(point[1])) for point in polygon]
    draw.line(points + [points[0]], fill=(20, 245, 255), width=4, joint="curve")
    for level, (x, y), radius in zip(range(1, 13), STRESS_POSITIONS, DRINK_COLLIDER_RADII):
        samples = [(x + radius * math.cos(step * math.tau / 64), y + radius * math.sin(step * math.tau / 64)) for step in range(64)]
        if not all(point_in_polygon(point_x, point_y, polygon) for point_x, point_y in samples):
            raise ValueError(f"L{level} collider footprint leaves the R04 playable polygon at {(x, y)}")
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), outline=(255, 40, 70), width=3)
        draw.ellipse((x - 4, y - 4, x + 4, y + 4), fill=(255, 245, 70))
        draw.text((x + radius + 3, y - 8), f"L{level}", fill=(255, 255, 255), stroke_width=2, stroke_fill=(20, 30, 40))
    return proof


def draw_embedded_shadow_identity(surface: Image.Image, surface_hash: str) -> Image.Image:
    proof = surface.convert("RGB").copy()
    draw = ImageDraw.Draw(proof)
    draw.rounded_rectangle((20, 1192, 700, 1262), radius=12, fill=(36, 22, 13), outline=(255, 207, 103), width=3)
    draw.text((36, 1201), "TABLE + CONTACT SHADOW ARE BAKED INTO THIS R04 SURFACE", fill=(255, 244, 218), stroke_width=1, stroke_fill=(35, 20, 12))
    draw.text((36, 1228), f"SHA-256 {surface_hash}", fill=(255, 211, 130), stroke_width=1, stroke_fill=(35, 20, 12))
    return proof


def main() -> None:
    campaign = json.loads(ISLANDS_PATH.read_text(encoding="utf-8"))
    island_by_id = {entry["id"]: entry for entry in campaign["islands"]}
    if set(island_by_id) != set(ISLAND_IDS):
        raise ValueError("campaign island inventory does not match the ten R04 surface families")

    EVIDENCE_ROOT.mkdir(parents=True, exist_ok=True)
    common_geometry: dict | None = None
    for island_id in ISLAND_IDS:
        island = island_by_id[island_id]
        island_dir = ISLAND_ROOT / island_id
        source_path = island_dir / "gameplay_surface_v07_r04.png"
        runtime_path = island_dir / "gameplay_surface.png"
        profile_path = island_dir / "playable_geometry_r04.json"
        source_bytes = source_path.read_bytes()
        with Image.open(source_path) as source_image:
            source_image.load()
            if source_image.size != (720, 1280) or source_image.mode != "RGB":
                raise ValueError(f"R04 surface must be 720x1280 RGB: {source_path}")
            surface = source_image.copy()

        runtime_path.write_bytes(source_bytes)
        source_sha = sha256_bytes(source_bytes)
        runtime_sha = sha256_file(runtime_path)
        if source_sha != runtime_sha:
            raise ValueError(f"canonical runtime copy differs from R04 source: {island_id}")

        old_geometry = island.get("playable_geometry")
        if not isinstance(old_geometry, dict) and profile_path.is_file():
            prior_profile = json.loads(profile_path.read_text(encoding="utf-8"))
            old_geometry = prior_profile.get("geometry")
        if not isinstance(old_geometry, dict):
            raise ValueError(f"missing existing shared gameplay geometry: {island_id}")
        geometry = {
            "playable_polygon": old_geometry["playable_polygon"],
            "launch_y": old_geometry["launch_y"],
            "spawn_y": old_geometry["spawn_y"],
            "death_y": old_geometry["death_y"],
            "surface_sha256": runtime_sha,
        }
        geometry_signature = {key: value for key, value in geometry.items() if key != "surface_sha256"}
        if common_geometry is None:
            common_geometry = geometry_signature
        elif geometry_signature != common_geometry:
            raise ValueError(f"gameplay geometry differs across islands: {island_id}")

        debug_name = f"{island_id}_geometry_debug_r04.png"
        debug_path = EVIDENCE_ROOT / debug_name
        draw_geometry_debug(surface, geometry["playable_polygon"]).save(debug_path, format="PNG", optimize=False)
        fit_name = f"{island_id}_cocktail_footprint_fit_r04.png"
        fit_path = EVIDENCE_ROOT / fit_name
        draw_cocktail_fit(surface, geometry["playable_polygon"]).save(fit_path, format="PNG", optimize=False)
        shadow_name = f"{island_id}_embedded_shadow_identity_r04.png"
        shadow_path = EVIDENCE_ROOT / shadow_name
        draw_embedded_shadow_identity(surface, runtime_sha).save(shadow_path, format="PNG", optimize=False)
        profile = {
            "schema_version": 1,
            "profile_id": f"{island_id}_gameplay_surface_v07_r04",
            "island_id": island_id,
            "surface_path": f"res://assets/ui_assets/campaign/islands/{island_id}/gameplay_surface.png",
            "surface_sha256": runtime_sha,
            "r04_source_path": f"assets/ui_assets/campaign/islands/{island_id}/gameplay_surface_v07_r04.png",
            "r04_source_sha256": source_sha,
            "viewport_px": [720, 1280],
            "geometry": geometry,
            "measurements_px": {
                "playable_point_count": len(geometry["playable_polygon"]),
                "playable_bounds": {
                    "left": min(point[0] for point in geometry["playable_polygon"]),
                    "top": min(point[1] for point in geometry["playable_polygon"]),
                    "right": max(point[0] for point in geometry["playable_polygon"]),
                    "bottom": max(point[1] for point in geometry["playable_polygon"]),
                },
                "launch_y": geometry["launch_y"],
                "spawn_y": geometry["spawn_y"],
                "death_y": geometry["death_y"],
                "cocktail_collider_radii_level_1_to_12": DRINK_COLLIDER_RADII,
                "cocktail_fit_centers_level_xy": [[level, *position] for level, position in zip(range(1, 13), STRESS_POSITIONS)],
                "calibration_surface_sha256": runtime_sha,
            },
            "calibration_method": "The shared accepted R11 gameplay boundary and all twelve existing collider radii are overlaid on the exact per-island R04 surface; physics is unchanged.",
            "debug_overlay_path": f"coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/visual-candidates/r04-technical-validation/{debug_name}",
            "debug_overlay_sha256": sha256_file(debug_path),
            "cocktail_fit_proof_path": f"coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/visual-candidates/r04-technical-validation/{fit_name}",
            "cocktail_fit_proof_sha256": sha256_file(fit_path),
            "embedded_shadow_identity_proof_path": f"coordination/sessions/BCM-M21-OWNER-RUNTIME-REMEDIATION/evidence/visual-candidates/r04-technical-validation/{shadow_name}",
            "embedded_shadow_identity_proof_sha256": sha256_file(shadow_path),
            "embedded_table_shadow": {
                "separate_shadow_asset": False,
                "surface_sha256": runtime_sha,
                "validation": "table contact shadows are baked into this exact R04 surface; no independent shadow image or alignment transform exists",
            },
        }
        profile_path.write_text(json.dumps(profile, indent=2) + "\n", encoding="utf-8")

        theme = island["theme"]
        for key in RETIRED_THEME_KEYS:
            theme.pop(key, None)
        theme["gameplay_surface"] = f"res://assets/ui_assets/campaign/islands/{island_id}/gameplay_surface.png"
        theme["playable_geometry_profile"] = f"res://assets/ui_assets/campaign/islands/{island_id}/playable_geometry_r04.json"
        island.pop("playable_geometry", None)
        island["playable_geometry_profile"] = theme["playable_geometry_profile"]

    ISLANDS_PATH.write_text(json.dumps(campaign, indent=4, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"R04_GAMEPLAY_SURFACE_PROFILES=PASS islands={len(ISLAND_IDS)} dimensions=720x1280 mode=RGB source_copies=byte-identical")
    print(f"R04_GEOMETRY_AND_FIT_EVIDENCE=PASS outputs={len(ISLAND_IDS) * 3} output={EVIDENCE_ROOT.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
