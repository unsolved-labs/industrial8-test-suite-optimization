# R003 verification

## Verification objective

Replay the complete R003 claim from public frozen artifacts without relying on the search process or on frontier-AI output, and formally certify the most delicate local combinatorial lower-bound step.

The final trust boundary contains:

1. the exact benchmark bytes in `INDUSTRIAL_8.txt`;
2. the mathematical definition of feasible $t$-way coverage;
3. the published witness CSV files;
4. the primary Python standard-library verifier;
5. an independently implemented C++20 model parser/verifier;
6. the Lean kernel for the partial formalization and an independent Lean type checker in CI;
7. ordinary language/compiler/runtime correctness for the executable replay paths.

No optimizer, SAT/SMT service, floating-point solver, network service, or model-generation process is required for replay.

## Frozen source identity

`verify_sources.py` requires:

- `INDUSTRIAL_8.txt`
  - SHA-256: `01785c43dbce4381d928c064c14dfe3c3734237db8fa7c2e84d8647f8ed299b4`
  - Git blob SHA-1: `4ede6ee93f6eea06927f972cf5ba22621ecc3013`
- `sources/ct_competition_2023_industrial8_t3.csv`
  - SHA-256: `ac55e077a871a8f1cb51a1558a981941811d51565cfa3de5329fc0194b2935a2`

The benchmark Git blob matches the pinned upstream file byte-for-byte.

## One-command local replay

```bash
./verify_release.sh
```

The script runs source verification, Python replay, C++ replay, report freshness, and `lake build` when Lean is installed. GitHub Actions always runs the Lean job.

## Primary replay

Requirements:

- Python 3.12 or a compatible Python 3 implementation;
- no third-party Python packages.

Run:

```bash
python3 verify_sources.py
python3 verify.py
```

`verify.py`:

- checks frozen source hashes;
- enumerates all $2^{13}\cdot3=24{,}576$ raw assignments;
- obtains exactly 159 valid configurations;
- confirms the nine 16-row mandatory classes and 15 residual rows;
- exactly solves the local binary covering subproblems by exhaustive subset search;
- reads each published witness CSV;
- verifies row validity and uniqueness;
- enumerates all feasible interactions at strengths 2–6;
- verifies complete coverage;
- confirms witness size equals the exact lower bound;
- checks `optima.csv`;
- checks that the committed machine-readable report is current.

Expected final line:

```text
PASS verification-report.json is current
```

## Independent C++20 replay

The C++ verifier does not call or import the Python verifier.

It separately:

- parses parameter domains from `INDUSTRIAL_8.txt`;
- parses and recursively evaluates the Boolean constraint expressions in the file;
- enumerates the complete valid configuration set;
- parses all published witness CSV files;
- enumerates all feasible interactions;
- brute-forces the four class-local binary covering minima;
- reconstructs the global lower bounds.

Build and run:

```bash
g++ -std=c++20 -O2 -Wall -Wextra -pedantic verify_independent.cpp -o verify_independent
./verify_independent
```

Expected final lines include:

```text
PASS independent parser evaluated the frozen model text directly.
PASS independent local subset search proves minima 2,5,8,16.
```

## Lean 4 partial formalization

The supplementary Lean project is pinned by:

- `lean-toolchain`: Lean `v4.32.0`;
- `lakefile.toml` and `lake-manifest.json`: Mathlib `v4.32.0` and its exact dependency graph;
- `formalization.yaml`: declaration-level scope, axiom audit, and review metadata.

Build:

```bash
lake build
```

The main declarations are:

- `R003.noFourRowPairwiseCover` — no four-row binary array on four columns covers all four value pairs on every distinct pair of columns;
- `R003.baseFivePairwiseCovers` — the explicit five-row block used in the proof does have full pairwise coverage.

These declarations certify the nontrivial local fact needed for the strength-3 lower bound. They **do not** formalize the full constrained-model theorem. The nine-class structural reduction, full model semantics, interaction enumeration, and the other strengths remain covered by the manuscript plus the independent Python/C++ exact replays.

Both finite Lean theorems use ordinary `decide`, not `native_decide` or an external computation oracle. The four-row theorem raises Lean's reduction resource limits because the complete finite decision tree exceeds the conservative default recursion depth; changing those limits does not add a proof axiom.

The expected `#print axioms` audit is:

```text
R003.noFourRowPairwiseCover: [propext, Quot.sound]
R003.baseFivePairwiseCovers: [propext, Quot.sound]
```

Those standard logical axioms arise from Mathlib's finite-type/finset decision infrastructure and are recorded explicitly in `formalization.yaml`. `sorryAx`, `Classical.choice`, and a native-decision oracle are not allowed for these declarations.

Production Lean files are required to contain no `sorry` or `admit`. CI runs `leanprover/lean-action` with `nanoda` and `nanoda-allow-sorry: false`, adding a separate Lean type-checking implementation to the trust-reduction stack.

## Deterministic verification report

To regenerate:

```bash
python3 verify.py --write-report
git diff --exit-code verification-report.json
```

The report contains exact witness hashes, interaction counts, local minima, lower bounds, and trust-boundary description.

## Why the verification paths are complementary

The Python path uses a small hand-auditable semantic function tied to the exact benchmark hash. The C++ path instead parses and evaluates the benchmark text. They therefore do not share a constraint parser or executable semantics implementation.

Lean checks a mathematical subclaim through a proof assistant rather than through either executable model implementation. This reduces the trusted surface for the strength-3 lower-bound bottleneck without overstating the formalization scope.

## CI

`.github/workflows/verify.yml` runs:

- source-integrity replay;
- primary Python replay;
- deterministic report freshness;
- C++20 compile and independent replay;
- Lean build with `sorry` rejection and independent `nanoda` checking;
- manuscript compilation.

The same public commands documented here are the commands CI executes.
