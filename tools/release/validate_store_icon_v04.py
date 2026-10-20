"""Validate V04 icon dimensions, size limit, source parity, and provenance hashes."""

from __future__ import annotations

import hashlib
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
MASTER = ROOT / "docs/release/store_media/icons_v04/beach_cocktails_merge_icon_master_v04.png"
PLAY = ROOT / "docs/release/store_media/icons_v04/google_play_icon_candidate_512_v04.png"
RUNTIME = ROOT / "assets/ui_assets/brand/beach_cocktails_merge_icon_v04.png"
SOURCES = [
    ROOT / "assets/ui_assets/campaign/world_map/world_map_ocean_background_owner_v02.png",
    ROOT / "assets/ui_assets/brand/logo_concept_v03.png",
    ROOT / "assets/cocktails/L01.png",
]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inspect_png(path: Path, size: tuple[int, int]) -> None:
    with Image.open(path) as image:
        if image.format != "PNG" or image.size != size or image.mode not in {"RGB", "RGBA"}:
            raise SystemExit(f"FAIL invalid PNG metadata: {path.relative_to(ROOT)} {image.format} {image.size} {image.mode}")
    print(f"PASS {path.relative_to(ROOT)} {size[0]}x{size[1]} {path.stat().st_size} bytes sha256={sha256(path)}")


def main() -> None:
    inspect_png(MASTER, (1024, 1024))
    inspect_png(PLAY, (512, 512))
    inspect_png(RUNTIME, (1024, 1024))
    if PLAY.stat().st_size > 1_048_576:
        raise SystemExit("FAIL Google Play PNG exceeds 1 MiB")
    if MASTER.read_bytes() != RUNTIME.read_bytes():
        raise SystemExit("FAIL runtime icon differs from review master")
    for source in SOURCES:
        print(f"SOURCE {source.relative_to(ROOT)} sha256={sha256(source)}")
    print("ICON_VALIDATION=PASS owner_visual_review=REQUIRED")


if __name__ == "__main__":
    main()
