#!/bin/bash
# Validate audit reporting and release gates without network or GitHub writes.
set -euo pipefail
cd "$(dirname "$0")/.."
if ! python3 -c "import yaml" >/dev/null 2>&1; then
    if [[ "${REQUIRE_TOOLS:-0}" == "1" ]]; then
        echo "[FAIL] PyYAML is required (REQUIRE_TOOLS=1) to run audit_tools.py"
        exit 1
    fi
    echo "[WARN] PyYAML not installed — skipping audit_tools.py (install python-yaml / python3-yaml)."
    exit 0
fi
python3 tests/audit_tools.py
