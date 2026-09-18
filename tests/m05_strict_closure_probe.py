"""Focused provenance probe for BCM-M05-STRICT-CLOSURE."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INDEPENDENT = ROOT / "docs/evidence/m05/strict_closure_independent_measurements.json"
COMPARISON = ROOT / "docs/evidence/m05/strict_closure_production_comparison.json"
GENERATOR = ROOT / "tools/m05_strict_closure_evidence.py"


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check(name: str, condition: bool) -> None:
    if not condition:
        raise AssertionError(name)
    print(f"M05_STRICT_PROBE PASS: {name}")


def main() -> int:
    check("independent dataset exists", INDEPENDENT.exists())
    check("comparison dataset exists", COMPARISON.exists())
    independent = json.loads(INDEPENDENT.read_text(encoding="utf-8"))
    comparison = json.loads(COMPARISON.read_text(encoding="utf-8"))
    levels = independent["levels"]
    check("exactly 12 independent records exist", len(levels) == 12)
    check("no L13 texture exists", not (ROOT / "assets/cocktails/L13.png").exists())
    check("generator has no production import", "scripts/drink.gd" not in GENERATOR.read_text(encoding="utf-8"))
    generator_source = GENERATOR.read_text(encoding="utf-8")
    check("generator has no production measurement symbols", not re.search(r"VISIBLE_BODY|COLLIDER_RADII|BOUNDARY_CONTACT_HULL|Drink\\.", generator_source))
    check("independent phase is before production comparison", independent["measurement_phase"].endswith("BEFORE_PRODUCTION_COMPARISON"))
    check("generator records production-free provenance", independent["independence"]["production_constants_read_before_output"] is False)
    check("all shape classifications have rationale", all(item.get("shape_category") and item.get("shape_rationale") for item in levels))
    check("all canonical hashes match current PNGs", all(sha256(ROOT / item["source_path"]) == item["source_sha256"] for item in levels))
    check("all source dimensions are present", all(len(item["source_dimensions"]) == 2 for item in levels))
    check("comparison has 12 records", len(comparison["levels"]) == 12)
    check("comparison is post-freeze", all(item["comparison_is_post_independent_freeze"] for item in comparison["levels"]))
    check("comparison contains non-circular differences", any(abs(item["width_difference_px"]) > 0.5 or abs(item["center_difference_px"][0]) > 0.5 for item in comparison["levels"]))
    check("representative overlay covers five required families", comparison["representative_overlay_levels"] == [4, 3, 8, 9, 12])
    check("protected R11 symbols match", all(item["matches_r11_baseline"] for item in comparison["protected_symbols"].values()))
    check("texture mapping remains 12 levels", len(re.findall(r'res://assets/cocktails/L\d+\.png', (ROOT / "scripts/drink.gd").read_text(encoding="utf-8"))) >= 12)
    print("M05_STRICT_PROBE_RESULT=PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
