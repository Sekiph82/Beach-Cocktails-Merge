"""Current regression suite runner.

Runs headless Godot probes, each in its own isolated APPDATA/LOCALAPPDATA so
normal game saves are never touched, with a per-probe timeout.

usage:
  python tests/run_regressions.py            # core suite
  python tests/run_regressions.py --all      # explicitly inventoried isolated headless probes
  python tests/run_regressions.py --display  # only the probes that need a real window
  python tests/run_regressions.py --json out.json
  python tests/run_regressions.py --strict-runtime-errors  # also fail on anchored Godot errors
Exit code 0 only if every selected probe exits 0.
With --strict-runtime-errors, each probe must also have no classified Godot runtime/parser errors.
The --all inventory prints display, harness, negative-only, Node E2E, legacy-disabled,
and support-script categories separately; these are not counted as skipped passes.
"""
import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
# owner storage rule 2026-10-17: task temp output stays inside the project (.godot/ is gitignored)
SANDBOX_ROOT = REPO / ".godot" / "bcm_sandboxes"
SANDBOX_ROOT.mkdir(parents=True, exist_ok=True)
SANDBOX_ROOT_RESOLVED = SANDBOX_ROOT.resolve()
ANSI_ESCAPE = re.compile(r"\x1b\[[0-9;]*m")
GODOT_RUNTIME_ERROR = re.compile(r"^\s*(SCRIPT ERROR|Parse Error|ERROR):")
GODOT_STACK_LINE = re.compile(r"^\s*(?:\[\d+\]|at:)")

CORE = [
    "tests/m34_economy_closure_probe.gd",
    "tests/m34_daily_rewards_probe.gd",
    "tests/m34_rewarded_ads_lifecycle_probe.gd",
    "tests/m34_mobile_reward_durable_delivery_probe.gd",
    "tests/m34_mobile_reward_async_controller_probe.gd",
    "tests/m34_mobile_reward_http_transport_probe.gd",
    "tests/m34_admob_test_adapter_probe.gd",
    "tests/m34_store_catalog_boundary_probe.gd",
    "tests/m34_native_export_contract_probe.gd",
    "tests/m34_play_billing_test_adapter_probe.gd",
    "tests/m33_campaign_navigation_probe.gd",
    "tests/m14_gameplay_session_bridge_probe.gd",
    "tests/m15_vip_boosters_economy_probe.gd",
    "tests/m34_production_routes_probe.gd",
    "tests/m34_r10_scene_uid_probe.gd",
    "tests/m34_r09_slim_export_content_probe.gd",
    "tests/m34_r10_vip_optional_rule_probe.gd",
    "tests/m33_campaign_content_probe.gd",
]

# Capture/GUI probes: they read the rendered viewport, so they need a real window
# (they hang or report "capture image unavailable" headless). m33_r05_r02_* also
# require the window to open at the exact requested size (fails under OS DPI scaling).
NEEDS_DISPLAY = {
    "tests/m07_r06_owner_layout_probe.gd",
    "tests/m12_world_map_gui_capture.gd",
    "tests/m26_002_campaign_unlock_presentation_probe.gd",
    "tests/m18_v02_r01_replay_capture_probe.gd",
    "tests/m27_003_legacy_m18_v02_replay_capture_probe.gd",
    "tests/m20_runtime_capture_probe.gd",
    "tests/m27_003_legacy_m20_runtime_capture_probe.gd",
    "tests/m21_mobile_qa_probe.gd",
    "tests/m27_003_mobile_qa_probe.gd",
    "tests/m27_003_legacy_m07_r06_owner_layout_probe.gd",
    "tests/m21_home_exact_target_r04_probe.gd",
    "tests/m23_r03_m21_tall_navigation_diagnostic.gd",
    "tests/m32_tutorial_mobile_capture_probe.gd",
    "tests/m33_r05_capture_tabletops.gd",
    "tests/m33_r05_r02_capture_tabletops.gd",
    "tests/m33_r05_r02_scale_comparison.gd",
    "tests/m34_mobile_capture_probe.gd",
    "tests/m34_r03_owner_review_capture.gd",
}
# Probes that only make sense under their own launcher (custom user-data profile).
NEEDS_HARNESS = {
    "tests/m33_r06_owner_playtest_probe.gd": "tools/BCM-M33-R06-Owner-Playtest.ps1",
}
LEGACY_DISABLED_PROBES = frozenset({"tests/m27_user_data_isolation_probe.gd"})

