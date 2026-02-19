## 2024-10-24 - Rolling Release Security Model
**Vulnerability:** Ambiguity in "Supported Versions" for rolling releases.
**Learning:** NeOS follows a rolling release model (Arch-based). This creates a unique security constraint where "supported versions" are effectively only the "latest". Traditional long-term support (LTS) policies do not apply, and the security policy must explicitly clarify this to avoid user confusion about backports.
**Prevention:** Explicitly define "Rolling" support in SECURITY.md and educate users that updates are the only fix.

## 2026-01-29 - Package Database Integrity
**Vulnerability:** Defaulting to `DatabaseOptional` allows mirrors to potentially serve stale or tampered package databases without detection (replay attacks).
**Learning:** In a snapshot-based distribution where the repository state is static and coordinated, there is no reason not to sign the database. Enforcing signatures adds a critical layer of trust to the supply chain.
**Prevention:** Set `SigLevel = Required DatabaseRequired` in `pacman.conf` to enforce database signature verification.

## 2026-01-30 - Unconditional Auto-Merge Workflow
**Vulnerability:** The `jules-auto-merge.yml` workflow triggered on all PRs and attempted to merge them immediately without verifying the actor or waiting for checks. This allowed unauthorized users to potentially merge code.
**Learning:** Convenience automation (like auto-merge bots) must always include strict actor verification (`if: github.actor == ...`) to prevent abuse in public repositories.
**Prevention:** Restrict auto-merge workflows to trusted bots/owners and use `gh pr merge --auto` to respect branch protection rules.

## 2026-05-20 - Device Validation in Installer Scripts
**Vulnerability:** Installer scripts operating on user-supplied paths without block device validation (`[[ -b ... ]]`).
**Learning:** Shell scripts dealing with `parted` or `mkfs` can easily destroy files or directories if the input is not strictly validated as a block device. This is a critical safety check for any system administration tool.
**Prevention:** Always use `[[ -b "$DEVICE" ]]` before executing destructive disk operations.

## 2026-06-01 - Installer Privilege Escalation via Live Config
**Vulnerability:** The installer copied `airootfs/etc/sudoers.d/wheel` (NOPASSWD) to the target system via `unpackfs`.
**Learning:** Files meant for the Live ISO environment (like passwordless sudo) must be explicitly excluded or removed from the installed system. Calamares `unpackfs` copies everything by default.
**Prevention:** Use a `shellprocess` module or `unpackfs` exclusions to remove sensitive live-only configuration files from the target.

## 2026-06-02 - Weak Password Policy in Installer
**Vulnerability:** The Calamares installer configuration explicitly allowed weak passwords (`allowWeakPasswords: true`).
**Learning:** Default configurations in installer frameworks often prioritize user convenience over security, allowing users to set single-character passwords that are easily brute-forced.
**Prevention:** Audit all installer configuration files (especially `users.conf`) to ensure `allowWeakPasswords` is set to `false`.

## 2026-06-05 - Unsafe Shell Execution in Driver Scripts
**Vulnerability:** The `neos-driver-manager` script utilized `shell=True` and `os.system` for executing system commands.
**Learning:** While the current inputs were hardcoded, using `shell=True` creates a latent vulnerability that becomes critical if dynamic input is ever introduced. It also violates the principle of least privilege by invoking a full shell environment unnecessarily.
**Prevention:** Always use `subprocess` functions with a list of arguments (e.g., `["cmd", "arg"]`) and `shell=False` to bypass shell expansion risks.

## 2026-06-08 - Insecure Lock File Location
**Vulnerability:** The automatic update script used `/var/lock` (a world-writable directory) for its lock file, allowing unprivileged users to pre-create and lock the file, causing a Denial of Service (DoS) for system updates.
**Learning:** System scripts running as root must place lock files in directories only writable by root (e.g., `/run` or `/var/lib`) to prevent user interference. World-writable directories like `/tmp` or `/var/lock` are unsafe for privileged lock files.
**Prevention:** Always use a secure, root-owned directory for lock files in privileged scripts.

