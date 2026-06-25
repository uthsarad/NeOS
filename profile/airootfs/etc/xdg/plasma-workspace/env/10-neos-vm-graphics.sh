#!/bin/sh
# Sourced by startplasma (X11 and Wayland) BEFORE KWin and plasmashell launch.
# This is the canonical, reliable place to set Plasma session environment — more
# dependable than /etc/environment, which relies on PAM reading it during
# autologin.
#
# In virtual machines without working hardware OpenGL (e.g. VMware with
# "Accelerate 3D graphics" disabled), KWin's GL compositor fails to start. That
# leaves a black desktop with only an unmanaged top-level window visible (the
# welcome dialog) whose buttons don't respond, because no window manager is
# routing input. Forcing Mesa's llvmpipe software renderer and the software Qt
# Quick backend lets KWin and plasmashell come up so the desktop actually works.
# Bare metal is left untouched on hardware OpenGL.
if [ "$(systemd-detect-virt 2>/dev/null || echo none)" != "none" ]; then
    # Software OpenGL + software Qt Quick for anything that still uses GL/QML.
    export LIBGL_ALWAYS_SOFTWARE=1
    export QT_QUICK_BACKEND=software

    # Belt-and-suspenders, and the real fix for VMware: forcing llvmpipe is not
    # enough when the guest has no usable GLX at all — KWin's GL compositor
    # crashes before it starts, leaving a black desktop with an unmanaged
    # window whose buttons don't respond. Disable KWin compositing so it runs
    # as a plain, GL-free window manager: windows are managed and clickable,
    # and plasmashell still paints the panel/wallpaper via the software Qt Quick
    # backend. Written per-user before KWin reads it; only in VMs, so bare metal
    # keeps full hardware compositing.
    kwinrc="${XDG_CONFIG_HOME:-$HOME/.config}/kwinrc"
    if ! grep -q '^\[Compositing\]' "$kwinrc" 2>/dev/null; then
        mkdir -p "$(dirname "$kwinrc")"
        printf '\n[Compositing]\nEnabled=false\n' >> "$kwinrc"
    fi
fi
