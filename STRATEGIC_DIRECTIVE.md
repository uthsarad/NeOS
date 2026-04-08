PHASE 1 — Product Alignment Check
- What is the product trying to become?
  NeOS is aiming to be a curated, snapshot-based Arch Linux desktop distribution focused on predictable behavior, stability, and a Windows-familiar UX.
- Are we building toward that?
  Yes, by emphasizing stability and low breakage through curated configurations rather than adding raw features.
- Are we solving the highest leverage problem?
  The deep audit report highlights a critical security gap: systemd services run with elevated privileges without strict sandboxing. Resolving this provides high-leverage stability and aligns with the resilience mindset.

PHASE 2 — Technical Posture Review
- Is the system stable?
  Generally stable, but vulnerable to potential privilege escalation if custom service components fail or are exploited.
- Is tech debt increasing?
  Tech debt remains from un-sandboxed services (`neos-autoupdate.service`, `neos-driver-manager.service`, etc.) as identified in the `DEEP_AUDIT.md`.
- Are we overbuilding?
  No. We are prioritizing hardening existing, necessary components rather than introducing new services.

PHASE 3 — Priority Selection
- Stabilization / hardening
  We will dedicate this effort entirely to implementing systemd sandboxing across custom services.

PHASE 4 — Controlled Scope Definition
- Exact files likely impacted:
  `airootfs/etc/systemd/system/neos-autoupdate.service`
  `airootfs/etc/systemd/system/neos-liveuser-setup.service`
  `airootfs/etc/systemd/system/neos-driver-manager.service`
- Maximum allowed surface area:
  Modifications must be strictly limited to adding sandbox directives within the `[Service]` block of existing custom systemd units.
- Constraints Architect must obey:
  - Do NOT write new executable scripts.
  - Do NOT modify the `ExecStart` lines.
  - Limit additions explicitly to: `ProtectSystem=strict`, `ProtectHome=yes`, `PrivateTmp=yes`, `NoNewPrivileges=yes`, `ProtectKernelTunables=yes`, and `RestrictRealtime=yes`.

PHASE 5 — Delegation Strategy
- Architect builds:
  Implementation of systemd sandboxing rules inside the specified unit files.
- Bolt optimizes:
  Validation that sandboxing additions do not measurably slow down service boot times.
- Palette enhances:
  Verification that any startup failures caused by tightened permissions yield clear, actionable log outputs for developers.
- Sentinel audits:
  Confirmation that the applied sandboxing directives correctly isolate the file system and prevent privilege escalation, adhering to the principle of least privilege.