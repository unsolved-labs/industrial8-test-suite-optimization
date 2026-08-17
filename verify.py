#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import hashlib
import itertools
import json
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MODEL = ROOT / "INDUSTRIAL_8.txt"
SOURCE_EXCERPT = ROOT / "sources" / "ct_competition_2023_industrial8_t3.csv"
REPORT = ROOT / "verification-report.json"

EXPECTED_MODEL_SHA256 = "01785c43dbce4381d928c064c14dfe3c3734237db8fa7c2e84d8647f8ed299b4"
EXPECTED_MODEL_GIT_BLOB_SHA1 = "4ede6ee93f6eea06927f972cf5ba22621ecc3013"
EXPECTED_SOURCE_EXCERPT_SHA256 = "ac55e077a871a8f1cb51a1558a981941811d51565cfa3de5329fc0194b2935a2"

DOMAINS = [("false", "true")] * 13 + [("v1", "v2", "v3")]
PARAMETERS = [f"p{i}" for i in range(1, 15)]
CATEGORIES = [f"p{i}" for i in range(5, 13)] + ["p13"]
ALL_BITS = list(itertools.product((0, 1), repeat=4))
EXPECTED = {2: 18, 3: 45, 4: 72, 5: 144, 6: 144}
EXPECTED_INTERACTIONS = {2: 326, 3: 2168, 4: 9374, 5: 28192, 6: 61272}
LOCAL_INTERACTION_DIMENSION = {2: 1, 3: 2, 4: 3, 5: 4, 6: 4}
WITNESS_FILES = {
    2: "industrial8_t2_opt18.csv",
    3: "industrial8_t3_opt45.csv",
    4: "industrial8_t4_opt72.csv",
    5: "industrial8_t5_opt144.csv",
    6: "industrial8_t6_opt144.csv",
}
MANDATORY_CLASSES = [f"p{i}=false" for i in range(5, 13)] + ["p13=false"]


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def git_blob_sha1(data: bytes) -> str:
    prefix = f"blob {len(data)}\0".encode()
    return hashlib.sha1(prefix + data).hexdigest()


def assert_frozen_sources() -> None:
    data = MODEL.read_bytes()
    assert sha256_bytes(data) == EXPECTED_MODEL_SHA256
    assert git_blob_sha1(data) == EXPECTED_MODEL_GIT_BLOB_SHA1
    excerpt = SOURCE_EXCERPT.read_bytes()
    assert sha256_bytes(excerpt) == EXPECTED_SOURCE_EXCERPT_SHA256


def is_valid(row: tuple[str, ...]) -> bool:
    """Independent semantic replay for the exact frozen INDUSTRIAL_8 bytes.

    This function is intentionally small and readable. The independent C++
    verifier separately parses and evaluates the model text itself.
    """
    if len(row) != 14:
        return False
    if any(row[i] not in ("false", "true") for i in range(13)):
        return False
    if row[13] not in ("v1", "v2", "v3"):
        return False

    b = [x == "true" for x in row[:13]]

    # The pairwise OR constraints among p5,...,p12 say at most one is false.
    if sum(not b[i] for i in range(4, 12)) > 1:
        return False

    # If p13 is false then p5,...,p12 must all be true.
    if not b[12] and any(not b[i] for i in range(4, 12)):
        return False

    # p14=v3 is forbidden; p14 is determined by p3.
    if row[13] == "v3":
        return False
    if row[13] == "v1" and not b[2]:
        return False
    if row[13] == "v2" and b[2]:
        return False

    # The all-true p1,...,p13 assignment is forbidden.
    if all(b):
        return False
    return True


def enumerate_valid_rows() -> list[tuple[str, ...]]:
    return [row for row in itertools.product(*DOMAINS) if is_valid(row)]


def category(row: tuple[str, ...]) -> str:
    false_middle = [i for i in range(4, 12) if row[i] == "false"]
    if row[12] == "false":
        return "p13=false"
    if len(false_middle) == 1:
        return f"p{false_middle[0] + 1}=false"
    if not false_middle:
        return "residual-all-true"
    raise AssertionError("invalid class")


def interaction_set(rows: list[tuple[str, ...]], strength: int):
    out = set()
    for row in rows:
        for columns in itertools.combinations(range(14), strength):
            out.add((columns, tuple(row[i] for i in columns)))
    return out


def read_suite(path: Path) -> list[tuple[str, ...]]:
    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        assert header == PARAMETERS, (path, header)
        rows = [tuple(row) for row in reader if row]
    assert all(len(row) == 14 for row in rows), path
    assert len(set(rows)) == len(rows), f"duplicate rows in {path}"
    return rows


def read_optima() -> dict[int, tuple[int, int]]:
    with (ROOT / "optima.csv").open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        assert reader.fieldnames == ["strength", "valid_interactions", "exact_minimum_tests"]
        out = {}
        for row in reader:
            t = int(row["strength"])
            out[t] = (int(row["valid_interactions"]), int(row["exact_minimum_tests"]))
    return out


