#!/usr/bin/env python3
"""Read-only Godot export source/package inventory. Never claims a package is clean
without inspecting its actual contents (including nested PCK files)."""
from __future__ import annotations

import argparse
import configparser
import fnmatch
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import zipfile

REQUIRED_EXCLUDED = (
    "coordination/",
    "docs/",
    "tests/",
    "tools/",
    "backend/",
)
EXPECTED_JSON = (
    "data/drinks.json",
    "data/ui/home_layout.json",
    "data/campaign/islands.json",
    "data/campaign/daily_rewards.json",
    "data/campaign/store_catalog.json",
    "data/campaign/ads_provider_policy.json",
    "data/campaign/content_manifest_m33.json",
    "data/campaign/content_generation_profiles_m33.json",
    "data/campaign/levels/sunny_cove.json",
    "data/campaign/levels/tiki_island_full.json",
    "data/campaign/levels/azure_bay.json",
    "data/campaign/levels/coconut_beach.json",
    "data/campaign/levels/sunset_island.json",
    "data/campaign/levels/party_beach.json",
    "data/campaign/levels/frozen_paradise.json",
    "data/campaign/levels/volcano_bay.json",
    "data/campaign/levels/billionaire_island.json",
    "data/campaign/levels/final_island.json",
)
SOURCE_ONLY_ALERTS = (
    "addons/godot_ai/",
    "assets/ui_assets/source/",
    "assets/ui_assets/v04_masters/",
)
ALLOWED_ZIP_SUFFIXES = {".zip", ".apk", ".aab", ".ipa"}


def matches(path: str, patterns: list[str]) -> bool:
    return any(fnmatch.fnmatchcase(path, pattern) for pattern in patterns)


def read_preset(root: Path, name: str | None) -> tuple[str, str, list[str], list[str]]:
    cfg = configparser.ConfigParser(interpolation=None)
    cfg.read(root / "export_presets.cfg", encoding="utf-8")
    presets = [section for section in cfg.sections() if section.startswith("preset.") and not section.endswith(".options")]
    if not presets:
        raise ValueError("No Godot export presets")

    def unquote(raw: str) -> str:
        raw = raw.strip()
        # Godot writes quoted strings in export_presets.cfg. ConfigParser is
        # an INI reader and intentionally leaves those quotes in place.
        if len(raw) >= 2 and raw[0] == raw[-1] and raw[0] in "\"'":
            return raw[1:-1]
        return raw

    section = next((section for section in presets if unquote(cfg.get(section, "name", fallback="")) == name), None) if name else presets[0]
    if section is None:
        raise ValueError(f"Unknown preset: {name!r}")

    def value(key: str, fallback: str = "") -> str:
        return unquote(cfg.get(section, key, fallback=fallback))

    def patterns(key: str) -> list[str]:
        return [item.strip() for item in value(key).split(",") if item.strip()]

    return value("name"), value("platform"), patterns("include_filter"), patterns("exclude_filter")


def tracked(root: Path) -> list[str]:
    proc = subprocess.run(["git", "-C", str(root), "ls-files", "-z"], capture_output=True, check=True)
    return sorted(p.decode("utf-8", "surrogateescape").replace("\\", "/") for p in proc.stdout.split(b"\0") if p)


