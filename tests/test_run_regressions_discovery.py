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
            "headless": 118,
            "display": 17,
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


if __name__ == "__main__":
    unittest.main()
