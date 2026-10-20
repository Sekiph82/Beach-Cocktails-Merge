#!/usr/bin/env python3
"""Inspect a Godot PCK by mounting it through Godot's resource-pack API."""
from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
from pck_directory import PCKInventoryError, inventory_pck


FORBIDDEN_PREFIXES = (
    "coordination/", "docs/", "tests/", "tools/", "backend/", ".github/",
    "_m32_validation/", "addons/godot_ai/", "addons/GodotGooglePlayBilling/",
    "addons/AdmobPlugin/AdmobPlugin.gd", "addons/AdmobPlugin/plugin.cfg",
    "addons/AdmobPlugin/config/", "addons/AdmobPlugin/model/", "addons/AdmobPlugin/icon.png",
    "addons/game_feel_flow/editor/", "addons/game_feel_flow/icons/",
    "addons/game_feel_flow/plugin.gd", "addons/game_feel_flow/plugin.cfg",
    "addons/saltmire_spark/plugin.gd", "addons/saltmire_spark/plugin.cfg",
    "scripts/campaign/play_billing_test_adapter.gd", "scripts/campaign/admob_test_adapter.gd",
    "scripts/campaign/m17_seeded_validation_harness.gd", "scripts/campaign/m17_canonical_screening_model.gd",
    "scripts/campaign/m32_content_workflow.gd", "scripts/campaign/owner_playtest_console.gd",
    "assets/ui_assets/source/", "assets/ui_assets/v04_masters/", "assets/ui_assets/v05_sources/",
    "f647e4ff-b906-40e7-93f8-3c4b59d95b23.png", "data/campaign/shop_catalog.json",
)
REQUIRED_FILES = (
    "data/drinks.json", "data/ui/home_layout.json", "data/campaign/islands.json",
    "data/campaign/daily_rewards.json", "data/campaign/store_catalog.json",
    "data/campaign/ads_provider_policy.json", "data/campaign/content_manifest_m33.json",
    "data/campaign/content_generation_profiles_m33.json",
    *(f"data/campaign/levels/{name}.json" for name in (
        "sunny_cove", "tiki_island_full", "azure_bay", "coconut_beach", "sunset_island",
        "party_beach", "frozen_paradise", "volcano_bay", "billionaire_island", "final_island",
    )),
)


def forbidden_entries(entries: list[dict]) -> list[str]:
    return sorted(
        entry["path"] for entry in entries
        if any(entry["path"].startswith(prefix) for prefix in FORBIDDEN_PREFIXES)
        or entry["path"].startswith("addons/AdmobPlugin/bin/")
    )


def metadata_leaks(entries: list[dict]) -> list[str]:
    patterns = (
        "assets/ui_assets/ASSET_MANIFEST.json",
        "assets/ui_assets/ASSET_DIMENSIONS.csv",
        "assets/ui_assets/V05_ASSET_REGEN_STATUS.csv",
        "assets/ui_assets/*_REPORT.json",
        "assets/ui_assets/ASSET_DIMENSIONS.*.translation",
        "assets/ui_assets/V05_ASSET_REGEN_STATUS.*.translation",
    )
    return sorted(
        entry["path"] for entry in entries
        if any(fnmatch.fnmatchcase(entry["path"], pattern) for pattern in patterns)
    )


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
    try:
        pack_inventory = inventory_pck(pack)
    except (OSError, PCKInventoryError) as exc:
        print(json.dumps({"status": "PCK_INVENTORY_INCOMPLETE", "reason": str(exc)}, indent=2))
        return 1

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
    try:
        engine_report = json.loads(report_line.split(marker, 1)[1])
    except json.JSONDecodeError as exc:
        print(json.dumps({"status": "PCK_INVENTORY_INCOMPLETE", "reason": f"invalid Godot engine report: {exc}"}, indent=2))
        return 1
    digest = hashlib.sha256()
    with pack.open("rb") as data:
        for chunk in iter(lambda: data.read(1024 * 1024), b""):
            digest.update(chunk)
    entries = pack_inventory["entries"]
    paths = {entry["path"] for entry in entries}
    missing = sorted(set(REQUIRED_FILES) - paths)
    required_scene_loaded = engine_report.get("main_scene_resource_loaded") is True
    for entry in entries:
        if entry["path"].startswith(".godot/imported/"):
            entry["classification"] = "hidden_imported_resource"
        elif entry["path"].startswith(".godot/exported/"):
            entry["classification"] = "hidden_exported_resource"
        elif entry["hidden_path"]:
            entry["classification"] = "other_hidden_resource"
        else:
            entry["classification"] = "runtime_resource"
    banned = forbidden_entries(entries)
    leaked_metadata = metadata_leaks(entries)
    coverage_complete = (
        pack_inventory.get("status") == "PASS"
        and pack_inventory["file_payload_bytes"] + pack_inventory["alignment_padding"]["bytes"]
        == pack_inventory["payload_region"]["bytes"]
        and pack_inventory["alignment_padding"]["nonzero_bytes"] == 0
        and pack_inventory["trailing_bytes"]["nonzero_bytes"] == 0
    )
    passed = coverage_complete and not missing and not banned and not leaked_metadata and required_scene_loaded \
        and engine_report.get("status") == "PASS" \
        and engine_report.get("admob_runtime_source_preserved") is True \
        and engine_report.get("ads_default_and_placements_disabled") is True
    report = {
        "status": "PASS" if passed else ("PCK_INVENTORY_INCOMPLETE" if not coverage_complete else "FAIL"),
        "engine_checks": engine_report,
        "inventory_authority": pack_inventory["authority"],
        "inventory_complete": coverage_complete,
        "format_version": pack_inventory["format_version"],
        "godot_version": pack_inventory["godot_version"],
        "listed_file_count": pack_inventory["entry_count"],
        "hidden_entry_count": pack_inventory["hidden_entry_count"],
        "file_payload_bytes": pack_inventory["file_payload_bytes"],
        "payload_region": pack_inventory["payload_region"],
        "alignment_padding": pack_inventory["alignment_padding"],
        "directory": pack_inventory["directory"],
        "trailing_bytes": pack_inventory["trailing_bytes"],
        "coverage_explanation": "The directory index lists each file payload; remaining payload-region bytes are measured zero alignment padding. Directory bytes and any trailer are measured separately.",
        "forbidden_entries": banned,
        "excluded_metadata_leaks": leaked_metadata,
        "missing_required_runtime_files": missing,
        "main_scene_resource_loaded": required_scene_loaded,
        "admob_runtime_source_preserved": engine_report.get("admob_runtime_source_preserved", False),
        "admob_native_binary_entries": [entry["path"] for entry in entries if entry["path"].startswith("addons/AdmobPlugin/bin/")],
        "billing_plugin_entries": [entry["path"] for entry in entries if entry["path"].startswith("addons/GodotGooglePlayBilling/")],
        "billing_test_adapter_present": "scripts/campaign/play_billing_test_adapter.gd" in paths,
        "ads_default_and_placements_disabled": engine_report.get("ads_default_and_placements_disabled", False),
        "file_manifest": entries,
        "pck_layout": {key: value for key, value in pack_inventory.items() if key != "entries"},
    }
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
