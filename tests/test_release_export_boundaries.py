"""Regression contract for safe export exclusions without deleting source."""
import importlib.util
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
