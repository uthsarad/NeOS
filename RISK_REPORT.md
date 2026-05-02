# Risk & Priority Report

## Security Risks
- **Sandboxing vs. Updates:** Applying overly strict systemd sandboxing (like `ProtectSystem=strict`) on `neos-autoupdate.service` will break pacman updates. This must be avoided.
- **Script Vulnerabilities:** System scripts need audits for log injection and path hijacking vulnerabilities.

## Performance Risks
- **External Binaries in Loops:** Relying on tools like `awk` or subshells in hot paths of bash scripts introduces unnecessary overhead.

## Complexity Creep
- Minor risk. Limiting the scope to script hardening and branding fixes prevents feature creep and aligns with the strategic directive.
