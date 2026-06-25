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
    export LIBGL_ALWAYS_SOFTWARE=1
    export QT_QUICK_BACKEND=software
fi