def local_requirement(bits: tuple[int, ...], r: int):
    """Interactions on the free p1,...,p4 bits forced inside one mandatory class."""
    return {
        (cols, tuple(bits[i] for i in cols))
        for cols in itertools.combinations(range(4), r)
    }


def local_minimum(r: int) -> int:
    """Exact brute-force minimum for the class-local binary covering subproblem.

    r=1,2,3,4 correspond to the lower-bound cores used for strengths 2,3,4,5/6.
    There are only 16 possible four-bit rows, so exhaustive subset search is tiny.
    """
    required = set()
    cover_by_word = []
    for word in ALL_BITS:
        cov = local_requirement(word, r)
        required |= cov
        cover_by_word.append(cov)

    for size in range(17):
        for indices in itertools.combinations(range(16), size):
            covered = set()
            for i in indices:
                covered |= cover_by_word[i]
            if covered == required:
                return size
    raise AssertionError("local covering problem has no solution")


def verify_source_comparison() -> dict:
    with SOURCE_EXCERPT.open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    assert len(rows) == 6
    assert all(r["ModelName"] == "INDUSTRIAL_8" and r["Strength"] == "3" for r in rows)
    valid = [r for r in rows if not r["ErrorType"]]
    invalid = [r for r in rows if r["ErrorType"]]
    best = min(valid, key=lambda r: int(r["Size"]))
    assert int(best["Size"]) == 54 and best["ToolName"] == "pmedici"
    assert any(int(r["Size"]) == 49 and r["ErrorType"] == "Invalid" for r in invalid)
    return {
        "frozen_2023_best_valid_strength3_size": 54,
        "tool": "pmedici",
        "invalid_49_row_entry_excluded": True,
    }


def verify_claim() -> dict:
    assert_frozen_sources()
    source_comparison = verify_source_comparison()

    valid_rows = enumerate_valid_rows()
    assert len(valid_rows) == 159, len(valid_rows)

    class_rows = Counter(category(row) for row in valid_rows)
    for name in MANDATORY_CLASSES:
        assert class_rows[name] == 16, (name, class_rows[name])
    assert class_rows["residual-all-true"] == 15

    local_minima = {r: local_minimum(r) for r in range(1, 5)}
    assert local_minima == {1: 2, 2: 5, 3: 8, 4: 16}, local_minima

    optima = read_optima()
    assert set(optima) == set(EXPECTED)

    results = {}
    for t in range(2, 7):
        suite_path = ROOT / WITNESS_FILES[t]
        suite = read_suite(suite_path)
        assert len(suite) == EXPECTED[t], (t, len(suite))
        assert all(is_valid(row) for row in suite), t

        required = interaction_set(valid_rows, t)
        assert len(required) == EXPECTED_INTERACTIONS[t], (t, len(required))
        covered = interaction_set(suite, t)
        missing = required - covered
        assert not missing, (t, len(missing), next(iter(missing)))

        counts = Counter(category(row) for row in suite)
        local = local_minima[LOCAL_INTERACTION_DIMENSION[t]]
        for name in MANDATORY_CLASSES:
            assert counts[name] == local, (t, name, counts[name], local)
        assert counts["residual-all-true"] == 0

        lower_bound = 9 * local
        assert lower_bound == EXPECTED[t] == len(suite)
        assert optima[t] == (EXPECTED_INTERACTIONS[t], EXPECTED[t])

        results[str(t)] = {
            "valid_interactions": len(required),
            "witness_file": WITNESS_FILES[t],
            "witness_sha256": sha256_bytes(suite_path.read_bytes()),
            "witness_rows": len(suite),
            "class_local_exact_minimum": local,
            "global_lower_bound": lower_bound,
            "optimal": True,
        }
        print(
            f"PASS t={t}: {len(suite)} published rows cover all {len(required)} "
            f"valid interactions; exact lower bound {lower_bound} is met."
        )

    return {
        "release": "R003",
        "model": "INDUSTRIAL_8",
        "model_sha256": EXPECTED_MODEL_SHA256,
        "model_git_blob_sha1": EXPECTED_MODEL_GIT_BLOB_SHA1,
        "raw_assignments": 24576,
        "valid_configurations": 159,
        "mandatory_classes": 9,
        "residual_configurations": 15,
        "local_minima": {str(k): v for k, v in local_minima.items()},
        "source_comparison": source_comparison,
        "strengths": results,
        "trust_boundary": {
            "primary": "Python 3 standard-library exact enumeration and exhaustive local subset search",
            "independent": "C++20 model parser/evaluator, CSV replay, interaction enumeration, and local subset search",
            "search_or_ai_generation_required_for_replay": False,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--write-report",
        action="store_true",
        help="Rewrite verification-report.json with the deterministic current result.",
    )
    args = parser.parse_args()

    report = verify_claim()
    rendered = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.write_report:
        REPORT.write_text(rendered, encoding="utf-8")
        print(f"WROTE {REPORT.name}")
    else:
        committed = REPORT.read_text(encoding="utf-8")
        assert committed == rendered, (
            "verification-report.json is stale; run `python verify.py --write-report` "
            "and review the diff"
        )
        print("PASS verification-report.json is current")


if __name__ == "__main__":
    main()
