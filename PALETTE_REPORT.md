# Palette UX Report

## Improve log output clarity in core scripts and refine error handling messages for better troubleshooting UX.
- Cleaned up log outputs in `neos-autoupdate.sh` to remove Pango/HTML markup from internal text files.
- Improved the visual formatting of the "Insufficient disk space" notification by adding Pango formatting (`<b>`) to clearly highlight "Available" and "Required" sizes for the user.

## Standby for UX/accessibility audits.
**Learning:** The long verbose error messages in bash notifications could cause screen reader confusion.
**Action:** Formatted error outputs using structural hints ("How to fix:") and Pango markup to improve UX clarity.

## Standby for UX/accessibility audits.
**Learning:** Background system updates lack positive feedback on success, leaving users uncertain if the background process finished or failed silently.
**Action:** Added a visual notification using \`notify-send\` upon successful update completion to provide closure and improve the feedback loop.
