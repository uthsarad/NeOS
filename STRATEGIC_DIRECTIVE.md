# Strategic Directive

## Phase 1 — Product Alignment Check
- **Product Vision:** NeOS aims to be a highly predictable, rolling-release Arch Linux-based desktop operating system delivering a refined, Windows-familiar user experience right out of the box. Our fundamental goal is to provide a seamless transition to a Linux environment, combining Arch's flexibility with workstation reliability.
- **Alignment:** The product continues to align with its core vision. However, our forward momentum is currently halted by critical unresolved validation tasks stemming from our recent infrastructure hardening initiatives. The strict systemd sandboxing must be thoroughly verified by our specialists before we can safely resume standard feature development.
- **Leverage:** The most critical action right now is to rigorously validate the recently introduced systemd sandboxing configurations (`ProtectSystem=strict`, `ProtectHome=yes`, `NoNewPrivileges=yes`) across mission-critical services like `neos-autoupdate.service` and `neos-liveuser-setup.service`. We must definitively prove that these restrictions do not cripple necessary operational tasks, such as accessing `/var/lib/pacman` for updates, modifying `/home/liveuser` during initialization, or rebuilding kernel modules via `dkms`. We must aggressively clear this validation debt to re-establish a stable, reliable foundation for future roadmap milestones.

## Phase 2 — Technical Posture Review
- **Stability:** We have deployed aggressive security enhancements, applying strict sandboxing to our core system services (`neos-autoupdate.service`, `neos-liveuser-setup.service`). While this significantly hardens the system against potential exploits, it also introduces substantial architectural fragility and a high likelihood of unintended operational breakage if permissions are misconfigured.
- **Tech Debt:** Our validation debt is now at a critical threshold. The specialist task manifests for Sentinel (privilege auditing and `ReadWritePaths` verification) and Palette (logging clarity and UX) are currently pending execution. We are operating blind until these audits confirm the stability of the sandboxed services. Crucially, `neos-liveuser-setup.service` performs operations like `useradd -m`, which are highly sensitive to `ProtectSystem=strict` and `ProtectHome=yes`.
- **Overbuilding:** Implementing any new features or optimizations at this juncture would be technically irresponsible. Adding complexity on top of unverified infrastructure hardening exponentially increases regression risks and significantly complicates any subsequent debugging. We must definitively secure the base before building upward.

## Phase 3 — Priority Selection
**No-build day (strategic pause)**

## Phase 4 — Controlled Scope Definition
- **Impacted Files:** None.
- **Maximum allowed surface area:** 0 files.
- **Constraints:** The Architect is explicitly and unequivocally forbidden from making any modifications to the codebase (`forbidden_files: ["**/*"]`). The entire focus must be on maintaining a pristine, unaltered repository state to provide a stable, unchanging foundation for the specialists to conduct their critical audits. No new code, bug fixes, refactoring, or superficial updates are permitted today.

## Phase 5 — Delegation Strategy
- **Architect:** Immediate and complete cessation of all coding activities. You must maintain this strict strategic pause without exception. Focus exclusively on system analysis and architectural planning for future phases, but execute absolutely no code modifications until the validation debt is fully cleared by the specialists.
- **Bolt:** Maintain the current performance baseline without introducing any changes. Optimization tasks are suspended until architectural stability is confirmed.
- **Palette:** URGENT: Execute the pending logging UX validation task immediately. Rigorously verify that the strictly sandboxed services provide exceptionally clear, actionable error diagnostics. Ensure that any failures caused by read-only filesystem restrictions are explicitly logged in `journalctl` and not masked by generic exit codes. This is paramount for future maintainability.
- **Sentinel:** URGENT: Execute the pending privilege auditing task immediately. Conduct a comprehensive security review of the systemd sandboxing in `neos-autoupdate.service` and `neos-liveuser-setup.service`. Definitively validate that `ReadWritePaths` are correctly tailored to allow essential operations (e.g., access to `/var`, `/boot`, `/opt`, `/srv`, `/home/liveuser`, and `CAP_SYS_MODULE` for dkms) while preventing unauthorized access. This validation is non-negotiable for system security and operational integrity.
