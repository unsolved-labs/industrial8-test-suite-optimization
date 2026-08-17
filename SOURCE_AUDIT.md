# R003 source and comparison audit

## Frozen benchmark

Canonical local file:

`INDUSTRIAL_8.txt`

Pinned upstream source:

- repository: `https://github.com/fmselab/CIT_Benchmark_Generator`
- path: `Benchmarks_CITCompetition_2023/EvaluationPhase/ACTS/INDUSTRIAL_8.txt`
- commit: `7ed44c18a771b9bbdc444a3c9178a7a68510a53f`
- Git blob: `4ede6ee93f6eea06927f972cf5ba22621ecc3013`
- local/upstream SHA-256: `01785c43dbce4381d928c064c14dfe3c3734237db8fa7c2e84d8647f8ed299b4`

The repository copy is intentionally byte-for-byte identical to that upstream blob.

The benchmark family is described in:

Andrea Bombarda and Angelo Gargantini, “Design, implementation, and validation of a benchmark generator for combinatorial interaction testing tools,” *Journal of Systems and Software* 209 (2024), 111920. DOI: `10.1016/j.jss.2023.111920`.

## Frozen 2023 comparison

Pinned result source:

- repository: `https://github.com/fmselab/ct-competition`
- path: `results/2023/data/output_best.csv`
- branch snapshot commit: `3c8cdc1ac9eb4e045404d8db75ce38bad7541808`
- Git blob: `414bc2b1d47a8cd5a8e7263b5fa01e1104929da3`

The six `INDUSTRIAL_8`, strength-3 rows are frozen in:

`sources/ct_competition_2023_industrial8_t3.csv`

They are:

| Tool | Size | Status in source table |
|---|---:|---|
| caopt | 55 | valid |
| acts | 68 | valid |
| cagen | 68 | valid |
| kali | 71 | `Invalid` |
| medici | 49 | `Invalid` |
| pmedici | 54 | valid |

Therefore the smallest valid result in this **frozen table** is 54.

The CT-Competition 2023 rules state that test-suite validity and completeness are mandatory for evaluation. This release accordingly does not treat the 49-row invalid entry as a competing valid suite.

Official competition page:

`https://fmselab.github.io/ct-competition/results/2023/index2023.html`

## Novelty and comparison boundary

The public claim is deliberately narrower than “best ever” or “first ever.”

R003 establishes an exact optimum for the pinned benchmark bytes and shows a strict improvement over the pinned 2023 public competition table. It does not assert that no later unpublished/private construction, independent 2024–2026 result, or differently normalized benchmark copy existed unless separately documented.

If a later public prior result is discovered, update the introduction/comparison wording without changing the exact optimum theorem.

## Automated source checks

Run:

```bash
python3 verify_sources.py
```

This verifies the benchmark identity and the frozen comparison excerpt before the mathematical replay begins.
