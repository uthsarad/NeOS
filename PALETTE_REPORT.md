# PALETTE_REPORT.md

## Overview
This report documents the UX and accessibility improvements made to the NeOS documentation in response to `ai/tasks/palette.json`.

## UX Improvements
1.  **`README.md` (Supported Architectures):**
    *   **What:** Converted the Markdown table detailing supported architectures into a structured, bulleted list.
    *   **Why:** Tables in Markdown can be difficult to read, especially on mobile devices or smaller screens. A structured list reduces cognitive load by presenting the primary tier (`x86_64`) and its benefits (full GUI experience, Calamares installer, snapshots) prominently, followed by the community tiers. This maintains the "Windows-familiar" framing by clearly establishing expectations upfront.
2.  **`docs/HANDBOOK.md` (Prerequisites -> Hardware):**
    *   **What:** Extracted the dense parenthetical note explaining architecture limitations into a clear sub-list under the "Hardware" requirement.
    *   **Why:** Embedding critical limitations (like the lack of a GUI for `i686` and `aarch64`) inside a parenthetical statement within a paragraph increases the risk of the user missing the information. The sub-list format draws attention to these constraints immediately, preventing frustration later in the installation process.

## Accessibility Fixes
*   While no direct code or ARIA labels were modified, structural changes to documentation significantly improve cognitive accessibility. Bulleted lists are easier for screen readers to parse and navigate compared to dense paragraphs or complex tables.

## Remaining Usability Risks
*   **Documentation Discoverability:** While the content is now easier to read, users must still find these documents. We rely on users reading the `README.md` or `docs/HANDBOOK.md` before attempting an installation on an unsupported architecture.
*   **Visual Hierarchy in Markdown:** Markdown's visual hierarchy is limited by the platform rendering it (e.g., GitHub). We are assuming the rendered output will provide sufficient visual distinction for the nested lists.
