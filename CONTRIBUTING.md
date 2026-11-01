# Contributing to NeOS

Thanks for your interest in improving NeOS! This guide covers how to propose changes and keep the project maintainable.

## Getting started

1. Fork the repository (https://github.com/uthsarad/NeOS) and create a feature branch from `testing` — that is the branch CI builds and cuts releases from, while `main` stays idle until the official public release.
2. Make sure your changes are focused and documented.
3. Run any relevant checks for the area you touched.
4. Open a pull request **targeting `testing`** with a clear summary and testing notes.
   - A non-draft PR into `testing` from a branch of this repository is merged automatically after CI succeeds, respecting branch protections. PRs from forks are reviewed and merged by a maintainer, because every push to `testing` publishes a release. `main` is not automatic.

## Development tips

- Keep commits small and descriptive.
- Update documentation whenever behavior changes.
- Include sample commands or screenshots for user-facing changes.
- Auto-merge:
  - Every non-draft PR into `testing` from a branch of this repository is approved and merged automatically after successful CI; fork PRs wait for a maintainer.
- Run every gate before opening a PR: `for t in tests/verify_*.sh; do bash "$t" || echo "FAILED: $t"; done` (or `rake test:all`). Gates that need a toolchain you do not have skip with a `[WARN]`; CI sets `REQUIRE_TOOLS=1`, so there they fail instead.

## Reporting issues

Please include:

- A brief summary of the problem.
- Steps to reproduce.
- Expected vs. actual behavior.
- Any logs or screenshots that help illustrate the issue.

## PR Reviews and Approvals

- **`testing`**: auto-merged for same-repository branches. The workflow in `.github/workflows/jules-auto-merge.yml` runs on every non-draft PR targeting `testing` and squash-merges it, after successful CI, respecting branch protections and pinning the validated head commit. This is intentional while `testing` is the only branch that builds ISOs. PRs from forks are never merged automatically: they get a comment and a maintainer merges them by hand (or runs the workflow manually with the PR URL).
- **`main`**: not automatic. `main` stays idle until the official public release and only moves by a maintainer merge from `testing`.

## Rust Integration Direction (3-5% target)

NeOS now includes a Rust-based profile validator under `tools/neos-profile-audit`. A practical next step is to keep Rust usage in the tooling layer while preserving shell compatibility in build scripts:

- Keep policy and manifest validation in Rust CLIs (fast, typed parsing, clearer errors).
- Use shell wrappers in `tests/` to call Rust tools so CI and contributor workflows stay simple.
- Gradually replace brittle text parsing checks in bash/python with focused Rust subcommands.

This keeps Rust around the 3-5% footprint while strengthening reliability in the parts of the project most prone to configuration drift.

## Code of conduct

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Automated Bots

- **Auto-merge into testing**: approves and squash-merges every non-draft, same-repository PR whose base is `testing`, after successful CI, respecting branch protections. It does not check out PR code. Fork PRs and `main` are out of scope.

## Reproducible audits

Run `python3 tools/audit.py` on Linux or `python tools/audit.py` on Windows (WSL required). The Windows command tests current working files in an isolated Linux snapshot, preserving Git executable and symlink modes. On Linux, add `--snapshot` for the same isolation.

Use `--strict --include-ui` to fail on missing tools and run GUI render checks. Install dependencies with `sudo bash tools/install-audit-tools.sh` on Arch or Ubuntu (including WSL Ubuntu), or use the list in `.github/workflows/build-iso.yml`; Arch-only checks need Arch Linux. With Docker available, add `--arch-container` to execute the Arch-only repository gate in a disposable `archlinux:latest` container with a read-only source mount. Built-ISO checks remain part of `build.sh`. Use `--only verify_autoinstall_runtime.sh` to run one gate. Each run writes logs and `summary.json` to `reports/audit-latest/`; override with `--output`. Zero-exit checks that skip tools are reported as incomplete, not passed.