# Explicit inventory for --all. A discovered SceneTree script is never silently
# treated as an ordinary probe: each path must be in exactly one category.
# Headless probes below are independently launched by run() with isolated profiles.
ALL_HEADLESS_PROBES = frozenset("""
tests/closeout-001/m09_audio_haptics_probe_closeout.gd
tests/closeout-001/m15_vip_boosters_economy_probe_closeout.gd
tests/closeout-001/m21_full_progression_probe_closeout.gd
tests/closeout-001/m22_001_plugin_contract_probe_closeout.gd
tests/closeout-001/m22_002_semantic_bridge_probe_closeout.gd
tests/closeout-001/m22_003_effect_policy_probe_closeout.gd
tests/closeout-001/m23_001_micro_feedback_probe_closeout.gd
tests/closeout-001/m23_002_merge_feedback_probe_closeout.gd
tests/closeout-001/m23_003_combo_milestone_probe_closeout.gd
tests/closeout-001/m23_closeout_001_color_lifecycle_probe.gd
tests/closeout-001/m23_closeout_001_color_lifecycle_stress.gd
tests/m01_contract_probe.gd
tests/m02_physics_regression.gd
tests/m03_economy_regression.gd
tests/m04_asset_import_probe.gd
tests/m05_sprite_integration_probe.gd
tests/m07_hud_composition_probe.gd
tests/m07_r04_focused_probe.gd
tests/m07_r05_hud_adaptation_probe.gd
tests/m08_to_go_delivery_probe.gd
tests/m09_audio_haptics_probe.gd
tests/m10_campaign_architecture_probe.gd
tests/m11_save_migration_progression_probe.gd
tests/m12_world_map_probe.gd
tests/m13_island_map_probe.gd
tests/m14_gameplay_session_bridge_probe.gd
tests/m15_vip_boosters_economy_probe.gd
tests/m16_sunny_cove_content_probe.gd
tests/m17_vip_optionality_probe.gd
tests/m18_completion_progression_probe.gd
tests/m18_cumulative_reward_claim_remediation_probe.gd
tests/m18_cumulative_star_rewards_probe.gd
tests/m18_integration_probe.gd
tests/m18_island_map_replay_probe.gd
tests/m18_replay_persistence_probe.gd
tests/m18_star_contract_probe.gd
tests/m18_untimed_cumulative_reward_probe.gd
tests/m20_app_shell_probe.gd
tests/m20_campaign_ux_probe.gd
tests/m20_migration_probe.gd
tests/m20_onboarding_probe.gd
tests/m20_pause_lifecycle_probe.gd
tests/m20_settings_probe.gd
tests/m21_full_progression_probe.gd
tests/m21_home_frontier_authority_r08_probe.gd
tests/m21_home_label_r07_probe.gd
tests/m21_island_map_full_background_followup_r01_probe.gd
tests/m21_island_map_node_visual_r07_probe.gd
tests/m21_island_map_page_focus_r07_probe.gd
tests/m21_owner_f5_remediation_v03_progression_probe.gd
tests/m21_owner_runtime_closure_v02_r01_performance_probe.gd
tests/m21_owner_runtime_closure_v02_r01_progression_probe.gd
tests/m21_performance_profile_probe.gd
tests/m21_r04_gameplay_surface_authority_probe.gd
tests/m21_release_persistence_probe.gd
tests/m21_world_map_production_v05_probe.gd
tests/m22_001_plugin_contract_probe.gd
tests/m22_002_semantic_bridge_probe.gd
tests/m22_003_effect_policy_probe.gd
tests/m23_001_micro_feedback_probe.gd
tests/m23_002_merge_feedback_probe.gd
tests/m23_003_combo_milestone_probe.gd
tests/m23_r03_color_restoration_probe.gd
tests/m24_001_order_progress_probe.gd
tests/m24_002_order_complete_probe.gd
tests/m24_003_vip_feedback_probe.gd
tests/m25_move_limit_probe.gd
tests/m25_result_presentation_probe.gd
tests/m26_001_island_map_presentation_probe.gd
tests/m26_003_reward_primary_feedback_probe.gd
tests/m27_001_lifecycle_stress_probe.gd
tests/m27_002_campaign_unlock_probe.gd
tests/m27_002_combo_feedback_probe.gd
tests/m27_002_effect_policy_probe.gd
tests/m27_002_island_map_probe.gd
tests/m27_002_merge_feedback_probe.gd
tests/m27_002_micro_feedback_probe.gd
tests/m27_002_order_complete_probe.gd
tests/m27_002_order_progress_probe.gd
tests/m27_002_result_presentation_probe.gd
tests/m27_002_reward_primary_probe.gd
tests/m27_002_vip_feedback_probe.gd
tests/m27_003_full_progression_probe.gd
tests/m27_003_legacy_m08_to_go_delivery_probe.gd
tests/m27_003_legacy_m09_audio_haptics_probe.gd
tests/m27_003_legacy_m15_vip_boosters_economy_probe.gd
tests/m27_003_main_boot_probe.gd
tests/m27_003_move_limit_probe.gd
tests/m27_003_plugin_fallback_probe.gd
tests/m32_campaign_contract_probe.gd
tests/m32_economy_shop_probe.gd
tests/m32_economy_tutorial_probe.gd
tests/m32_focus_booster_probe.gd
tests/m32_tiki_vertical_slice_probe.gd
tests/m33_campaign_content_probe.gd
tests/m33_campaign_navigation_probe.gd
tests/m33_content_unavailable_probe.gd
tests/m33_r05_tabletop_probe.gd
tests/m33_tiki_compatibility_probe.gd
tests/m34_admob_test_adapter_probe.gd
tests/m34_daily_rewards_probe.gd
tests/m34_economy_closure_probe.gd
tests/m34_mobile_reward_async_controller_probe.gd
tests/m34_mobile_reward_durable_delivery_probe.gd
tests/m34_mobile_reward_http_transport_probe.gd
tests/m34_native_export_contract_probe.gd
tests/m34_play_billing_test_adapter_probe.gd
tests/m34_production_routes_probe.gd
tests/m34_r09_slim_export_content_probe.gd
tests/m34_r10_scene_uid_probe.gd
tests/m34_r10_vip_optional_rule_probe.gd
tests/m34_rewarded_ads_lifecycle_probe.gd
tests/m34_store_catalog_boundary_probe.gd
tests/r09_no_input_runtime_regression.gd
tests/r10_desktop_idle_smoke.gd
tests/r10_v10_visual_hull_containment_probe.gd
tests/touch_single_shot_probe.gd
""".split())

