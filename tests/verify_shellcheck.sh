#!/bin/bash
set -euo pipefail

# Mirror the CI "Run Security Scans" shellcheck invocation EXACTLY, so anything
# that fails shellcheck in CI also fails here (and vice versa). Previously this
# test scoped to a few dirs and ended every run with `|| true`, so it never
# failed — a build.sh SC2012 *info* finding sailed past locally but broke CI.
#
# CI runs (build-iso.yml, "Run Security Scans"): it builds the same
# SHELL_SCRIPTS array from a *.sh find plus a shebang grep over
# profile/airootfs/usr/local/bin, then lints that whole array.
# Invoked bare, the linter uses the default severity (style) and exits non-zero
# on ANY finding — including info — so we do the same and let it propagate.
# (Kept out of this comment on purpose: writing the literal command form here
# trips SC1073, which parses any '# shellcheck <word>' line as a directive.)
#
# Scope note: matching only `*.sh` used to leave every privileged script in
# profile/airootfs/usr/local/bin/ unlinted, because those have no extension.
# Files are now selected by shebang instead, which also correctly excludes the
# Python welcome app. `*.hook` files are pacman/alpm INI config, not shell, so
# they are not lint targets.

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "[WARN] shellcheck not installed — skipping (install it to reproduce CI locally, e.g. 'apt install shellcheck')."
  exit 0
fi

mapfile -t SHELL_SCRIPTS < <(
  {
    find . -type f -name '*.sh'
    grep -rlE '^#!.*(bash|/bin/sh|dash|ksh)' profile/airootfs/usr/local/bin 2>/dev/null
  } | sort -u
)

if (( ${#SHELL_SCRIPTS[@]} == 0 )); then
  echo "[FAIL] No shell scripts discovered to lint"
  exit 1
fi

echo "Running ShellCheck on ${#SHELL_SCRIPTS[@]} script(s) (CI-aligned: shebang-based, fail on any finding)..."
shellcheck -- "${SHELL_SCRIPTS[@]}"
echo "[PASS] ShellCheck validation passed."
