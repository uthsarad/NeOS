#!/bin/bash
# Verify Python runtime behaviors for live ISO scripts (neos-welcome-app, neospacstrap).
set -euo pipefail
cd "$(dirname "$0")/.."

echo "Verifying live ISO Python script unit tests..."
if command -v python3 >/dev/null 2>&1; then
    python3 tests/test_live_scripts.py
else
    python tests/test_live_scripts.py
fi
echo "[PASS] All live ISO Python script tests passed."

