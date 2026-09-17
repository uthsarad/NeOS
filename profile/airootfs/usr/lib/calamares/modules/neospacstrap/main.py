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

# Pacman non-TTY download output prints "downloading <pkgname>..."
_DOWNLOAD_RE = re.compile(
    r"^(?:downloading\s+(\S+?)(?:\.\.\.|\s|$)|::\s+(?:Retrieving packages|downloading\s+(\S+)))",
    re.IGNORECASE
)
_TOTAL_PKGS_RE = re.compile(r"downloading latest (\d+) packages|installing (\d+) packages")
_OVERLAY_RE = re.compile(r"applying NeOS overlay", re.IGNORECASE)
_RETRY_RE = re.compile(r"pacstrap attempt (\d+)/(\d+)", re.IGNORECASE)

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
    download_count = 0
    estimated_total = 178

    try:
        assert proc.stdout is not None
        for line in proc.stdout:
            line = line.rstrip("\n")
            output_lines.append(line)
            libcalamares.utils.debug(f"neos-pacstrap: {line}")

            total_match = _TOTAL_PKGS_RE.search(line)
            if total_match:
                found_total = total_match.group(1) or total_match.group(2)
                if found_total:
                    estimated_total = int(found_total)

            retry_match = _RETRY_RE.search(line)
            if retry_match:
                cur_attempt, max_attempts = retry_match.groups()
                status = _("🔁 Mirror retry ({cur}/{max})…").format(
                    cur=cur_attempt, max=max_attempts)

            install_match = _INSTALL_RE.match(line)
            if install_match:
                n, total, _verb, pkg = install_match.groups()
                n, total = int(n), int(total)
                seen_install_phase = True
                status = _("⚙️ Installing {pkg} ({n}/{total})…").format(
                    pkg=pkg, n=n, total=total)
                if total > 0:
                    # Allocate 0.45 to 0.95 for package unpacking/installation
                    libcalamares.job.setprogress(0.45 + 0.50 * (n / total))
                continue

            if _OVERLAY_RE.search(line):
                status = _("🎨 Applying NeOS desktop configuration & branding…")
                libcalamares.job.setprogress(0.97)
                continue

            download_match = _DOWNLOAD_RE.match(line)
            if download_match and not seen_install_phase:
                download_count += 1
                pkg_raw = download_match.group(1) or download_match.group(2) or ""
                # Strip archive extension and architecture if present
                pkg_clean = re.sub(r"-(?:\d.*|\.pkg\.tar\..*)$", "", pkg_raw)
                pkg_clean = pkg_clean.strip()
                if pkg_clean:
                    status = _("⬇️ Downloading {pkg} ({cur}/{total})…").format(
                        pkg=pkg_clean, cur=download_count, total=estimated_total)
                else:
                    status = _("⬇️ Downloading packages ({cur}/{total})…").format(
                        cur=download_count, total=estimated_total)
                download_frac = min(1.0, download_count / max(estimated_total, 1))
                # Allocate 0.05 to 0.45 for downloading packages
                libcalamares.job.setprogress(0.05 + 0.40 * download_frac)
            elif not seen_install_phase and download_count == 0:
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

