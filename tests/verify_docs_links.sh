#!/bin/bash
# Fails when a relative link or referenced path inside the documentation points
# at a file that does not exist.
#
# Five documents linked to "docs/README.md" as their index for months while that
# file did not exist, and CLAUDE.md pointed at eight documents under
# docs/orchestrator/, docs/policies/ and docs/ that were never committed
# (reports/v2026.09.22/UPDATES_NEEDED.md, sections 2.2/2.3).
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
    echo "[WARN] python3 not installed — skipping documentation link check."
    exit 0
fi

echo "Verifying relative links in documentation..."

python3 - <<'PY'
import os, re, sys

ROOT = os.path.abspath(os.getcwd())
LINK = re.compile(r'\[[^\]]*\]\(([^)#\s]+?)(#[^)\s]*)?\)')
bad = []
checked = 0

for dirpath, dirnames, filenames in os.walk(ROOT):
    dirnames[:] = [d for d in dirnames if d not in ('.git', 'graphify-out', 'node_modules')]
    for name in filenames:
        if not name.endswith('.md'):
            continue
        path = os.path.join(dirpath, name)
        try:
            text = open(path, encoding='utf-8', errors='ignore').read()
        except OSError:
            continue
        for match in LINK.finditer(text):
            target = match.group(1)
            if target.startswith(('http://', 'https://', 'mailto:', '#')):
                continue
            if target.startswith('/'):
                continue  # absolute filesystem paths are not repo links
            checked += 1
            resolved = os.path.normpath(os.path.join(dirpath, target))
            if not os.path.exists(resolved):
                bad.append((os.path.relpath(path, ROOT), target))

print("checked %d relative link(s)" % checked)
for source, target in bad:
    print("[FAIL] %s -> %s (missing)" % (source, target))
if bad:
    print("[FAIL] %d broken documentation link(s)" % len(bad))
    sys.exit(1)
print("[PASS] all relative documentation links resolve")
PY
