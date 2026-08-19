#!/usr/bin/env python3
"""Check local Markdown link targets without network access."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parent.parent
LINK = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
failures: list[str] = []

for document in [ROOT / "README.md", ROOT / "AGENTS.md", *sorted((ROOT / "docs").rglob("*.md"))]:
    text = document.read_text(encoding="utf-8")
    for raw_target in LINK.findall(text):
        target = raw_target.strip().split("#", 1)[0]
        if not target or "://" in target or target.startswith("mailto:"):
            continue
        candidate = (document.parent / target).resolve()
        if not candidate.exists():
            failures.append(f"{document.relative_to(ROOT)} -> {raw_target}")

if failures:
    print("broken local Markdown links:", file=sys.stderr)
    for failure in failures:
        print(f"  {failure}", file=sys.stderr)
    raise SystemExit(1)

print("local Markdown links passed")
