#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

python3 verify_sources.py
python3 verify.py

g++ -std=c++20 -O2 -Wall -Wextra -pedantic verify_independent.cpp -o /tmp/r003_verify_independent
/tmp/r003_verify_independent
rm -f /tmp/r003_verify_independent

python3 verify.py --write-report
git diff --exit-code -- verification-report.json

if command -v lake >/dev/null 2>&1; then
  lake build
else
  echo "NOTE: lake is not installed locally; GitHub Actions enforces the Lean build." >&2
fi
