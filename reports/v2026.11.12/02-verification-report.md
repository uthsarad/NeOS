# Tooling verification report

## Delivered

- `tools/neosctl/main_test.go` covers mirror-list parsing, the 15-mirror ceiling, missing and inactive fixtures, and concurrent HTTP benchmark ranking/failure filtering.
- `tools/neos-profile-audit/src/main.rs` now validates every `config:` declaration in Calamares `settings.conf` against the profile's local `modules/` directory, rejecting empty and unsafe paths.
- `tests/test_live_scripts.py` and `tests/verify_live_scripts.sh` add 14 unit test assertions for `neos-welcome-app` (live mode detection, os-release parsing) and `neospacstrap` (pacman progress parsing, root mount guards).
- The Rust pass has unit coverage for a valid declaration, a missing configuration, and traversal-like paths.

## Results

- `go vet ./...` and `go test -v -cover ./...` pass in `tools/neosctl`; coverage is 100.0% for `parseMirrors` and 96.7% for `benchmarkMirrors`.
- `go test -v -race ./...` cannot run on this Windows host because `gcc` is not installed; Go requires a C compiler for race instrumentation.
- `cargo test --verbose`: 16 passed, 0 failed.
- `cargo check` and `cargo clippy -- -D warnings`: passed.
- `cargo run --quiet -- --root ../../profile`: passed, reporting 576 unique live packages.
- `git diff --check`: passed.
