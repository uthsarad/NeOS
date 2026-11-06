#!/bin/bash
set -euo pipefail

SCRIPT="tests/verify_mirrorlist_connectivity.sh"

if grep -q 'RETRY_COUNT++' "$SCRIPT"; then
    echo "[FAIL] Bug found: retry loop still uses RETRY_COUNT++ under set -e"
    exit 1
fi

if grep -q 'FAILED_COUNT++' "$SCRIPT"; then
    echo "[FAIL] Bug found: failure counter still uses FAILED_COUNT++ under set -e"
    exit 1
fi

if grep -q 'RETRY_COUNT += 1' "$SCRIPT"; then
    echo "[PASS] Mirror retry loop uses a set -e safe increment."
else
    echo "[FAIL] Mirror retry loop increment fix missing."
    exit 1
fi

if grep -q 'FAILED_COUNT += 1' "$SCRIPT"; then
    echo "[PASS] Mirror failure counter uses a set -e safe increment."
else
    echo "[FAIL] Mirror failure counter increment fix missing."
    exit 1
fi
