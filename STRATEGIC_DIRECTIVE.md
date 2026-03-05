# STRATEGIC DIRECTIVE ✒️

**Date:** 2026-03-03
**Phase:** 1 - Foundations & Stabilization
**Primary Focus:** Workflow Automation and Continuous Delivery

## 1. Product Alignment Check
The NeOS mission prioritizes a stable, predictable rolling release model supported by an automated, reliable staging pipeline. Currently, we are drifting from this product goal because our automated merge bot lacks the necessary permissions to merge pull requests that modify GitHub Actions workflows. This creates a bottleneck in our CI/CD pipeline, requiring manual intervention for critical infrastructure updates. Our highest leverage problem is unblocking the automation pipeline to restore velocity.

## 2. Technical Posture Review
The system's build-time stability has improved with the recent addition of pre-build tests, but technical debt is surfacing in our automation tooling. We are not overbuilding; we are under-automating. The `jules-auto-merge.yml` workflow is functionally incomplete because it cannot process workflow updates, which is a common occurrence during infrastructure improvements.

## 3. Priority Selection
**Selection: Infrastructure improvement / Stabilization**

We will fix the auto-merge bot permissions to ensure seamless, automated integration of all pull requests, particularly those that refine our CI pipeline.

## 4. Controlled Scope Definition
The Architect is tasked with a highly constrained deliverable: **Enable Auto-Merge for Workflow Updates**.

### Exact Files Impacted:
- `.github/workflows/jules-auto-merge.yml`

### Maximum Allowed Surface Area:
- Add the `workflows: write` permission to the `approve-and-merge` job (or globally in the workflow).
- Do not modify the existing condition that restricts the auto-merge bot to specific actors (`github.repository_owner` or `google-labs-jules[bot]`).

### Constraints Architect Must Obey:
- **STRICT PROHIBITION:** Do NOT modify any other workflows or application code.
- Maintain the strict actor verification to prevent unauthorized merges.

## 5. Delegation Strategy
- **Architect:** Implement the permission fix in the auto-merge workflow.
- **Bolt (Performance):** No direct performance optimizations required for this specific task; focus on ensuring any future workflow additions maintain fast execution times.
- **Palette (UX):** No direct UX changes required; however, ensure any new PR templates or documentation clearly communicate the bot's capabilities.
- **Sentinel (Security):** Ensure that granting `workflows: write` is strictly coupled with the existing actor verification (`if: github.actor == ...`) to prevent privilege escalation via malicious PRs.
