#!/bin/bash
set -euo pipefail

# Mirror the CI "Run Security Scans" shellcheck invocation EXACTLY, so anything
# that fails shellcheck in CI also fails here (and vice versa). Previously this
# test scoped to a few dirs and ended every run with `|| true`, so it never
# failed — a build.sh SC2012 *info* finding sailed past locally but broke CI.
#
# CI runs (build-iso.yml, "Run Security Scans"):
#     find . -type f -name '*.sh' -print0 | xargs -0 -r shellcheck
# Bare `shellcheck` uses the default severity (style) and exits non-zero on ANY
# finding — including info — so we do the same and let the failure propagate.

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "⚠️ shellcheck not installed — skipping (install it to reproduce CI locally, e.g. 'apt install shellcheck')."
  exit 0
fi

echo "Running ShellCheck (CI-aligned: all *.sh, fail on any finding)..."
find . -type f -name '*.sh' -print0 | xargs -0 -r shellcheck
echo "✅ ShellCheck validation passed."
