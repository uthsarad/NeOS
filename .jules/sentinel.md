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
