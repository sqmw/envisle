#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
cd "$repo_root"

required_files=(
  AGENTS.md
  README.md
  .gitignore
  docs/README.md
  docs/TODO.md
  docs/STEPS.md
  docs/DECISIONS.md
  docs/agent-context/current.md
  docs/architecture/overview.md
  docs/architecture/code-map.md
  docs/architecture/product-options.md
  docs/research/discussion-source.md
  docs/research/breadth-scan.md
)

for path in "${required_files[@]}"; do
  if [[ ! -f "$path" ]]; then
    printf 'missing required file: %s\n' "$path" >&2
    exit 1
  fi
done

runtime_dirs=(data state cache logs images downloads snapshots .osdeck)
for path in "${runtime_dirs[@]}"; do
  if [[ -e "$path" ]]; then
    printf 'runtime data directory found inside repository: %s\n' "$path" >&2
    exit 1
  fi
done

if find . -path './.git' -prune -o -type f \( \
  -name '*.img' -o -name '*.qcow2' -o -name '*.raw' -o \
  -name '*.iso' -o -name '*.ipsw' -o -name '*.vhd' -o \
  -name '*.vhdx' -o -name '*.db' -o -name '*.sqlite' -o \
  -name '*.sqlite3' -o -name '*.log' -o -name '*.key' -o \
  -name '*.pem' \
\) -print -quit | grep -q .; then
  printf 'runtime, database, log, or credential file found inside repository\n' >&2
  exit 1
fi

python3 scripts/check-markdown-links.py
printf 'project checks passed\n'
