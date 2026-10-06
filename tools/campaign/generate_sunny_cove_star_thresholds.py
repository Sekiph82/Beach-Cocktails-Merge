#!/usr/bin/env python3
"""Generate and validate owner-approved Sunny Cove R07 score thresholds."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[2]
DRINKS_PATH = ROOT / "data" / "drinks.json"
LEVELS_PATH = ROOT / "data" / "campaign" / "levels" / "sunny_cove.json"
REPORT_PATH = (
    ROOT
    / "coordination"
    / "sessions"
    / "BCM-M21-ISLAND-MAP-STAR-R07"
    / "SUNNY_COVE_STAR_THRESHOLDS_R07.json"
)
FORMULA_VERSION = "BCM-M21-R07-STAR-THRESHOLDS-1"
LEVEL_ID_PATTERN = re.compile(r'"level_id"\s*:\s*(\d+)')
THRESHOLDS_PATTERN = re.compile(r'"score_star_thresholds"\s*:\s*\{[^{}]*\}')


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def ceil_to_50_from_ratio(value: int, numerator: int, denominator: int) -> int:
    """Compute ceil_to_50(value * numerator / denominator) with integers."""
    divisor = denominator * 50
    return ((value * numerator + divisor - 1) // divisor) * 50


def build_thresholds() -> tuple[dict[str, Any], str, str]:
    drinks = load_json(DRINKS_PATH).get("levels", [])
    if not drinks:
        raise ValueError("canonical drinks.json has no levels")
    drink_by_id = {int(drink["id"]): drink for drink in drinks}
    max_drink_id = max(drink_by_id)
    if set(drink_by_id) != set(range(1, max_drink_id + 1)):
        raise ValueError("drink ids must be consecutive from 1")

    construct_score = {1: 0, 2: 0, 3: 0}
    for level_id in range(4, max_drink_id + 1):
        construct_score[level_id] = (
            2 * construct_score[level_id - 1]
            + int(drink_by_id[level_id].get("score", 0))
        )

    source_text = LEVELS_PATH.read_text(encoding="utf-8-sig")
    source = json.loads(source_text)
    levels = source.get("levels", [])
    if len(levels) != 100:
        raise ValueError(f"expected 100 Sunny Cove levels, found {len(levels)}")

    report_levels: list[dict[str, Any]] = []
    thresholds_by_level: dict[int, tuple[int, int]] = {}
    for expected_id, level in enumerate(levels, start=1):
        level_id = int(level.get("level_id", 0))
        if level_id != expected_id:
            raise ValueError(f"expected level_id {expected_id}, found {level_id}")
        orders = level.get("orders")
        if not isinstance(orders, list) or not orders:
            raise ValueError(f"level {level_id} has no normal order list")
        mastery_base = 0
        for order in orders:
            cocktail_level = int(order.get("cocktail_level", 0))
            quantity = int(order.get("quantity", 0))
            if quantity <= 0 or cocktail_level < 1 or cocktail_level > max_drink_id:
                raise ValueError(f"invalid normal order in level {level_id}: {order}")
            entry_base = quantity * (
                construct_score.get(cocktail_level, 0)
                + int(drink_by_id[cocktail_level].get("order_reward", 0))
            )
            mastery_base += entry_base

        if mastery_base == 0:
            two_stars, three_stars = 100, 150
        else:
            two_stars = ceil_to_50_from_ratio(mastery_base, 11, 10)
            three_stars = ceil_to_50_from_ratio(mastery_base, 135, 100)
        if two_stars <= 0 or three_stars <= two_stars:
            raise ValueError(f"invalid thresholds for level {level_id}")

        thresholds_by_level[level_id] = (two_stars, three_stars)
        vip = level.get("vip")
        report_levels.append(
            {
                "level_id": level_id,
                "normal_orders": orders,
                "mastery_base": mastery_base,
                "two_stars": two_stars,
                "three_stars": three_stars,
                "vip_enabled": isinstance(vip, dict) and bool(vip.get("enabled", False)),
                "formula_version": FORMULA_VERSION,
            }
        )

    lines = source_text.splitlines()
    seen: set[int] = set()
    updated_lines: list[str] = []
    for line in lines:
        match = LEVEL_ID_PATTERN.search(line)
        if match is None:
            updated_lines.append(line)
            continue
        level_id = int(match.group(1))
        if level_id not in thresholds_by_level or level_id in seen:
            raise ValueError(f"duplicate or unexpected level id in source line: {level_id}")
        seen.add(level_id)
        two_stars, three_stars = thresholds_by_level[level_id]
        replacement = (
            f'"score_star_thresholds":{{"one_star":0,"two_stars":{two_stars},'
            f'"three_stars":{three_stars}}}'
        )
        updated_line, substitutions = THRESHOLDS_PATTERN.subn(replacement, line, count=1)
        if substitutions != 1:
            raise ValueError(f"level {level_id} must have one score_star_thresholds object")
        updated_lines.append(updated_line)
    if seen != set(range(1, 101)):
        raise ValueError("could not locate all 100 level records in the canonical source")

    updated_text = "\n".join(updated_lines) + "\n"
    updated_data = json.loads(updated_text)
    for level in updated_data["levels"]:
        thresholds = level.get("score_star_thresholds", {})
        expected = thresholds_by_level[int(level["level_id"])]
        if (
            thresholds.get("two_stars") != expected[0]
            or thresholds.get("three_stars") != expected[1]
        ):
            raise ValueError(f"generated source failed validation at level {level['level_id']}")

    report = {
        "schema_version": 1,
        "formula_version": FORMULA_VERSION,
        "island_id": "sunny_cove",
        "level_count": 100,
        "sources": {
            "drinks": "data/drinks.json",
            "levels": "data/campaign/levels/sunny_cove.json",
        },
        "construct_score": {str(key): construct_score[key] for key in sorted(construct_score)},
        "levels": report_levels,
    }
    report_text = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    return report, updated_text, report_text


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="validate current canonical data and report without writing files",
    )
    args = parser.parse_args()

    try:
        report, levels_text, report_text = build_thresholds()
        outputs = ((LEVELS_PATH, levels_text), (REPORT_PATH, report_text))
        if args.check:
            mismatches = [str(path.relative_to(ROOT)) for path, text in outputs if path.read_text(encoding="utf-8-sig") != text]
            if mismatches:
                print("R07_STAR_THRESHOLDS_CHECK=FAIL mismatches=" + ",".join(mismatches))
                return 1
            print("R07_STAR_THRESHOLDS_CHECK=PASS levels=100 deterministic=PASS")
            return 0

        changed: list[str] = []
        for path, text in outputs:
            old_text = path.read_text(encoding="utf-8-sig") if path.exists() else ""
            if old_text != text:
                path.write_text(text, encoding="utf-8", newline="\n")
                changed.append(str(path.relative_to(ROOT)))
        print(
            "R07_STAR_THRESHOLDS_GENERATION=PASS "
            f"levels={len(report['levels'])} changed={','.join(changed) if changed else 'none'}"
        )
        return 0
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as error:
        print(f"R07_STAR_THRESHOLDS_GENERATION=FAIL {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
