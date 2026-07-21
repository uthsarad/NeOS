# Sentinel Security Report

### Risks found
- High: Symlink traversal vulnerability (CWE-59) in `profile/airootfs/usr/local/bin/neos-liveuser-setup`. The script runs as root and writes to `/home/liveuser/.config` and `/home/liveuser/Desktop` without verifying if these subdirectories are symlinks, potentially allowing arbitrary file writes if the live environment is compromised prior to setup.

### Fixes applied
- Added strict `[[ -L ]]` symlink checks for `.config` and `Desktop` directories before execution of `mkdir -p` and subsequent file creation.

### Remaining attack surface
- The overarching `neos-liveuser-setup.service` remains unsandboxed (`ProtectSystem=strict` and `ProtectHome=yes` cannot be applied because it must execute `useradd -m`). While safe systemd isolation is applied, the script inherently retains root access to the filesystem.

### Severity summary
- 1 HIGH risk mitigated.
