from __future__ import annotations

import hashlib
import struct
import tempfile
import unittest
import zipfile
from pathlib import Path

from tools.release.inspect_sparse_android_apk import SparseAPKError, inventory_apk, parse_sparse_index


def make_pack(records: list[tuple[str, bytes, int]] | None = None, *, magic: int = 0x43504447) -> bytes:
    records = records or [("res://data/sample.bin", b"sample", 0)]
    directory = bytearray(struct.pack("<I", len(records)))
    for name, payload, flags in records:
        raw = name.encode("utf-8")
        raw += b"\0" * ((-len(raw)) % 4)
        directory += struct.pack("<I", len(raw)) + raw
        directory += struct.pack("<QQ", 0, len(payload))
        directory += hashlib.md5(payload).digest()
        directory += struct.pack("<I", flags)
    header = struct.pack("<6IQQ", magic, 4, 4, 7, 2, 6, 0, 104)
    header += bytes(64)
    return header + directory


class SparseAPKInspectorTests(unittest.TestCase):
    def test_valid_sparse_directory(self) -> None:
        header, entries = parse_sparse_index(make_pack())
        self.assertEqual(header["entry_count"], 1)
        self.assertEqual(entries[0]["path"], "data/sample.bin")

    def test_invalid_sparse_header_rejected(self) -> None:
        with self.assertRaisesRegex(SparseAPKError, "identity"):
            parse_sparse_index(make_pack(magic=0))

    def test_invalid_sparse_directory_rejected(self) -> None:
        with self.assertRaisesRegex(SparseAPKError, "truncated or out-of-bounds"):
            parse_sparse_index(make_pack()[:-1])

    def test_duplicate_or_traversal_path_rejected(self) -> None:
        with self.assertRaisesRegex(SparseAPKError, "duplicate"):
            parse_sparse_index(make_pack([
                ("data/sample.bin", b"a", 0),
                ("res://data/sample.bin", b"b", 0),
            ]))
        with self.assertRaisesRegex(SparseAPKError, "unsafe"):
            parse_sparse_index(make_pack([("res://../outside", b"a", 0)]))

    def test_missing_external_reference_rejected(self) -> None:
        with self.assertRaisesRegex(SparseAPKError, "missing referenced"):
            self._inspect([("assets/assets.sparsepck", make_pack())])

    def test_mutated_payload_rejected_by_pck_md5(self) -> None:
        with self.assertRaisesRegex(SparseAPKError, "MD5 mismatch"):
            self._inspect([
                ("assets/assets.sparsepck", make_pack()),
                ("assets/data/sample.bin", b"samplf"),
            ])

    def test_forbidden_unindexed_leak_rejected(self) -> None:
        with self.assertRaisesRegex(SparseAPKError, "forbidden APK archive"):
            self._inspect([
                ("assets/assets.sparsepck", make_pack()),
                ("assets/data/sample.bin", b"sample"),
                ("assets/tests/secret_fixture.pem", b"private"),
            ])

    def test_forbidden_indexed_test_path_rejected(self) -> None:
        payload = b"seed"
        with self.assertRaisesRegex(SparseAPKError, "forbidden APK archive"):
            self._inspect([
                ("assets/assets.sparsepck", make_pack([("res://tests/fixtures/seed.json", payload, 0)])),
                ("assets/tests/fixtures/seed.json", payload),
            ])

    def test_unknown_entry_flags_rejected(self) -> None:
        with self.assertRaisesRegex(SparseAPKError, "unsupported"):
            parse_sparse_index(make_pack([("res://data/sample.bin", b"sample", 1)]))

    def _inspect(self, entries: list[tuple[str, bytes]]) -> dict:
        repo = Path(__file__).resolve().parents[1]
        work = repo / ".godot" / "bcm_release_preflight"
        work.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=work) as temp_dir:
            apk = Path(temp_dir) / "synthetic.apk"
            with zipfile.ZipFile(apk, "w", compression=zipfile.ZIP_DEFLATED) as archive:
                for name, payload in entries:
                    archive.writestr(name, payload)
            return inventory_apk(apk, repo)


if __name__ == "__main__":
    unittest.main()