# These do not belong in --all; their distinct behavior is executed explicitly
# by --isolation-only or the Node orchestrator, while support is never runnable.
ISOLATION_ONLY_PROBES = frozenset({"tests/m34_sandbox_guard_negative_probe.gd"})
NODE_E2E_PROBES = frozenset({"tests/m34_worker_sqlite_godot_e2e_probe.gd"})
SUPPORT_SCENE_TREES = frozenset({"tests/support/isolated_test_scene_tree.gd"})


def discover_all_categories() -> dict[str, frozenset[str]]:
    """Return auditable runnable and separately launched SceneTree categories."""
    discovered = frozenset(
        path.relative_to(REPO).as_posix()
        for path in (REPO / "tests").rglob("*.gd")
        if "fixtures" not in path.parts
        and ("extends SceneTree" in path.read_text(encoding="utf-8", errors="ignore")[:400]
             or "isolated_test_scene_tree.gd" in path.read_text(encoding="utf-8", errors="ignore")[:400])
    )
    categories = {
        "headless": ALL_HEADLESS_PROBES,
        "display": frozenset(NEEDS_DISPLAY),
        "custom_harness": frozenset(NEEDS_HARNESS),
        "legacy_disabled": LEGACY_DISABLED_PROBES,
        "isolation_only": ISOLATION_ONLY_PROBES,
        "node_e2e": NODE_E2E_PROBES,
        "support": SUPPORT_SCENE_TREES,
    }
    classified = set().union(*categories.values())
    if len(classified) != sum(map(len, categories.values())):
        raise RuntimeError("SceneTree probe categories overlap")
    if discovered != classified:
        unknown = sorted(discovered - classified)
        stale = sorted(classified - discovered)
        raise RuntimeError(f"SceneTree discovery inventory mismatch; unclassified={unknown}; missing={stale}")
    return categories


def all_headless_probes() -> list[str]:
    """Return the frozen --all headless list after validating every category."""
    return sorted(discover_all_categories()["headless"])


def classify_godot_runtime_errors(output: str) -> list[dict[str, object]]:
    """Return anchored Godot fatal/runtime diagnostics and their stack locations.

    This deliberately ignores ordinary prose containing words such as "error".
    Godot's script/parser/runtime diagnostics use stable line prefixes; following
    stack frames are retained so a strict verdict has actionable source context.
    """
    lines = [ANSI_ESCAPE.sub("", line) for line in output.splitlines()]
    findings: list[dict[str, object]] = []
    for index, line in enumerate(lines):
        match = GODOT_RUNTIME_ERROR.match(line)
        if match is None:
            continue
        stack: list[str] = []
        cursor = index + 1
        while cursor < len(lines) and GODOT_STACK_LINE.match(lines[cursor]):
            stack.append(lines[cursor])
            cursor += 1
        findings.append({"kind": match.group(1), "message": line.strip(), "stack": stack})
    return findings


