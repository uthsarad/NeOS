#!/bin/bash
# Guards the "any PR into testing merges automatically" policy.
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
    echo "[FAIL] $WF must trigger on pull_request_target so same-repo and fork PRs can merge"
    FAIL=1
fi

if [[ "$CONTENT" == *"branches: [testing]"* ]] || [[ "$CONTENT" == *"branches: [ testing ]"* ]]; then
    echo "  [PASS] restricted to the testing branch"
else
    echo "[FAIL] $WF must restrict pull_request_target to branches: [testing]"
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

# main must not be an auto-merge target. A naive 'branches: [testing, main]'
# would ship the firehose onto the release branch.
if grep -A20 '^  pull_request_target:' "$WF" | grep -q 'main'; then
    echo "[FAIL] pull_request_target must not list main (main stays manual)"
    FAIL=1
else
    echo "  [PASS] main is not an auto-merge target"
fi

if [[ "$CONTENT" == *"checkout"* && "$CONTENT" == *"actions/checkout"* ]]; then
    echo "[FAIL] $WF must not check out PR code under pull_request_target"
    FAIL=1
else
    echo "  [PASS] no actions/checkout (gh is API-only)"
fi

if (( FAIL )); then
    echo "[FAIL] Auto-merge workflow does not match the testing-branch policy."
    exit 1
fi

echo "[PASS] Auto-merge into testing verified."
