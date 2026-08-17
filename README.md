# R003 - Exact constrained test-suite optimization for `INDUSTRIAL_8`

**Unsolved Labs Research Release R003**

R003 determines the exact minimum number of valid tests needed to cover every feasible interaction of the frozen public `INDUSTRIAL_8` constrained combinatorial-testing benchmark at strengths 2 through 6.

Research artifact generated with frontier AI and released by Unsolved Labs. Correctness is supported by a public proof, explicit optimal witnesses, two independently implemented exact replay paths, and a pinned Lean 4 formalization of a load-bearing lower-bound core. External specialist review remains **pending**.

## Exact result

Let $N_t$ be the minimum number of valid configurations required to cover every feasible $t$-way interaction of the frozen model. Then

$$
N_2=18,\qquad N_3=45,\qquad N_4=72,\qquad N_5=N_6=144.
$$

| Strength | Feasible interactions | Exact minimum | Published witness |
|---:|---:|---:|---|
| 2 | 326 | 18 | [`industrial8_t2_opt18.csv`](industrial8_t2_opt18.csv) |
| 3 | 2,168 | **45** | [`industrial8_t3_opt45.csv`](industrial8_t3_opt45.csv) |
| 4 | 9,374 | 72 | [`industrial8_t4_opt72.csv`](industrial8_t4_opt72.csv) |
| 5 | 28,192 | 144 | [`industrial8_t5_opt144.csv`](industrial8_t5_opt144.csv) |
| 6 | 61,272 | 144 | [`industrial8_t6_opt144.csv`](industrial8_t6_opt144.csv) |

For strength 3, the pinned 2023 CT-Competition table records 54 as the smallest **valid** result for this model; a 49-row entry is marked invalid. R003 therefore improves that frozen valid comparison from 54 to 45 tests, a reduction of 9 tests (16.7%), and proves 45 optimal for the frozen benchmark.

## Why the lower bounds are exact

The constraints partition 144 of the 159 valid configurations into nine disjoint **mandatory classes**. In each mandatory class the four Boolean parameters `p1,...,p4` are completely free.

Any interaction containing the false parameter that defines one mandatory class can only be covered by a row from that class. Thus class-local covering lower bounds add across the nine classes.

| Global strength | Local obligation on `p1,...,p4` | Class-local minimum | Global lower bound |
|---:|---|---:|---:|
| 2 | all 1-way assignments | 2 | 18 |
| 3 | all 2-way assignments | 5 | 45 |
| 4 | all 3-way assignments | 8 | 72 |
| 5 | all 4-way assignments | 16 | 144 |
| 6 | all 4-way assignments plus one forced-true parameter | 16 | 144 |

The only nontrivial local combinatorial obstruction is the pairwise minimum 5 on four binary columns. The proof note and manuscript give the short analytic argument; both exact replay implementations independently brute-force the local finite problem. Lean additionally kernel-checks the four-row obstruction, the explicit five-row witness, and the arithmetic aggregation of a class-local bound across nine classes.

## Read the proof

- [GitHub-rendered proof note](proof.md)
- [LaTeX manuscript source](manuscript/r003_industrial8_exact_optima.tex) - CI compiles this source from a clean checkout and publishes the resulting PDF as a workflow artifact
- [Manuscript build instructions](manuscript/README.md)
- [Exact claim and non-claims](CLAIM.md)
- [Statement-to-evidence crosswalk](STATEMENT_AUDIT.md)
- [Verification and trust boundary](VERIFICATION.md)
- [Source and comparison audit](SOURCE_AUDIT.md)

## Verification architecture

R003 deliberately uses complementary assurance methods rather than treating any one script or formalization as the whole proof.

