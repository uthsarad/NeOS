## Accessibility fixes
- Explicitly mapped accessible names and descriptions to interactive QPushButtons in the NeOS Welcome app using `.setAccessibleName()` and `.setAccessibleDescription()`, ensuring screen readers announce rich context alongside visual tooltips.

## UX improvements
- Improved screen reader context for core onboarding actions (e.g., Try NeOS, Install NeOS, Get Started).

## Remaining usability risks
- The custom layout implementation means standard tab orders might require manual testing on less common screen reader configurations.
