# Strategic Directive

## Core Operating Standard
- **Product Vision:** NeOS - a curated, snapshot-based Arch Linux desktop distribution engineered for predictable behavior, fast boot, system stability, and a refined KDE Plasma 6 experience for users transitioning from Windows.
- **Anti-Slop Rule:** 
 - **No Meta-Work:** Do not open pull requests that only acknowledge directives, update status manifests, or commit empty reports.
 - **Code Deliverables Only:** Every automated session must produce tangible, scoped, test-backed code or configuration improvements directly in target files.
 - **No Endless Pause Loops:** No strategic pause or validation pause commits. If there is nothing to build or fix, do not commit.

---

## Maestro Coordination & Role Separation
Maestro coordinates priorities and work allocation among the three specialist agents to ensure tasks do not conflict:

### 1. Bolt (Performance & Efficiency)
* **Domain:** Runtime speed, ISO build times, resource efficiency, and minimal overhead.
* **Scope:**
 * Eliminate subshell execution overhead and redundant forks in `build.sh` and shell utilities.
 * Optimize package downloading, caching, and filesystem compression during ISO generation.
 * Benchmark boot timing and live-session initialization scripts.
* **Prohibitions:** Do not alter security sandboxing or modify UI themes without coordination.

### 2. Palette (UX, Theming & Accessibility)
* **Domain:** Desktop experience, accessibility, typography, and clean user feedback.
* **Scope:**
 * Polish keyboard navigation, tab order, and active focus styling across `neos-welcome-app`.
 * Ensure user-facing CLI and GUI utilities provide clear error messages and next-step troubleshooting guidance.
 * Maintain clean, consistent KDE Plasma 6 visuals without visual bloat or unneeded ornamentation.
* **Prohibitions:** Do not introduce unvetted third-party graphical libraries or heavy assets.

### 3. Sentinel (Security & Hardening)
* **Domain:** Privilege boundaries, system hardening, defensive scripting, and vulnerability mitigation.
* **Scope:**
 * Audit file permissions and prevent insecure temporary file handling in scripts (`profile/airootfs/usr/local/bin/`).
 * Ensure systemd service units adhere to principle of least privilege (`ProtectSystem`, `NoNewPrivileges`, `ProtectHome`).
 * Validate and sanitize all user and environment inputs in administrative utilities.
* **Prohibitions:** Do not break essential desktop/system services by over-restricting filesystem access.

---

## Active Coordination Matrix
| Specialist | Target Path | Task Objective |
| :--- | :--- | :--- |
| **Bolt** | `build.sh` | Profile and eliminate redundant subprocess invocations in the build/packaging loop. |
| **Palette** | `profile/airootfs/usr/local/bin/neos-welcome-app` | Audit keyboard navigation and ensure high-contrast focus rings on interactive elements. |
| **Sentinel** | `profile/airootfs/usr/local/bin/neos-autoupdate.sh` | Audit temporary file handling and enforce restrictive umask defaults. |

*Coordinated by Maestro - Updated 2026-09-19T23:15:52Z*
