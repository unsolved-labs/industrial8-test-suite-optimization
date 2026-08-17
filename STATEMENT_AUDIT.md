# R003 statement audit

This crosswalk maps each load-bearing public statement to the paper and machine evidence. "Lean" below means the scoped auxiliary formalization, not a formalization of the complete benchmark theorem.

| Public statement | Manuscript | Complete exact replay | Lean evidence |
|---|---|---|---|
| The frozen benchmark has 24,576 raw assignments. | Section 2 | Python product enumeration; C++ parses domains | Not formalized |
| Exactly 159 configurations satisfy the frozen constraints. | Proposition 1 | independent Python/C++ exhaustive enumeration | Not formalized |
| Valid configurations split into nine 16-row mandatory classes plus 15 residual rows. | Proposition 1 | independent Python/C++ class census | Not formalized |
| Class-local 1-way binary covering minimum is 2. | Lemma 2 | independent Python/C++ subset search | Not a standalone Lean theorem |
| Class-local 2-way binary covering minimum is 5. | Lemma 3 | independent Python/C++ subset search | `pairwiseFourRowObstruction` + `pairwiseFiveRowWitness` |
| Class-local 3-way binary covering minimum is 8. | Lemma 4 | independent Python/C++ subset search | Not a standalone Lean theorem |
| Class-local 4-way binary covering minimum is 16. | Lemma 5 | independent Python/C++ subset search | Not a standalone Lean theorem |
| Nine disjoint classes multiply a class-local bound by 9. | Theorem 6 proof | reconstructed independently in Python/C++ | `nineClassSumLower` and arithmetic specializations |
| $N_2\ge18$, $N_3\ge45$, $N_4\ge72$, $N_5,N_6\ge144$. | Theorem 6 | exact local minima + nine-class decomposition | Aggregation arithmetic is formalized; model-to-class hypotheses are not |
| Published strength-2 witness has 18 valid rows covering all 326 interactions. | Section 4 | independent Python/C++ replay of CSV | Not formalized |
| Strength-3 witness has 45 valid rows covering all 2,168 interactions. | Section 4 | independent Python/C++ replay of CSV | Not formalized |
| Strength-4 witness has 72 rows covering all 9,374 interactions. | Section 4 | independent Python/C++ replay | Not formalized |
| Strength-5 witness has 144 rows covering all 28,192 interactions. | Section 4 | independent Python/C++ replay | Not formalized |
| Strength-6 witness has 144 rows covering all 61,272 interactions. | Section 4 | independent Python/C++ replay | Not formalized |
| Exact optima are 18,45,72,144,144. | Theorem 7 | lower bounds + witness coverage in two complete exact implementations | Partial lower-bound core only |
| Frozen 2023 comparison has best valid strength-3 size 54; the 49-row row is invalid. | Sections 1 and 5 | `verify_sources.py` + pinned source excerpt | Not formalized |
| 45 improves 54 by 9 rows = 1/6 ≈16.7%. | Sections 1 and 5 | exact arithmetic | Not formalized |

## Formalization identity

The public Lean declarations and scope are listed in `formalization.yaml`. Production Lean code is pinned by `lean-toolchain` and `lake-manifest.json`, scanned for proof shortcuts, audited for axioms, and replayed with `leanchecker --fresh` in CI.

The formalization must not be described as proving the complete R003 theorem unless future code formally links the frozen benchmark semantics, mandatory-class decomposition, and witness coverage to the final theorem.

## Canonical statement rule

`CLAIM.md` and `claim.json` are the canonical claim boundary. Any change in README, manuscript, release page, verification code, or formalization scope that affects that boundary must update this crosswalk in the same pull request.
