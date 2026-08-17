#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

printf '== R003 source identity ==\n'
python3 verify_sources.py

printf '\n== R003 primary exact replay ==\n'
python3 verify.py

printf '\n== R003 independent C++20 replay ==\n'
g++ -std=c++20 -O2 -Wall -Wextra -pedantic verify_independent.cpp -o /tmp/r003_verify_independent
/tmp/r003_verify_independent
rm -f /tmp/r003_verify_independent

printf '\n== R003 deterministic report freshness ==\n'
python3 verify.py --write-report
git diff --exit-code -- verification-report.json

if ! command -v lake >/dev/null 2>&1; then
  echo 'ERROR: lake/Lean is required for the auxiliary formal verification.' >&2
  echo 'Install the pinned toolchain from lean-toolchain, then rerun this script.' >&2
  exit 1
fi

printf '\n== R003 pinned Lean build ==\n'
test "$(cat lean-toolchain)" = "leanprover/lean4:v4.32.0"
lake build R003 R003.Audit

printf '\n== R003 Lean production-source shortcut scan ==\n'
python3 - <<'PYSCAN'
import pathlib, re, sys
sources = [pathlib.Path('R003.lean')] + sorted(pathlib.Path('R003').rglob('*.lean'))
pattern = re.compile(r'\b(?:sorry|admit|native_decide)\b|debug\.skipKernelTC|Lean\.ofReduceBool|^\s*(?:axiom|opaque|unsafe|extern|partial)\b|^\s*@\[implemented_by')
hits = []
for path in sources:
    if path.name == 'Audit.lean':
        continue
    for line_number, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
        if pattern.search(line):
            hits.append(f'{path}:{line_number}:{line}')
if hits:
    print('\n'.join(hits))
    sys.exit(1)
print(f'Lean production-source scan is empty across {len(sources)-1} files.')
PYSCAN

printf '\n== R003 trust-zero Lean axiom audit ==\n'
AXIOM_LOG="$(mktemp)"
trap 'rm -f "$AXIOM_LOG"' EXIT
lake env lean --trust=0 R003/Audit.lean 2>&1 | tee "$AXIOM_LOG"
python3 - "$AXIOM_LOG" <<'PYAX'
import pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text(encoding='utf-8')
for marker in ('sorryAx', 'Lean.trustCompiler'):
    if marker in text:
        raise SystemExit(f'Forbidden Lean trust marker: {marker}')
allowed = {'propext', 'Classical.choice', 'Quot.sound'}
for group in re.findall(r'depends on axioms:\s*\[([^\]]*)\]', text, flags=re.S):
    names = {n.strip() for n in group.replace('\n', ' ').split(',') if n.strip()}
    unexpected = names - allowed
    if unexpected:
        raise SystemExit(f'Unexpected axioms: {sorted(unexpected)}')
print('Lean axiom audit contains no forbidden or unexpected trust assumptions.')
PYAX

printf '\n== R003 fresh Lean kernel replay ==\n'
lake env leanchecker --fresh R003.LocalCovering

printf '\nPASS: complete R003 public verification replay succeeded.\n'
