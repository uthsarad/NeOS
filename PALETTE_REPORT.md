# Palette UX Report

## Improve log output clarity in core scripts and refine error handling messages for better troubleshooting UX.
- Cleaned up log outputs in `neos-autoupdate.sh` to remove Pango/HTML markup from internal text files.
- Improved the visual formatting of the "Insufficient disk space" notification by adding Pango formatting (`<b>`) to clearly highlight "Available" and "Required" sizes for the user.
