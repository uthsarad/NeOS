# Risk & Priority Report

## Current Risk Assessment
The project is currently facing an unacceptable level of validation debt that jeopardizes our core architectural stability and future product milestones. Recent infrastructure efforts applied strict systemd sandboxing (including `ProtectSystem=strict` and `ProtectHome=yes`) to critical system services: `neos-autoupdate.service` and `neos-liveuser-setup.service`. However, the mandatory validation tasks assigned to Sentinel (for security and privilege auditing) and Palette (for logging UX and error clarity) remain unexecuted and are blocking development.

**Identified Risks:**
1. **Compounding Validation Debt:** The failure to audit the core service hardening introduces a severe blind spot in our QA pipeline. Proceeding with new feature development without clearing this debt creates unacceptable risks for system security and reliability. The longer this validation is delayed, the higher the risk of catastrophic regressions slipping into the release.
2. **Regression Blindspots in Sandboxing:** The unverified `ProtectSystem=strict` directives have a high probability of silently breaking critical operations. Specifically, `neos-liveuser-setup.service` performs initialization tasks like `useradd -m` and creates directories in `/home/liveuser`. Without explicit, verified `ReadWritePaths` for these directories, the live environment will fail to initialize. Similarly, `neos-autoupdate.service` requires unfettered access to `/var/lib/pacman`, `/etc/pacman.d`, `/opt`, and `/srv`, as well as `CAP_SYS_MODULE` for DKMS rebuilds. Incorrectly configured sandboxing will cause autoupdates to fail silently or result in unbootable kernels.
3. **Feature Creep & Instability:** Attempting to implement Phase 1, Phase 2, or Phase 3 Roadmap features prior to resolving these fundamental infrastructure risks constitutes reckless engineering. Building on top of unverified security constraints will severely complicate troubleshooting and move the project further from its goal of providing a dependably stable rolling-release experience.

## Priority Selection
**No-build day (strategic pause)**

## Actionable Mitigation
- **Architect:** Must strictly enforce the strategic pause, resulting in exactly zero file modifications across the entire repository. The Architect must focus entirely on system comprehension and ensuring the repository remains a stable baseline for specialist audits. No coding, refactoring, or architectural drift is permitted.
- **Specialists:** Must urgently and decisively execute their pending validation tasks on the restricted systemd services. Resolving this validation debt is the highest priority and explicitly blocks all subsequent roadmap progress.
- **Governance:** Normal roadmap implementation will only resume after the entire validation debt queue has been cleared and baseline system stability is definitively confirmed by both Sentinel and Palette.
