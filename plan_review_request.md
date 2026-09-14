The architect scope explicitly asks to:
"Refine Phase 8 Operations Hub features, focusing on crash reporting opt-in UX and logic."
"Ensure the solution handles cases where drkonqi is not installed gracefully."

And the current code in `neos-operations-hub` is:
```bash
    "4")
        if command -v drkonqi >/dev/null 2>&1; then
            # Palette: Verify crash reporting UX is intuitive.
            exec drkonqi >/dev/null 2>&1
        else
            exec kdialog --icon dialog-error --title "Crash Reporting" --error "Crash reporting tool (drkonqi) is not currently installed or available in this session."
        fi
        ;;
```

I will enhance the crash reporting option UX in `neos-operations-hub` by explicitly asking the user for confirmation and using a `kdialog` with clear language before launching `drkonqi`. In the error case, I will update the language to make it friendlier and more informative. I will also make sure to append my changes into `PALETTE_REPORT.md` and `ai/tasks/palette.json` as task completion.

Plan:
1. Update `profile/airootfs/usr/local/bin/neos-operations-hub` option "4" to improve UX of crash reporting opt-in and missing tool error dialog.
2. Update `ai/tasks/palette.json` by adding the completed task for this UX improvement.
3. Update `PALETTE_REPORT.md` to log the completed UX improvement.
4. Complete pre-commit steps to ensure proper testing, verification, review, and reflection are done. (Including running `tests/verify_operations_hub.sh` and `tests/verify_ux_polish.sh`)
5. Submit the change.
