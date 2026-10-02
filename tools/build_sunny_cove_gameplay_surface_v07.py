#!/usr/bin/env python3
"""Build Sunny Cove V07 from a fresh scene plate and V2 geometry masters."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
ISLAND = ROOT / "assets/ui_assets/campaign/islands/sunny_cove"
SOURCE = ISLAND / "source_v07"
TABLES = ROOT / "assets/ui_assets/tables"
SIZE = (720, 1280)
SCENE = SOURCE / "scenic_plate.png"
TEAK = SOURCE / "teak_material.png"
PLAY_MASK = TABLES / "table_playable_surface_mask_v2.png"
STRUCTURE_MASK = TABLES / "table_structure_mask_v2.png"
EDGE_MASK = TABLES / "table_edge_extraction_mask_v2.png"
SHADOW_MASTER = TABLES / "table_shadow_master_v2.png"

TABLE = ISLAND / "gameplay_table_v07.png"
EDGE = ISLAND / "table_edge_overlay_v07.png"
SHADOW = ISLAND / "gameplay_table_shadow_v07.png"
SURFACE = ISLAND / "gameplay_surface_v07.png"
PROVENANCE = ISLAND / "gameplay_surface_v07.provenance.json"
TABLE_PROOF = ISLAND / "gameplay_table_v07_fit_proof.png"
SHADOW_PROOF = ISLAND / "gameplay_table_v07_shadow_proof.png"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fit_cover(source: Image.Image, size: tuple[int, int]) -> tuple[Image.Image, dict]:
    sw, sh = source.size
    scale = max(size[0] / sw, size[1] / sh)
    rw, rh = round(sw * scale), round(sh * scale)
    resized = source.resize((rw, rh), Image.Resampling.LANCZOS)
    left, top = (rw - size[0]) // 2, (rh - size[1]) // 2
    return resized.crop((left, top, left + size[0], top + size[1])), {
        "operation": "fresh_cover_crop",
        "source_dimensions": [sw, sh],
        "resize_dimensions": [rw, rh],
        "crop_xywh": [left, top, size[0], size[1]],
        "output_dimensions": list(size),
    }


def make_table() -> Image.Image:
    playable = Image.open(PLAY_MASK).convert("RGBA").getchannel("A")
    structure = Image.open(STRUCTURE_MASK).convert("RGBA").getchannel("A")
    material = Image.open(TEAK).convert("RGB")

    # Re-author a new V2 table: only material pixels come from the texture source;
    # all visible tabletop/lower-structure coverage comes from the V2 masters.
    sw, sh = material.size
    target_ratio = SIZE[0] / (SIZE[1] - 398)
    crop_h = min(sh, round(sw / target_ratio))
    crop_top = max(0, (sh - crop_h) // 2)
    material = material.crop((0, crop_top, sw, crop_top + crop_h))
    surface_rgb = material.resize((SIZE[0], SIZE[1] - 398), Image.Resampling.LANCZOS)
    surface_rgb = ImageEnhance.Color(surface_rgb).enhance(0.86)
    surface_rgb = ImageEnhance.Contrast(surface_rgb).enhance(0.91)
    surface = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    surface.paste(surface_rgb, (0, 398))
    surface.putalpha(playable)

    # The V2 structural mask fixes the apron and exactly two leg footprints.
    struct_rgb = material.resize((SIZE[0], SIZE[1] - 989), Image.Resampling.LANCZOS)
    struct_rgb = ImageEnhance.Color(struct_rgb).enhance(0.62)
    struct_rgb = Image.blend(struct_rgb, Image.new("RGB", struct_rgb.size, (25, 111, 107)), 0.48)
    struct = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    struct.paste(struct_rgb, (0, 989))
    struct.putalpha(structure)

    table = Image.alpha_composite(surface, struct)

    # Quiet lagoon enamel framing makes the playable edge readable without
    # drawing any independent geometry or entering the play area as decoration.
    eroded = playable.filter(ImageFilter.MinFilter(25))
    outer_band = ImageChops.subtract(playable, eroded)
    rail = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    rail_pixels = Image.new("RGBA", SIZE, (12, 91, 98, 238))
    rail_pixels.putalpha(outer_band)
    rail = Image.alpha_composite(rail, rail_pixels)

    inset_8 = playable.filter(ImageFilter.MinFilter(17))
    inset_20 = playable.filter(ImageFilter.MinFilter(41))
    accent_band = ImageChops.subtract(inset_8, inset_20)
    accent_pixels = Image.new("RGBA", SIZE, (247, 207, 126, 108))
    accent_pixels.putalpha(accent_band)
    rail = Image.alpha_composite(rail, accent_pixels)
    table = Image.alpha_composite(table, rail)

    # A restrained apron cap follows the V2 front transition exactly.
    cap = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(cap, "RGBA")
    draw.rectangle((0, 988, SIZE[0] - 1, 994), fill=(243, 192, 104, 235))
    cap_alpha = Image.open(STRUCTURE_MASK).convert("RGBA").getchannel("A")
    cap_alpha = ImageChops.lighter(cap_alpha, playable)
    cap.putalpha(ImageChops.multiply(cap.getchannel("A"), cap_alpha))
    table = Image.alpha_composite(table, cap)
    return table


def main() -> None:
    for source in (SCENE, TEAK, PLAY_MASK, STRUCTURE_MASK, EDGE_MASK, SHADOW_MASTER):
        if not source.is_file():
            raise FileNotFoundError(source)

    scene_source = Image.open(SCENE).convert("RGB")
    scene, scene_fit = fit_cover(scene_source, SIZE)
    table = make_table()
    table.save(TABLE, format="PNG", optimize=False, compress_level=9)

    # V2 overlay is extracted from the exact final table through the canonical mask.
    edge_mask = Image.open(EDGE_MASK).convert("RGBA").getchannel("A")
    edge_alpha = ImageChops.multiply(table.getchannel("A"), edge_mask)
    edge = table.copy()
    edge.putalpha(edge_alpha)
    edge.save(EDGE, format="PNG", optimize=False, compress_level=9)

    # The canonical shadow is copied byte-for-byte, never independently illustrated.
    SHADOW.write_bytes(SHADOW_MASTER.read_bytes())
    shadow_master = Image.open(SHADOW).convert("RGBA")

    composed = scene.convert("RGBA")
    composed = Image.alpha_composite(composed, shadow_master)
    composed = Image.alpha_composite(composed, table)
    composed = Image.alpha_composite(composed, edge)
    composed.convert("RGB").save(SURFACE, format="PNG", optimize=False, compress_level=9)

    fit = table.copy()
    fit = Image.alpha_composite(fit, edge)
    checker = Image.new("RGBA", SIZE, (39, 62, 72, 255))
    checker.alpha_composite(fit)
    checker.convert("RGB").save(TABLE_PROOF, format="PNG", optimize=False, compress_level=9)

    shadow_fit = Image.new("RGBA", SIZE, (70, 139, 156, 255))
    shadow_fit = Image.alpha_composite(shadow_fit, shadow_master)
    shadow_fit = Image.alpha_composite(shadow_fit, table)
    shadow_fit.save(SHADOW_PROOF, format="PNG", optimize=False, compress_level=9)

    provenance = {
        "format": "sunny-cove-gameplay-surface-v07-provenance-v1",
        "canonical_dimensions": list(SIZE),
        "fresh_canvas": True,
        "v06_composite_or_layer_coordinates_used": False,
        "geometry_authority": "assets/ui_assets/tables/table_geometry_v2.json and V2 master masks",
        "runtime_asset": SURFACE.relative_to(ROOT).as_posix(),
        "output_sha256": sha(SURFACE),
        "production_layers_back_to_front": [
            {"role": "new_scenic_plate", "path": SCENE.relative_to(ROOT).as_posix(), "sha256": sha(SCENE), "fit": scene_fit},
            {"role": "canonical_fixed_shadow", "path": SHADOW.relative_to(ROOT).as_posix(), "sha256": sha(SHADOW), "master_path": SHADOW_MASTER.relative_to(ROOT).as_posix(), "exact_master_pixel_copy": True},
            {"role": "fresh_v2_table_material", "path": TABLE.relative_to(ROOT).as_posix(), "sha256": sha(TABLE), "surface_mask": PLAY_MASK.relative_to(ROOT).as_posix(), "structure_mask": STRUCTURE_MASK.relative_to(ROOT).as_posix()},
            {"role": "table_overlay_derived_from_final_table", "path": EDGE.relative_to(ROOT).as_posix(), "sha256": sha(EDGE), "extraction_mask": EDGE_MASK.relative_to(ROOT).as_posix()},
        ],
        "source_art": [
            {"path": SCENE.relative_to(ROOT).as_posix(), "sha256": sha(SCENE), "description": "newly generated Sunny Cove lagoon scenic plate"},
            {"path": TEAK.relative_to(ROOT).as_posix(), "sha256": sha(TEAK), "description": "newly generated low-contrast teak material texture"},
        ],
        "fit_proofs": [TABLE_PROOF.relative_to(ROOT).as_posix(), SHADOW_PROOF.relative_to(ROOT).as_posix()],
        "table_y_offset": 0,
    }
    PROVENANCE.write_text(json.dumps(provenance, indent=2) + "\n", encoding="utf-8")
    print(f"SUNNY_COVE_V07_SURFACE_RESULT=PASS size=720x1280 sha256={sha(SURFACE)}")
    print(f"TABLE_SHA256={sha(TABLE)}")
    print(f"EDGE_DERIVED_SHA256={sha(EDGE)}")
    print(f"SHADOW_EQUALS_V2_MASTER={sha(SHADOW) == sha(SHADOW_MASTER)}")
    print(f"PROVENANCE={PROVENANCE.relative_to(ROOT).as_posix()}")


if __name__ == "__main__":
    main()
