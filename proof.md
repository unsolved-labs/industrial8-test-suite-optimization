# R003 — Exact constrained covering arrays for `INDUSTRIAL_8`

A typeset version of this proof is available in
[`manuscript/r003_industrial8_exact_optima.pdf`](manuscript/r003_industrial8_exact_optima.pdf).

## Statement

Let $N_t$ denote the minimum number of valid configurations required to cover every feasible $t$-way interaction of the frozen CT-Competition model `INDUSTRIAL_8`. Then

$$
N_2=18,\qquad N_3=45,\qquad N_4=72,\qquad N_5=N_6=144.
$$

The frozen public 2023 competition output table records 54 as the smallest **valid** strength-3 result for this model. A 49-row entry is present but marked `Invalid`. Thus the 45-row construction improves the frozen valid comparison by nine tests, or $1/6\approx16.7\%$, and the lower bound below proves that 45 is optimal for the frozen model.

## Structural reduction

The model has 13 Boolean parameters and one three-valued parameter. Its constraints imply:

1. `p14=v3` is impossible.
2. `p14=v1` exactly when `p3=true`; otherwise `p14=v2`.
3. Among `p5,...,p12`, at most one parameter may be false.
4. If `p13=false`, then all of `p5,...,p12` are true.
5. The assignment with `p1,...,p13` all true is forbidden.

Hence there are exactly 159 valid configurations:

- for each $q\in\{p5,\ldots,p12\}$, 16 configurations with $q=false$, all other `p5,...,p12` true, and `p13=true`;
- 16 configurations with `p13=false` and `p5,...,p12` all true;
- 15 residual configurations with `p5,...,p13` all true and `(p1,p2,p3,p4)` not all true.

The first nine groups are disjoint. Call them the **mandatory classes**. Inside every mandatory class, `p1,...,p4` are completely free.

The primary verifier enumerates all 24,576 raw assignments and obtains this 159-row set. The independent C++ verifier reaches the same set by parsing and evaluating the model text directly.

## Lower bounds

Fix one mandatory class. Any interaction containing its class-defining false parameter can only be covered by a row in that same class. Therefore lower bounds proved within one class add across the nine disjoint classes.

### Strength 2

Fix the class-defining false parameter and one of `p1,...,p4`. Both Boolean values occur among valid interactions, so every mandatory class needs at least two rows:

$$
N_2\ge 9\cdot2=18.
$$

### Strength 3

Fix the class-defining false parameter and two of `p1,...,p4`. The rows selected from that class must form a binary pairwise covering array on four columns.

Four rows are impossible. If four rows covered every pair, each pair of columns would contain `00,01,10,11` exactly once. Normalize two columns to `0011` and `0101`. Up to complement, the only third balanced column orthogonal to both is `0110`, leaving no fourth column orthogonal to all three.

Five rows suffice, for example

$$
B=\{0000,0111,1011,1101,1110\}.
$$

Therefore

$$
N_3\ge9\cdot5=45.
$$

Both verifiers also solve this 16-word local covering problem exhaustively and independently obtain the exact minimum 5.

### Strength 4

Fix the class-defining false parameter and any three of `p1,...,p4`. A fixed triple has all $2^3=8$ possible assignments among the 16 valid class rows. Each selected test covers only one assignment of that triple, so at least eight rows are required:

$$
N_4\ge9\cdot8=72.
$$

### Strength 5

Fix the class-defining false parameter and all four of `p1,...,p4`. All $2^4=16$ assignments are feasible, hence

$$
N_5\ge9\cdot16=144.
$$

### Strength 6

In a mandatory class, choose any parameter among the remaining `p5,...,p13` that is forced true. Add it to the strength-5 interaction. The same 16 assignments of `p1,...,p4` remain necessary:

$$
N_6\ge9\cdot16=144.
$$

The local minima $2,5,8,16$ are independently confirmed by exhaustive subset search in both `verify.py` and `verify_independent.cpp`.

## Constructions

All released constructions use only mandatory-class rows.

- **Strength 2:** use a complementary pair of four-bit words in each mandatory class, cycling four cut types across the classes.
- **Strength 3:** use the five-word array
  $$
  B=\{0000,0111,1011,1101,1110\},
  $$
  translated by `0000`, `0001`, `0010`, and `0011` and cycled through the nine classes.
- **Strength 4:** alternate the even- and odd-parity eight-word classes. Each gives all assignments on every three selected coordinates.
- **Strengths 5 and 6:** use all 16 four-bit words in every mandatory class.

The explicit witnesses are published as CSV files rather than existing only inside verifier source code.

## Exhaustive coverage replay

Exact enumeration gives:

| Strength | Valid interactions | Published rows | Lower bound |
|---:|---:|---:|---:|
| 2 | 326 | 18 | 18 |
| 3 | 2,168 | 45 | 45 |
| 4 | 9,374 | 72 | 72 |
| 5 | 28,192 | 144 | 144 |
| 6 | 61,272 | 144 | 144 |

For every strength, both independent implementations read the published witness, verify every row satisfies the model, enumerate all feasible $t$-way interactions, and confirm that none are missing.

Since each construction attains the corresponding exact lower bound,

$$
(N_2,N_3,N_4,N_5,N_6)=(18,45,72,144,144).
$$

## Verification boundary

Run:

```bash
python3 verify_sources.py
python3 verify.py

g++ -std=c++20 -O2 -Wall -Wextra -pedantic verify_independent.cpp -o verify_independent
./verify_independent
```

Search, optimization, and AI generation are outside the final correctness oracle. The released theorem is replayed from frozen public artifacts by exact finite computation and the analytic lower-bound argument above.

See [`VERIFICATION.md`](VERIFICATION.md) and [`STATEMENT_AUDIT.md`](STATEMENT_AUDIT.md).

## Source comparison and status

Provenance is pinned in [`SOURCE_AUDIT.md`](SOURCE_AUDIT.md). The public comparison is intentionally limited to the frozen CT-Competition 2023 result table.

External specialist review remains pending, and peer review is not claimed.
