#!/bin/bash
# Exercise the release step with real temporary keys and a stubbed transport.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tests/sourceforge_upload.py
