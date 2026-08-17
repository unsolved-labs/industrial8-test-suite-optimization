# R003 - Exact constrained covering arrays for `INDUSTRIAL_8`

A typeset version is available in [`manuscript/r003_industrial8_exact_optima.pdf`](manuscript/r003_industrial8_exact_optima.pdf). Machine-checking details are in [`VERIFICATION.md`](VERIFICATION.md).

## Statement

Let $N_t$ be the minimum number of valid configurations required to cover every feasible $t$-way interaction of the frozen `INDUSTRIAL_8` benchmark. Then

$$
N_2=18,\qquad N_3=45,\qquad N_4=72,\qquad N_5=N_6=144.
$$

The pinned 2023 competition table has smallest valid strength-3 size 54; a 49-row entry is explicitly marked invalid. Thus the 45-row R003 witness improves that frozen valid comparison by nine rows (16.7%) and is optimal for the frozen model.

## Structural reduction

There are 13 Boolean parameters and one three-valued parameter. The constraints imply:

1. `p14=v3` is impossible.
2. `p14=v1` exactly when `p3=true`; otherwise `p14=v2`.
3. Among `p5,...,p12`, at most one parameter is false.
4. If `p13=false`, then all of `p5,...,p12` are true.
5. The assignment with `p1,...,p13` all true is forbidden.

Hence exactly 159 configurations are valid:

- eight classes, one for each choice of a false parameter among `p5,...,p12`, with 16 assignments of the free tuple `(p1,p2,p3,p4)`;
- one 16-row class with `p13=false` and `p5,...,p12=true`;
- 15 residual configurations with `p5,...,p13=true` and `(p1,p2,p3,p4)` not all true.

The first nine are disjoint **mandatory classes**. In every mandatory class, `p1,...,p4` range freely over all 16 binary words.

Both complete exact replay implementations independently reconstruct this census from the frozen model; the C++ implementation parses and evaluates the constraint text directly.

## Lower bounds

Fix a mandatory class and let $q$ be its class-defining false parameter. Any feasible interaction containing `q=false` can only be covered by a row from that class, so class-local lower bounds add across all nine classes.

### Strength 2

For any free coordinate $p_i$, both `(q=false,p_i=false)` and `(q=false,p_i=true)` are feasible. One row cannot cover both values. Each class therefore needs at least 2 rows, giving

$$N_2\ge9\cdot2=18.$$

### Strength 3

For each pair of free coordinates, selected rows in a class must realize all four binary ordered pairs. Four rows cannot do this on four columns simultaneously: with four rows every column must be balanced, and every column pair must be orthogonal. After normalizing two columns to `0011` and `0101`, the only third balanced column up to complement that is orthogonal to both is `0110`; no fourth balanced column is orthogonal to all three.

Five rows suffice, for example

$$B=\{0000,0111,1011,1101,1110\}.$$

Hence the local minimum is 5 and

$$N_3\ge9\cdot5=45.$$

This nontrivial local obstruction and the five-row witness are additionally checked by Lean declarations `R003.pairwiseFourRowObstruction` and `R003.pairwiseFiveRowWitness`.

### Strength 4

Fix any three of the four free coordinates. All $2^3=8$ assignments occur in a mandatory class and each selected test realizes one assignment, so at least 8 class rows are required:

$$N_4\ge9\cdot8=72.$$

### Strengths 5 and 6

At strength 5, combine `q=false` with all four free coordinates. All $2^4=16$ assignments are feasible, so each class needs all 16 rows. At strength 6, adding any other parameter forced true in that class leaves the same 16 required assignments. Thus

$$N_5,N_6\ge9\cdot16=144.$$

Lean theorem `R003.nineClassSumLower` separately checks the arithmetic fact that any class-local lower bound $m$ contributes at least $9m$ across nine classes, together with specializations for 18, 45, 72, and 144. The Lean layer does **not** formalize the model-to-nine-class reduction itself.

## Constructions

All witnesses use mandatory-class rows only.

- **Strength 2:** two complementary four-bit words per class, with cut types cycled across classes.
- **Strength 3:** the five-word array $B$ above, translated by `0000`, `0001`, `0010`, and `0011` and cycled across the nine classes.
- **Strength 4:** even- and odd-parity eight-word subsets, alternated across classes.
- **Strengths 5 and 6:** all 16 four-bit words in every class.

The explicit witnesses are stored as CSV files.

## Exhaustive coverage replay

| Strength | Feasible interactions | Published rows | Lower bound |
|---:|---:|---:|---:|
| 2 | 326 | 18 | 18 |
| 3 | 2,168 | 45 | 45 |
| 4 | 9,374 | 72 | 72 |
| 5 | 28,192 | 144 | 144 |
| 6 | 61,272 | 144 | 144 |

Both independent complete implementations read the published witness files, verify every row against the frozen model, enumerate every feasible interaction, and confirm complete coverage. Since each witness attains its matching lower bound,

$$
(N_2,N_3,N_4,N_5,N_6)=(18,45,72,144,144).
$$

## Verification boundary

Complete frozen-model replay:

```bash
python3 verify_sources.py
python3 verify.py

g++ -std=c++20 -O2 -Wall -Wextra -pedantic verify_independent.cpp -o verify_independent
./verify_independent
```

Auxiliary Lean lower-bound replay:

```bash
lake build R003 R003.Audit
lake env lean --trust=0 R003/Audit.lean
lake env leanchecker --fresh R003.LocalCovering
```

Search, optimization, and AI generation are outside the final correctness oracle. The complete theorem is replayed by exact Python/C++ enumeration; Lean independently kernel-checks the pairwise local obstruction/witness and nine-class aggregation arithmetic. The full theorem must not be labeled fully Lean-formalized.

External specialist review remains pending and peer review is not claimed.
