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

## 2025-05-23 - Empty State Visibility
**Learning:** Placing an empty state message *below* a list creates a disconnected experience, especially if the list retains its height (blank space).
**Action:** Use `StackLayout` to swap the list with a centered, actionable empty state container that fills the same visual space.

## 2025-05-24 - List Item Safety
**Learning:** In destructive contexts (e.g., system restore), allowing the entire list row to trigger the action increases the risk of accidental execution (slip error).
**Action:** Decouple selection from execution by using a specific action button (e.g., "Restore") within the delegate, leaving the row click for selection only.

## 2026-05-25 - Keyboard Navigation in List Items
**Learning:** In QML `ListView`, complex delegates with internal actions (like buttons) are often skipped by standard arrow key navigation, making them inaccessible to keyboard users.
**Action:** Use `KeyNavigation.right` (or appropriate direction) on the delegate root to move focus *into* the action button, and `KeyNavigation.left` on the button to return focus to the list item.

## 2026-06-25 - Contextual Safety with Tooltips
**Learning:** Destructive buttons in QML dialogs (like "Reboot") often lack secondary safety checks for keyboard users who might tab-press quickly.
**Action:** Add `ToolTip.visible: hovered || activeFocus` to destructive buttons to reinforce the consequence (e.g., "Reboot immediately") *before* the click occurs.

## 2026-06-25 - Async Load Focus
**Learning:** When replacing content asynchronously (e.g., refreshing a list), keyboard focus is often lost or remains on the trigger, disrupting the navigation flow.
**Action:** Automatically shift focus to the new content (e.g., `listView.forceActiveFocus()`) and select the first item upon successful load to maintain continuity.

## 2026-02-14 - Calamares Slideshow Accessibility
**Learning:** Default QML slideshows in Calamares often lack accessibility properties, making the installation process silent for screen reader users. Also, improper anchoring can render text invisible.
**Action:** Always wrap Calamares slides in a layout container (like `Column`) and explicitly set `Accessible.role` and `Accessible.name` on all visual elements.

## 2026-06-26 - Contrast Assurance in Themed Environments
**Learning:** In customizable branding environments (like Calamares), text color (e.g., white) can become invisible if the background changes (e.g., to a light theme).
**Action:** Always wrap text content in a semi-transparent container (e.g., `Rectangle { color: "#99000000" }`) to guarantee high contrast and legibility regardless of the underlying background.

## 2024-05-27 - Calamares Slideshow Navigation
**Learning:** Default Calamares slideshows are often passive, frustrating users who read quickly or want to skip. Lack of keyboard controls also alienates power users.
**Action:** Add explicit navigation controls (like clicking to advance) and bind keyboard shortcuts (e.g., Right Arrow) to the `Presentation` component to empower user control.

## 2024-10-24 - Accessibility in QML Slideshows
**Learning:** QML `Presentation` components in Calamares often lack built-in focus indicators and keyboard navigation beyond basic advancement, making them inaccessible to keyboard users.
**Action:** When working with QML slideshows, always explicitly add `activeFocus` visual states (e.g., borders) and comprehensive keyboard handlers (Space, Left/Right arrows) to ensure WCAG compliance.
