## 2024-10-24 - Rolling Release Security Model
**Vulnerability:** Ambiguity in "Supported Versions" for rolling releases.
**Learning:** NeOS follows a rolling release model (Arch-based). This creates a unique security constraint where "supported versions" are effectively only the "latest". Traditional long-term support (LTS) policies do not apply, and the security policy must explicitly clarify this to avoid user confusion about backports.
**Prevention:** Explicitly define "Rolling" support in SECURITY.md and educate users that updates are the only fix.
