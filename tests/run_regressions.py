"""Current regression suite runner.

Runs headless Godot probes, each in its own isolated APPDATA/LOCALAPPDATA so
normal game saves are never touched, with a per-probe timeout.

usage:
  python tests/run_regressions.py            # core suite
  python tests/run_regressions.py --all      # every tests/**/*.gd probe
  python tests/run_regressions.py --json out.json
Exit code 0 only if every selected probe exits 0.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]

CORE = [
    "tests/m34_economy_closure_probe.gd",
    "tests/m34_daily_rewards_probe.gd",
    "tests/m33_campaign_navigation_probe.gd",
    "tests/m14_gameplay_session_bridge_probe.gd",
    "tests/m15_vip_boosters_economy_probe.gd",
    "tests/m34_production_routes_probe.gd",
    "tests/m34_r10_scene_uid_probe.gd",
    "tests/m34_r09_slim_export_content_probe.gd",
    "tests/m34_r10_vip_optional_rule_probe.gd",
    "tests/m33_campaign_content_probe.gd",
]


def run(godot: str, args: list[str], timeout: int, tutorial_done: bool = True) -> dict:
    sandbox = Path(tempfile.mkdtemp(prefix="bcm_reg_"))
    (sandbox / "r").mkdir()
    (sandbox / "l").mkdir()
    if tutorial_done:
        # Returning-player profile: the first-play gameplay tutorial (M32) holds the
        # result overlay until it finishes, which most campaign probes predate.
        user_dir = sandbox / "r/Godot/app_userdata/CocktailMerge"
        user_dir.mkdir(parents=True)
        (user_dir / "gameplay_tutorial_state.json").write_text('{"schema_version":1,"current_step":6,"completed":true}', encoding="utf-8")
    env = dict(os.environ, APPDATA=str(sandbox / "r"), LOCALAPPDATA=str(sandbox / "l"))
    started = time.monotonic()
    try:
        proc = subprocess.run([godot, *args], cwd=REPO, env=env, capture_output=True, text=True,
                              encoding="utf-8", errors="replace", timeout=timeout)
        code, out = proc.returncode, proc.stdout + proc.stderr
    except subprocess.TimeoutExpired:
        code, out = None, "TIMEOUT"
    finally:
        shutil.rmtree(sandbox, ignore_errors=True)
    errors = [l for l in out.splitlines() if "SCRIPT ERROR" in l or "Parse Error" in l or l.startswith("ERROR")]
    return {"exit_code": code, "pass": code == 0, "wall_ms": int((time.monotonic() - started) * 1000),
            "error_lines": errors[:10], "tail": out.splitlines()[-3:]}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--all", action="store_true")
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--timeout", type=int, default=240)
    parser.add_argument("--json", default="")
    parser.add_argument("probes", nargs="*")
    args = parser.parse_args()
    godot = shutil.which("godot_console.exe") or shutil.which("godot")

    if args.probes:
        probes = args.probes
    elif args.all:
        probes = sorted(p.relative_to(REPO).as_posix() for p in (REPO / "tests").rglob("*.gd") if "fixtures" not in p.parts)
    else:
        probes = CORE

    results = {"editor_import": run(godot, ["--headless", "--editor", "--path", ".", "--quit"], 600)}
    print(f"{'PASS' if results['editor_import']['pass'] else 'FAIL'} editor_import", flush=True)
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = {p: pool.submit(run, godot, ["--headless", "--path", ".", "--script", f"res://{p}"], args.timeout, "tutorial" not in p) for p in probes}
        for p, f in futures.items():
            results[p] = f.result()
            print(f"{'PASS' if results[p]['pass'] else 'FAIL'} {p} exit={results[p]['exit_code']} {results[p]['wall_ms']}ms", flush=True)
    results["startup_smoke"] = run(godot, ["--headless", "--path", ".", "--quit-after", "3"], 120)
    print(f"{'PASS' if results['startup_smoke']['pass'] else 'FAIL'} startup_smoke", flush=True)

    passed = sum(r["pass"] for r in results.values())
    print(f"SUMMARY {passed}/{len(results)} passed")
    if args.json:
        Path(args.json).write_text(json.dumps(results, indent=1) + "\n", encoding="utf-8")
    return 0 if passed == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())
