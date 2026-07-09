# Sentinel Security Report

- Risks found: Inconsistent error handling in core scripts, missing standardized logging block leading to potential risk of masking script exit codes and command injection vulnerabilities via trap commands.
- Fixes applied: Standardized error handling and safe trap command implemented in `neos-driver-manager` and `neos-autoupdate.sh` to match `neos-liveuser-setup`.
- Remaining attack surface: Other non-core bash scripts may lack standardized error handling.
- Severity summary: Medium

- Risks found: Unverified network download of Chaotic-AUR keyring package leaves build process vulnerable to supply chain attacks.
- Fixes applied: Added signature verification (`pacman-key --verify`) for the downloaded Chaotic-AUR keyring package before installation in `build.sh`.
- Remaining attack surface: Other downloaded dependencies inside mkarchiso might rely on their own verification steps, but base build configuration is now hardened.
- Severity summary: High

- Risks found: Potential arbitrary file write via symlink attack in `neos-liveuser-setup`. The script creates directories and modifies files in `/home/liveuser` as root before ultimately chowning the directory, allowing a compromised `liveuser` to pre-create `/home/liveuser` as a symlink pointing to sensitive system locations.
- Fixes applied: Added a symlink check (`-L`) for `LIVE_USER_HOME` in `neos-liveuser-setup` before any directory creation or file writing occurs, aborting if a symlink is detected.
- Remaining attack surface: Other root scripts operating on user directories must be carefully audited for symlink traversal vulnerabilities.
- Severity summary: High
