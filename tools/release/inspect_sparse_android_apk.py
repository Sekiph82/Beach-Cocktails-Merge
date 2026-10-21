#!/usr/bin/env python3
"""Fail-closed verifier for Godot 4.7.x sparse PCK assets embedded in an APK.

The Android APK path must resolve inside the project checkout. This utility
never extracts files and never modifies the APK.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import stat
import struct
import sys
import zipfile
from pathlib import Path, PurePosixPath

MAGIC = 0x43504447
MAX_ENTRIES = 200_000
MAX_RECORD_NAME = 1_000_000
MAX_ARCHIVE_UNCOMPRESSED = 2_000_000_000
EXPECTED_VERSION = 4
EXPECTED_GODOT = (4, 7, 2)
EXPECTED_FLAGS = 6  # PACK_REL_FILEBASE | PACK_SPARSE_BUNDLE
KNOWN_ENTRY_FLAGS = 0x7  # encrypted, removal, delta; reject all below.

FORBIDDEN_SEGMENTS = {
    "coordination", "docs", "tests", "tools", "backend", ".github",
    "_m32_validation", "godot_ai", "godotgoogleplaybilling",
}
FORBIDDEN_SUFFIXES = {
    ".env", ".pem", ".p12", ".pfx", ".jks", ".keystore", ".mobileprovision",
    ".ipa", ".apk", ".aab", ".dmp", ".sqlite", ".sqlite3", ".db",
}
SECRET_NAME = re.compile(r"(^|[._-])(secret|credential|private[_-]?key|upload[_-]?key)([._-]|$)", re.I)


class SparseAPKError(ValueError):
    pass


def _need(data: bytes, offset: int, length: int, label: str) -> bytes:
    if length < 0 or offset < 0 or offset + length > len(data):
        raise SparseAPKError(f"truncated or out-of-bounds {label}")
    return data[offset:offset + length]


def _u32(data: bytes, offset: int, label: str) -> int:
    return struct.unpack("<I", _need(data, offset, 4, label))[0]


def _u64(data: bytes, offset: int, label: str) -> int:
    return struct.unpack("<Q", _need(data, offset, 8, label))[0]


def _safe_resource_path(raw: bytes, index: int) -> str:
    # PCK v4 aligns UTF-8 record names to four bytes with zero padding.
    name_bytes = raw.rstrip(b"\0")
    if not name_bytes or b"\0" in name_bytes:
        raise SparseAPKError(f"empty or embedded-NUL path in entry {index}")
    try:
        name = name_bytes.decode("utf-8", errors="strict")
    except UnicodeDecodeError as exc:
        raise SparseAPKError(f"invalid UTF-8 path in entry {index}") from exc
    if "\\" in name or name.startswith("/") or re.match(r"^[A-Za-z]:", name):
        raise SparseAPKError(f"absolute or noncanonical path in entry {index}: {name!r}")
    if name.startswith("res://"):
        name = name[6:]
    elif "://" in name:
        raise SparseAPKError(f"unsupported URI scheme in entry {index}: {name!r}")
    parts = name.split("/")
    if not name or any(part in ("", ".", "..") for part in parts):
        raise SparseAPKError(f"unsafe path in entry {index}: {name!r}")
    return name


def _forbidden(path: str) -> bool:
    p = PurePosixPath(path)
    parts = [part.casefold() for part in p.parts]
    if any(part in FORBIDDEN_SEGMENTS for part in parts):
        return True
    if any(part.startswith(".env") for part in parts):
        return True
    if p.suffix.casefold() in FORBIDDEN_SUFFIXES:
        return True
    return any(SECRET_NAME.search(part) for part in parts)


def parse_sparse_index(data: bytes) -> tuple[dict, list[dict]]:
    if len(data) < 104:
        raise SparseAPKError("sparse PCK is shorter than the v4 header")
    magic, version, major, minor, patch, flags = struct.unpack_from("<6I", data, 0)
    if magic != MAGIC or version != EXPECTED_VERSION or (major, minor, patch) != EXPECTED_GODOT:
        raise SparseAPKError(f"unexpected PCK identity: magic={magic:#x}, version={version}, Godot={major}.{minor}.{patch}")
    if flags != EXPECTED_FLAGS:
        raise SparseAPKError(f"unsupported pack flags {flags:#x}; expected {EXPECTED_FLAGS:#x}")
    file_base = _u64(data, 24, "file base")
    directory_offset = _u64(data, 32, "directory offset")
    if file_base != 0 or directory_offset < 104 or directory_offset > len(data):
        raise SparseAPKError("invalid sparse file base or directory offset")
    if any(_need(data, 40, 64, "reserved header")):
        raise SparseAPKError("nonzero reserved header bytes")
    count = _u32(data, directory_offset, "directory count")
    if not 0 < count <= MAX_ENTRIES:
        raise SparseAPKError(f"invalid/unreasonable directory count {count}")
    cursor = directory_offset + 4
    entries: list[dict] = []
    names: set[str] = set()
    folded_names: set[str] = set()
    for index in range(count):
        path_size = _u32(data, cursor, f"entry {index} path length")
        cursor += 4
        if not 0 < path_size <= MAX_RECORD_NAME or path_size % 4:
            raise SparseAPKError(f"invalid v4 path length in entry {index}")
        raw = _need(data, cursor, path_size, f"entry {index} path")
        cursor += path_size
        path = _safe_resource_path(raw, index)
        if path in names or path.casefold() in folded_names:
            raise SparseAPKError(f"duplicate/case-colliding resource path {path!r}")
        names.add(path)
        folded_names.add(path.casefold())
        offset = _u64(data, cursor, f"entry {index} external offset")
        size = _u64(data, cursor + 8, f"entry {index} size")
        md5 = _need(data, cursor + 16, 16, f"entry {index} MD5")
        entry_flags = _u32(data, cursor + 32, f"entry {index} flags")
        cursor += 36
        if entry_flags & ~KNOWN_ENTRY_FLAGS:
            raise SparseAPKError(f"unknown entry flags {entry_flags:#x} for {path}")
        if entry_flags:
            raise SparseAPKError(f"encrypted/removal/delta entry is unsupported: {path}")
        if offset != 0:
            raise SparseAPKError(f"sparse external record has nonzero offset: {path}")
        entries.append({"path": path, "bytes": size, "md5": md5.hex(), "flags": entry_flags})
    if cursor != len(data):
        raise SparseAPKError(f"unaccounted bytes after directory: {len(data) - cursor}")
    return {
        "format_version": version,
        "godot_version": f"{major}.{minor}.{patch}",
        "pack_flags": flags,
        "file_base": file_base,
        "directory_offset": directory_offset,
        "directory_bytes": len(data) - directory_offset,
        "entry_count": count,
    }, entries


def inventory_apk(apk_path: Path, project_root: Path) -> dict:
    root = project_root.resolve(strict=True)
    apk = apk_path.resolve(strict=True)
    try:
        apk.relative_to(root)
    except ValueError as exc:
        raise SparseAPKError("APK must be inside the canonical project checkout") from exc
    if not apk.is_file():
        raise SparseAPKError("APK path is not a regular file")
    apk_sha = hashlib.sha256()
    with apk.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            apk_sha.update(chunk)
    with zipfile.ZipFile(apk, "r") as archive:
        infos = archive.infolist()
        if len(infos) > MAX_ENTRIES * 2:
            raise SparseAPKError("unreasonable APK ZIP entry count")
        if sum(i.file_size for i in infos) > MAX_ARCHIVE_UNCOMPRESSED:
            raise SparseAPKError("APK uncompressed content exceeds safety limit")
        names: dict[str, zipfile.ZipInfo] = {}
        folded_zip_names: set[str] = set()
        forbidden_archive_paths: list[str] = []
        for info in infos:
            if info.is_dir():
                continue
            if info.filename in names or info.filename.casefold() in folded_zip_names:
                raise SparseAPKError(f"duplicate/case-colliding ZIP entry {info.filename!r}")
            if info.flag_bits & 1:
                raise SparseAPKError(f"encrypted ZIP entry {info.filename!r}")
            parts = info.filename.split("/")
            if info.filename.startswith("/") or "\\" in info.filename or any(part in ("", ".", "..") for part in parts):
                raise SparseAPKError(f"unsafe ZIP entry path {info.filename!r}")
            if stat.S_ISLNK(info.external_attr >> 16):
                raise SparseAPKError(f"symbolic-link ZIP entry is unsupported: {info.filename!r}")
            names[info.filename] = info
            folded_zip_names.add(info.filename.casefold())
            inspected_path = info.filename[len("assets/"):] if info.filename.startswith("assets/") else info.filename
            if _forbidden(inspected_path):
                forbidden_archive_paths.append(info.filename)
        if forbidden_archive_paths:
            raise SparseAPKError(f"forbidden APK archive paths: {forbidden_archive_paths[:20]}")
        sparse_name = "assets/assets.sparsepck"
        sparse_info = names.get(sparse_name)
        if sparse_info is None:
            raise SparseAPKError(f"missing {sparse_name}")
        sparse_bytes = archive.read(sparse_info)
        header, entries = parse_sparse_index(sparse_bytes)
        mapped: set[str] = set()
        verified = []
        for entry in entries:
            path = entry["path"]
            if _forbidden(path):
                raise SparseAPKError(f"forbidden indexed path: {path}")
            zip_name = "assets/" + path
            info = names.get(zip_name)
            if info is None:
                raise SparseAPKError(f"missing referenced APK asset: {zip_name}")
            if info.file_size != entry["bytes"]:
                raise SparseAPKError(f"size mismatch for {zip_name}: index={entry['bytes']} ZIP={info.file_size}")
            md5 = hashlib.md5()
            sha = hashlib.sha256()
            with archive.open(info, "r") as stream:
                for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                    md5.update(chunk)
                    sha.update(chunk)
            if md5.hexdigest() != entry["md5"]:
                raise SparseAPKError(f"sparse index MD5 mismatch for {zip_name}")
            # Reading each ZIP stream to EOF also makes zipfile verify the ZIP CRC.
            mapped.add(zip_name)
            verified.append({"path": path, "bytes": entry["bytes"], "md5": md5.hexdigest(), "sha256": sha.hexdigest()})
        expanded = sorted(name for name in names if name.startswith("assets/") and name != sparse_name)
        unindexed = sorted(set(expanded) - mapped)
        forbidden_extra = [name for name in unindexed if _forbidden(name[len("assets/"):])]
        if forbidden_extra:
            raise SparseAPKError(f"forbidden unindexed APK assets: {forbidden_extra[:20]}")
        if set(expanded) - mapped != set(unindexed):
            raise SparseAPKError("incomplete expanded APK asset accounting")
        extras = [{"apk_path": name, "bytes": names[name].file_size, "sha256": _zip_sha256(archive, names[name])} for name in unindexed]
        manifest_material = "".join(f"{row['path']}\0{row['bytes']}\0{row['sha256']}\n" for row in sorted(verified, key=lambda row: row["path"]))
        return {
            "status": "SPARSEPCK_INDEX_PASS",
            "apk": {"path": str(apk.relative_to(root)).replace("\\", "/"), "bytes": apk.stat().st_size, "sha256": apk_sha.hexdigest()},
            "sparse_pck": {"apk_path": sparse_name, "bytes": len(sparse_bytes), **header},
            "indexed_assets": {"count": len(verified), "bytes": sum(row["bytes"] for row in verified), "verified_bytes": sum(row["bytes"] for row in verified), "md5_verified": True, "sha256_per_file": True, "sha256_sorted_manifest": hashlib.sha256(manifest_material.encode("utf-8")).hexdigest()},
            "expanded_apk_assets": {"count": len(expanded), "bytes": sum(names[name].file_size for name in expanded)},
            "missing_paths": [],
            "forbidden_indexed_paths": [],
            "forbidden_unindexed_paths": forbidden_extra,
            "forbidden_archive_paths": forbidden_archive_paths,
            "unindexed_extras": extras,
            "all_asset_hashes": verified,
        }


def _zip_sha256(archive: zipfile.ZipFile, info: zipfile.ZipInfo) -> str:
    digest = hashlib.sha256()
    with archive.open(info, "r") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path, help="APK inside the current project checkout")
    parser.add_argument("--project-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--summary-only", action="store_true", help="omit per-file hashes from JSON")
    args = parser.parse_args()
    try:
        report = inventory_apk(args.apk, args.project_root)
    except (OSError, zipfile.BadZipFile, RuntimeError, SparseAPKError) as exc:
        print(f"SPARSEPCK_INDEX_UNVERIFIED: {exc}", file=sys.stderr)
        return 2
    if args.summary_only:
        report.pop("all_asset_hashes", None)
    print(json.dumps(report, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
