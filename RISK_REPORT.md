# NeOS Risk & Priority Report

## Current Risk Posture

1.  **Shell Script Vulnerabilities (High Risk):**
    *   **Description:** The repository relies heavily on custom Bash scripts for both CI validation (`tests/verify_*.sh`) and critical runtime operations (`airootfs/usr/local/bin/*`, e.g., autoupdate, installer partitioning, live user setup). Currently, these scripts lack automated static analysis.
    *   **Impact:** Without ShellCheck, there is a high risk of introducing subtle regressions, unquoted variable expansions leading to command injection, or logic errors that could compromise the build process or the final installed system's security.
    *   **Mitigation Strategy:** Implement a dedicated GitHub Actions workflow to run ShellCheck on all bash scripts. This satisfies item #14 in `AUDIT_ACTION_PLAN.md`.

2.  **Unvalidated External Dependencies in CI (Medium Risk):**
    *   **Description:** Existing workflows (e.g., `build-iso.yml`) install packages dynamically (like `python-yaml` or `chaotic-keyring`).
    *   **Impact:** If upstream repositories are compromised or unavailable, the CI pipeline will fail or potentially execute malicious code.
    *   **Mitigation Strategy:** Ensure new workflows (like the proposed ShellCheck workflow) use pinned actions or securely verify installed tools.

3.  **Feature Creep (Low Risk):**
    *   **Description:** The temptation to add new GUI features before stabilizing the core architecture.
    *   **Impact:** Delays the beta release and increases the maintenance burden.
    *   **Mitigation Strategy:** Strictly adhere to the "Infrastructure improvement" priority for this iteration. Refuse modifications to existing scripts or feature additions.

## Prioritization Decision

Based on the above risks, the immediate priority is **Stabilization / hardening** via **Infrastructure improvement**.

We will prioritize the creation of a ShellCheck CI workflow over fixing individual script warnings or adding new features. This establishes the necessary automated guardrails to ensure the long-term maintainability and security of the NeOS codebase.