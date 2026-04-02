# Contributing to NeOS

Thanks for your interest in improving NeOS! This guide covers how to propose changes and keep the project maintainable.

## Getting started

1. Fork the repository (https://github.com/uthsarad/NeOS) and create a feature branch from `main`.
2. Make sure your changes are focused and documented.
3. Run any relevant checks for the area you touched.
4. Open a pull request with a clear summary and testing notes.
   - *Note: The auto-merge bot automatically handles PR approvals for the core maintainer team and trusted bots.*

## Development tips

- Keep commits small and descriptive.
- Update documentation whenever behavior changes.
- Include sample commands or screenshots for user-facing changes.
- Auto-Merge Bot:
  - Automatically handles PR approvals for the core maintainer team and trusted bots.

## Reporting issues

Please include:

- A brief summary of the problem.
- Steps to reproduce.
- Expected vs. actual behavior.
- Any logs or screenshots that help illustrate the issue.

## PR Reviews and Approvals

Our automated systems help streamline the development process:
- **Auto-merge bot**: Handles PR approvals and merging automatically.
  - Triggers for the core maintainer team.
  - Triggers for trusted bots (e.g., `google-labs-jules[bot]`).
- **Community contributions**: Require review from a maintainer before the bot will merge.

## Rust Integration Direction (3-5% target)

NeOS now includes a Rust-based profile validator under `tools/neos-profile-audit`. A practical next step is to keep Rust usage in the tooling layer while preserving shell compatibility in build scripts:

- Keep policy and manifest validation in Rust CLIs (fast, typed parsing, clearer errors).
- Use shell wrappers in `tests/` to call Rust tools so CI and contributor workflows stay simple.
- Gradually replace brittle text parsing checks in bash/python with focused Rust subcommands.

This keeps Rust around the 3-5% footprint while strengthening reliability in the parts of the project most prone to configuration drift.

## Code of conduct

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Automated Bots

- **jules-auto-merge**: This bot automatically approves and merges PRs when invoked by authorized actors. It triggers on pull request open, synchronize, reopen, or ready for review events.
