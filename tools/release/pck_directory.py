#!/usr/bin/env python3
"""Authoritative directory and payload inventory for unencrypted Godot PCK v2-v4.

The format reader follows Godot's own file_access_pack.cpp and pck_packer.cpp.
Unsupported/encrypted/sparse variants fail closed rather than returning a partial list.
"""
from __future__ import annotations

import hashlib
import struct
from pathlib import Path

MAGIC = 0x43504447  # GDPC
PACK_DIR_ENCRYPTED = 1
PACK_REL_FILEBASE = 2
PACK_SPARSE_BUNDLE = 4
PACK_FILE_ENCRYPTED = 1
PACK_FILE_REMOVAL = 2
PACK_FILE_DELTA = 4
MAX_FILES = 1_000_000
MAX_PATH_BYTES = 1_000_000


class PCKInventoryError(ValueError):
    """The PCK could not be accounted for completely and safely."""


def _read_exact(handle, count: int, what: str) -> bytes:
    data = handle.read(count)
    if len(data) != count:
        raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: truncated {what}")
    return data


def _u32(handle, what: str) -> int:
    return struct.unpack("<I", _read_exact(handle, 4, what))[0]


def _u64(handle, what: str) -> int:
    return struct.unpack("<Q", _read_exact(handle, 8, what))[0]


