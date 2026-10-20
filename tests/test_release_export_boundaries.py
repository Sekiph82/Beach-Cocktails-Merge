"""Regression contract for safe export exclusions without deleting source."""
import importlib.util
import hashlib
import json
from pathlib import Path
import re
import struct
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "check_export_boundaries", ROOT / "tools" / "release" / "check_export_boundaries.py"
)
release = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(release)
sys.path.insert(0, str(ROOT / "tools" / "release"))
from pck_directory import PCKInventoryError, inventory_pck  # noqa: E402
from inspect_godot_pck import forbidden_entries, metadata_leaks  # noqa: E402


def make_pck(entries: list[tuple[str, bytes]]) -> bytearray:
    """Small Godot 4 PCK v4 fixture with Godot's 4-byte directory path padding."""
    file_base = 112
    data = bytearray(b"\0" * file_base)
    records = []
    for name, payload in entries:
        while len(data) % 32:
            data.append(0)
        offset = len(data) - file_base
        data.extend(payload)
        records.append((name.encode("utf-8"), offset, payload, hashlib.md5(payload).digest()))
    while len(data) % 32:
        data.append(0)
    directory_offset = len(data)
    directory = bytearray(struct.pack("<I", len(records)))
    for name, offset, payload, md5 in records:
        name_padded = name + b"\0" * ((-len(name)) % 4)
        directory.extend(struct.pack("<I", len(name_padded)))
        directory.extend(name_padded)
        directory.extend(struct.pack("<QQ", offset, len(payload)))
        directory.extend(md5)
        directory.extend(struct.pack("<I", 0))
    data.extend(directory)
    struct.pack_into("<6IQQ", data, 0, 0x43504447, 4, 4, 7, 2, 2, file_base, directory_offset)
    return data


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

    def test_only_proven_asset_generation_metadata_is_excluded(self):
        for name in ("Android Store Candidate (NOT SHIPPING)", "iOS Store Candidate (NOT SHIPPING)"):
            _name, _platform, _include, exclude = release.read_preset(ROOT, name)
            for path in (
                "assets/ui_assets/ASSET_MANIFEST.json",
                "assets/ui_assets/ASSET_DIMENSIONS.csv",
                "assets/ui_assets/V05_ASSET_REGEN_STATUS.csv",
                "assets/ui_assets/ISLAND_UNIQUENESS_REPORT.json",
                "assets/ui_assets/ASSET_DIMENSIONS.width.translation",
                "assets/ui_assets/V05_ASSET_REGEN_STATUS.status.translation",
            ):
                with self.subTest(preset=name, path=path):
                    self.assertTrue(release.matches(path, exclude), path)
            # Generated Godot import/remap maps are retained pending engine dependency proof.
            self.assertFalse(release.matches("assets/ui_assets/ASSET_DIMENSIONS.csv.import", exclude))
            self.assertFalse(release.matches("assets/ui_assets/main_menu/logo.png.import", exclude))

    def test_authoritative_pck_index_includes_hidden_forbidden_paths(self):
        fixture = make_pck([("docs/.private/release_notes.txt", b"hidden forbidden content")])
        with tempfile.TemporaryDirectory(dir=ROOT / ".godot" / "bcm_release_preflight") as temp:
            path = Path(temp) / "hidden_forbidden.pck"
            path.write_bytes(fixture)
            report = inventory_pck(path)
        self.assertTrue(report["entries"][0]["hidden_path"])
        self.assertEqual(report["entries"][0]["path"], "docs/.private/release_notes.txt")
        self.assertEqual(forbidden_entries(report["entries"]), ["docs/.private/release_notes.txt"])
        self.assertEqual(metadata_leaks([{"path": "assets/ui_assets/V05_ASSET_REGEN_STATUS.visual.translation"}]), ["assets/ui_assets/V05_ASSET_REGEN_STATUS.visual.translation"])

    def test_authoritative_pck_reader_fails_closed_on_unaccounted_payload_bytes(self):
        fixture = make_pck([(".godot/imported/runtime.res", b"payload")])
        file_base = 112
        payload_end = file_base + len(b"payload")
        fixture[payload_end] = 0x7f  # Nonzero byte in what must be a zero alignment gap.
        with tempfile.TemporaryDirectory(dir=ROOT / ".godot" / "bcm_release_preflight") as temp:
            path = Path(temp) / "incomplete_coverage.pck"
            path.write_bytes(fixture)
            with self.assertRaisesRegex(PCKInventoryError, "PCK_INVENTORY_INCOMPLETE"):
                inventory_pck(path)

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

    def test_release_checker_reads_helper_result_from_nested_engine_report(self):
        self.assertEqual(
            release.package_debug_helper_status({"engine_checks": {"godot_ai_game_helper_present": False}}),
            "EXCLUDED_FROM_INSPECTED_PCK",
        )
        self.assertEqual(
            release.package_debug_helper_status({"engine_checks": {"godot_ai_game_helper_present": True}}),
            "PRESENT_IN_INSPECTED_PCK",
        )

    def test_store_copy_fields_stay_within_declared_limits(self):
        copy = (ROOT / "docs" / "release" / "store_media" / "BCM_M34_STORE_COPY_V02.md").read_text(encoding="utf-8")
        for line in copy.splitlines():
            field = re.match(r"^- (?:Name|Title|Subtitle|Short description): `([^`]+)` \((\d+)/(30|80) characters\)$", line)
            if field:
                value, declared, limit = field.groups()
                self.assertEqual(len(value), int(declared), line)
                self.assertLessEqual(len(value), int(limit), line)
            keywords = re.match(r"^- Keywords: `([^`]+)` \((\d+)/100 UTF-8 bytes\)$", line)
            if keywords:
                value, declared = keywords.groups()
                self.assertEqual(len(value.encode("utf-8")), int(declared), line)
                self.assertLessEqual(len(value.encode("utf-8")), 100, line)
        descriptions = re.findall(r"^> (.+)$", copy, flags=re.MULTILINE)
        self.assertGreaterEqual(len(descriptions), 2)
        self.assertTrue(all(len(description) <= 4000 for description in descriptions))

    def test_store_feature_graphic_and_draft_states_are_validated(self):
        graphic = ROOT / "docs" / "release" / "store_media" / "google_play_feature_graphic_v02.png"
        data = graphic.read_bytes()
        self.assertEqual(data[:8], b"\x89PNG\r\n\x1a\n")
        width, height, bit_depth, color_type = struct.unpack(">IIBB", data[16:26])
        self.assertEqual((width, height), (1024, 500))
        self.assertEqual((bit_depth, color_type), (8, 2))  # Opaque RGB PNG, no alpha channel.
        privacy = (ROOT / "docs" / "release" / "store_media" / "BCM_M34_PRIVACY_AND_SUPPORT_DRAFT_EN_TR_V02.md").read_text(encoding="utf-8")
        capture = (ROOT / "docs" / "release" / "store_media" / "BCM_M34_SCREENSHOT_LAYOUT_PLAN_V02.md").read_text(encoding="utf-8")
        self.assertIn("OWNER_REVIEW_REQUIRED", privacy)
        self.assertIn("CAPTURE_PENDING", capture)
        self.assertIn("OWNER_VISUAL_APPROVAL_REQUIRED", capture)


if __name__ == "__main__":
    unittest.main()
