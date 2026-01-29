## 2024-10-24 - Rolling Release Security Model
**Vulnerability:** Ambiguity in "Supported Versions" for rolling releases.
**Learning:** NeOS follows a rolling release model (Arch-based). This creates a unique security constraint where "supported versions" are effectively only the "latest". Traditional long-term support (LTS) policies do not apply, and the security policy must explicitly clarify this to avoid user confusion about backports.
**Prevention:** Explicitly define "Rolling" support in SECURITY.md and educate users that updates are the only fix.

## 2026-01-29 - Package Database Integrity
**Vulnerability:** Defaulting to `DatabaseOptional` allows mirrors to potentially serve stale or tampered package databases without detection (replay attacks).
**Learning:** In a snapshot-based distribution where the repository state is static and coordinated, there is no reason not to sign the database. Enforcing signatures adds a critical layer of trust to the supply chain.
**Prevention:** Set `SigLevel = Required DatabaseRequired` in `pacman.conf` to enforce database signature verification.
