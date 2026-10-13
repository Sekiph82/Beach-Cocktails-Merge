"""Deterministic feasibility checks for the BCM-M33 R04-R01 owner gate."""

from __future__ import annotations

import importlib.util
import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "tools/analyze_m33_r04_r01_design_space.py"
SPEC = importlib.util.spec_from_file_location("m33_r04_r01_design_space", MODULE_PATH)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError(f"could not load analysis tool: {MODULE_PATH}")
ANALYSIS = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ANALYSIS)


class M33R04R01DesignSpaceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.profile = json.loads((ROOT / "data/campaign/content_generation_profiles_m33.json").read_text(encoding="utf-8"))
        cls.space = ANALYSIS.enumerate_recipe_space(cls.profile)

    def test_l9_is_outside_the_ordinary_t56_space(self) -> None:
        self.assertEqual(1 << (9 - 3), 64)
        self.assertGreater(1 << (9 - 3), self.profile["design_contract"]["ordinary_normal_T_max"])
        self.assertTrue(all(9 not in row["eligible_normal_targets_after_L6_floor_and_T56"] for row in self.space["per_band"]))

    def test_upper_bound_is_below_ordinary_campaign_demand(self) -> None:
        self.assertEqual(self.space["canonical_normal_recipe_sets_ignoring_display_order"], 8)
        self.assertEqual(self.space["normal_signatures_counting_order_array_positions"], 20)
        self.assertEqual(self.space["full_recipe_sets_including_optional_VIP_ignoring_display_order"], 40)
        self.assertEqual(self.space["full_signatures_counting_order_array_positions_and_VIP"], 100)
        self.assertLess(100, 879)

    def test_baseline_campaign_count_and_t56_arithmetic(self) -> None:
        report_path = ROOT / "coordination/sessions/BCM-M33-900-LEVELS-AND-CONTENT-DELIVERY-V01/evidence/M33-R04/before_after_summary.json"
        summary = json.loads(report_path.read_text(encoding="utf-8"))
        rows = summary.get("islands", summary)
        count = sum(int(row["after_generated_normal_T56_or_less"]) for row in rows)
        self.assertEqual(count, 879)
        self.assertEqual(sum(int(row.get("after_ordinary_rows_over_T56", 0)) for row in rows), 0)

    def test_every_current_generated_l5_and_duplicate_is_reported(self) -> None:
        report, duplicates = ANALYSIS.build_report()
        current = report["current_package_audit"]
        self.assertEqual(current["generated_records"], 888)
        self.assertEqual(current["ordinary_generated_records"], 879)
        self.assertEqual(current["marked_capstones"], 9)
        self.assertEqual(current["ordinary_generated_records_over_T56"], 0)
        self.assertGreater(current["ordinary_generated_L5_target_rows"], 0)
        self.assertEqual(current["current_generated_duplicate_records"], 361)
        self.assertEqual(len(duplicates), 361)
        self.assertEqual(report["infeasibility"]["unique_signature_shortfall"], 779)


if __name__ == "__main__":
    unittest.main()
