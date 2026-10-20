#!/usr/bin/env python3
"""Inspect a Godot PCK by mounting it through Godot's resource-pack API."""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys


def main() -> int:
    root = Path(__file__).resolve().parents[2]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pack", required=True, type=Path, help="PCK file inside the canonical project")
    parser.add_argument("--godot", default=shutil.which("godot"), help="Godot 4.7 executable")
    parser.add_argument(
        "--manifest-output",
        type=Path,
        help="Optional JSON output path inside the canonical project",
    )
    args = parser.parse_args()
    pack = args.pack.resolve()
    if not pack.is_relative_to(root) or not pack.is_file() or pack.suffix.lower() != ".pck":
        parser.error("--pack must be an existing .pck file inside the canonical project")
    if not args.godot:
        parser.error("Godot executable was not found; pass --godot explicitly")
    manifest_output = args.manifest_output.resolve() if args.manifest_output else None
    if manifest_output and not manifest_output.is_relative_to(root):
        parser.error("--manifest-output must stay inside the canonical project")

    sandbox = root / ".godot" / "bcm_release_preflight" / "pck_inspector"
    sandbox.mkdir(parents=True, exist_ok=True)
    (sandbox / "project.godot").write_text(
        'config_version=5\n[application]\nconfig/name="BCM PCK Inspection"\n',
        encoding="utf-8",
    )
    script_source = Path(__file__).with_suffix(".gd").read_text(encoding="utf-8")
    (sandbox / "inspect_godot_pck.gd").write_text(script_source, encoding="utf-8")
    proc = subprocess.run(
        [
            args.godot,
            "--headless",
            "--path",
            str(sandbox),
            "--script",
            "res://inspect_godot_pck.gd",
            "--",
            str(pack),
        ],
        capture_output=True,
        text=True,
        check=False,
    )
    marker = "BCM_PCK_REPORT="
    report_line = next((line for line in proc.stdout.splitlines() if marker in line), None)
    if report_line is None:
        print(
            json.dumps(
                {"status": "BLOCKED", "godot_exit": proc.returncode, "stdout": proc.stdout[-4000:], "stderr": proc.stderr[-4000:]},
                indent=2,
            )
        )
        return 2
    report = json.loads(report_line.split(marker, 1)[1])
    digest = hashlib.sha256()
    with pack.open("rb") as data:
        for chunk in iter(lambda: data.read(1024 * 1024), b""):
            digest.update(chunk)
    report["artifact"] = {
        "path": pack.relative_to(root).as_posix(),
        "bytes": pack.stat().st_size,
        "sha256": digest.hexdigest(),
    }
    if proc.returncode != 0 and report.get("status") == "PASS":
        report["status"] = "FAIL"
    if manifest_output:
        manifest_output.parent.mkdir(parents=True, exist_ok=True)
        with manifest_output.open("w", encoding="utf-8", newline="\n") as manifest_file:
            manifest_file.write(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
        report["manifest_output"] = manifest_output.relative_to(root).as_posix()
    summary = dict(report)
    summary.pop("file_manifest", None)
    print(json.dumps(summary, indent=2, ensure_ascii=False))
    return 0 if report.get("status") == "PASS" and proc.returncode == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
