#!/bin/bash
# Validate audit reporting and release gates without network or GitHub writes.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tests/audit_tools.py
