# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- ISO size validation in CI/CD (1.9 GiB limit)
- "Supported Architectures" section to README
- Testing guidelines to CONTRIBUTING.md
- Trap for better error logging in `neos-liveuser-setup`
- Dependency checks in `neos-autoupdate.sh` (already present, verified)

### Security
- Hardened `neos-driver-manager.service` with `ProtectSystem=strict` and other sandbox settings
- Verified `pacman.conf` uses `DatabaseOptional` for build compatibility
- Updated verification tests for service hardening

## [0.1.0] - 2026-02-14

### Added
- Initial project scaffolding.
- Basic Arch ISO profile.
- KDE Plasma desktop environment.
- Calamares installer for x86_64.
