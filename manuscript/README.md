# R003 manuscript

Typeset source:

- `r003_industrial8_exact_optima.tex`

Committed PDF:

- `r003_industrial8_exact_optima.pdf`

Build from this directory with a standard TeX Live installation:

```bash
pdflatex -interaction=nonstopmode -halt-on-error r003_industrial8_exact_optima.tex
pdflatex -interaction=nonstopmode -halt-on-error r003_industrial8_exact_optima.tex
```

The GitHub Actions workflow compiles the manuscript on every push and pull request.

If theorem numbering or wording changes, update `../STATEMENT_AUDIT.md`, `../CLAIM.md`, `../claim.json`, and the public release page in the same reviewed change.