def probe_verdict(exit_code: int | None, runtime_errors: list[dict[str, object]], strict_runtime_errors: bool) -> dict[str, bool]:
    exit_code_pass = exit_code == 0
    strict_pass = exit_code_pass and not runtime_errors
    return {
        "exit_code_pass": exit_code_pass,
        "strict_pass": strict_pass,
        "pass": strict_pass if strict_runtime_errors else exit_code_pass,
    }


def run(godot: str, args: list[str], timeout: int, tutorial_done: bool = True,
        strict_runtime_errors: bool = False) -> dict:
    sandbox = Path(tempfile.mkdtemp(prefix="bcm_reg_", dir=SANDBOX_ROOT))
    sandbox_resolved = sandbox.resolve()
    if not sandbox_resolved.is_relative_to(SANDBOX_ROOT_RESOLVED) or sandbox_resolved == SANDBOX_ROOT_RESOLVED:
        raise RuntimeError(f"Refusing test profile outside project sandbox: {sandbox_resolved}")
    app_data = sandbox_resolved / "r"
    local_app_data = sandbox_resolved / "l"
    app_data.mkdir()
    local_app_data.mkdir()
    if tutorial_done:
        # Returning-player profile: the first-play gameplay tutorial (M32) holds the
        # result overlay until it finishes, which most campaign probes predate.
        user_dir = app_data / "Godot/app_userdata/CocktailMerge"
        user_dir.mkdir(parents=True)
        (user_dir / "gameplay_tutorial_state.json").write_text('{"schema_version":1,"current_step":6,"completed":true}', encoding="utf-8")
    env = dict(os.environ, APPDATA=str(app_data), LOCALAPPDATA=str(local_app_data),
               BCM_TEST_MODE="1", BCM_TEST_SANDBOX_ROOT=str(sandbox_resolved),
               BCM_TEST_BUILD_MARKER="NONSHIPPING_LOCAL_TEST")
    started = time.monotonic()
    try:
        proc = subprocess.run([godot, *args], cwd=REPO, env=env, capture_output=True, text=True,
                              encoding="utf-8", errors="replace", timeout=timeout)
        code, out = proc.returncode, proc.stdout + proc.stderr
    except subprocess.TimeoutExpired:
        code, out = None, "TIMEOUT"
    # Keep every generated test profile under .godot/bcm_sandboxes for audit;
    # do not remove it, even after a failure or timeout.
    runtime_errors = classify_godot_runtime_errors(out)
    verdict = probe_verdict(code, runtime_errors, strict_runtime_errors)
    user_dir = app_data / "Godot/app_userdata/CocktailMerge"
    def sha256_or_none(path: Path) -> str | None:
        if not path.is_file():
            return None
        return hashlib.sha256(path.read_bytes()).hexdigest()
    return {"exit_code": code, **verdict, "runtime_errors": runtime_errors,
            "wall_ms": int((time.monotonic() - started) * 1000),
            "error_lines": [str(item["message"]) for item in runtime_errors[:10]],
            "tail": out.splitlines()[-3:], "sandbox_root": str(sandbox_resolved),
            "user_data_root": str(user_dir),
            "campaign_save_sha256": sha256_or_none(user_dir / "campaign_save.json"),
            "campaign_save_backup_sha256": sha256_or_none(user_dir / "campaign_save.json.bak")}