def inventory_pck(path: Path) -> dict:
    """Parse a standalone PCK directory, verify every payload MD5 and hash every entry."""
    pack_size = path.stat().st_size
    entries: list[dict] = []
    intervals: list[tuple[int, int, str]] = []
    names: set[str] = set()
    with path.open("rb") as handle:
        magic = _u32(handle, "magic")
        if magic != MAGIC:
            raise PCKInventoryError("PCK_INVENTORY_INCOMPLETE: standalone GDPC header not found at offset 0")
        version = _u32(handle, "format version")
        if version not in (2, 3, 4):
            raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: unsupported PCK format version {version}")
        godot_version = [_u32(handle, "Godot version") for _ in range(3)]
        flags = _u32(handle, "pack flags")
        if flags & (PACK_DIR_ENCRYPTED | PACK_SPARSE_BUNDLE):
            raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: encrypted/sparse PCK flags 0x{flags:x}")
        file_base_value = _u64(handle, "file base")
        pck_start = 0
        if version in (3, 4):
            directory_offset = _u64(handle, "directory offset")
            # Godot v3/v4 header reserves 16 uint32 words after the directory offset.
            _read_exact(handle, 64, "reserved header")
            directory_start = pck_start + directory_offset
            file_base = pck_start + file_base_value
        else:
            _read_exact(handle, 64, "reserved v2 header")
            directory_start = handle.tell()
            file_base = pck_start + file_base_value if flags & PACK_REL_FILEBASE else file_base_value
        if not (0 <= file_base <= directory_start <= pack_size):
            raise PCKInventoryError("PCK_INVENTORY_INCOMPLETE: invalid file-base/directory bounds")
        handle.seek(directory_start)
        file_count = _u32(handle, "directory file count")
        if file_count > MAX_FILES:
            raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: unreasonable file count {file_count}")

        for index in range(file_count):
            path_length = _u32(handle, f"entry {index} path length")
            if not path_length or path_length > MAX_PATH_BYTES:
                raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: invalid path length at entry {index}")
            try:
                path_bytes = _read_exact(handle, path_length, f"entry {index} path")
                name_bytes = path_bytes.rstrip(b"\0")
                if any(path_bytes[len(name_bytes):]):
                    raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: nonzero path padding at entry {index}")
                name = name_bytes.decode("utf-8", errors="strict")
            except UnicodeDecodeError as exc:
                raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: invalid UTF-8 path at entry {index}") from exc
            normalized = name.replace("\\", "/")
            if normalized.startswith("res://"):
                normalized = normalized[6:]
            if not normalized or normalized.startswith("/") or any(part in ("", ".", "..") for part in normalized.split("/")):
                raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: unsafe entry path {name!r}")
            if normalized in names:
                raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: duplicate entry path {normalized!r}")
            names.add(normalized)
            relative_offset = _u64(handle, f"entry {index} offset")
            size = _u64(handle, f"entry {index} size")
            expected_md5 = _read_exact(handle, 16, f"entry {index} MD5")
            entry_flags = _u32(handle, f"entry {index} flags")
            next_record = handle.tell()
            if entry_flags & (PACK_FILE_ENCRYPTED | PACK_FILE_REMOVAL | PACK_FILE_DELTA):
                raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: unsupported flags 0x{entry_flags:x} on {normalized}")
            start = file_base + relative_offset
            end = start + size
            if start < file_base or end < start or end > directory_start:
                raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: payload bounds invalid for {normalized}")
            handle.seek(start)
            md5 = hashlib.md5()
            sha256 = hashlib.sha256()
            remaining = size
            while remaining:
                chunk = handle.read(min(1024 * 1024, remaining))
                if not chunk:
                    raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: truncated payload {normalized}")
                md5.update(chunk)
                sha256.update(chunk)
                remaining -= len(chunk)
            if md5.digest() != expected_md5:
                raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: MD5 mismatch for {normalized}")
            entries.append({
                "path": normalized,
                "bytes": size,
                "sha256": sha256.hexdigest(),
                "type": Path(normalized).suffix.lower().lstrip(".") or "[no extension]",
                "hidden_path": any(part.startswith(".") for part in normalized.split("/")),
                "flags": entry_flags,
            })
            if size:
                intervals.append((start, end, normalized))
            handle.seek(next_record)

        directory_end = handle.tell()
        if directory_end > pack_size:
            raise PCKInventoryError("PCK_INVENTORY_INCOMPLETE: directory extends past pack end")

        intervals.sort()
        cursor = file_base
        padding_ranges: list[tuple[int, int]] = []
        for start, end, entry_name in intervals:
            if start < cursor:
                raise PCKInventoryError(f"PCK_INVENTORY_INCOMPLETE: overlapping payload at {entry_name}")
            if start > cursor:
                padding_ranges.append((cursor, start))
            cursor = end
        if cursor < directory_start:
            padding_ranges.append((cursor, directory_start))

        nonzero_padding_bytes = 0
        padding_bytes = 0
        for start, end in padding_ranges:
            padding_bytes += end - start
            handle.seek(start)
            remaining = end - start
            while remaining:
                chunk = _read_exact(handle, min(1024 * 1024, remaining), "payload alignment padding")
                nonzero_padding_bytes += sum(byte != 0 for byte in chunk)
                remaining -= len(chunk)
        trailer_bytes = pack_size - directory_end
        trailer_nonzero_bytes = 0
        if trailer_bytes:
            handle.seek(directory_end)
            trailer = _read_exact(handle, trailer_bytes, "trailing pack bytes")
            trailer_nonzero_bytes = sum(byte != 0 for byte in trailer)

    if nonzero_padding_bytes or trailer_nonzero_bytes:
        raise PCKInventoryError(
            "PCK_INVENTORY_INCOMPLETE: unindexed nonzero bytes exist outside directory payload entries "
            f"(padding_nonzero={nonzero_padding_bytes}, trailer_nonzero={trailer_nonzero_bytes})"
        )
    entries.sort(key=lambda item: item["path"])
    return {
        "status": "PASS",
        "authority": "Godot PCK v2-v4 directory index; every indexed payload byte hashed and MD5 verified",
        "format_version": version,
        "godot_version": ".".join(map(str, godot_version)),
        "pack_flags": flags,
        "entry_count": len(entries),
        "file_payload_bytes": sum(item["bytes"] for item in entries),
        "hidden_entry_count": sum(item["hidden_path"] for item in entries),
        "payload_region": {"start": file_base, "end": directory_start, "bytes": directory_start - file_base},
        "alignment_padding": {"ranges": len(padding_ranges), "bytes": padding_bytes, "nonzero_bytes": nonzero_padding_bytes},
        "directory": {"start": directory_start, "end": directory_end, "bytes": directory_end - directory_start},
        "trailing_bytes": {"bytes": trailer_bytes, "nonzero_bytes": trailer_nonzero_bytes},
        "entries": entries,
    }
