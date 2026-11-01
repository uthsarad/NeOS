#!/bin/bash
# Exercise generated installer YAML and mount lifecycle without mounting disks.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 tests/autoinstall_runtime.py
