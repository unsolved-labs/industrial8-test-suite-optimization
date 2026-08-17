# R003 manuscript

Canonical paper source:

- `r003_industrial8_exact_optima.tex`

The manuscript is intentionally source-controlled as LaTeX rather than relying on an opaque committed PDF. GitHub Actions compiles this file from a clean checkout on every push and pull request.

Build locally with a standard TeX Live installation:

```bash
pdflatex -interaction=nonstopmode -halt-on-error r003_industrial8_exact_optima.tex
pdflatex -interaction=nonstopmode -halt-on-error r003_industrial8_exact_optima.tex
```

The resulting local file is `r003_industrial8_exact_optima.pdf`.

The public paper distinguishes three assurance layers:

1. the human proof;
2. two independent exact full-model replay implementations; and
3. the auxiliary pinned Lean lower-bound formalization.

The Lean layer is deliberately narrower than the complete R003 theorem. See `../VERIFICATION.md`, `../STATEMENT_AUDIT.md`, and `../formalization.yaml` for the exact boundary.

If theorem numbering, wording, formalization scope, or verification status changes, update `../STATEMENT_AUDIT.md`, `../CLAIM.md`, `../claim.json`, and the public release page in the same reviewed change.
