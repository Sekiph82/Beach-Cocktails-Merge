#!/usr/bin/env python3
"""Static, deterministic validation for the packaged M33 campaign candidates."""

from __future__ import annotations

import hashlib
import importlib.util
import json
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GENERATOR_PATH = ROOT / "tools/generate_m33_campaign_content.py"
ISLANDS_PATH = ROOT / "data/campaign/islands.json"
MANIFEST_PATH = ROOT / "data/campaign/content_manifest_m33.json"
SUNNY_SHA256 = "573B5CA14CA75BEC04F40A5B7D00AA441534A266569B200E36E78B28D3591128"
EXPECTED_ISLANDS = [
    "sunny_cove", "tiki_island", "azure_bay", "coconut_beach", "sunset_island",
    "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
]


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def normal_signature(row: dict) -> str:
    return json.dumps(
        [{"cocktail_level": int(order["cocktail_level"]), "quantity": int(order["quantity"])} for order in row["orders"]],
        separators=(",", ":"), sort_keys=True,
    )


def full_signature(row: dict) -> str:
    vip = row.get("vip")
    normalized_vip = {"enabled": False, "cocktail_level": 0, "quantity": 0}
    if isinstance(vip, dict) and vip.get("enabled", True):
        normalized_vip = {"enabled": True, "cocktail_level": int(vip["cocktail_level"]), "quantity": int(vip["quantity"])}
    return json.dumps({"orders": json.loads(normal_signature(row)), "time_limit_sec": float(row.get("time_limit_sec", 0)), "vip": normalized_vip}, separators=(",", ":"), sort_keys=True)


def theoretical_shots(row: dict) -> int:
    total = sum((1 << (int(order["cocktail_level"]) - 3)) * int(order["quantity"]) for order in row["orders"])
    vip = row.get("vip")
    if isinstance(vip, dict) and vip.get("enabled", True):
        total += (1 << (int(vip["cocktail_level"]) - 3)) * int(vip["quantity"])
    return total


def fail(message: str) -> None:
    raise SystemExit(f"M33_STATIC_VALIDATION=FAIL {message}")


