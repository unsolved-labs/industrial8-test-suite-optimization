# R003 statement audit

This file maps every load-bearing public statement to its paper statement and machine-checkable evidence.

| Public statement | Manuscript location | Primary verification | Independent verification |
|---|---|---|---|
| The frozen benchmark has 24,576 raw assignments. | §2 | `verify.py`: product of 13 binary domains and one 3-valued domain | `verify_independent.cpp`: parses domains from `INDUSTRIAL_8.txt` |
| Exactly 159 configurations satisfy the constraints. | Proposition 1, §2 | `verify.py`: exact enumeration under the pinned semantics | C++ parser evaluates the constraint text on every raw assignment |
| The valid configurations split into nine 16-row mandatory classes plus 15 residual rows. | Proposition 1, §2 | class census in `verify.py` | independent class census in C++ |
| Class-local 1-way binary covering minimum is 2. | Lemma 2, §3 | exhaustive subset search over all 16 four-bit words | independent C++ subset search |
| Class-local 2-way binary covering minimum is 5. | Lemma 3, §3 | exhaustive subset search over all 16 four-bit words | independent C++ subset search |
| Class-local 3-way binary covering minimum is 8. | Lemma 4, §3 | exhaustive subset search | independent C++ subset search |
| Class-local 4-way binary covering minimum is 16. | Lemma 5, §3 | exhaustive subset search | independent C++ subset search |
| $N_2\ge18$, $N_3\ge45$, $N_4\ge72$, $N_5,N_6\ge144$. | Theorem 6, §3 | nine disjoint mandatory classes × exact local minima | same lower-bound reconstruction in C++ |
| The published strength-2 witness has 18 valid distinct rows and covers all 326 valid 2-way interactions. | §4 and Table 2 | `verify.py` reads `industrial8_t2_opt18.csv` | C++ reads the same CSV and re-enumerates interactions |
| The published strength-3 witness has 45 valid distinct rows and covers all 2,168 valid 3-way interactions. | §4 and Table 2 | `verify.py` reads `industrial8_t3_opt45.csv` | C++ reads the same CSV and re-enumerates interactions |
| The published strength-4 witness has 72 rows and covers all 9,374 valid interactions. | §4 and Table 2 | primary exact replay | independent C++ replay |
| The published strength-5 witness has 144 rows and covers all 28,192 valid interactions. | §4 and Table 2 | primary exact replay | independent C++ replay |
| The published strength-6 witness has 144 rows and covers all 61,272 valid interactions. | §4 and Table 2 | primary exact replay | independent C++ replay |
| Therefore the exact optima are 18,45,72,144,144. | Theorem 7, §4 | each witness size equals its exact lower bound | same conclusion independently replayed |
| The frozen 2023 comparison has best valid strength-3 size 54. | §1 and §5 | `verify_sources.py` checks the frozen excerpt | source commit/blob is independently auditable |
| The 49-row competition entry is excluded because it is marked `Invalid`. | §5 | source excerpt check | pinned source table |
| 45 improves 54 by nine rows, i.e. $1/6\approx16.7\%$. | §1 | exact integer arithmetic | direct arithmetic |

## Statement identity rule

The canonical public theorem is the statement in `CLAIM.md` / `claim.json`. If the README, manuscript, release page, or verifier output changes its scope, this audit must be updated in the same pull request.

## What is not machine-formalized

No Lean proof is claimed in this release. The mathematical lower bound is short, and its only nontrivial finite subproblem—the impossibility of a 4-row binary pairwise covering array on four columns—is exhaustively checked twice by independent implementations. The full constrained-model theorem is additionally verified by exhaustive enumeration of all 24,576 raw assignments and every feasible interaction.

A future Lean formalization could reduce the trusted mathematical layer further, but the present claim must not be described as Lean-verified.
