# R003 — Exact constrained covering arrays for `INDUSTRIAL_8`

## Statement

Let \(N_t\) denote the minimum number of valid configurations required to
cover every valid \(t\)-way interaction of the public CT-Competition model
`INDUSTRIAL_8`. Then

\[
N_2=18,\qquad N_3=45,\qquad N_4=72,\qquad N_5=N_6=144.
\]

The public 2023 competition output table records a best valid strength-3
submission of 54 tests. The 45-row construction in this release therefore
removes nine tests (16.7%), and the lower bound below proves that 45 is optimal.

## Structural reduction

The public model has 13 Boolean parameters and one nominally three-valued
parameter. Its constraints imply:

1. `p14=v3` is impossible.
2. `p14=v1` exactly when `p3=true`; otherwise `p14=v2`.
3. Among `p5,...,p12`, at most one parameter may be false.
4. If `p13=false`, then all of `p5,...,p12` are true.
5. The assignment with `p1,...,p13` all true is forbidden.

Hence there are exactly 159 valid configurations:

- for each \(q\in\{p5,\ldots,p12\}\), 16 configurations with \(q=false\),
  all other `p5,...,p12` true, and `p13=true`;
- 16 configurations with `p13=false` and `p5,...,p12` all true;
- 15 residual configurations with `p5,...,p13` all true and
  `(p1,p2,p3,p4)` not all true.

The first nine groups are disjoint. Call them the **mandatory classes**.
Inside every mandatory class, `p1,...,p4` are completely free.

## Lower bounds

Fix one mandatory class.

### Strength 2

Interactions fixing the class-defining false parameter and one of
`p1,...,p4` require both Boolean values. At least 2 rows are needed per class:

\[
N_2\ge 9\cdot2=18.
\]

### Strength 3

Interactions fixing the class-defining false parameter and two of
`p1,...,p4` require a binary pairwise covering array on four columns.

Four rows are impossible. If four rows existed, every pair of columns would
have to contain `00,01,10,11` exactly once. Normalize two columns to `0011`
and `0101`. Up to complement, the only third balanced column orthogonal to
both is `0110`, leaving no fourth column orthogonal to all three.

Five rows suffice, for example

\[
\{0000,0111,1011,1101,1110\}.
\]

Therefore

\[
N_3\ge 9\cdot5=45.
\]

### Strength 4

Fixing the class-defining false parameter and any three of `p1,...,p4`
requires all \(2^3=8\) triples:

\[
N_4\ge9\cdot8=72.
\]

### Strength 5

Fixing the class-defining false parameter and all four of `p1,...,p4`
requires all \(2^4=16\) assignments:

\[
N_5\ge9\cdot16=144.
\]

### Strength 6

Add any parameter forced true in the chosen class to the preceding
strength-5 interactions. The same 16 assignments remain necessary:

\[
N_6\ge9\cdot16=144.
\]

## Constructions

All constructions use only mandatory-class rows.

- **Strength 2:** two complementary four-bit words in each class. Four
  different cut types are cycled through the nine classes.
- **Strength 3:** start with
  \[
  B=\{0000,0111,1011,1101,1110\},
  \]
  a binary \(CA(5;2,4,2)\). Translate \(B\) by `0000`, `0001`, `0010`,
  and `0011`; these translations jointly contain all 16 four-bit words.
  Cycle the translations through the nine classes.
- **Strength 4:** alternate the even- and odd-parity eight-word classes.
  Each is an \(OA(8,4,2,3)\), and together they contain all 16 words.
- **Strengths 5 and 6:** use all 16 four-bit words in every mandatory class.

The independent verifier enumerates all 159 valid configurations and all
valid interactions and confirms complete coverage:

| Strength | Valid interactions | Construction | Lower bound |
|---:|---:|---:|---:|
| 2 | 326 | 18 | 18 |
| 3 | 2,168 | 45 | 45 |
| 4 | 9,374 | 72 | 72 |
| 5 | 28,192 | 144 | 144 |
| 6 | 61,272 | 144 | 144 |

Thus every displayed construction is optimal.

## Reproduction

```bash
python verify.py
```

The verifier uses only the Python standard library. No optimizer, language
model, floating-point solver, or external service lies inside the final trust
boundary.

## Source comparison

Public benchmark:
https://github.com/fmselab/CIT_Benchmark_Generator/blob/main/Benchmarks_CITCompetition_2023/EvaluationPhase/ACTS/INDUSTRIAL_8.txt

Public 2023 competition outputs:
https://github.com/fmselab/ct-competition/blob/gh-pages/results/2023/data/output_best.csv

## External status

The release has not yet received independent specialist review or peer review.
The public comparison above is deliberately limited to the audited competition
table; no stronger priority claim is made.
