#!/bin/bash
set -euo pipefail

if ! command -v cargo &> /dev/null; then
    echo "⚠️ cargo not installed, skipping Rust profile audit validation to gracefully degrade."
    exit 0
fi

echo "Running Rust-based NeOS profile audit..."

cargo run --quiet --manifest-path tools/neos-profile-audit/Cargo.toml -- --root profile

echo "Rust profile audit checks passed."
