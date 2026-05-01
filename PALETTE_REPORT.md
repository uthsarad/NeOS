# Palette Report 🎨

## UX & Accessibility Improvements

1. **Visual Hierarchy in Boot Logs:** Structured multi-line hardware detection outputs (GPU & Network) in `neos-driver-manager` into bulleted lists. This significantly improves readability and scanning speed for admins watching the fast-scrolling boot sequence.
2. **Terminal Progress Feedback:** Upgraded the visual progression bars in `neos-installer-partition.sh` to use standard ASCII equals characters (`==`) instead of `#` to provide a clearer, more distinct visual fill indicator.
3. **Calamares Contrast Fix:** Fixed an accessibility contrast issue in `branding.desc` where `sidebarTextSelect` was the same color as the highlight background (`#005A9E`), rendering selected text invisible. Changed `sidebarTextSelect` to `#FFFFFF` for high contrast.
