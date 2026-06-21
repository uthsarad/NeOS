## 2025-02-23 - [Standardize Error Handling]
**Vulnerability:** [Inconsistent error handling and trap usage in core bash scripts leading to potential command injection or exit code masking.]
**Learning:** [Shell trap commands executing arbitrary strings without sanitation pose high risks; evaluating variables inside unquoted trap bodies can lead to command injection.]
**Prevention:** [Standardize error handler functions that securely evaluate parameters and use properly constructed traps (`trap '_error_handler $? $LINENO' ERR`) to avoid evaluation issues.]
## 2026-06-21 - [Supply Chain Verification]
**Vulnerability:** The build process downloaded the `chaotic-keyring.pkg.tar.zst` package directly over the network and installed it using `pacman -U` without cryptographically verifying its signature, leaving the CI/CD pipeline vulnerable to a network-based supply chain attack or CDN compromise.
**Learning:** Even when using HTTPS, direct downloads of system-level packages must be manually verified using `.sig` files and `pacman-key --verify` before installation, especially since `pacman -U` bypasses standard repository verification checks.
**Prevention:** Always download the `.sig` companion file for any `.pkg.tar.zst` obtained via `curl` or `wget`, and explicitly verify it against the local `pacman-key` keyring before passing it to `pacman -U`.
