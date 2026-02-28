# SENTINEL REPORT 🛡️

## Risks Found

### 1. Persistent Live Environment Autologin (High Severity)
- **Vulnerability**: The file `airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf` configures passwordless autologin for the user `liveuser` on TTY1. This file was not excluded from the installation process.
- **Impact**: If a user creates an account named `liveuser` during installation, they would be automatically logged in to the console without a password on the installed system. Even if the username doesn't match, the presence of this configuration file on a production system is a security misconfiguration.
- **Location**: `airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf`

### 2. Unsigned Package Repository (Medium Severity)
- **Vulnerability**: `pacman.conf` configures the `alci_repo` with `SigLevel = Optional`.
- **Impact**: Allows installation of unsigned packages, posing a supply chain risk if the repository is compromised.
- **Status**: Not fixed in this pass (requires external repository changes or signing infrastructure).

### 3. Hardcoded Driver Probing (Low Severity)
- **Vulnerability**: `neos-driver-manager` uses `subprocess.run` to load drivers based on internal logic.
- **Impact**: Low risk as inputs are largely hardcoded or derived from system enumeration, but worth monitoring.
- **Status**: Reviewed, deemed acceptable for now.

## Fixes Applied

### 1. Excluded Autologin Configuration
- **Action**: Modified `airootfs/etc/calamares/modules/unpackfs.conf`.
- **Details**: Added `etc/systemd/system/getty@tty1.service.d/autologin.conf` to the `exclude` list. This prevents Calamares from copying the file from the live image to the target system.

### 2. Redundant Cleanup
- **Action**: Modified `airootfs/etc/calamares/modules/shellprocess.conf`.
- **Details**: Added `rm -f /etc/systemd/system/getty@tty1.service.d/autologin.conf` to the post-install script. This ensures the file is removed even if the exclusion fails or logic changes.

### 3. Verification Test
- **Action**: Created `tests/verify_security_autologin.sh`.
- **Details**: A regression test that verifies the presence of the exclusion and removal rules in the configuration files.

## Remaining Attack Surface
- **Unsigned Repos**: The `alci_repo` remains a weak point. Recommendation: Mirror packages to a signed repository or enforce signing.
- **Kernel Hardening**: While `sysctl` settings are good, enabling Secure Boot and further kernel locking (e.g., `lockdown=confidentiality`) could enhance security for high-risk environments.

## Severity Summary
- **Critical**: 0
- **High**: 1 (Fixed)
- **Medium**: 1 (Open)
- **Low**: 1 (Open)

## Sentinel Report - Security Posture Verification

### Risks Found

1. **Medium Priority - Time-of-Check Time-of-Use (TOCTOU) Race Condition**
   - **File**: `airootfs/usr/local/bin/neos-autoupdate.sh`
   - **Description**: The script checked if a log file existed (`if [ ! -f "$LOG_FILE" ]`), then created it (`touch "$LOG_FILE"`) and finally set permissions (`chmod 600 "$LOG_FILE"`). This three-step process creates a brief window where the file exists with default permissions (often `644`) before the `chmod` command is executed. If an attacker could anticipate this window, they could potentially read from or write to the file before it is secured.
   - **Impact**: Potential information disclosure or log tampering.

### Fixes Applied

1. **Atomic File Creation in `neos-autoupdate.sh`**
   - **Fix**: Replaced the separate `touch` command with the atomic pattern `(umask 077; set -C; > "$LOG_FILE") 2>/dev/null || true` followed by `chmod 600 "$LOG_FILE"`. This ensures exclusive creation with the restricted `umask` of `077` (resulting in `600` permissions), completely eliminating the TOCTOU window for new files, while also ensuring `600` permissions if the file already exists.

### Remaining Attack Surface

-   While the log file creation is now secure, the script still requires root privileges to execute and manages critical system operations (Btrfs snapshots and pacman updates). Any future modifications must carefully audit how files and directories are manipulated to prevent privilege escalation.
-   The overall attack surface remains largely unchanged but is marginally safer regarding log manipulation.

### Severity Summary

-   **Medium Risks Resolved**: 1 (TOCTOU race condition)
-   **Security Validations Passed**: 1 (Verified `airootfs/etc/pacman.conf` correctly enforces `SigLevel = Required DatabaseRequired` on the installed system).
