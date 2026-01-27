# Security Policy

## Reporting a vulnerability

If you discover a security issue, please email the project team at security@neos.example with details.

We will acknowledge receipt within 72 hours and provide updates as we investigate. Please do not disclose the issue publicly until we have had a chance to resolve it.

## Supported versions

While the project is in its early stages, only the `main` branch is considered supported.
## Supported Versions

NeOS is a rolling release distribution. We generally support the latest available version of all packages in our stable repositories.

| Version | Supported | Notes |
| :-- | :-- | :-- |
| Rolling | :white_check_mark: | All users are expected to stay up-to-date. |

## Reporting a Vulnerability

We take the security of NeOS seriously. If you have discovered a security vulnerability, we appreciate your help in disclosing it to us in a responsible manner.

### How to Report

Please **DO NOT** report security vulnerabilities through public GitHub issues.

Instead, please report vulnerabilities by creating a **Draft Security Advisory** in this repository (if enabled). If you cannot create a draft advisory, please reach out to the maintainers via private communication channels listed in the project documentation.

Please include the following details in your report:

*   Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
*   Full paths of source file(s) related to the manifestation of the issue
*   The location of the affected source code (tag/branch/commit or direct URL)
*   Any special configuration required to reproduce the issue
*   Step-by-step instructions to reproduce the issue
*   Proof-of-concept or exploit code (if possible)
*   Impact of the issue, including how an attacker might exploit the issue

### Response Timeline

We will make a best effort to handle your report with the following timeline:

*   **Acknowledgment:** Within 48 hours.
*   **Assessment:** Within 1 week we will confirm the finding.
*   **Resolution:** We will collaborate on a fix and release it as soon as possible.

## Security Updates

Since NeOS is a rolling release, security updates are delivered via the standard package manager (`pacman` or `Discover`). Critical security updates are prioritized in our curation pipeline.

## Third-Party Components

NeOS relies on upstream Arch Linux repositories and various third-party projects (KDE, Qt, etc.). Vulnerabilities in upstream packages should generally be reported to the respective upstream project, unless the issue is specific to NeOS packaging or configuration.
