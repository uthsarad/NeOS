# Palette's Journal 🎨

## 2024-10-25 - Documentation Navigation
**Learning:** In a docs-only repo, "UX" translates to "Reading Experience". Dense markdown files without navigation create friction.
**Action:** Add Table of Contents and "Back" links to all major documentation files to improve wayfinding.

## 2024-10-26 - Visualizing Complexity
**Learning:** Complex flows (like repo staging pipelines) described purely in text cause cognitive load.
**Action:** Use Mermaid diagrams to visualize architecture flows directly in markdown.

## 2024-10-27 - Visual Roadmaps
**Learning:** Long numbered lists (like release phases) are hard to scan for high-level context.
**Action:** Use flowcharts or timelines to visualize sequential roadmaps before detailing the steps.

## 2024-05-22 - Destructive Action Clarity
**Learning:** Generic "Confirm" buttons on destructive system actions (like rollback) increase user anxiety.
**Action:** Use explicit verb-based labels (e.g., "Rollback & Reboot") to clarify consequences immediately.

## 2025-02-12 - Safe Focus in Destructive Dialogs
**Learning:** In QML Popups, focus defaults to the first interactive element (often the destructive action), creating a risk of accidental execution via Enter key.
**Action:** Explicitly set `onOpened: cancelButton.forceActiveFocus()` in destructive dialogs to default safety to "Cancel".
