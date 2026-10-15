#!/usr/bin/env python3
"""Compare tiny same-payload ZIPs to isolate timestamp effects from APK claims."""

from __future__ import annotations

import hashlib
import json
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / "coordination/sessions/BCM-M34-END-TO-END-GAME-COMPLETION-V01/evidence/M34-R10"
PAYLOAD = b"BCM-M34-R10 reproducibility probe\n"
ENTRY_NAME = "payload.txt"


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def make_zip(path: Path, timestamp: tuple[int, int, int, int, int, int]) -> None:
    info = zipfile.ZipInfo(ENTRY_NAME, date_time=timestamp)
    info.compress_type = zipfile.ZIP_DEFLATED
    info.create_system = 0
    info.external_attr = 0
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        archive.writestr(info, PAYLOAD, compress_type=zipfile.ZIP_DEFLATED, compresslevel=6)


def inspect(path: Path) -> dict[str, object]:
    raw = path.read_bytes()
    with zipfile.ZipFile(path, "r") as archive:
        members = archive.infolist()
        if len(members) != 1 or members[0].filename != ENTRY_NAME:
            raise RuntimeError(f"unexpected member list in {path.name}")
        entry = members[0]
        extracted = archive.read(entry)
        if extracted != PAYLOAD:
            raise RuntimeError(f"payload mismatch in {path.name}")
        return {
            "name": path.name,
            "archive_sha256": sha256(raw),
            "archive_bytes": len(raw),
            "payload_sha256": sha256(extracted),
            "payload_bytes": len(extracted),
            "central_directory_entries": len(members),
            "central_directory_file_timestamp": list(entry.date_time),
            "compression": "DEFLATE level 6",
            "crc32": f"{entry.CRC:08X}",
            "compressed_bytes": entry.compress_size,
            "uncompressed_bytes": entry.file_size,
            "entry_order": [item.filename for item in members],
            "extra_field_bytes": len(entry.extra),
            "file_comment_bytes": len(entry.comment),
            "zip_comment_bytes": len(archive.comment),
            "signed": False,
        }


def main() -> None:
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    first_path = EVIDENCE / "repro_probe_2020.zip"
    second_path = EVIDENCE / "repro_probe_2026.zip"
    make_zip(first_path, (2020, 1, 2, 3, 4, 6))
    make_zip(second_path, (2026, 1, 2, 3, 4, 6))
    first = inspect(first_path)
    second = inspect(second_path)
    report = {
        "schema_version": 1,
        "work_item": "BCM-M34-R10-004",
        "method": "Two tiny ZIPs with identical one-file payload, entry name, order, compression and permissions; only DOS central-directory timestamp differs.",
        "artifacts": [first, second],
        "same_uncompressed_payload": first["payload_sha256"] == second["payload_sha256"],
        "same_archive_sha256": first["archive_sha256"] == second["archive_sha256"],
        "timestamp_is_the_only_controlled_difference": first["central_directory_file_timestamp"] != second["central_directory_file_timestamp"],
        "interpretation": "The controlled timestamp difference changes ZIP bytes and archive SHA-256 while preserving payload bytes. This isolates one metadata source of non-determinism; it does not identify all causes of APK non-determinism.",
        "apk_scope": "No R09 APK binaries are present in this worktree. Historical R09 APK hashes/sizes remain prior builder evidence; APK central-directory timestamps/signing were not independently re-read here. No APK was rebuilt.",
    }
    if not report["same_uncompressed_payload"] or report["same_archive_sha256"]:
        raise RuntimeError("controlled ZIP timestamp experiment did not produce the expected result")
    output = EVIDENCE / "zip_metadata_comparison.json"
    output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
