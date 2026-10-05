#!/bin/bash
set -euo pipefail

if ! command -v cargo &> /dev/null; then
    if [[ "${REQUIRE_TOOLS:-0}" == "1" ]]; then
        echo "[FAIL] cargo is required (REQUIRE_TOOLS=1) but not installed — the Rust auditor cannot be skipped here."
        exit 1
    fi
    echo "[WARN] cargo not installed, skipping Rust profile audit validation to gracefully degrade."
    exit 0
fi

echo "Running Rust-based NeOS profile audit..."

cargo run --quiet --manifest-path tools/neos-profile-audit/Cargo.toml -- --root profile

# The auditor carries unit tests for the invariant helpers; they were never run
# anywhere (reports/v2026.09.18 H3), so a broken assertion could ship unnoticed.
echo "Running the Rust auditor's unit tests..."
cargo test --quiet --manifest-path tools/neos-profile-audit/Cargo.toml

echo "Rust profile audit checks passed."
