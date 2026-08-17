# R003 statement audit

This file maps every load-bearing public statement to the paper and machine-checkable evidence. It is deliberately explicit about the boundary of the supplementary Lean formalization.

| Public statement | Manuscript location | Primary verification | Independent verification | Lean/formal verification |
|---|---|---|---|---|
| The frozen benchmark has 24,576 raw assignments. | §2 and §5 | `verify.py`: product of 13 binary domains and one 3-valued domain | `verify_independent.cpp`: parses domains from `INDUSTRIAL_8.txt` | Not formalized in Lean |
| Exactly 159 configurations satisfy the constraints. | Proposition 1, §2 | exact enumeration under the pinned semantics | C++ parser evaluates the constraint text on every raw assignment | Not formalized in Lean |
| The valid configurations split into nine 16-row mandatory classes plus 15 residual rows. | Proposition 1, §2 | class census in `verify.py` | independent class census in C++ | Not formalized in Lean |
| Class-local 1-way binary covering minimum is 2. | Lemma 2, §3 | exhaustive subset search over all 16 four-bit words | independent C++ subset search | Not formalized in Lean |
| Class-local 2-way binary covering minimum is 5. | Lemma 3, §3 | exhaustive subset search over all 16 four-bit words | independent C++ subset search | `R003.noFourRowPairwiseCover` and `R003.baseFivePairwiseCovers` check the 4-row impossibility and explicit 5-row witness |
| Class-local 3-way binary covering minimum is 8. | Lemma 4, §3 | exhaustive subset search | independent C++ subset search | Not formalized in Lean |
| Class-local 4-way binary covering minimum is 16. | Lemma 5, §3 | exhaustive subset search | independent C++ subset search | Not formalized in Lean |
| $N_2\ge18$, $N_3\ge45$, $N_4\ge72$, $N_5,N_6\ge144$. | Theorem 6, §3 | nine disjoint mandatory classes × exact local minima | same lower-bound reconstruction in C++ | Lean certifies the nontrivial local strength-3 subclaim only; the global class reduction is not Lean-formalized |
| The published strength-2 witness has 18 valid distinct rows and covers all 326 valid 2-way interactions. | §4, Table 1 | reads `industrial8_t2_opt18.csv` | C++ reads the same CSV and re-enumerates interactions | Not formalized in Lean |
| The published strength-3 witness has 45 valid distinct rows and covers all 2,168 valid 3-way interactions. | §4, Table 1 | reads `industrial8_t3_opt45.csv` | C++ reads the same CSV and re-enumerates interactions | The local 5-row building block is Lean-checked; global constrained coverage is Python/C++ checked |
| The published strength-4 witness has 72 rows and covers all 9,374 valid interactions. | §4, Table 1 | exact replay | independent C++ replay | Not formalized in Lean |
| The published strength-5 witness has 144 rows and covers all 28,192 valid interactions. | §4, Table 1 | exact replay | independent C++ replay | Not formalized in Lean |
| The published strength-6 witness has 144 rows and covers all 61,272 valid interactions. | §4, Table 1 | exact replay | independent C++ replay | Not formalized in Lean |
| Therefore the exact optima are 18,45,72,144,144. | Theorem 7, §4 | every witness size equals its exact lower bound | same conclusion independently replayed | Partial only; no claim of a full Lean proof of all five optima |
| The frozen 2023 comparison has best valid strength-3 size 54. | §1 and §6, Table 2 | `verify_sources.py` checks the frozen excerpt | pinned source commit/blob is directly auditable | Not applicable |
| The 49-row competition entry is excluded because it is marked `Invalid`. | §1 and §6, Table 2 | frozen source excerpt check | pinned source table | Not applicable |
| 45 improves 54 by nine rows, i.e. $1/6\approx16.7\%$. | Abstract/§1/§6 | exact integer arithmetic | direct arithmetic | Not applicable |

## Canonical statement identity

The canonical public claim is `CLAIM.md` / `claim.json`. If the README, manuscript, release page, verifier output, or formal declarations change scope, this audit must be updated in the same pull request.

## Formalization boundary

The repository contains a **supplementary partial Lean 4 formalization** of the load-bearing local strength-3 covering-array fact. It proves that no four-row binary array on four columns realizes every binary value pair on every distinct column pair, and that the explicit five-row block used in the construction does.

The full 14-parameter constraint semantics, the 159-configuration census, the nine-class reduction, all released global witness checks, and the strength-2/4/5/6 local minima remain outside Lean. Those obligations are covered by the manuscript plus two exact executable implementations with different model-semantics paths: the Python verifier uses a small hand-auditable semantic function tied to the frozen model hash, while the C++ verifier parses and evaluates the frozen constraint text directly.

Accordingly, public wording may say **“partial Lean formalization of the local strength-3 bound”** but must not say **“the complete R003 theorem is Lean-verified.”**
