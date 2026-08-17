# R003 verification

## Verification objective

Replay the complete R003 claim from public frozen artifacts without relying on the search process or on frontier-AI output.

The final trust boundary contains:

1. the exact benchmark bytes in `INDUSTRIAL_8.txt`;
2. the mathematical definition of feasible $t$-way coverage;
3. the published witness CSV files;
4. the primary Python standard-library verifier;
5. an independently implemented C++20 model parser/verifier;
6. ordinary language/compiler/runtime correctness.

No optimizer, SAT/SMT service, floating-point solver, network service, or model-generation process is required.

## Frozen source identity

`verify_sources.py` requires:

- `INDUSTRIAL_8.txt`
  - SHA-256: `01785c43dbce4381d928c064c14dfe3c3734237db8fa7c2e84d8647f8ed299b4`
  - Git blob SHA-1: `4ede6ee93f6eea06927f972cf5ba22621ecc3013`
- `sources/ct_competition_2023_industrial8_t3.csv`
  - SHA-256: `ac55e077a871a8f1cb51a1558a981941811d51565cfa3de5329fc0194b2935a2`

The benchmark Git blob matches the pinned upstream file byte-for-byte.

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

## Deterministic verification report

To regenerate:

```bash
python3 verify.py --write-report
git diff --exit-code verification-report.json
```

The report contains the exact witness hashes, interaction counts, local minima, lower bounds, and trust-boundary description.

## Why two implementations matter

The Python path deliberately uses a small hand-auditable semantic function tied to the exact benchmark hash. The C++ path instead parses and evaluates the benchmark text. They therefore do not share a constraint parser or executable semantics implementation.

Both paths still rely on the same mathematical definition of $t$-way coverage; that definition is stated in the manuscript.

## Formal-proof status

This release does **not** claim Lean verification.

The lower-bound argument is elementary except for a tiny finite binary covering subproblem. That finite core is exhaustively solved by both implementations, while the full model/witness claim is exhaustively enumerated. This is currently the principal verification route.

A future proof-assistant development may formalize the class decomposition and the implication from class-local minima to the global lower bounds. Until such code exists and passes kernel checking, no Lean/formal-proof badge or wording should be used.

## CI

`.github/workflows/verify.yml` runs:

- source-integrity replay;
- primary Python replay;
- deterministic report freshness;
- C++20 compile and independent replay;
- manuscript compilation.

The same commands documented here are the commands CI executes.
