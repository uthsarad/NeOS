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
