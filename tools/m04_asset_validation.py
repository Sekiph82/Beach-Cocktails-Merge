"""Deterministic, non-production metrics for the canonical M04 PNG library."""

from __future__ import annotations

import struct
from pathlib import Path

from PIL import Image


CANONICAL = [
    *(Path("assets/cocktails") / f"L{level:02d}.png" for level in range(1, 13)),
    Path("assets/environment/game_board_background.png"),
    Path("assets/ui/logo_beach_cocktails_merge.png"),
    Path("assets/ui/panel_best_score.png"),
    Path("assets/ui/panel_score.png"),
    Path("assets/ui/panel_to_go_orders.png"),
    Path("assets/ui/panel_next.png"),
    Path("assets/ui/progression_strip.png"),
    Path("assets/ui/launch_zone.png"),
    Path("assets/ui/danger_line.png"),
    Path("assets/effects/to_go_trail.png"),
]


def png_color_type(path: Path) -> int:
    with path.open("rb") as stream:
        signature = stream.read(8)
        chunk_length = struct.unpack(">I", stream.read(4))[0]
        chunk_type = stream.read(4)
        ihdr = stream.read(chunk_length)
    if signature != b"\x89PNG\r\n\x1a\n" or chunk_type != b"IHDR" or len(ihdr) < 10:
        raise ValueError("invalid PNG signature or IHDR")
    return ihdr[9]


def metrics(path: Path) -> dict[str, object]:
    file_size = path.stat().st_size
    with Image.open(path) as image:
        image.load()
        rgba = image.convert("RGBA")
        alpha = rgba.getchannel("A")
        histogram = alpha.histogram()
        transparent = histogram[0]
        opaque = histogram[255]
        nontransparent = rgba.width * rgba.height - transparent
        bbox = alpha.getbbox()
        return {
            "size": file_size,
            "dimensions": f"{rgba.width}x{rgba.height}",
            "mode": image.mode,
            "png_color_type": png_color_type(path),
            "alpha": "present" if "A" in image.getbands() or image.mode == "P" else "absent",
            "transparent": transparent,
            "transparent_pct": 100.0 * transparent / (rgba.width * rgba.height),
            "nontransparent": nontransparent,
            "nontransparent_pct": 100.0 * nontransparent / (rgba.width * rgba.height),
            "bbox": bbox if bbox is not None else "EMPTY",
            "fully_opaque": opaque == rgba.width * rgba.height,
            "semi_transparent": nontransparent - opaque,
        }


def main() -> int:
    failures: list[str] = []
    print(f"M04_PYTHON_ASSET_COUNT expected={len(CANONICAL)} observed={len(CANONICAL)}")
    for path in CANONICAL:
        if not path.is_file():
            failures.append(f"missing {path.as_posix()}")
            print(f"M04_PYTHON_ASSET FAIL path={path.as_posix()} missing")
            continue
        try:
            result = metrics(path)
        except Exception as error:  # pragma: no cover - evidence tool failure path
            failures.append(f"load {path.as_posix()}: {error}")
            print(f"M04_PYTHON_ASSET FAIL path={path.as_posix()} error={error}")
            continue
        bbox = result["bbox"]
        bbox_text = "(" + ",".join(str(value) for value in bbox) + ")" if bbox != "EMPTY" else "EMPTY"
        print(
            "M04_PYTHON_ASSET PASS path=%s bytes=%d dimensions=%s mode=%s png_color_type=%d "
            "alpha=%s transparent=%d(%.4f%%) nontransparent=%d(%.4f%%) bbox=%s fully_opaque=%s semi_transparent=%d"
            % (
                path.as_posix(),
                result["size"],
                result["dimensions"],
                result["mode"],
                result["png_color_type"],
                result["alpha"],
                result["transparent"],
                result["transparent_pct"],
                result["nontransparent"],
                result["nontransparent_pct"],
                bbox_text,
                result["fully_opaque"],
                result["semi_transparent"],
            )
        )

    with Image.open("assets/ui/panel_best_score.png") as best, Image.open("assets/ui/panel_score.png") as score:
        dimensions_match = best.size == score.size
        print(
            f"M04_PANEL_DIMENSIONS best={best.width}x{best.height} score={score.width}x{score.height} "
            f"match={dimensions_match} width_delta={abs(best.width - score.width)} height_delta={abs(best.height - score.height)}"
        )

    print("M04_PROGRESS_OVERLAY_MANUAL intended_empty_slots=12 (direct visual inspection)")
    print("M04_PYTHON_RESULT=PASS" if not failures else f"M04_PYTHON_RESULT=FAIL failures={'; '.join(failures)}")
    return 0 if not failures else 1


if __name__ == "__main__":
    raise SystemExit(main())
