#!/bin/bash
# Regression guard: bare arithmetic increments under `set -e`.
#
# Why this test exists: `((VAR++))` is a COMMAND whose exit status is the value
# of the expression evaluated *before* the increment. Starting from 0 that value
# is 0, which bash reports as failure — so under `set -e` the very first
# occurrence aborts the script. This silently killed tools/gen-install-repo.sh:
# CACHED_COUNT / REUSED_COUNT / CLEANED all start at 0, so the first package
# found in mkarchiso's cache terminated the offline-repo build (and, because
# build.sh calls it unguarded behind an ERR trap, the whole ISO build).
#
# It survived undetected because no test and no CI job ever executed that
# script: build-iso.yml builds the ISO inline and never runs the offline-repo
# step, so only a local ./build.sh could reach the bug.
#
# Correct forms:
#   VAR=$((VAR + 1))      # assignment: always status 0
#   (( VAR++ )) || true   # tolerated only when failure is genuinely expected
#   if (( VAR++ )); then  # inside a condition: exempt from set -e
#
# Only standalone increments are flagged. Increments used as a condition
# (`if (( i++ )); then`) or on a `||`/`&&` list are legitimate and not reported.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

# Same script discovery as tests/verify_shellcheck.sh: everything with a .sh
# extension plus the extensionless shell-shebang scripts in airootfs.
mapfile -t SCRIPTS < <(
    {
        find . -type f -name '*.sh'
        grep -rlE '^#!.*(bash|/bin/sh|dash|ksh)' profile/airootfs/usr/local/bin 2>/dev/null
    } | sort -u
)

if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
    echo "[FAIL] No shell scripts discovered to check"
    exit 1
fi

echo "Checking ${#SCRIPTS[@]} shell script(s) for standalone arithmetic increments..."

# A line that consists of nothing but (( VAR++ )) / (( ++VAR )) / (( VAR-- )).
PATTERN='^[[:space:]]*\(\([[:space:]]*([[:alnum:]_]+(\+\+|--)|(\+\+|--)[[:alnum:]_]+)[[:space:]]*\)\)[[:space:]]*$'

FOUND=0
for script in "${SCRIPTS[@]}"; do
    # This test contains the pattern in its own documentation and regex, so skip
    # itself — it never executes a bare increment, but the literal would match.
    if [[ "$script" == *verify_shell_arithmetic.sh ]]; then
        continue
    fi

    while IFS= read -r match; do
        echo "[FAIL] $script:$match"
        echo "       Bare arithmetic increment as a standalone command."
        echo "       Under 'set -e' the first increment from 0 returns status 1 and"
        echo "       aborts the script. Use 'VAR=\$((VAR + 1))' instead."
        FOUND=1
    done < <(grep -nE "$PATTERN" "$script" 2>/dev/null || true)
done

if [[ "$FOUND" -ne 0 ]]; then
    echo ""
    echo "Fix with the assignment form:"
    echo "  ((count++))        ->  count=\$((count + 1))"
    exit 1
fi

echo "[PASS] No standalone arithmetic increments found."
