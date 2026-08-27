#!/usr/bin/env python3
"""neospacstrap — Calamares job wrapping /usr/local/bin/neos-pacstrap.

Replaces the old shellprocess@pacstrap step. shellprocess can only report
"job running" for the whole duration of a single shell command — it has no
way to move the progress bar while that command runs. Since neos-pacstrap's
actual install (pacstrap -K on ~165 packages) can take many minutes, the
Calamares progress bar sat frozen at whatever percentage the sequence had
reached when the step started (2 of ~20 equal-weighted steps in = 10%) for
the entire download+install phase, looking like the installer had hung.

This module runs the same neos-pacstrap script as a subprocess and
concurrently tails the target's pacman.log, counting "[ALPM] installed"
lines against the known package total to report real fractional progress
via libcalamares.job.setprogress() — the same technique Calamares' own
upstream 'packages' module uses for pacman installs.
"""

import os
import subprocess
import threading

import libcalamares

NEOS_PACSTRAP = "/usr/local/bin/neos-pacstrap"
PACKAGE_LIST = "/etc/calamares/neos-packages.txt"
TIMEOUT_SECONDS = 3600

_status_message = "Preparing package installation…"


def pretty_status_message():
    return _status_message


def _total_package_count():
    try:
        with open(PACKAGE_LIST, "r") as f:
            return sum(
                1 for line in f
                if line.strip() and not line.strip().startswith("#")
            )
    except OSError:
        return 0


def _count_installed(log_path):
    try:
        with open(log_path, "r", errors="replace") as f:
            return sum(1 for line in f if "[ALPM] installed " in line)
    except OSError:
        return 0


def _watch_progress(root, total, stop_event):
    global _status_message
    log_path = os.path.join(root, "var/log/pacman.log")
    while not stop_event.is_set():
        installed = _count_installed(log_path)
        if total > 0:
            fraction = min(installed / total, 0.99)
            _status_message = "Installing packages ({} / {})".format(
                installed, total
            )
            libcalamares.job.setprogress(fraction)
        stop_event.wait(1.5)


def _kill_on_timeout(proc, timeout, stop_event):
    if not stop_event.wait(timeout):
        if proc.poll() is None:
            libcalamares.utils.debug(
                "neos-pacstrap: timed out after {}s, killing".format(timeout)
            )
            proc.kill()


def run():
    global _status_message

    root = libcalamares.globalstorage.value("rootMountPoint")
    if not root:
        return (
            "Internal error",
            "No target root mount point was set before the pacstrap step.",
        )

    total = _total_package_count()

    _status_message = "Preparing package installation…"
    libcalamares.job.setprogress(0.0)

    proc = subprocess.Popen(
        [NEOS_PACSTRAP, root],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        universal_newlines=True,
        bufsize=1,
    )

    stop_event = threading.Event()
    watcher = threading.Thread(
        target=_watch_progress, args=(root, total, stop_event), daemon=True
    )
    watcher.start()
    killer = threading.Thread(
        target=_kill_on_timeout,
        args=(proc, TIMEOUT_SECONDS, stop_event),
        daemon=True,
    )
    killer.start()

    output_tail = []
    for line in proc.stdout:
        line = line.rstrip("\n")
        libcalamares.utils.debug("neos-pacstrap: " + line)
        output_tail.append(line)
        if len(output_tail) > 60:
            output_tail.pop(0)

    returncode = proc.wait()
    stop_event.set()
    watcher.join(timeout=5)

    if returncode != 0:
        return (
            "Installation failed",
            "neos-pacstrap exited with status {}.\n\n{}".format(
                returncode, "\n".join(output_tail[-25:])
            ),
        )

    libcalamares.job.setprogress(1.0)
    return None