## 2026-06-15 - Missing Kernel Hardening Defaults
**Vulnerability:** The default `airootfs` configuration lacked `fs.protected_hardlinks`, `fs.protected_symlinks`, and `kernel.unprivileged_bpf_disabled`.
**Learning:** Arch Linux and many minimal distributions default to upstream kernel settings, which are often permissive for compatibility. Security-focused distributions must explicitly enable these protections to mitigate TOCTOU attacks and reduce the kernel attack surface.
**Prevention:** Audit `sysctl.d` configurations against security baselines (like the Kernel Self Protection Project) and enforce restrictive defaults.

## 2026-06-20 - QML HTML Injection via Default Text Format
**Vulnerability:** The QML `Label` component defaults to `Text.AutoText`, which renders HTML tags (like `<b>`, `<img>`, `<a href>`) if present in the text property. This allows stored XSS or UI redress attacks if the text comes from untrusted user input (e.g., snapshot descriptions).
**Learning:** Default UI component behaviors often prioritize richness over security. In QML, any string that looks like HTML is rendered as such by default, which is dangerous for user-generated content.
**Prevention:** Explicitly set `textFormat: Text.PlainText` for all `Label` components displaying dynamic or user-controlled text to force literal rendering.

## 2026-06-25 - Enable Firewall by Default
**Vulnerability:** The `ufw` firewall package was installed but not enabled by default (`ufw.service` was missing from `services-systemd.conf`). This left new installations with no network filtering, exposing them to potential attacks on open ports.
**Learning:** Installing security tools is not enough; they must be explicitly enabled and configured. Desktop users expect "secure by default" networking.
**Prevention:** Audit `services-systemd` configuration in Calamares to ensure critical security services (like firewalls) are enabled on first boot.

## 2026-07-15 - Insecure Build Configuration Inheritance
**Vulnerability:** The ISO build script (`build.sh`) copied `/etc/pacman.conf` from the host system, inheriting its repository configuration, mirrorlist, and security settings (like `SigLevel`).
**Learning:** Build processes must be hermetic and reproducible. Relying on host configuration introduces unpredictability and potential security risks (e.g., weak signature checks or compromised mirrors on the host).
**Prevention:** Always use a repository-controlled configuration file for build tools and explicitly inject necessary environment-specific paths (like mirrorlists) rather than copying host files.

## 2026-08-05 - Deprecated User Groups Removal
**Vulnerability:** The default user configuration in Calamares added users to deprecated and potentially unsafe groups like `storage`, `optical`, `video`, etc.
**Learning:** Modern systemd-logind systems manage device access via ACLs (uaccess) for the active session. Adding users to these static groups grants permanent access, bypassing session security and increasing the attack surface.
**Prevention:** Audit `users.conf` to ensure only `wheel` (for sudo) is assigned by default, removing all legacy device groups.

## 2026-10-24 - Log File Symlink Attacks
**Vulnerability:** `neos-autoupdate.sh` wrote to `/var/log/neos-autoupdate.log` using `tee -a` without checking if the target file was a symlink.
**Learning:** Even root-owned directories like `/var/log` can be vectors for privilege escalation if permissions are misconfigured or if a user can pre-create a symlink (TOCTOU). Scripts running as root must be paranoid about file operations.
**Prevention:** Always check `if [ -L "$FILE" ]` before writing to predictable file paths in shell scripts, or use `O_NOFOLLOW` where possible.

## 2026-10-25 - Hardening Live ISO SSH Access
**Vulnerability:** The live ISO environment configures the `liveuser` with an empty password and installs `openssh`. If `sshd` is enabled (manually or accidentally), it allows unauthorized root access via passwordless sudo.
**Learning:** Live ISOs often prioritize convenience (no password) but fail to account for the risk of installed services like SSH being activated. The combination of "empty password" + "sudo ALL" + "sshd installed" is a critical chain.
**Prevention:** Explicitly configure `sshd_config` in the live overlay to deny empty passwords (`PermitEmptyPasswords no`) and root login (`PermitRootLogin no`). This forces the user to set a password before remote access is possible.
