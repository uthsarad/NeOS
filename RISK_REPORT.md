# Risk & Priority Report

## Security Risks
- **Option Injection in Scripts:** System administration scripts that accept arguments (such as device paths) without option termination (using `--`) are vulnerable to option injection if an input starts with a dash (`-`). This requires immediate hardening in the partitioning scripts.
- **Symlink TOCTOU Attacks:** Writing state files to world-writable directories remains a theoretical risk if not strictly managed.
- **Sandboxing Constraints:** We must ensure that `ProtectSystem=strict` is avoided for package manager services like `neos-autoupdate.service` to preserve functional system updates.

## Performance Risks
- **Execution Overhead:** Relying on external binaries and subshells in frequent operations continues to be a performance bottleneck. Ongoing monitoring is required.

## Complexity Creep
- **Feature Creep:** Remains a significant risk. We are enforcing strict scope boundaries, explicitly preventing new functionality and isolating work to critical security and stability improvements.
