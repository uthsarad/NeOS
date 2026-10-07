#!/bin/bash
# Guards the auto-merge policy: non-draft PRs into testing from branches of this
# repository merge automatically; PRs from forks never do, because testing
# publishes releases (reports/v2026.10.02/00-improvement-plan.md A2).
set -euo pipefail

WF=".github/workflows/jules-auto-merge.yml"

echo "Verifying auto-merge-into-testing workflow..."

FAIL=0

if [[ ! -f "$WF" ]]; then
    echo "[FAIL] Missing $WF"
    exit 1
fi

CONTENT="$(<"$WF")"

if [[ "$CONTENT" == *"pull_request_target"* ]]; then
    echo "  [PASS] triggered on pull_request_target (write token, no PR checkout)"
else
    echo "[FAIL] $WF must trigger on pull_request_target (write token, PR code never checked out)"
    FAIL=1
fi

# testing is the merge target; main may be listed only so bot PRs aimed at it
# can be retargeted (checked below: nothing is ever merged into main).
if [[ "$CONTENT" == *"branches: [testing]"* ]] || [[ "$CONTENT" == *"branches: [testing, main]"* ]]; then
    echo "  [PASS] triggered for PRs into testing (and main, for retargeting only)"
else
    echo "[FAIL] $WF must trigger on pull_request_target branches: [testing] or [testing, main]"
    FAIL=1
fi

if [[ "$CONTENT" == *"--admin"* ]]; then
    echo "  [PASS] forced merge (--admin) is available"
else
    echo "[FAIL] $WF must pass --admin so testing cannot deadlock on required checks"
    FAIL=1
fi

if [[ "$CONTENT" == *"gh pr merge"* ]]; then
    echo "  [PASS] merges via gh pr merge"
else
    echo "[FAIL] $WF never calls gh pr merge"
    FAIL=1
fi

# Fork PRs must be refused on the automatic path. The check has to read
# isCrossRepository and exit before any `gh pr merge`.
if [[ "$CONTENT" == *"isCrossRepository"* ]] \
    && awk '/"\$PR_FROM_FORK" != "false"/ && !fork {fork=NR} /gh pr merge/ && !merge {merge=NR} END {exit !(fork && merge && fork < merge)}' "$WF"; then
    echo "  [PASS] fork PRs are refused before any merge attempt"
else
    echo "[FAIL] $WF must refuse PRs from forks (isCrossRepository) before calling gh pr merge"
    FAIL=1
fi

# main must never be an auto-merge target: a strict "base must be testing"
# guard has to sit before the first `gh pr merge`, and any PR into main that is
# not retargeted must exit before reaching it.
if awk '/"\$PR_BASE" != "testing"/ && !guard {guard=NR} /gh pr merge/ && !merge {merge=NR} END {exit !(guard && merge && guard < merge)}' "$WF" \
    && grep -q 'left for a maintainer' "$WF"; then
    echo "  [PASS] main is never an auto-merge target (strict testing-only guard before any merge)"
else
    echo "[FAIL] $WF must refuse to merge anything whose base is not testing, before any gh pr merge"
    FAIL=1
fi

if [[ "$CONTENT" == *"checkout"* && "$CONTENT" == *"actions/checkout"* ]]; then
    echo "[FAIL] $WF must not check out PR code under pull_request_target"
    FAIL=1
else
    echo "  [PASS] no actions/checkout (gh is API-only)"
fi

# PRs that change no files are closed, never merged: an empty commit on testing
# still builds and publishes a release. The check must come before any merge.
EMPTY_LINE="$(grep -n 'PR_FILES" == "0"' "$WF" | head -1 | cut -d: -f1)"
MERGE_LINE="$(grep -n 'gh pr merge' "$WF" | head -1 | cut -d: -f1)"
if [[ "$CONTENT" == *"changedFiles"* && -n "$EMPTY_LINE" && -n "$MERGE_LINE" ]] && (( EMPTY_LINE < MERGE_LINE )) \
    && grep -qF 'gh pr close "' "$WF"; then
    echo "  [PASS] PRs that change no files are closed before any merge"
else
    echo "[FAIL] $WF must close PRs with changedFiles == 0 before merging"
    FAIL=1
fi

if (( FAIL )); then
    echo "[FAIL] Auto-merge workflow does not match the testing-branch policy."
    exit 1
fi

echo "[PASS] Auto-merge into testing verified."