def run_negative_isolation_probe(godot: str, timeout: int, strict_runtime_errors: bool = False) -> dict:
    sandbox = Path(tempfile.mkdtemp(prefix="bcm_negative_", dir=SANDBOX_ROOT)).resolve()
    if not sandbox.is_relative_to(SANDBOX_ROOT_RESOLVED) or sandbox == SANDBOX_ROOT_RESOLVED:
        raise RuntimeError(f"Refusing negative-test profile outside project sandbox: {sandbox}")
    app_data, local_app_data = sandbox / "r", sandbox / "l"
    app_data.mkdir()
    local_app_data.mkdir()
    env = dict(os.environ, APPDATA=str(app_data), LOCALAPPDATA=str(local_app_data))
    for key in ("BCM_TEST_MODE", "BCM_TEST_SANDBOX_ROOT", "BCM_TEST_BUILD_MARKER"):
        env.pop(key, None)
    started = time.monotonic()
    try:
        proc = subprocess.run([godot, "--headless", "--path", ".", "--script",
                               "res://tests/m34_mobile_reward_async_controller_probe.gd"],
                              cwd=REPO, env=env, capture_output=True, text=True,
                              encoding="utf-8", errors="replace", timeout=timeout)
        output, code = proc.stdout + proc.stderr, proc.returncode
    except subprocess.TimeoutExpired:
        output, code = "TIMEOUT", None
    refused_before_test = code == 70 and "BCM_TEST_SANDBOX_ABORT=" in output
    runtime_errors = classify_godot_runtime_errors(output)
    user_dir = app_data / "Godot/app_userdata/CocktailMerge"
    touched_saves = (user_dir / "campaign_save.json").exists() or (user_dir / "campaign_save.json.bak").exists()
    strict_pass = not runtime_errors
    return {"exit_code": code, "exit_code_pass": refused_before_test and not touched_saves,
            "strict_pass": strict_pass,
            "pass": refused_before_test and not touched_saves and (strict_pass or not strict_runtime_errors),
            "runtime_errors": runtime_errors,
            "error_lines": [str(item["message"]) for item in runtime_errors[:10]],
            "wall_ms": int((time.monotonic() - started) * 1000), "sandbox_root": str(sandbox),
            "user_data_root": str(user_dir), "campaign_save_or_backup_created": touched_saves,
            "tail": output.splitlines()[-3:]}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--display", action="store_true")
    parser.add_argument("--isolation-only", action="store_true", help="run only the fail-closed sandbox refusal probe")
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--timeout", type=int, default=240)
    parser.add_argument("--strict-runtime-errors", action="store_true",
                        help="fail a probe on anchored Godot SCRIPT ERROR, Parse Error, or ERROR diagnostics, even when exit code is zero")
    parser.add_argument("--json", default="")
    parser.add_argument("probes", nargs="*")
    args = parser.parse_args()
    godot = shutil.which("godot_console.exe") or shutil.which("godot")

    if not godot:
        print("FAIL isolation_refusal godot_executable_not_found", flush=True)
        return 1
    refusal = run_negative_isolation_probe(godot, min(args.timeout, 60), args.strict_runtime_errors)
    if not refusal["pass"]:
        print(f"FAIL isolation_refusal {refusal}", flush=True)
        return 1
    print(f"PASS isolation_refusal user_data={refusal['user_data_root']} saves_created=false", flush=True)
    if args.isolation_only:
        print("SUMMARY 1/1 passed", flush=True)
        if args.json:
            Path(args.json).write_text(json.dumps({"isolation_refusal": refusal}, indent=1) + "\n", encoding="utf-8")
        return 0

    categories = discover_all_categories()
    if args.display:
        probes = sorted(categories["display"])
    elif args.probes:
        probes = args.probes
    elif args.all:
        probes = sorted(categories["headless"])
        print("ALL_SCOPE headless_run=%d display_separate=%d custom_harness_separate=%d "
              "legacy_disabled=%d isolation_only_separate=%d node_e2e_separate=%d support_nonrunnable=%d" % (
                  len(categories["headless"]), len(categories["display"]), len(categories["custom_harness"]),
                  len(categories["legacy_disabled"]), len(categories["isolation_only"]), len(categories["node_e2e"]),
                  len(categories["support"])), flush=True)
    else:
        probes = CORE

    results = {"editor_import": run(godot, ["--headless", "--editor", "--path", ".", "--quit"], 600,
                                    strict_runtime_errors=args.strict_runtime_errors)}
    print(f"{'PASS' if results['editor_import']['pass'] else 'FAIL'} editor_import", flush=True)
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = {p: pool.submit(run, godot,
                                  ([] if p in NEEDS_DISPLAY else ["--headless"]) + ["--path", ".", "--script", f"res://{p}"],
                                  args.timeout, "tutorial" not in p, args.strict_runtime_errors) for p in probes}
        for p, f in futures.items():
            results[p] = f.result()
            print(f"{'PASS' if results[p]['pass'] else 'FAIL'} {p} exit={results[p]['exit_code']} {results[p]['wall_ms']}ms", flush=True)
    results["startup_smoke"] = run(godot, ["--headless", "--path", ".", "--quit-after", "3"], 120,
                                   strict_runtime_errors=args.strict_runtime_errors)
    print(f"{'PASS' if results['startup_smoke']['pass'] else 'FAIL'} startup_smoke", flush=True)

    results["isolation_refusal"] = refusal
    passed = sum(r["pass"] for r in results.values())
    print(f"SUMMARY {passed}/{len(results)} passed")
    if args.json:
        Path(args.json).write_text(json.dumps(results, indent=1) + "\n", encoding="utf-8")
    return 0 if passed == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())
