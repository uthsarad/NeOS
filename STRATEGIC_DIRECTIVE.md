# Strategic Directive

## Objective
To stabilize the NeOS project by finalizing the "Active Hardening" phase. The immediate focus is strictly on completing the systemd sandboxing implementation across all remaining services.

## Scope
This directive applies to the NeOS repository. Feature development remains suspended. Engineering efforts are explicitly limited to a single coherent deliverable: applying standard systemd sandboxing directives to any unhardened `.service` files to reduce the system's attack surface.

## Rationale
The previous phase successfully addressed architecture decision records and error handling in core scripts. However, leaving the remaining systemd services without complete sandboxing represents an unacceptable residual security risk. By focusing solely on this one deliverable, we ensure high-quality security enforcement without risking feature creep or scope bloat.
