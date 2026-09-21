# Palette UX Report

## Accessibility & UX Fixes
* Replaced confusing backticks with `<b>` Pango markup in desktop notifications triggered by `neos-autoupdate.sh` to ensure `notify-send` accurately renders important context.
* Added missing stderr redirection (`>&2`) to early script dependency checks in `build.sh` to prevent error invisibility during piped executions.

## Codebase Convention Adherence
* Removed emojis from `_error_handler` in `neos-autoupdate.sh` to comply with the global no-emoji rule.
* Replaced em dashes (`—`) with standard double-hyphens (`--`) in `build.sh` comments to comply with the global no-em-dash rule.

## Remaining Usability Risks
* The terminal prompt for deleting the `WORK_DIR` in `build.sh` functions correctly using `-n 1`, but may silently fail to capture multi-character inputs gracefully.