def main() -> int:
    spec = importlib.util.spec_from_file_location("m33_generator", GENERATOR_PATH)
    if spec is None or spec.loader is None:
        fail("generator module cannot be loaded")
    generator = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(generator)
    outputs_a, report_a = generator.generate()
    outputs_b, report_b = generator.generate()
    if outputs_a != outputs_b or report_a != report_b:
        fail("same seed/profile did not generate identical data and metrics")
    islands = json.loads(ISLANDS_PATH.read_text(encoding="utf-8"))
    registry = islands["islands"]
    if [row["id"] for row in sorted(registry, key=lambda row: row["order_index"])] != EXPECTED_ISLANDS:
        fail("canonical island order changed")
    if any(int(row["level_count"]) != 100 for row in registry):
        fail("island registry does not declare exactly 100 levels per island")

    sunny_root = json.loads((ROOT / "data/campaign/levels/sunny_cove.json").read_text(encoding="utf-8"))
    sunny_intro = {normal_signature(row) for row in sunny_root["levels"][:10]}
    records = 0
    global_signatures: set[str] = set()
    for island_id, root in outputs_a.items():
        rows = root["levels"]
        if len(rows) != 100 or [int(row["level_id"]) for row in rows] != list(range(1, 101)):
            fail(f"{island_id} is not 100 contiguous local levels")
        if len({full_signature(row) for row in rows}) != 100:
            fail(f"{island_id} repeats a complete challenge recipe")
        policy = next(row["target_policy"] for row in registry if row["id"] == island_id)
        band_metrics = next(row for row in report_a["islands"] if row["island_id"] == island_id)
        if not bool(band_metrics["all_generated_normal_templates_avoid_sunny_intro_1_10"]):
            fail(f"{island_id} repeats a Sunny Cove introduction recipe")
        if any(normal_signature(row) in sunny_intro for row in rows):
            fail(f"{island_id} has a direct Sunny Cove introduction collision")
        if int(band_metrics["record_count"]) != 100:
            fail(f"{island_id} metrics report an incorrect record count")
        normal_counts = Counter(normal_signature(row) for row in rows)
        if int(band_metrics["normal_template_repeat_records"]) != sum(count - 1 for count in normal_counts.values()):
            fail(f"{island_id} repeat-template metric is inconsistent")
        for row in rows:
            records += 1
            signature = full_signature(row)
            if signature in global_signatures:
                fail(f"complete challenge recipe collides across islands: {island_id}/{row['level_id']}")
            global_signatures.add(signature)
            if str(row["island_id"]) != island_id or float(row["time_limit_sec"]) != 0.0 or len(row["orders"]) < 2:
                fail(f"{island_id}/{row['level_id']} has invalid identity, timer, or order count")
            order_targets: set[int] = set()
            for order in row["orders"]:
                level, quantity = int(order["cocktail_level"]), int(order["quantity"])
                if not 3 <= level <= 12 or not int(policy["min_level"]) <= level <= int(policy["max_level"]) or not 1 <= quantity <= 2:
                    fail(f"{island_id}/{row['level_id']} has an out-of-policy To-Go target or quantity")
                order_targets.add(level)
            vip = row.get("vip")
            if isinstance(vip, dict) and vip.get("enabled", True):
                target, quantity = int(vip["cocktail_level"]), int(vip["quantity"])
                if target in order_targets or not int(policy["min_level"]) <= target <= int(policy["max_level"]) or not 1 <= quantity <= 2:
                    fail(f"{island_id}/{row['level_id']} VIP is not optional or policy-legal")
            shots = theoretical_shots(row)
            if shots != int(row["theoretical_shots_total"]) or int(row["move_limit"]) != shots * 4:
                fail(f"{island_id}/{row['level_id']} derived move budget is inconsistent")
            if int(row["global_level_id"]) != (EXPECTED_ISLANDS.index(island_id) * 100 + int(row["level_id"])):
                fail(f"{island_id}/{row['level_id']} global ID is not stable")
    if records != 900:
        fail(f"expected 900 generated records, got {records}")
    if len(global_signatures) != records or int(report_a["unique_full_challenge_signatures_global"]) != records:
        fail("global full-challenge recipes are not all unique")

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    if manifest.get("ordered_island_ids") != EXPECTED_ISLANDS or int(manifest.get("total_levels", 0)) != 1000:
        fail("manifest campaign contract is inconsistent")
    if len(manifest.get("islands", [])) != 10:
        fail("manifest is missing island records")
    for item in manifest["islands"]:
        path = ROOT / str(item["path"]).removeprefix("res://")
        if not path.is_file() or sha256(path.read_bytes()) != str(item["sha256"]).upper():
            fail(f"manifest checksum mismatch: {item.get('id')}")
        packaged = json.loads(path.read_text(encoding="utf-8"))
        if packaged != outputs_a.get(item["id"], packaged) and item["id"] != "sunny_cove":
            fail(f"packaged output differs from deterministic generator: {item['id']}")
        if len(packaged.get("levels", [])) != 100 or str(packaged.get("island_id", "")) != str(item["id"]):
            fail(f"packaged content identity/count mismatch: {item['id']}")
    sunny_bytes = (ROOT / "data/campaign/levels/sunny_cove.json").read_bytes()
    if sha256(sunny_bytes) != SUNNY_SHA256 or next(row for row in manifest["islands"] if row["id"] == "sunny_cove")["sha256"] != SUNNY_SHA256:
        fail("Sunny Cove content bytes changed")
    print(json.dumps({
        "result": "PASS_STATIC_CANDIDATE_CHECKS_PHYSICS_NOT_CERTIFIED",
        "deterministic_generation": True,
        "generated_records": records,
        "globally_unique_full_recipes": len(global_signatures),
        "sunny_cove_sha256": SUNNY_SHA256,
        "island_metrics": [
            {
                "island_id": row["island_id"],
                "unique_full_recipes": row["unique_full_challenge_signatures"],
                "unique_normal_templates": row["unique_normal_objective_templates"],
                "normal_template_repeat_rate": row["normal_template_repeat_rate"],
                "max_normal_template_repetition": row["max_repetition_of_one_normal_template"],
                "vip_levels": row["vip_enabled_levels"],
                "theoretical_shots_median": row["theoretical_shots_median"],
            }
            for row in report_a["islands"]
        ],
        "limitations": ["static arithmetic and deterministic checks do not certify physics reachability or human playability"],
    }, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
