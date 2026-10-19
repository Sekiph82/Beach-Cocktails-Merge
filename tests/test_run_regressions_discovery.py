"""Contract test for explicit SceneTree test-runner classifications."""
import importlib.util
import unittest
from pathlib import Path

MODULE_PATH = Path(__file__).with_name("run_regressions.py")
SPEC = importlib.util.spec_from_file_location("bcm_run_regressions", MODULE_PATH)
RUNNER = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(RUNNER)


class ProbeDiscoveryContract(unittest.TestCase):
    def test_all_scene_tree_scripts_have_one_explicit_category(self):
        categories = RUNNER.discover_all_categories()
        self.assertEqual(
            {"headless", "display", "custom_harness", "legacy_disabled", "isolation_only", "node_e2e", "support"},
            set(categories),
        )
        self.assertEqual({
            "headless": 117,
            "display": 18,
            "custom_harness": 1,
            "legacy_disabled": 1,
            "isolation_only": 1,
            "node_e2e": 1,
            "support": 1,
        }, {name: len(paths) for name, paths in categories.items()})

    def test_nonstandard_probes_never_enter_ordinary_all(self):
        categories = RUNNER.discover_all_categories()
        self.assertEqual({"tests/m34_sandbox_guard_negative_probe.gd"}, categories["isolation_only"])
        self.assertEqual({"tests/m34_worker_sqlite_godot_e2e_probe.gd"}, categories["node_e2e"])
        self.assertEqual({"tests/support/isolated_test_scene_tree.gd"}, categories["support"])
        self.assertEqual({
            "tests/m33_r06_owner_playtest_probe.gd",
        }, categories["custom_harness"])
        self.assertEqual({"tests/m27_user_data_isolation_probe.gd"}, categories["legacy_disabled"])
        self.assertTrue(categories["display"].isdisjoint(categories["headless"]))
        self.assertEqual(sorted(categories["headless"]), RUNNER.all_headless_probes())

    def test_real_gl_capture_probe_is_classified_as_display_required(self):
        path = "tests/m26_002_campaign_unlock_presentation_probe.gd"
        source = (RUNNER.REPO / path).read_text(encoding="utf-8")
        self.assertIn(path, RUNNER.NEEDS_DISPLAY)
        self.assertNotIn(path, RUNNER.ALL_HEADLESS_PROBES)
        self.assertIn("DisplayServer.window_set_mode(", source)
        self.assertIn("get_viewport().get_texture().get_image()", source)
        self.assertIn('"real GL framebuffer saved: %s"', source)

    def test_runtime_error_classifier_keeps_stack_context_and_ignores_benign_prose(self):
        output = """M34 PASS: error state is handled
ERROR: Unable to start the timer because it's not inside the scene tree. Either add it or set autostart to true.
   at: start (scene/main/node.cpp:1234)
   [0] _start_timer (res://scripts/campaign/ads_service.gd:281)
   [1] show_rewarded (res://scripts/campaign/ads_service.gd:215)
SCRIPT ERROR: Invalid call. Nonexistent function.
   [0] _run (res://tests/sample_probe.gd:42)
"""
        findings = RUNNER.classify_godot_runtime_errors(output)
        self.assertEqual(["ERROR", "SCRIPT ERROR"], [finding["kind"] for finding in findings])
        self.assertEqual(2, len(findings))
        self.assertIn("ads_service.gd:281", "\n".join(findings[0]["stack"]))
        self.assertFalse(any("handled" in str(finding) for finding in findings))

    def test_strict_runtime_error_verdict_is_opt_in(self):
        errors = [{"kind": "ERROR", "message": "ERROR: sample", "stack": []}]
        self.assertEqual({"exit_code_pass": True, "strict_pass": False, "pass": True},
                         RUNNER.probe_verdict(0, errors, False))
        self.assertEqual({"exit_code_pass": True, "strict_pass": False, "pass": False},
                         RUNNER.probe_verdict(0, errors, True))
        self.assertFalse(RUNNER.probe_verdict(1, [], True)["pass"])


if __name__ == "__main__":
    unittest.main()