1. **Source identity** - `verify_sources.py` checks the frozen benchmark and 2023 comparison excerpt against pinned hashes.
2. **Primary exact replay** - `verify.py` enumerates all 24,576 raw assignments, derives exactly 159 valid configurations, enumerates all feasible interactions, reads the published witnesses, checks coverage, and exhaustively solves the local binary covering subproblems.
3. **Independent exact replay** - `verify_independent.cpp` separately parses and evaluates the benchmark text, re-enumerates the model/interactions, reads the witness files, and independently brute-forces the local minima.
4. **Auxiliary Lean formalization** - `R003/LocalCovering.lean` kernel-checks the nontrivial four-row pairwise obstruction, the explicit five-row witness, and the nine-class arithmetic aggregation theorem. It is intentionally **not** presented as a full Lean formalization of the benchmark parser, mandatory-class decomposition, or complete witness-coverage theorem.
5. **CI trust checks** - Lean and Mathlib are pinned; production Lean sources are scanned for proof shortcuts; an axiom audit runs at `--trust=0`; and `leanchecker --fresh` replays the compiled formalization.

### One-command clean-checkout replay

With Python 3, a C++20 compiler, and the pinned Lean/Lake toolchain available:

```bash
./verify_release.sh
```

The script replays frozen-source identity, the Python proof checker, the independent C++ parser/checker, deterministic report freshness, the pinned Lean build, the production-source shortcut scan, the trust-zero axiom audit, and the fresh Lean kernel replay.

The same components can be run separately:

```bash
python3 verify_sources.py
python3 verify.py

g++ -std=c++20 -O2 -Wall -Wextra -pedantic verify_independent.cpp -o verify_independent
./verify_independent

lake build R003 R003.Audit
lake env lean --trust=0 R003/Audit.lean
lake env leanchecker --fresh R003.LocalCovering
```

The Python/C++ replay proves the complete frozen-model claim. The Lean layer narrows the trusted mathematical core but does not replace those full-model checks. See `VERIFICATION.md` and `formalization.yaml` for the precise boundary.

## Provenance

The benchmark is pinned to `fmselab/CIT_Benchmark_Generator`:

- commit `7ed44c18a771b9bbdc444a3c9178a7a68510a53f`
- Git blob `4ede6ee93f6eea06927f972cf5ba22621ecc3013`
- SHA-256 `01785c43dbce4381d928c064c14dfe3c3734237db8fa7c2e84d8647f8ed299b4`

The frozen 2023 comparison is pinned to `fmselab/ct-competition` commit `3c8cdc1ac9eb4e045404d8db75ce38bad7541808`, file blob `414bc2b1d47a8cd5a8e7263b5fa01e1104929da3`.

## Claim boundary

R003 proves exact optima **only for the frozen `INDUSTRIAL_8` model and the feasible-interaction semantics documented here**. It does not claim a general theorem for arbitrary constrained test suites, and the 54-to-45 comparison is deliberately limited to the pinned 2023 public result table rather than asserting priority over every later or unpublished construction.

The repository does not claim that the complete theorem is Lean-formalized. External specialist review and peer review are not claimed.

## Repository map

- `INDUSTRIAL_8.txt` - frozen benchmark.
- `industrial8_t*_opt*.csv` - explicit optimal witnesses.
- `manuscript/` - paper source, build instructions, and CI-generated PDF artifact.
- `proof.md` - GitHub-rendered proof.
- `R003/` / `R003.lean` - auxiliary Lean lower-bound formalization and axiom audit.
- `formalization.yaml` - machine-readable formalization scope and declarations.
- `CLAIM.md`, `claim.json`, `STATEMENT_AUDIT.md` - statement identity.
- `VERIFICATION.md` - reproduction and trust boundary.
- `SOURCE_AUDIT.md` - benchmark/comparison provenance.
- `verify.py`, `verify_independent.cpp`, `verify_sources.py` - exact replay paths.
- `verify_release.sh` - one-command public replay of the complete verification stack.
- `verification-report.json` - deterministic machine-readable results.
- `CITATION.cff` - citation metadata.
- `LICENSE` - public research-use notice and rights statement.

Public release page: https://unsolved-labs.github.io/results/r003-industrial8/
