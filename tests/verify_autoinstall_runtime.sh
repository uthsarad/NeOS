#!/bin/bash
# Exercise generated installer YAML and mount lifecycle without mounting disks.
set -euo pipefail
cd "$(dirname "$0")/.."
if ! python3 -c "import yaml" >/dev/null 2>&1; then
    if [[ "${REQUIRE_TOOLS:-0}" == "1" ]]; then
        echo "[FAIL] PyYAML is required (REQUIRE_TOOLS=1) to run autoinstall_runtime.py"
        exit 1
    fi
    echo "[WARN] PyYAML not installed — skipping autoinstall_runtime.py (install python-yaml / python3-yaml)."
    exit 0
fi
python3 tests/autoinstall_runtime.py
