# R003 claim

## Canonical statement

Let $N_t$ denote the minimum number of valid configurations required to cover every feasible $t$-way interaction of the frozen public CT-Competition model `INDUSTRIAL_8`.

Then

$$
N_2=18,\qquad N_3=45,\qquad N_4=72,\qquad N_5=N_6=144.
$$

The frozen 2023 CT-Competition result table records 54 tests as the smallest **valid** strength-3 result for `INDUSTRIAL_8`. The R003 45-row witness therefore improves that frozen valid comparison by 9 rows, or $1/6\approx16.7\%$, and the matching lower bound proves that 45 is optimal for the frozen model.

## Model identity

The theorem is about the exact benchmark bytes in `INDUSTRIAL_8.txt`, pinned to upstream Git blob:

`4ede6ee93f6eea06927f972cf5ba22621ecc3013`

SHA-256:

`01785c43dbce4381d928c064c14dfe3c3734237db8fa7c2e84d8647f8ed299b4`

## Explicit non-claims

- No general optimum formula is claimed for arbitrary constrained combinatorial-testing models.
- No claim is made that the 2023 competition table represents all constructions developed after that frozen public comparison.
- The 49-row `medici` entry in the frozen competition table is **not** treated as a valid baseline because that table marks it `Invalid`.
- External specialist review remains pending; peer review is not claimed.
- Search or AI generation is not part of the final verification trust boundary.
