# R003 — Exact Constrained Test-Suite Optimization

**Unsolved Labs Research Release R003**

A proof-carrying solution of the public `INDUSTRIAL_8` constrained combinatorial-testing benchmark.

## Result

For interaction strength `t`, the exact minimum number of valid tests is:

| Strength | Exact minimum |
|---:|---:|
| 2 | 18 |
| 3 | **45** |
| 4 | 72 |
| 5 | 144 |
| 6 | 144 |

At strength 3, the best valid public 2023 competition submission used 54 tests. This release gives 45 tests, a reduction of 9 tests (16.7%), together with a matching analytic lower bound proving optimality.

## Status

- Public construction and proof
- Exact exhaustive verification
- External specialist/novelty review: pending

## Reproduce

The verifier uses only Python's standard library:

```bash
python verify.py
```

It enumerates all 24,576 raw assignments, derives the 159 valid configurations and all valid interactions at strengths 2 through 6, checks the constructions, and confirms that every construction meets the analytic lower bound.

## Files

- `INDUSTRIAL_8.txt` — frozen public benchmark model
- `industrial8_t3_opt45.csv` — 45-test optimal strength-3 witness
- `optima.csv` — exact optimum summary
- `proof.md` — analytic optimality proof and claim boundary
- `verify.py` — dependency-free exhaustive verifier

## Upstream sources

Benchmark model:
https://github.com/fmselab/CIT_Benchmark_Generator/blob/main/Benchmarks_CITCompetition_2023/EvaluationPhase/ACTS/INDUSTRIAL_8.txt

2023 competition outputs:
https://github.com/fmselab/ct-competition/blob/gh-pages/results/2023/data/output_best.csv

## Public release page

https://unsolved-labs.github.io/results/r003-industrial8/
