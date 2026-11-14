#!/bin/bash
# Exercise the release step with real temporary keys and a stubbed transport.
set -euo pipefail
cd "$(dirname "$0")/.."
if ! python3 -c "import yaml" >/dev/null 2>&1; then
    if [[ "${REQUIRE_TOOLS:-0}" == "1" ]]; then
        echo "[FAIL] PyYAML is required (REQUIRE_TOOLS=1) to run sourceforge_upload.py"
        exit 1
    fi
    echo "[WARN] PyYAML not installed — skipping sourceforge_upload.py (install python-yaml / python3-yaml)."
    exit 0
fi
python3 tests/sourceforge_upload.py
