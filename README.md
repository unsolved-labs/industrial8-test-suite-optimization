# R003 — Exact constrained test-suite optimization for `INDUSTRIAL_8`

**Unsolved Labs Research Release R003**

This release proves the exact minimum number of valid tests needed for the frozen public `INDUSTRIAL_8` constrained combinatorial-interaction-testing benchmark at strengths 2 through 6.

> This research artifact was generated with frontier AI and released by Unsolved Labs. The correctness claim is supported by the public proof, exact finite certificates, and two independently implemented verification paths described below.

## Result

Let $N_t$ be the minimum number of valid configurations required to cover every feasible $t$-way interaction of the frozen benchmark model. Then

$$
N_2=18,\qquad N_3=45,\qquad N_4=72,\qquad N_5=N_6=144.
$$

| Strength | Valid interactions | Exact minimum | Published witness |
|---:|---:|---:|---|
| 2 | 326 | 18 | [`industrial8_t2_opt18.csv`](industrial8_t2_opt18.csv) |
| 3 | 2,168 | **45** | [`industrial8_t3_opt45.csv`](industrial8_t3_opt45.csv) |
| 4 | 9,374 | 72 | [`industrial8_t4_opt72.csv`](industrial8_t4_opt72.csv) |
| 5 | 28,192 | 144 | [`industrial8_t5_opt144.csv`](industrial8_t5_opt144.csv) |
| 6 | 61,272 | 144 | [`industrial8_t6_opt144.csv`](industrial8_t6_opt144.csv) |

For strength 3, the frozen 2023 CT-Competition result table records a best **valid** entry of 54 tests; a 49-row entry in the same table is marked invalid. R003 therefore reduces that frozen valid comparison from 54 to 45 tests, a reduction of 9 tests (16.7%), and proves that 45 is optimal for this model.

## Why the optimum is exact

The constraints partition 144 of the 159 valid configurations into nine disjoint **mandatory classes**, each containing all 16 assignments of the four free Boolean parameters `p1,...,p4`.

Within each mandatory class, covering selected interactions forces exact local binary covering minima:

| Global strength | Required local coverage on `p1,...,p4` | Exact local minimum |
|---:|---|---:|
| 2 | all 1-way interactions | 2 |
| 3 | all 2-way interactions | 5 |
| 4 | all 3-way interactions | 8 |
| 5 | all 4-way interactions | 16 |
| 6 | all 4-way interactions plus a forced-true parameter | 16 |

Because an interaction containing a class-defining false parameter can only be covered by a row from that class, the nine classwise bounds add. This yields lower bounds $18,45,72,144,144$. The published witnesses meet those bounds exactly and are therefore optimal.

See the [paper manuscript](manuscript/r003_industrial8_exact_optima.pdf) and the GitHub-rendered [proof note](proof.md).

## Verification

Three complementary checks are public:

1. **Source/provenance check** — [`verify_sources.py`](verify_sources.py) verifies that the frozen benchmark bytes exactly match the pinned upstream Git blob and that the frozen 2023 competition excerpt has best valid strength-3 size 54.
2. **Primary exact verifier** — [`verify.py`](verify.py) independently enumerates all 24,576 raw assignments, obtains the 159 valid configurations, enumerates every feasible interaction at strengths 2–6, reads the **published CSV witnesses**, checks complete coverage, and exhaustively solves the 16-row class-local lower-bound subproblems.
3. **Independent C++20 verifier** — [`verify_independent.cpp`](verify_independent.cpp) separately parses and evaluates the benchmark constraint text, re-enumerates the model and all interactions, reads the published witnesses, and independently brute-forces the local binary minima.

No optimizer, language model, floating-point solver, network service, or search trace is required to replay the final correctness claim.

### Reproduce from a clean checkout

```bash
python3 verify_sources.py
python3 verify.py

g++ -std=c++20 -O2 -Wall -Wextra -pedantic verify_independent.cpp -o verify_independent
./verify_independent
```

The committed [`verification-report.json`](verification-report.json) is deterministic. To regenerate it:

```bash
python3 verify.py --write-report
git diff --exit-code verification-report.json
```

Full verification details and trust boundaries are in [`VERIFICATION.md`](VERIFICATION.md).

## Exact claim boundary

This release proves exact optima **for the frozen `INDUSTRIAL_8` model and the feasible-interaction semantics used here**. It does not claim a general formula for arbitrary constrained test-generation instances, nor does it claim that the 2023 competition table exhausts all later, unpublished, or independently developed constructions.

See [`CLAIM.md`](CLAIM.md), [`claim.json`](claim.json), and [`STATEMENT_AUDIT.md`](STATEMENT_AUDIT.md).

## Provenance

The local `INDUSTRIAL_8.txt` is byte-for-byte identical to the upstream benchmark at:

- repository: `fmselab/CIT_Benchmark_Generator`
- commit: `7ed44c18a771b9bbdc444a3c9178a7a68510a53f`
- Git blob: `4ede6ee93f6eea06927f972cf5ba22621ecc3013`
- SHA-256: `01785c43dbce4381d928c064c14dfe3c3734237db8fa7c2e84d8647f8ed299b4`

The 2023 comparison is pinned to:

- repository: `fmselab/ct-competition`
- branch snapshot commit: `3c8cdc1ac9eb4e045404d8db75ce38bad7541808`
- file Git blob: `414bc2b1d47a8cd5a8e7263b5fa01e1104929da3`

See [`SOURCE_AUDIT.md`](SOURCE_AUDIT.md).

## Repository map

- `manuscript/` — typeset paper source and PDF
- `INDUSTRIAL_8.txt` — frozen benchmark, byte-identical to the pinned upstream blob
- `industrial8_t*_opt*.csv` — explicit optimal witnesses at strengths 2–6
- `proof.md` — rendered proof note
- `CLAIM.md` / `claim.json` — exact claim and non-claims
- `STATEMENT_AUDIT.md` — public claim → paper → verification crosswalk
- `SOURCE_AUDIT.md` — benchmark and comparison provenance
- `VERIFICATION.md` — reproduction and trust boundary
- `verify.py` — primary exact verifier
- `verify_independent.cpp` — independent parser/verifier
- `verify_sources.py` — source-integrity replay
- `verification-report.json` — deterministic machine-readable result

## Status

- Public construction and proof: **available**
- Exact primary verification: **available**
- Independent implementation replay: **available**
- External specialist review: **pending**
- Peer review: **not claimed**

## Public release page

https://unsolved-labs.github.io/results/r003-industrial8/
