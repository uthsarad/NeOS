#!/bin/bash
set -euo pipefail

echo "Running Rust-based NeOS profile audit..."

cargo run --quiet --manifest-path tools/neos-profile-audit/Cargo.toml -- --root .

echo "Rust profile audit checks passed."
