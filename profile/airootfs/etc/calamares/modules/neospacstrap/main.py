#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# neospacstrap — Calamares Python job wrapping /usr/local/bin/neos-pacstrap.
#
# The old setup ran pacstrap via the 'shellprocess' module (see git history:
# etc/calamares/modules/pacstrap.conf), which has no progress-reporting hook
# at all (confirmed against Calamares' own ShellProcessJob.cpp — it only ever
# calls run() and returns the result, no setProgress calls anywhere). Since
# this is by far the slowest job in the exec sequence and every other job is
# weighted equally, the overall bar would sit dead at whatever fraction
# (finished-jobs / total-jobs) landed on right as pacstrap started — visually
# indistinguishable from a hang.
#
# Real installers don't treat "install packages" as one opaque blocking step:
# archinstall and pacman's own progress bar both read pacman's own line-based
# transaction output (which is stable and documented even when stdout isn't a
# TTY: pacman prints "(n/N) installing pkgname" once per package during the
# install phase). Ubuntu's curtin/subiquity openly document that some phases
# (bulk package unpack, rsync) simply don't have granular feedback either —
# so this only claims real numbers where pacman actually gives them: precise
# progress during the install phase, an honest "still downloading" status
# with no fabricated percentage during the download phase.
#
# All of the actual install logic (online/offline decision, retries, entropy
# handling, overlay copy) stays in neos-pacstrap unchanged — this module is
# an instrumentation wrapper around it, not a reimplementation.

import re
import subprocess
import threading

import libcalamares

import gettext
_ = gettext.translation("calamares-python",
                        localedir=libcalamares.utils.gettext_path(),
                        languages=libcalamares.utils.gettext_languages(),
                        fallback=True).gettext

TIMEOUT_SECONDS = 3600  # matches the old pacstrap.conf shellprocess timeout

# Non-TTY pacman prints one line per package like:
#   (12/340) installing linux-firmware                      [-----] 100%
# (the "[----] 100%" bar is TTY-only; the "(n/N) installing pkg" prefix is
# not — it's plain text either way.) Same line shape for upgrading/reinstalling.
_INSTALL_RE = re.compile(
    r"^\((\d+)/(\d+)\)\s+(installing|upgrading|reinstalling)\s+(\S+)"
)

status = _("📦 Preparing to install packages…")


def pretty_name():
    return _("📦 Installing base system (pacstrap)")


def pretty_status_message():
    return status


def run():
    """Run neos-pacstrap against the target root, translating its output
    into Calamares job progress instead of blocking silently."""
    global status

    root = libcalamares.globalstorage.value("rootMountPoint")
    if not root:
        return (_("rootMountPoint is not set"),
                _("neospacstrap must run after the mount job."))

    libcalamares.job.setprogress(0.0)
    status = _("⬇️ Downloading packages…")

    proc = subprocess.Popen(
        ["/usr/local/bin/neos-pacstrap", root],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

    # A wall-clock watchdog, not a per-line check: neos-pacstrap can go quiet
    # for a while with no output (e.g. blocked in pacman-key/gpg entropy
    # generation) and a check that only runs when a line arrives would never
    # fire during exactly that silence — the one case this timeout most needs
    # to cover. Timer fires independently of whether any output is flowing.
    timed_out = threading.Event()

    def _on_timeout():
        timed_out.set()
        proc.kill()

    watchdog = threading.Timer(TIMEOUT_SECONDS, _on_timeout)
    watchdog.start()

    output_lines = []
    seen_install_phase = False

    try:
        assert proc.stdout is not None
        for line in proc.stdout:
            line = line.rstrip("\n")
            output_lines.append(line)
            libcalamares.utils.debug(f"neos-pacstrap: {line}")

            match = _INSTALL_RE.match(line)
            if match:
                n, total, _verb, pkg = match.groups()
                n, total = int(n), int(total)
                seen_install_phase = True
                status = _("⚙️ Installing {pkg} ({n}/{total})…").format(
                    pkg=pkg, n=n, total=total)
                if total > 0:
                    libcalamares.job.setprogress(0.05 + 0.95 * (n / total))
            elif not seen_install_phase:
                # Still in the download phase, which pacman does not expose a
                # reliable non-TTY percentage for — nudge the bar off zero so
                # it doesn't look identical to "not started" and keep the
                # status text moving so the UI clearly isn't frozen.
                status = _("Downloading packages…")
                libcalamares.job.setprogress(0.02)

        returncode = proc.wait()
    finally:
        watchdog.cancel()

    if timed_out.is_set():
        return (_("⏱️ Installation timed out"),
                _("neos-pacstrap did not finish within {timeout} seconds.")
                .format(timeout=TIMEOUT_SECONDS))

    if returncode != 0:
        tail = "\n".join(output_lines[-40:])
        return (_("❌ Base system installation failed (exit {code})")
                .format(code=returncode), tail)

    libcalamares.job.setprogress(1.0)
    status = _("✅ Base system installed.")
    return None
