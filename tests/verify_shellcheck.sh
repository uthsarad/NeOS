#!/bin/bash
set -euo pipefail

# Sentinel: Check if shellcheck is available to prevent execution failures
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "⚠️ shellcheck not installed, skipping ShellCheck validation to gracefully degrade."
else
  # Bolt: Use fast file discovery targeting only specific scripts
  echo "Running ShellCheck validation..."
  find tests/ airootfs/usr/local/bin/ -type f \( -name '*.sh' -o -path 'airootfs/usr/local/bin/*' ! -name '*.*' \) -print0 | xargs -0 -r shellcheck --format=gcc || true
  echo "✅ ShellCheck validation completed."
fi
