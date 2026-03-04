# PALETTE_REPORT

## UX Audit: CLI Output Clarity (neos-profile-audit)

**Date**: May 20, 2024
**Objective**: Enhance CLI tool error messages directly experienced by builders or contributors updating the NeOS installer profiles.

### Enhancements Made
1. **Empty `pacman_conf` string**: Error message updated from "pacman_conf is set to an empty string" to actively ask the user to provide a valid path.
2. **Missing `pacman_conf` target**: Added context on what value is broken ("The pacman config referenced...").
3. **Missing `DatabaseOptional`**: Rather than stating "does not use DatabaseOptional", the message actively guides the user: "Ensure 'SigLevel = ... DatabaseOptional' is set to allow building the ISO."
4. **Invalid Bootmodes Array**: The most visually significant change. Replaced a comma-separated single line of valid states with an indented, multi-line bullet list:
   * **Before**: `Invalid bootmode in profiledef.sh: 'foo'. Valid modes are: uefi.grub, uefi.systemd-boot, bios.syslinux...`
   * **After**:
     ```
     Invalid bootmode in profiledef.sh: 'foo'.
       Valid modes are:
         - uefi.grub
         - uefi.systemd-boot
         - bios.syslinux
     ```
5. **Missing `pacman_conf` property**: Added 'why' this matters. Now explicitly explains that mkarchiso requires it to build the image rather than throwing an obscure realpath error.
6. **Missing `bootmodes` array**: Instructs user to "Please define an array of valid bootmodes" instead of abruptly stating it's missing.

### Remaining Usability Risks
- If a user specifies a non-string bootmode format (e.g. integer 1) in their profile, bash handles the syntax but Rust string parsing will panic or silently bypass the regex logic. The tool currently expects valid bash string-array constructs.
- A user trying to set a valid environment variable reference (e.g. `pacman_conf="$HOME/pacman.conf"`) will fail file validation because the tool treats `$` strings literally. We may need macro expansion warnings if users mistakenly try this.
## UX Audit: Actionable CI Output Error Logs

**Date**: $(date +%B\ %d,\ %Y)
**Objective**: Guarantee that if the CI size check fails, the terminal output is highly actionable for developers (displaying current size, limit, and human-readable formats).

### Enhancements Made
1. **Human-Readable Sizes**: The ISO size validation step now calculates and displays both the current ISO size and the maximum size limit in MiB alongside bytes, making it significantly easier to parse.
2. **Actionable Remediation**: Replaced a generic failure message ("ISO exceeds GitHub release limit (2 GiB)!") with a structured, multi-line error. When the build fails, the CI logs now provide a `💡 How to reduce ISO size:` section with clear steps:
   - Reviewing `packages.x86_64`.
   - Utilizing `NoExtract` rules in `pacman.conf`.
   - Checking for large unintended assets in `airootfs/`.

### Remaining Usability Risks
- The byte to MiB conversion uses standard shell math via `awk`. While functional, very large precision differences could occur if the shell does not support the expected float formatting, but this is mitigated by Ubuntu's standard `awk`.
- The suggested remediation steps are static text; they don't dynamically check if `NoExtract` is actually missing or if `packages.x86_64` is the true source of bloat.
