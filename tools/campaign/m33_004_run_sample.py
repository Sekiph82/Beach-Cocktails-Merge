"""BCM-M33-004 sample runner (uncensored fixed-fps protocol).

Plays every level of the frozen owner-approved 100-level random sample
(seed 20261016, 10 per island) with the production game physics, several
seeded attempts per level, in parallel headless Godot processes.

Resumable: an attempt whose result JSON already exists is skipped.
Each Godot process gets an isolated APPDATA/LOCALAPPDATA so normal game
saves are never touched.

usage: python tools/campaign/m33_004_run_sample.py [--workers 8] [--attempts 1]
       python tools/campaign/m33_004_run_sample.py --retry-unwon --attempts 6
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
SELECTION = REPO / "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R23/qualification/r23_random_selection_seed_20261016_v01.json"
SELECTION_SHA256 = "ef21d5a3023ae7328424da4e459b667c6d6b0dbd567e7a2106cc9b9161d66eb2"
OUT = REPO / "coordination/sessions/BCM-M33-004-CLAUDE-V01/evidence/trials"
TRIAL_SCRIPT = "res://tools/campaign/m33_004_sample_trial.gd"
SEED_OFFSET = 100_000_000  # attempt k uses case_seed + k * SEED_OFFSET
TIMEOUT_SEC = 900


def attempt_seed(case_seed: int, k: int) -> int:
    return case_seed + k * SEED_OFFSET


def run_one(godot: str, entry: dict, k: int) -> str:
    seed = attempt_seed(int(entry["case_seed"]), k)
    out = OUT / f"{entry['island_id']}_L{int(entry['level_id']):03d}_a{k}.json"
    if out.exists():
        return f"skip {out.name}"
    sandbox = Path(tempfile.mkdtemp(prefix="m33_004_"))
    env = dict(os.environ, APPDATA=str(sandbox / "roaming"), LOCALAPPDATA=str(sandbox / "local"))
    (sandbox / "roaming").mkdir()
    (sandbox / "local").mkdir()
    tmp = out.with_suffix(".partial")
    cmd = [godot, "--headless", "--fixed-fps", "60", "--path", str(REPO), "--script", TRIAL_SCRIPT, "--",
           f"--t-island={entry['island_id']}", f"--t-level={entry['level_id']}", f"--t-seed={seed}", f"--t-output={tmp}"]
    started = time.monotonic()
    try:
        proc = subprocess.run(cmd, env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=TIMEOUT_SEC)
        code = proc.returncode
        stderr = proc.stderr
    except subprocess.TimeoutExpired:
        code, stderr = None, "PROCESS_TIMEOUT"
    finally:
        shutil.rmtree(sandbox, ignore_errors=True)
    if tmp.exists():
        record = json.loads(tmp.read_text(encoding="utf-8"))
        tmp.unlink()
    else:
        record = {"classification": "ERROR", "reason": "NO_RESULT", "island_id": entry["island_id"], "level_id": entry["level_id"], "seed": seed}
    record["attempt_index"] = k
    record["selection_round"] = entry["round"]
    record["process_exit_code"] = code
    record["process_wall_ms"] = int((time.monotonic() - started) * 1000)
    errors = [line for line in stderr.splitlines() if "ERROR" in line or "SCRIPT ERROR" in line]
    record["stderr_error_lines"] = errors[:20]
    out.write_text(json.dumps(record) + "\n", encoding="utf-8")
    return f"{record['classification']:<18} {out.name} shots={record.get('shots_used')}/{record.get('normal_4t_shot_cap')} wall={record['process_wall_ms']}ms"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workers", type=int, default=8)
    parser.add_argument("--attempts", type=int, default=1)
    parser.add_argument("--only", default="", help="island_id:level filter, e.g. party_beach:82")
    parser.add_argument("--retry-unwon", action="store_true", help="only levels with no recorded win yet")
    args = parser.parse_args()

    raw = SELECTION.read_bytes()
    if hashlib.sha256(raw).hexdigest() != SELECTION_SHA256:
        print("selection manifest SHA-256 mismatch; refusing to run", file=sys.stderr)
        return 3
    selection = json.loads(raw)["selection"]
    assert len(selection) == 100 and len({(e["island_id"], e["level_id"]) for e in selection}) == 100
    if args.only:
        island, level = args.only.split(":")
        selection = [e for e in selection if e["island_id"] == island and int(e["level_id"]) == int(level)]

    godot = shutil.which("godot_console.exe") or shutil.which("godot")
    OUT.mkdir(parents=True, exist_ok=True)
    if args.retry_unwon:
        won = set()
        for path in OUT.glob("*.json"):
            record = json.loads(path.read_text(encoding="utf-8"))
            if record.get("classification") == "WIN_OBSERVED":
                won.add((record["island_id"], int(record["level_id"])))
        selection = [e for e in selection if (e["island_id"], int(e["level_id"])) not in won]
    jobs = [(e, k) for k in range(args.attempts) for e in selection]  # attempt 0 for all levels first
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = [pool.submit(run_one, godot, e, k) for e, k in jobs]
        for done, future in enumerate(as_completed(futures), 1):
            print(f"[{done}/{len(jobs)}] {future.result()}", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
