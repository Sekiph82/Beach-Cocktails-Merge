"""Regression contract for safe export exclusions without deleting source."""
import importlib.util
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "check_export_boundaries", ROOT / "tools" / "release" / "check_export_boundaries.py"
)
release = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(release)


class ReleaseBoundaryTests(unittest.TestCase):
    def test_developer_directories_excluded_from_preset(self):
        name, platform, include, exclude = release.read_preset(ROOT, None)
        self.assertIn("Android", platform)
        for path in (
            "coordination/sessions/example.md",
            "docs/codex-logs/log.md",
            "tests/m34_probe.gd",
            "tools/release/check_export_boundaries.py",
            "backend/mobile-rewards/src/index.js",
        ):
            with self.subTest(path=path):
                self.assertTrue(release.matches(path, exclude), path)

    def test_candidate_presets_keep_developer_and_godot_ai_sources_out(self):
        for name, platform in (
            ("Android Store Candidate (NOT SHIPPING)", "Android"),
            ("iOS Store Candidate (NOT SHIPPING)", "iOS"),
        ):
            actual_name, actual_platform, _include, exclude = release.read_preset(ROOT, name)
            self.assertEqual(actual_name, name)
            self.assertIn(platform, actual_platform)
            self.assertFalse(release.matches("data/campaign/shop_catalog.json", _include))
            for path in (
                "coordination/sessions/example.md",
                "docs/codex-logs/log.md",
                "tests/m34_probe.gd",
                "tools/release/check_export_boundaries.py",
                "backend/mobile-rewards/src/index.js",
                "_m32_validation/m32_probe.result.json",
                "f647e4ff-b906-40e7-93f8-3c4b59d95b23.png",
                "addons/godot_ai/runtime/game_helper.gd",
                "addons/GodotGooglePlayBilling/BillingClient.gd",
                "addons/GodotGooglePlayBilling/bin/release/GodotGooglePlayBilling-release.aar",
                "addons/AdmobPlugin/bin/release/AdmobPlugin-release.aar",
                "addons/AdmobPlugin/AdmobPlugin.gd",
                "addons/AdmobPlugin/config/admob_android_export_config.gd",
                "addons/game_feel_flow/editor/ui/combos_panel.gd",
                "addons/game_feel_flow/icons/icon_flash.svg",
                "addons/saltmire_spark/plugin.gd",
                "scripts/campaign/admob_test_adapter.gd",
                "scripts/campaign/play_billing_test_adapter.gd",
                "scripts/campaign/m17_seeded_validation_harness.gd",
                "scripts/campaign/m17_canonical_screening_model.gd",
                "scripts/campaign/m32_content_workflow.gd",
                "scripts/campaign/owner_playtest_console.gd",
                "assets/ui_assets/source/style_reference_board.png",
                "assets/ui_assets/v04_masters/CONTACT_SHEET_V04.png",
            ):
                with self.subTest(preset=name, path=path):
                    self.assertTrue(release.matches(path, exclude), path)

    def test_native_monetization_sdks_are_explicitly_opt_in(self):
        config = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
        admob_export = (ROOT / "addons" / "AdmobPlugin" / "AdmobPlugin.gd").read_text(encoding="utf-8")
        billing_export = (ROOT / "addons" / "GodotGooglePlayBilling" / "export_plugin.gd").read_text(encoding="utf-8")
        policy = json.loads((ROOT / "data" / "campaign" / "ads_provider_policy.json").read_text(encoding="utf-8"))

        self.assertIn('features.has("m34_admob_native_enabled")', admob_export)
        self.assertIn('features.has("m34_store_billing_enabled")', billing_export)
        self.assertIn('if not _native_ads_export_enabled:', admob_export)
        self.assertIn('if not _native_billing_export_enabled:', billing_export)
        self.assertNotIn("m34_admob_native_enabled", config)
        self.assertNotIn("m34_store_billing_enabled", config)
        self.assertFalse(policy["default_enabled"])
        self.assertTrue(all(not placement["enabled"] for placement in policy["placements"].values()))

    def test_owner_playtest_console_is_debug_only_and_dynamically_loaded(self):
        shell = (ROOT / "scripts" / "campaign" / "application_shell.gd").read_text(encoding="utf-8")
        self.assertNotIn("OWNER_PLAYTEST_CONSOLE_SCRIPT := preload", shell)
        self.assertIn("owner_playtest_requested and OS.is_debug_build()", shell)
        self.assertIn('load("res://scripts/campaign/owner_playtest_console.gd")', shell)

    def test_monetization_test_adapters_are_debug_only_and_dynamically_loaded(self):
        navigation = (ROOT / "scripts" / "campaign" / "campaign_navigation_controller.gd").read_text(encoding="utf-8")
        self.assertNotIn('preload("res://scripts/campaign/admob_test_adapter.gd")', navigation)
        self.assertNotIn('preload("res://scripts/campaign/play_billing_test_adapter.gd")', navigation)
        self.assertIn('if not OS.is_debug_build() or mobile_reward_transport == null', navigation)
        self.assertIn('if not OS.is_debug_build() or store_service == null', navigation)

    def test_candidate_presets_remain_explicitly_nonshipping(self):
        for name in (
            "Android Store Candidate (NOT SHIPPING)",
            "iOS Store Candidate (NOT SHIPPING)",
        ):
            report = release.source_report(ROOT, name)
            self.assertFalse(report["shipping_release_preset"])
            self.assertEqual(report["runtime_json_missing_from_include_filter"], [])
            self.assertEqual(report["nonexcluded_developer_sources"], [])

    def test_runtime_json_explicitly_included(self):
        _name, _platform, include, exclude = release.read_preset(ROOT, None)
        for path in release.EXPECTED_JSON:
            with self.subTest(path=path):
                self.assertTrue(release.matches(path, include), path)
                self.assertFalse(release.matches(path, exclude), path)

    def test_debug_not_conflated_with_shipping_release(self):
        report = release.source_report(ROOT, None)
        self.assertFalse(report["shipping_release_preset"])
        self.assertEqual(report["nonexcluded_developer_sources"], [])
        self.assertEqual(report["runtime_json_missing_from_include_filter"], [])
        self.assertEqual(report["status"], "STATIC_FILTER_ONLY_PACKAGE_UNVERIFIED")
        self.assertEqual(report["debug_helper_shipped"], "UNVERIFIED_NEEDS_ACTUAL_PACKAGE_INSPECTION")

    def test_no_claim_of_a_clean_binary_from_source_only(self):
        report = release.source_report(ROOT, None)
        self.assertNotIn("GO", report["status"])
        self.assertIn("UNVERIFIED", report["status"])


if __name__ == "__main__":
    unittest.main()
