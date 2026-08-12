#!/usr/bin/env python3
from __future__ import annotations
import itertools
from collections import Counter

DOMAINS = [("false", "true")] * 13 + [("v1", "v2", "v3")]
CATEGORIES = [f"p{i}" for i in range(5, 13)] + ["p13"]
ALL_BITS = list(itertools.product((0, 1), repeat=4))
EXPECTED = {2: 18, 3: 45, 4: 72, 5: 144, 6: 144}
EXPECTED_INTERACTIONS = {2: 326, 3: 2168, 4: 9374, 5: 28192, 6: 61272}
PER_CLASS_LOWER_BOUND = {2: 2, 3: 5, 4: 8, 5: 16, 6: 16}
MANDATORY_CLASSES = [f"p{i}=false" for i in range(5, 13)] + ["p13=false"]

def is_valid(row):
    if len(row) != 14:
        return False
    if any(row[i] not in ("false", "true") for i in range(13)):
        return False
    if row[13] not in ("v1", "v2", "v3"):
        return False
    b = [x == "true" for x in row[:13]]
    if sum(not b[i] for i in range(4, 12)) > 1:
        return False
    if not b[12] and any(not b[i] for i in range(4, 12)):
        return False
    if row[13] == "v3":
        return False
    if row[13] == "v1" and not b[2]:
        return False
    if row[13] == "v2" and b[2]:
        return False
    if all(b):
        return False
    return True

def make_row(category, bits):
    first = tuple("true" if bit else "false" for bit in bits)
    middle = ["true"] * 8
    p13 = "true"
    if category == "p13":
        p13 = "false"
    else:
        middle[int(category[1:]) - 5] = "false"
    p14 = "v1" if bits[2] else "v2"
    return first + tuple(middle) + (p13, p14)

def construct_suites():
    suites = {}
    reps = [(0,0,0,0), (0,0,0,1), (0,0,1,0), (0,1,0,0)]
    suites[2] = [make_row(c, w) for i, c in enumerate(CATEGORIES) for w in (reps[i % 4], tuple(1-b for b in reps[i % 4]))]
    base = [(0,0,0,0), (0,1,1,1), (1,0,1,1), (1,1,0,1), (1,1,1,0)]
    shifts = [(0,0,0,0), (0,0,0,1), (0,0,1,0), (0,0,1,1)]
    suites[3] = [make_row(c, tuple(a ^ b for a, b in zip(w, shifts[i % 4]))) for i, c in enumerate(CATEGORIES) for w in base]
    even = [w for w in ALL_BITS if sum(w) % 2 == 0]
    odd = [w for w in ALL_BITS if sum(w) % 2 == 1]
    suites[4] = [make_row(c, w) for i, c in enumerate(CATEGORIES) for w in (even if i % 2 == 0 else odd)]
    all_mandatory = [make_row(c, w) for c in CATEGORIES for w in ALL_BITS]
    suites[5] = list(all_mandatory)
    suites[6] = list(all_mandatory)
    return suites

def enumerate_valid_rows():
    return [row for row in itertools.product(*DOMAINS) if is_valid(row)]

def interaction_set(rows, strength):
    out = set()
    for row in rows:
        for columns in itertools.combinations(range(14), strength):
            out.add((columns, tuple(row[i] for i in columns)))
    return out

def category(row):
    false_middle = [i for i in range(4, 12) if row[i] == "false"]
    if row[12] == "false":
        return "p13=false"
    if len(false_middle) == 1:
        return f"p{false_middle[0] + 1}=false"
    if not false_middle:
        return "residual-all-true"
    raise AssertionError("invalid class")

def main():
    valid_rows = enumerate_valid_rows()
    assert len(valid_rows) == 159, len(valid_rows)
    suites = construct_suites()
    for t in range(2, 7):
        suite = suites[t]
        assert len(suite) == EXPECTED[t]
        assert len(set(suite)) == len(suite)
        assert all(is_valid(row) for row in suite)
        required = interaction_set(valid_rows, t)
        assert len(required) == EXPECTED_INTERACTIONS[t], (t, len(required))
        covered = interaction_set(suite, t)
        missing = required - covered
        assert not missing, (t, len(missing), next(iter(missing)))
        counts = Counter(category(row) for row in suite)
        per_class = PER_CLASS_LOWER_BOUND[t]
        for name in MANDATORY_CLASSES:
            assert counts[name] == per_class, (t, name, counts[name])
        assert counts["residual-all-true"] == 0
        lower_bound = 9 * per_class
        assert lower_bound == len(suite)
        print(f"PASS t={t}: {len(suite)} valid unique tests cover all {len(required)} valid interactions; analytic lower bound {lower_bound} is met, so the suite is optimal.")

if __name__ == "__main__":
    main()
