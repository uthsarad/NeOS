# Risk & Priority Report

## Security Risks
- **Sandboxing Constraints:** We must continue to ensure that `ProtectSystem=strict` is not applied to package manager services like `neos-autoupdate.service`, as it prevents system updates.
- **Script Vulnerabilities:** We need to keep auditing shell scripts for proper sanitization and path management to prevent injection or path hijacking.

## Performance Risks
- **Execution Overhead:** Using subshells and external binaries in hot loops remains a risk that requires ongoing monitoring.

## Complexity Creep
- Feature creep is a significant risk. We are enforcing a strategic pause today to mitigate this and maintain long-term stability.
