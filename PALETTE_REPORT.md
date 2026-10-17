## Accessibility fixes
Added explicit accessible names and descriptions to all interactive buttons in `profile/airootfs/usr/local/bin/neos-welcome-app`. By assigning `setAccessibleName` and `setAccessibleDescription`, screen readers can correctly identify the buttons' purpose and context beyond just their visible text or implicit roles.

## UX improvements
Improved the underlying semantic structure for assistive technologies. There are no visual design changes, ensuring the layout remains consistent while enhancing invisible interactions for users relying on keyboard navigation and screen readers.

## Remaining usability risks
- Some feature cards containing icons and text lack full ARIA-equivalent accessibility bindings. A screen reader might read them simply as separate labels instead of cohesive feature descriptions.
- The window's overall structure and static text labels could benefit from explicit accessible roles (e.g., as headings) to improve document flow for assistive tools.
