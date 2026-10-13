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


def normal_theoretical_shots(row: dict) -> int:
    return sum((1 << (int(order["cocktail_level"]) - 3)) * int(order["quantity"]) for order in row["orders"])


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
    m32_tiki_seed = json.loads((ROOT / "data/campaign/levels/tiki_island.json").read_text(encoding="utf-8"))
    profile = json.loads((ROOT / "data/campaign/content_generation_profiles_m33.json").read_text(encoding="utf-8"))
    profile_sha = sha256((ROOT / "data/campaign/content_generation_profiles_m33.json").read_bytes())
    contract = profile.get("design_contract", {})
    if int(contract.get("ordinary_normal_T_max", 0)) != 56 or int(contract.get("prestige_capstone_local_level", 0)) != 100:
        fail("owner-approved T56 / level-100 capstone contract is missing")
    sunny_intro = {normal_signature(row) for row in sunny_root["levels"][:10]}
    records = 0
    generated_records = 0
    global_signatures: set[str] = set()
    capstone_count = 0
    for island_id, root in outputs_a.items():
        rows = root["levels"]
        if len(rows) != 100 or [int(row["level_id"]) for row in rows] != list(range(1, 101)):
            fail(f"{island_id} is not 100 contiguous local levels")
        preserved_count = 12 if island_id == "tiki_island" else 0
        if int(root["campaign_generation"]["preserved_m32_seed_levels"]) != preserved_count:
            fail(f"{island_id} preserved-seed count is incorrect")
        if island_id == "tiki_island":
            for source, packaged in zip(m32_tiki_seed["levels"][:12], rows[:12], strict=True):
                if any(packaged.get(key) != value for key, value in source.items()):
                    fail(f"M32 Tiki L{source['level_id']} gameplay fields changed")
                if int(packaged.get("global_level_id", 0)) != 100 + int(source["level_id"]):
                    fail(f"M32 Tiki L{source['level_id']} global ID is not mapped correctly")
                if packaged.get("difficulty_tier") != "PRESERVED_M32_SEED":
                    fail(f"M32 Tiki L{source['level_id']} provenance metadata is missing")
        policy = next(row["target_policy"] for row in registry if row["id"] == island_id)
        band_metrics = next(row for row in report_a["islands"] if row["island_id"] == island_id)
        generated_rows = rows[preserved_count:]
        if int(band_metrics["record_count"]) != 100:
            fail(f"{island_id} metrics report an incorrect record count")
        normal_counts = Counter(normal_signature(row) for row in generated_rows)
        for row in rows:
            records += 1
            inherited_m32 = island_id == "tiki_island" and int(row["level_id"]) <= 12
            generated_records += 0 if inherited_m32 else 1
            signature = full_signature(row)
            global_signatures.add(signature)
            if str(row["island_id"]) != island_id or float(row["time_limit_sec"]) != 0.0 or (not inherited_m32 and len(row["orders"]) < 2):
                fail(f"{island_id}/{row['level_id']} has invalid identity, timer, or order count")
            order_targets: set[int] = set()
            for order in row["orders"]:
                level, quantity = int(order["cocktail_level"]), int(order["quantity"])
                if not 3 <= level <= 12 or not int(policy["min_level"]) <= level <= int(policy["max_level"]) or not 1 <= quantity <= 2:
                    fail(f"{island_id}/{row['level_id']} has an out-of-policy To-Go target or quantity")
                order_targets.add(level)
            if not inherited_m32:
                expected_rewards = {"coins": 10, "gems": 1} if island_id == "tiki_island" else {"coins": 0}
                if row.get("rewards") != expected_rewards:
                    fail(f"{island_id}/{row['level_id']} changed the established campaign reward payload")
                normal_t = normal_theoretical_shots(row)
                is_capstone = int(row["level_id"]) == 100
                if bool(row.get("prestige_capstone", False)) != is_capstone or str(row.get("level_type", "")) != ("PRESTIGE_CAPSTONE" if is_capstone else "ORDINARY"):
                    fail(f"{island_id}/{row['level_id']} lacks the explicit ordinary/capstone marker")
                if is_capstone:
                    capstone_count += 1
                    if normal_t <= 56 or normal_t > 80 or 9 not in order_targets:
                        fail(f"{island_id}/{row['level_id']} capstone is outside the L9 / T68-T80 contract")
                else:
                    if normal_t > 56 or any(int(order["cocktail_level"]) < 6 or int(order["cocktail_level"]) > 8 for order in row["orders"]):
                        fail(f"{island_id}/{row['level_id']} ordinary normal objectives exceed T56/L8")
                    if not any(int(order["cocktail_level"]) >= 6 for order in row["orders"]):
                        fail(f"{island_id}/{row['level_id']} has no ordinary L6+ target")
                if row.get("initial_tabletop_drinks_version") != 1 or not isinstance(row.get("initial_tabletop_drinks"), list):
                    fail(f"{island_id}/{row['level_id']} is missing versioned initial tabletop data")
                normal_quantities: Counter[int] = Counter()
                stock_quantities: Counter[int] = Counter()
                for order in row["orders"]:
                    normal_quantities[int(order["cocktail_level"])] += int(order["quantity"])
                for drink in row["initial_tabletop_drinks"]:
                    target = int(drink["cocktail_level"])
                    position = drink["position"]
                    if target not in normal_quantities and target + 1 not in normal_quantities or not isinstance(position, list) or len(position) != 2:
                        fail(f"{island_id}/{row['level_id']} has an incompatible tabletop drink")
                    if not 0.30 <= float(position[0]) <= 0.70 or not 0.48 <= float(position[1]) <= 0.56:
                        fail(f"{island_id}/{row['level_id']} tabletop placement is outside the safe area")
                    if isinstance(row.get("vip"), dict) and bool(row["vip"].get("enabled", True)) and target == int(row["vip"]["cocktail_level"]):
                        fail(f"{island_id}/{row['level_id']} tabletop stock can claim VIP")
                    stock_quantities[target] += 1
                if sum(stock_quantities.values()) >= sum(normal_quantities.values()) or any(stock_quantities[target] > normal_quantities[target] for target in stock_quantities if target in normal_quantities):
                    fail(f"{island_id}/{row['level_id']} tabletop stock can complete or exceed normal goals")
            vip = row.get("vip")
            if isinstance(vip, dict) and vip.get("enabled", True):
                target, quantity = int(vip["cocktail_level"]), int(vip["quantity"])
                if target in order_targets or not int(policy["min_level"]) <= target <= int(policy["max_level"]) or not 1 <= quantity <= 2:
                    fail(f"{island_id}/{row['level_id']} VIP is not optional or policy-legal")
                if vip.get("reward") != {}:
                    fail(f"{island_id}/{row['level_id']} changed the existing optional VIP reward payload")
                if not inherited_m32 and target <= max(order_targets):
                    fail(f"{island_id}/{row['level_id']} VIP can be produced as a normal objective intermediate")
            shots = theoretical_shots(row)
            if shots != int(row["theoretical_shots_total"]) or int(row["move_limit"]) != shots * 4:
                fail(f"{island_id}/{row['level_id']} derived move budget is inconsistent")
            if int(row["global_level_id"]) != (EXPECTED_ISLANDS.index(island_id) * 100 + int(row["level_id"])):
                fail(f"{island_id}/{row['level_id']} global ID is not stable")
    if records != 900 or generated_records != 888:
        fail(f"expected 900 packaged records including 12 inherited and 888 generated, got {records} packaged/{generated_records} generated")
    if int(report_a["unique_full_challenge_signatures_global"]) != len(global_signatures):
        fail("global full-recipe diversity report is inconsistent")
    if capstone_count != 9:
        fail(f"expected one marked prestige capstone per generated island, got {capstone_count}")
    if int(report_a.get("global_full_recipe_duplicate_records_including_within_island", -1)) != records - len(global_signatures):
        fail("global full-recipe duplicate metric is inconsistent")
    generated_normal_t: list[int] = []
    for island_id, root in outputs_a.items():
        first_generated = 12 if island_id == "tiki_island" else 0
        generated_normal_t.extend(normal_theoretical_shots(row) for row in root["levels"][first_generated:])
    max_normal_step = int(contract["max_adjacent_normal_T_delta"])
    if any(abs(right - left) > max_normal_step for left, right in zip(generated_normal_t, generated_normal_t[1:])):
        fail("generated cross-island normal-T transition exceeds the locked adjacent-step ceiling")

    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    if manifest.get("ordered_island_ids") != EXPECTED_ISLANDS or int(manifest.get("total_levels", 0)) != 1000:
        fail("manifest campaign contract is inconsistent")
    if len(manifest.get("islands", [])) != 10:
        fail("manifest is missing island records")
    if manifest.get("content_version") != "BCM-M33.4":
        fail("R05 campaign content version was not advanced")
    if report_a.get("profile_set_sha256") != profile_sha:
        fail("generation report does not bind to the current profile bytes")
    for item in manifest["islands"]:
        path = ROOT / str(item["path"]).removeprefix("res://")
        if not path.is_file() or sha256(path.read_bytes()) != str(item["sha256"]).upper():
            fail(f"manifest checksum mismatch: {item.get('id')}")
        packaged = json.loads(path.read_text(encoding="utf-8"))
        if item["id"] != "sunny_cove" and packaged.get("campaign_generation", {}).get("profile_set_sha256") != profile_sha:
            fail(f"packaged profile checksum mismatch: {item['id']}")
        if packaged != outputs_a.get(item["id"], packaged) and item["id"] != "sunny_cove":
            fail(f"packaged output differs from deterministic generator: {item['id']}")
        if len(packaged.get("levels", [])) != 100 or str(packaged.get("island_id", "")) != str(item["id"]):
            fail(f"packaged content identity/count mismatch: {item['id']}")
    for island in registry:
        for asset_key in ("map_asset", "playable_geometry_profile"):
            asset_path = ROOT / str(island[asset_key]).removeprefix("res://")
            if not asset_path.is_file():
                fail(f"registered campaign asset is missing: {island['id']} {asset_key}")
        for theme_key in ("island_map_background", "gameplay_surface", "playable_geometry_profile"):
            asset_path = ROOT / str(island["theme"][theme_key]).removeprefix("res://")
            if not asset_path.is_file():
                fail(f"registered theme asset is missing: {island['id']} {theme_key}")
    sunny_bytes = (ROOT / "data/campaign/levels/sunny_cove.json").read_bytes()
    if sha256(sunny_bytes) != SUNNY_SHA256 or next(row for row in manifest["islands"] if row["id"] == "sunny_cove")["sha256"] != SUNNY_SHA256:
        fail("Sunny Cove content bytes changed")
    print(json.dumps({
        "result": "PASS_OWNER_APPROVED_DIFFICULTY_STATIC_CHECKS_PHYSICS_NOT_CERTIFIED",
        "deterministic_generation": True,
        "packaged_campaign_records": records,
        "preserved_m32_tiki_records": records - generated_records,
        "generated_records": generated_records,
        "globally_unique_full_recipes": len(global_signatures),
        "cross_island_full_recipe_repeats": records - len(global_signatures),
        "marked_prestige_capstones": capstone_count,
        "sunny_cove_sha256": SUNNY_SHA256,
        "island_metrics": [
            {
                "island_id": row["island_id"],
                "unique_full_recipes": row["unique_full_challenge_signatures"],
                "unique_normal_templates": row["unique_normal_objective_templates"],
                "normal_template_repeat_rate": row["normal_template_repeat_rate"],
                "max_normal_template_repetition": row["max_repetition_of_one_normal_template"],
                "vip_levels": row["vip_enabled_levels"],
                "normal_T_median": row["normal_T_median"],
                "normal_T_p90": row["normal_T_p90"],
                "normal_T_max": row["normal_T_max"],
                "normal_T_at_most_56_count": row["normal_T_at_most_56_count"],
                "theoretical_shots_median": row["theoretical_shots_median"],
            }
            for row in report_a["islands"]
        ],
        "limitations": ["static arithmetic and deterministic checks do not certify physics reachability or human playability"],
    }, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
