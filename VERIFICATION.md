# R003 verification

## Objective

Replay the complete R003 claim from frozen public artifacts while minimizing dependence on the search process or the frontier-AI system that generated the research artifact.

The release uses a hybrid assurance boundary:

- exact finite replay of the **complete frozen-model theorem** in independent Python and C++ implementations;
- pinned Lean 4 / Mathlib checking of a load-bearing local lower-bound core;
- a statement/provenance crosswalk tying both layers to the public manuscript and witnesses.

No optimizer, SAT/SMT service, floating-point solver, network service, or model-generation trace is required for the final replay.

## Frozen source identity

`verify_sources.py` checks:

- `INDUSTRIAL_8.txt`
  - SHA-256: `01785c43dbce4381d928c064c14dfe3c3734237db8fa7c2e84d8647f8ed299b4`
  - Git blob: `4ede6ee93f6eea06927f972cf5ba22621ecc3013`
- `sources/ct_competition_2023_industrial8_t3.csv`
  - SHA-256: `ac55e077a871a8f1cb51a1558a981941811d51565cfa3de5329fc0194b2935a2`

## Complete exact replay: Python

```bash
python3 verify_sources.py
python3 verify.py
```

`verify.py` uses the Python standard library and:

- checks frozen source hashes;
- enumerates all $2^{13}\cdot3=24{,}576$ raw assignments;
- obtains exactly 159 valid configurations;
- confirms nine 16-row mandatory classes plus 15 residual rows;
- exactly solves the local binary covering subproblems;
- reads every published witness CSV;
- verifies row validity and uniqueness;
- enumerates every feasible interaction at strengths 2-6;
- verifies complete coverage;
- confirms witness size equals the proved lower bound;
- checks `optima.csv` and the deterministic `verification-report.json`.

## Independent complete replay: C++20

```bash
g++ -std=c++20 -O2 -Wall -Wextra -pedantic verify_independent.cpp -o verify_independent
./verify_independent
```

The C++ verifier does not import or call the Python implementation. It separately parses the benchmark parameter domains and constraint expressions, evaluates the model on all raw assignments, parses the witnesses, re-enumerates all feasible interactions, and independently brute-forces the local covering minima.

The two implementations share the mathematical definition of constrained $t$-way coverage, stated in the manuscript, but do not share a constraint parser or executable model-semantics implementation.

## Auxiliary Lean 4 formalization

The repository also contains a deliberately scoped formal proof layer.

Pinned environment:

- Lean toolchain: `leanprover/lean4:v4.32.0`
- Mathlib commit: `81a5d257c8e410db227a6665ed08f64fea08e997`
- dependency closure: `lake-manifest.json`

Main declarations in `R003/LocalCovering.lean`:

- `R003.pairwiseFourRowObstruction` - kernel-checked finite proof that no four distinct 4-bit rows cover every binary pair of coordinates;
- `R003.pairwiseFiveRowWitness` - kernel-checked verification of the explicit five-row pairwise covering array;
- `R003.nineClassSumLower` - formal arithmetic aggregation of a class-local lower bound across nine classes;
- arithmetic specializations for lower bounds 18, 45, 72, and 144 once the corresponding class-local hypotheses are supplied.

Run:

```bash
lake build R003 R003.Audit
lake env lean --trust=0 R003/Audit.lean
lake env leanchecker --fresh R003.LocalCovering
```

### Lean trust controls

CI additionally rejects production-source occurrences of `sorry`, `admit`, `native_decide`, `Lean.ofReduceBool`, unsafe/opaque/axiom/extern/partial shortcuts, `debug.skipKernelTC`, and `@[implemented_by]`.

`R003/Audit.lean` prints the axiom dependencies of the public declarations. CI rejects `sorryAx`, `Lean.trustCompiler`, and any axiom outside the explicit standard allowlist. A fresh `leanchecker` replay then checks the compiled module.

## Exact scope of Lean verification

The Lean layer is **partial but load-bearing**. It does not formalize:

- the parser semantics of the entire `INDUSTRIAL_8.txt` language;
- the correspondence between the pinned text file and a Lean model;
- Proposition 1's complete nine-class decomposition of the frozen benchmark;
- the full interaction enumeration or CSV witness-coverage theorem;
- the class-local minima 2, 8, and 16 as standalone Lean cardinality theorems.

Those obligations remain covered by the two independent exact full-model replays and the human proof. Therefore the correct public wording is **"auxiliary Lean-checked lower-bound core"**, not "the complete R003 theorem is Lean-formalized."

The machine-readable boundary is recorded in `formalization.yaml`.

## Deterministic report

```bash
python3 verify.py --write-report
git diff --exit-code -- verification-report.json
```

The report records source identity, witness hashes, interaction counts, local minima, lower bounds, and trust-boundary metadata.

## Manuscript

The paper source is `manuscript/r003_industrial8_exact_optima.tex`; CI compiles it from a clean checkout. The manuscript distinguishes the complete Python/C++ replay from the auxiliary Lean formalization.

## CI

`.github/workflows/verify.yml` executes three independent jobs:

1. complete source/Python/C++ verification and deterministic report check;
2. pinned Lean build, proof-shortcut scan, trust-zero axiom audit, and fresh kernel replay;
3. manuscript compilation.

All public verification wording must remain consistent with this boundary.
