"""Deterministic tests for the BCM-M33 R03 necessary-condition screen."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from tools.campaign import m33_r03_difficulty_analytics as analytics  # noqa: E402


def fixture_level() -> tuple[dict, dict]:
    island = {"id": "azure_bay", "target_policy": {"min_level": 7, "max_level": 10}}
    level = {
        "global_level_id": 201,
        "island_id": "azure_bay",
        "level_id": 1,
        "difficulty_tier": "EXPERT_ENTRY",
        "time_limit_sec": 0,
        "orders": [{"cocktail_level": 8, "quantity": 1}, {"cocktail_level": 9, "quantity": 1}],
        "vip": {"enabled": True, "cocktail_level": 7, "quantity": 1},
        "theoretical_shots_total": 112,
        "move_limit": 448,
        "feature_flags": {"timed": False, "vip": True},
    }
    return level, island


class DifficultyAnalyticsTests(unittest.TestCase):
    def test_production_merge_cost_and_expected_spawn_algebra(self) -> None:
        self.assertEqual(analytics.cocktail_cost(3), 4)
        self.assertEqual(analytics.cocktail_cost(12), 2048)
        self.assertEqual(analytics.l3_equivalent(2048), 512)
        self.assertAlmostEqual(analytics.expected_launches(7), 3.0)

    def test_4t_includes_enabled_optional_vip_and_data_is_not_physics_proof(self) -> None:
        level, island = fixture_level()
        row = analytics.analyze_level(level, island, 201)
        self.assertEqual(row["normal_T"], 96)
        self.assertEqual(row["vip_T"], 16)
        self.assertEqual(row["total_T"], 112)
        self.assertEqual(row["move_limit_4T"], 448)
        self.assertEqual(row["one_star_max_launches_if_complete"], 448)
        self.assertEqual(row["two_star_max_launches_if_complete"], 335)
        self.assertEqual(row["three_star_max_launches_if_complete"], 223)
        self.assertIn("CERTIFIED_DATA_LEGAL", row["status_labels"])
        self.assertIn("PHYSICS_UNVERIFIED", row["status_labels"])
        self.assertIn("HUMAN_FAIRNESS_UNVERIFIED", row["status_labels"])
        self.assertIn("VIP_INTERMEDIATE_RESERVE_REQUIRED", row["suspicion_flags"])

    def test_malformed_target_and_stale_move_budget_are_suspicious(self) -> None:
        level, island = fixture_level()
        level["orders"][0]["cocktail_level"] = 11
        row = analytics.analyze_level(level, island, 201)
        self.assertIn("ANALYTICALLY_SUSPICIOUS", row["status_labels"])
        self.assertIn("ORDER_0_TARGET_OUTSIDE_PRODUCTION_OR_ISLAND_POLICY", row["data_errors"])
        self.assertIn("MOVE_LIMIT_NOT_4T_TOTAL", row["data_errors"])

    def test_quantity_is_counted_in_merge_algebra_and_nonproduction_amount_is_flagged(self) -> None:
        level, island = fixture_level()
        level["orders"][0]["quantity"] = 3
        level["theoretical_shots_total"] = 176
        level["move_limit"] = 704
        row = analytics.analyze_level(level, island, 201)
        self.assertEqual(row["normal_T"], 160)
        self.assertIn("ORDER_0_QUANTITY_ABOVE_GENERATOR_MAX_2", row["suspicion_flags"])
        self.assertIn("CERTIFIED_DATA_LEGAL", row["status_labels"])

    def test_malformed_vip_is_reported_without_crashing_the_batch(self) -> None:
        level, island = fixture_level()
        level["vip"] = {"enabled": True, "cocktail_level": "twelve", "quantity": "one"}
        row = analytics.analyze_level(level, island, 201)
        self.assertIn("VIP_TARGET_OR_QUANTITY_INVALID", row["data_errors"])
        self.assertIn("ANALYTICALLY_SUSPICIOUS", row["status_labels"])
        self.assertEqual(row["vip_T"], 0)

    def test_real_campaign_partition_and_accepted_tiki_seed_are_preserved_in_analysis(self) -> None:
        rows, raw, island_doc = analytics.load_campaign(ROOT)
        report = analytics.build_report(rows, raw, island_doc)
        self.assertEqual(len(rows), 1000)
        self.assertEqual(report["scope"]["candidate_slice_global_102_to_1000"], 899)
        self.assertEqual(report["scope"]["preserved_sunny_cove_levels"], 100)
        self.assertEqual(report["scope"]["preserved_m32_tiki_l1_l12"], 12)
        tiki_seed = [x for x in rows if x["island_id"] == "tiki_island" and x["local_level_id"] <= 12]
        self.assertEqual(len(tiki_seed), 12)
        self.assertTrue(all(x["difficulty_tier"] == "PRESERVED_M32_SEED" for x in tiki_seed))
        self.assertEqual(report["summary"]["data_invalid_record_count_all_1000"], 0)
        self.assertEqual(report["summary"]["candidate_conservative_vip_intermediate_flags"], 307)
        self.assertEqual(report["summary"]["candidate_physics_unverified_count"], 899)
        self.assertEqual(report["summary"]["candidate_human_fairness_unverified_count"], 899)


if __name__ == "__main__":
    unittest.main()