def archive_report(root: Path, filename: str) -> dict:
    path = (root / filename).resolve()
    if not path.is_relative_to(root.resolve()):
        raise ValueError("Archive must be inside the canonical project root")
    if path.suffix.lower() == ".pck":
        proc = subprocess.run(
            [
                sys.executable,
                str(root / "tools" / "release" / "inspect_godot_pck.py"),
                "--pack",
                str(path),
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        try:
            pck_report = json.loads(proc.stdout)
        except json.JSONDecodeError as exc:
            raise ValueError(f"Godot PCK inspection produced no JSON report: {proc.stderr[-1000:]}") from exc
        return {
            "path": path.relative_to(root.resolve()).as_posix(),
            "sha256": pck_report.get("artifact", {}).get("sha256", ""),
            "bytes": pck_report.get("artifact", {}).get("bytes", path.stat().st_size),
            "pck_content": pck_report,
            "verdict": "PCK_INSPECTED_PASS" if pck_report.get("status") == "PASS" and proc.returncode == 0 else "PCK_INSPECTION_FAILED",
        }
    if path.suffix.lower() not in ALLOWED_ZIP_SUFFIXES:
        raise ValueError("Only .zip / .apk / .aab / .ipa or a Godot-inspected .pck are supported")
    if not path.is_file():
        raise FileNotFoundError(path)
    size = path.stat().st_size
    digest = hashlib.sha256()
    with path.open("rb") as data:
        for chunk in iter(lambda: data.read(1024 * 1024), b""):
            digest.update(chunk)
    with zipfile.ZipFile(path) as zf:
        names = sorted(n.replace("\\", "/") for n in zf.namelist() if not n.endswith("/"))
        bad = sorted(n for n in names if any(n.startswith(prefix) or f"/{prefix}" in n for prefix in REQUIRED_EXCLUDED))
        inner_pck = sorted(n for n in names if n.lower().endswith(".pck"))
        return {
            "path": path.relative_to(root.resolve()).as_posix(),
            "sha256": digest.hexdigest(),
            "bytes": size,
            "zip_entries": len(names),
            "forbidden_visible_entries": bad[:100],
            "nested_pck_entries": inner_pck,
            "nested_pck_verified": False if inner_pck else None,
            "verdict": "BLOCKED_NESTED_PCK_UNINSPECTED" if inner_pck else (
                "FAIL_VISIBLE_BANNED_PATH" if bad else "ZIP_ENTRIES_CLEAN_ONLY_NOT_RELEASE_APPROVED"),
        }


def source_report(root: Path, preset_name: str | None) -> dict:
    name, platform, included, excluded = read_preset(root, preset_name)
    paths = tracked(root)
    # No owner-save, userdata or generated cache is read.
    forbidden = [p for p in paths if p.startswith(REQUIRED_EXCLUDED)]
    bad = [p for p in forbidden if not matches(p, excluded)]
    json_missing = [p for p in EXPECTED_JSON if p in paths and not matches(p, included)]
    risks = {prefix: sum(1 for p in paths if p.startswith(prefix)) for prefix in SOURCE_ONLY_ALERTS}
    autoload_debug = "_mcp_game_helper" in (root / "project.godot").read_text(encoding="utf-8")
    stat_bytes = 0
    for name_in_git in paths:
        path = root / name_in_git
        if path.is_symlink():
            continue
        if path.is_file():
            stat_bytes += path.stat().st_size
    return {
        "preset": name,
        "platform": platform,
        "shipping_release_preset": not any(
            marker in name.lower() for marker in ("nonshipping", "not shipping", "debug")
        ),
        "tracked_files": len(paths),
        "tracked_source_bytes": stat_bytes,
        "required_excluded_sources": len(forbidden),
        "nonexcluded_developer_sources": bad[:100],
        "runtime_json_missing_from_include_filter": json_missing,
        "source_only_asset_candidates": risks,
        "debug_helper_autoload_present": autoload_debug,
        "debug_helper_shipped": "UNVERIFIED_NEEDS_ACTUAL_PACKAGE_INSPECTION" if autoload_debug else False,
        "excluded_patterns": excluded,
        "included_patterns": included,
        "status": "FAIL_STATIC_BOUNDARY" if (bad or json_missing) else "STATIC_FILTER_ONLY_PACKAGE_UNVERIFIED",
    }


def package_debug_helper_status(pck_content: dict) -> str:
    """Read the Godot runtime check from the nested report without confusing inventory fields."""
    engine_checks = pck_content.get("engine_checks", pck_content)
    return "PRESENT_IN_INSPECTED_PCK" if engine_checks.get("godot_ai_game_helper_present", True) else "EXCLUDED_FROM_INSPECTED_PCK"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--preset", help="Exact Godot preset name (default: first preset)")
    parser.add_argument("--archive", help="Optional zip/apk/aab/ipa inside project; a nested PCK remains unverified")
    args = parser.parse_args()
    root = args.root.resolve()
    if not (root / "project.godot").exists() or not (root / ".git").exists():
        parser.error("Project root must be the canonical Git checkout with project.godot and .git")
    try:
        report = {"source": source_report(root, args.preset)}
        if args.archive:
            report["archive"] = archive_report(root, args.archive)
            pck_content = report["archive"].get("pck_content", {})
            if pck_content:
                report["source"]["debug_helper_shipped"] = package_debug_helper_status(pck_content)
    except (OSError, ValueError, subprocess.CalledProcessError, zipfile.BadZipFile) as exc:
        print(json.dumps({"status": "BLOCKED", "reason": str(exc)}, indent=2), file=sys.stderr)
        return 2
    print(json.dumps(report, indent=2, ensure_ascii=False))
    if report["source"]["status"] == "FAIL_STATIC_BOUNDARY":
        return 1
    if args.archive and report["archive"]["verdict"].startswith(("FAIL", "BLOCKED", "PCK_INSPECTION_FAILED")):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
