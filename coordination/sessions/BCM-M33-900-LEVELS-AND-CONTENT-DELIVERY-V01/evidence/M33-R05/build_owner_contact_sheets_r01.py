#!/usr/bin/env python3
"""Build owner-review pair images and overview galleries from the 38 active R05 captures."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[5]
EVIDENCE = ROOT / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R05"
MANIFEST = EVIDENCE / "screenshots/capture_manifest.json"
OUT = EVIDENCE / "owner_visual_contact_sheets_r01"
ISLAND_ORDER = [
    "tiki_island", "azure_bay", "coconut_beach", "sunset_island", "party_beach",
    "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]
ISLAND_LABELS = {x: x.replace("_", " ").title() for x in ISLAND_ORDER}
FONT = Path("C:/Windows/Fonts/arial.ttf")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT), size=size)


def capture_index(manifest: dict) -> dict[tuple[str, int, str], dict]:
    captures = manifest["captures"]
    assert len(captures) == 38, len(captures)
    assert len(manifest["superseded_artifacts"]) == 9
    active_paths = {item["path"] for item in captures}
    old_paths = {item["path"] for item in manifest["superseded_artifacts"]}
    assert not active_paths & old_paths
    index = {}
    for item in captures:
        path = ROOT / item["path"]
        assert path.is_file(), path
        assert sha256(path) == item["sha256"], path
        viewport = "x".join(str(v) for v in item["viewport"])
        key = (viewport, item["island_id"], item["kind"])
        if key in index:
            raise AssertionError(f"Duplicate active capture key {key}")
        index[key] = item
    return index


def source_level(island: str, level_id: int) -> dict:
    filename = "tiki_island_full.json" if island == "tiki_island" else f"{island}.json"
    payload = json.loads((ROOT / "data/campaign/levels" / filename).read_text(encoding="utf-8"))
    matches = [row for row in payload["levels"] if row["level_id"] == level_id]
    assert len(matches) == 1, (island, level_id, len(matches))
    return matches[0]


def label(draw: ImageDraw.ImageDraw, xy, text: str, fnt, color=(20, 40, 50)):
    draw.text(xy, text, font=fnt, fill=color)


def make_pair(viewport: str, island: str, empty: dict, populated: dict) -> Path:
    width, height = map(int, viewport.split("x"))
    gap, pad, head_h, cap_h = 24, 20, 76, 54
    canvas = Image.new("RGB", (pad * 2 + width * 2 + gap, pad * 2 + head_h + height + cap_h), "#f3f7f8")
    draw = ImageDraw.Draw(canvas)
    label(draw, (pad, pad + 3), f"{ISLAND_LABELS[island]}  |  {viewport}", font(36))
    label(draw, (pad, pad + 46), "EMPTY opening  vs  POPULATED opening — original frames, full size", font(19), (55, 77, 85))
    y = pad + head_h
    left_x, right_x = pad, pad + width + gap
    left_path, right_path = ROOT / empty["path"], ROOT / populated["path"]
    with Image.open(left_path) as src:
        assert src.size == (width, height), (left_path, src.size)
        canvas.paste(src.convert("RGB"), (left_x, y))
    with Image.open(right_path) as src:
        assert src.size == (width, height), (right_path, src.size)
        canvas.paste(src.convert("RGB"), (right_x, y))
    cap_y = y + height + 10
    label(draw, (left_x + 8, cap_y), f"EMPTY  •  L{empty['level_id']:03d}", font(21))
    label(draw, (right_x + 8, cap_y), f"POPULATED  •  L{populated['level_id']:03d}", font(21))
    out = OUT / "pairs" / viewport / f"{island}.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out, optimize=True)
    return out


def make_tiki_contrast(viewport: str, one: dict, two: dict) -> Path:
    width, height = map(int, viewport.split("x"))
    gap, pad, head_h, cap_h = 24, 20, 86, 62
    canvas = Image.new("RGB", (pad * 2 + width * 2 + gap, pad * 2 + head_h + height + cap_h), "#f3f7f8")
    draw = ImageDraw.Draw(canvas)
    label(draw, (pad, pad + 3), f"Tiki Island  |  one-starter / two-starter contrast  |  {viewport}", font(30))
    label(draw, (pad, pad + 48), "Two different representative levels; compare visible tabletop density only.", font(18), (55, 77, 85))
    y = pad + head_h
    for x, item in ((pad, one), (pad + width + gap, two)):
        with Image.open(ROOT / item["path"]) as src:
            assert src.size == (width, height)
            canvas.paste(src.convert("RGB"), (x, y))
    cap_y = y + height + 10
    label(draw, (pad + 8, cap_y), f"ONE STARTER  •  L{one['level_id']:03d}", font(21))
    label(draw, (pad + width + gap + 8, cap_y), f"TWO STARTERS  •  L{two['level_id']:03d}", font(21))
    out = OUT / "tiki_contrast" / f"tiki_{viewport}.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out, optimize=True)
    return out


def make_overview(viewport: str, pairs: list[tuple[str, Path]]) -> Path:
    # The pair PNGs remain full resolution. Only this gallery preview is reduced to fit a 3x3 grid.
    cols, card_w, gap, pad = 3, 560, 24, 26
    head_h = 78
    thumbs = []
    for island, path in pairs:
        with Image.open(path) as src:
            new_h = round(src.height * card_w / src.width)
            thumbs.append((island, src.convert("RGB").resize((card_w, new_h), Image.Resampling.LANCZOS)))
    card_h = max(im.height for _, im in thumbs)
    rows = (len(thumbs) + cols - 1) // cols
    canvas = Image.new("RGB", (pad * 2 + cols * card_w + (cols - 1) * gap,
                               pad * 2 + head_h + rows * (card_h + 50) + (rows - 1) * gap), "#eaf1f3")
    draw = ImageDraw.Draw(canvas)
    label(draw, (pad, pad + 2), f"M33 R05 • Nine-island tabletop gallery • {viewport}", font(36))
    label(draw, (pad, pad + 48), "Each card pairs the empty opening with its populated opening. Full-size uncropped pair files are linked in the README.", font(20), (55, 77, 85))
    y0 = pad + head_h
    for i, (island, thumb) in enumerate(thumbs):
        col, row = i % cols, i // cols
        x = pad + col * (card_w + gap)
        y = y0 + row * (card_h + 50 + gap)
        label(draw, (x + 4, y), ISLAND_LABELS[island], font(26))
        canvas.paste(thumb, (x, y + 38))
    out = OUT / f"nine_island_gallery_{viewport}.png"
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out, optimize=True)
    return out


def describe_level(island: str, item: dict) -> str:
    row = source_level(island, item["level_id"])
    orders = ", ".join(f"L{o['cocktail_level']} × {o['quantity']}" for o in row.get("orders", [])) or "none"
    vip = row.get("vip")
    vip_text = "none" if not vip else f"L{vip.get('cocktail_level')} × {vip.get('quantity', 1)}"
    normal_t = row.get("theoretical_shots_total", "not recorded")
    starters = row.get("initial_tabletop_drinks", [])
    if not starters:
        starter_text = "None (empty opening)"
    else:
        entries = []
        for starter in starters:
            level = starter["cocktail_level"]
            pos = starter["position"]
            if any(o["cocktail_level"] == level for o in row.get("orders", [])):
                relation = "direct order stock"
            elif any(o["cocktail_level"] == level + 1 for o in row.get("orders", [])):
                relation = "one-level merge precursor"
            else:
                relation = "not directly matching listed normal orders"
            entries.append(f"L{level} at ({pos[0]:.2f}, {pos[1]:.2f}) — {relation}")
        starter_text = "; ".join(entries)
    return (f"L{item['level_id']:03d}: To-Go {orders}; VIP {vip_text}; normal T {normal_t}; "
            f"starter: {starter_text}.")


def build_readme_section(index: dict, pairs: dict[tuple[str, str], Path], galleries: dict[str, Path], tiki: dict[str, Path]) -> str:
    lines = [
        "## Owner visual contact sheets — R05-R01",
        "",
        "Status: `AWAITING_GPT_AND_OWNER_M33_R05_VISUAL_REVIEW`. These are review aids built only from the 38 active original PNGs in `screenshots/capture_manifest.json`. The nine superseded captures were excluded and left untouched. No gameplay source or screenshot pixels were retouched. Individual pair PNGs place the original frames uncropped at native dimensions; overview thumbnails are scaled proportionally for the grid.",
        "",
        "### Nine-island overview galleries",
        "",
    ]
    for viewport in ("390x844", "432x960"):
        relative = galleries[viewport].relative_to(EVIDENCE).as_posix()
        lines += [f"**{viewport}** — [open full-size gallery]({relative})", "", f"![Nine-island gallery {viewport}]({relative})", ""]
    lines += ["### Island pairs and representative level details", "",
              "The populated screenshot's local level ID selects the live level JSON row. Normal T is `theoretical_shots_total`; positions are the normalized `initial_tabletop_drinks` coordinates. Each original frame is linked separately.", ""]
    for island in ISLAND_ORDER:
        level_file = "tiki_island_full.json" if island == "tiki_island" else f"{island}.json"
        json_link = f"../../../../../data/campaign/levels/{level_file}"
        lines += [f"#### {ISLAND_LABELS[island]}", ""]
        for viewport in ("390x844", "432x960"):
            empty = index[(viewport, island, "empty")]
            populated = index[(viewport, island, "populated")]
            assert empty["level_id"] == 1
            pair_path = pairs[(viewport, island)].relative_to(EVIDENCE).as_posix()
            empty_path = Path("screenshots") / viewport / Path(empty["path"]).name
            populated_path = Path("screenshots") / viewport / Path(populated["path"]).name
            lines.append(f"- **{viewport}:** [EMPTY vs POPULATED pair]({pair_path}) · [empty original, L{empty['level_id']:03d}]({empty_path.as_posix()}) · [populated original, L{populated['level_id']:03d}]({populated_path.as_posix()})")
        representative = index[("390x844", island, "populated")]
        assert representative["level_id"] == index[("432x960", island, "populated")]["level_id"]
        lines += [f"- **Representative populated level facts:** {describe_level(island, representative)} [current level JSON]({json_link})", ""]
    lines += ["### Tiki two-starter contrast", "",
              "These compare different Tiki levels, so they show one-versus-two starter density rather than a controlled same-level before/after. The displayed objective/position facts are read from each level JSON row.", ""]
    for viewport in ("390x844", "432x960"):
        one = index[(viewport, "tiki_island", "populated")]
        two = index[(viewport, "tiki_island", "contrast_two_drinks")]
        path = tiki[viewport].relative_to(EVIDENCE).as_posix()
        one_orig = Path("screenshots") / viewport / Path(one["path"]).name
        two_orig = Path("screenshots") / viewport / Path(two["path"]).name
        lines += [f"**{viewport}:** [one vs two starters]({path}) · [one-starter original]({one_orig.as_posix()}) · [two-starter original]({two_orig.as_posix()})", "",
                  f"- One starter: {describe_level('tiki_island', one)}",
                  f"- Two starters: {describe_level('tiki_island', two)}", ""]
    lines += [
        "### Builder visual observations",
        "",
        "- In the inspected populated frames, starter glass art and its floor shadow are visible against the tabletop. The starters sit in the central playable area and do not visibly cross the dashed danger boundary; several of the larger single glasses end close to it, so clearance needs owner review. The held launch drink remains lower in the launch lane, and the visible HUD/order shelf remain above the starters.",
        "- Starter glass art occupies a substantial tabletop footprint, especially in the Tiki two-starter contrast. The two Tiki drinks are separated horizontally and remain visibly above the danger boundary in the captured frames.",
        "- Static screenshots show no starter occluding the HUD, shelf, danger marker, launch drink, or another starter in the inspected captures. Actual touch/mouse hit-target behavior cannot be established from still images and remains for owner/runtime review.",
        "- Theme lighting and tabletop grain/shadows vary by island. These observations are builder inspection only; none of the visuals are labeled owner-approved.",
        "",
        "### Owner review checklist",
        "",
        "Please reply briefly for each item (yes/no plus any island or level ID):",
        "",
        "1. Are the starter cocktails clearly visible and at a suitable scale on each island?",
        "2. Are their positions safely clear of the HUD, order shelf, danger boundary, and launch lane?",
        "3. Is the two-starter Tiki layout readable and comfortably spaced?",
        "4. Do the representative starters feel like useful direct order stock or merge precursors for their displayed orders?",
        "5. Which island/level layouts should change before visual approval?",
        "",
        "No owner visual approval is claimed. Human playability, physical-device review, and independent follow-up remain separate gates.",
        "",
    ]
    return "\n".join(lines)


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    index = capture_index(manifest)
    pairs: dict[tuple[str, str], Path] = {}
    galleries: dict[str, Path] = {}
    tiki: dict[str, Path] = {}
    for viewport in ("390x844", "432x960"):
        gallery_pairs = []
        for island in ISLAND_ORDER:
            empty = index[(viewport, island, "empty")]
            populated = index[(viewport, island, "populated")]
            assert empty["initial_drinks"] == []
            assert populated["initial_drinks"]
            pair = make_pair(viewport, island, empty, populated)
            pairs[(viewport, island)] = pair
            gallery_pairs.append((island, pair))
        tiki_one = index[(viewport, "tiki_island", "populated")]
        tiki_two = index[(viewport, "tiki_island", "contrast_two_drinks")]
        assert len(tiki_two["initial_drinks"]) == 2
        tiki[viewport] = make_tiki_contrast(viewport, tiki_one, tiki_two)
        galleries[viewport] = make_overview(viewport, gallery_pairs)

    section = build_readme_section(index, pairs, galleries, tiki)
    readme = EVIDENCE / "README.md"
    old = readme.read_text(encoding="utf-8")
    begin, end = "<!-- OWNER_VISUAL_CONTACT_SHEETS_R01_BEGIN -->", "<!-- OWNER_VISUAL_CONTACT_SHEETS_R01_END -->"
    if begin in old:
        old = old[:old.index(begin)].rstrip() + "\n\n" + old[old.index(end) + len(end):].lstrip()
    updated = old.rstrip() + "\n\n" + begin + "\n\n" + section + end + "\n"
    readme.write_text(updated, encoding="utf-8", newline="\n")
    print(json.dumps({
        "active_originals_verified": len(manifest["captures"]),
        "superseded_excluded_and_untouched": len(manifest["superseded_artifacts"]),
        "pair_images": len(pairs),
        "overview_galleries": len(galleries),
        "tiki_contrast_images": len(tiki),
        "output": str(OUT),
        "readme": str(readme),
    }, indent=2))


if __name__ == "__main__":
    main()
