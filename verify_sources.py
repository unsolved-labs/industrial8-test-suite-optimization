#!/usr/bin/env python3
from __future__ import annotations

import csv
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MODEL = ROOT / "INDUSTRIAL_8.txt"
EXCERPT = ROOT / "sources" / "ct_competition_2023_industrial8_t3.csv"

EXPECTED_MODEL_SHA256 = "01785c43dbce4381d928c064c14dfe3c3734237db8fa7c2e84d8647f8ed299b4"
EXPECTED_MODEL_GIT_BLOB_SHA1 = "4ede6ee93f6eea06927f972cf5ba22621ecc3013"
EXPECTED_EXCERPT_SHA256 = "ac55e077a871a8f1cb51a1558a981941811d51565cfa3de5329fc0194b2935a2"


def git_blob_sha1(data: bytes) -> str:
    return hashlib.sha1(f"blob {len(data)}\0".encode() + data).hexdigest()


def main() -> None:
    model = MODEL.read_bytes()
    assert hashlib.sha256(model).hexdigest() == EXPECTED_MODEL_SHA256
    assert git_blob_sha1(model) == EXPECTED_MODEL_GIT_BLOB_SHA1

    excerpt = EXCERPT.read_bytes()
    assert hashlib.sha256(excerpt).hexdigest() == EXPECTED_EXCERPT_SHA256
    rows = list(csv.DictReader(excerpt.decode().splitlines()))
    assert len(rows) == 6
    valid = [r for r in rows if r["ErrorType"] == ""]
    assert min(int(r["Size"]) for r in valid) == 54
    assert any(r["Size"] == "49" and r["ErrorType"] == "Invalid" for r in rows)

    print("PASS frozen benchmark bytes match upstream Git blob 4ede6ee93f6eea06927f972cf5ba22621ecc3013")
    print("PASS frozen 2023 competition excerpt has best valid INDUSTRIAL_8 strength-3 size 54")
    print("PASS 49-row competition entry is explicitly marked Invalid")


if __name__ == "__main__":
    main()
