# 4. Use plasma-meta for KDE Plasma desktop

Date: 2026-02-17
Status: Accepted

## Context
We need to provide a complete, well-integrated, and consistently updated desktop environment.

## Decision
We will install the KDE Plasma desktop using the `plasma-meta` package rather than picking individual packages.

## Consequences
- Ensures all core KDE Plasma components are installed.
- Simplifies updates and reduces the risk of missing dependencies.
- May include some applications or utilities that some users might consider "bloat".

## Amendment (2026-09-23)

The shipped `profile/packages.x86_64` does not use `plasma-meta`: it selects
individual Plasma 6 packages (`plasma-desktop`, `plasma-pa`, `plasma-nm`,
`plasma-systemmonitor`, `plasma-firewall`, `powerdevil`, `kscreen`,
`systemsettings`, `kinfocenter`, `sddm`, `sddm-kcm`, `konsole`, `dolphin`,
`spectacle`, plus `plasma-x11-session` for the default X11 session). This is
deliberate, not drift: the meta package's contents shift between Plasma
releases, while the explicit list pins exactly what the live image and the
derived install manifest contain, and is covered by the duplicate/required
package gates. Functionally the list is a superset of what the ISO needs from
the meta group. This ADR's intent (a complete, integrated Plasma desktop)
stands; only the mechanism changed from meta-package to explicit selection.
