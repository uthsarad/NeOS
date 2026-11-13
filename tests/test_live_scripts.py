"""Unit tests for live ISO scripts and Calamares modules (neos-welcome-app, neospacstrap)."""

import importlib.machinery
import importlib.util
import os
import sys
import tempfile
import types
import unittest
from pathlib import Path
from unittest.mock import mock_open, patch

ROOT = Path(__file__).resolve().parents[1]
WELCOME_APP_PATH = ROOT / "profile/airootfs/usr/local/bin/neos-welcome-app"
PACSTRAP_MODULE_PATH = (
    ROOT / "profile/airootfs/usr/lib/calamares/modules/neospacstrap/main.py"
)


def load_welcome_module():
    """Load neos-welcome-app with PyQt6 stubbed out so tests run in headless/CI environments."""
    for m in ["PyQt6", "PyQt6.QtWidgets", "PyQt6.QtCore", "PyQt6.QtGui"]:
        if m not in sys.modules:
            sys.modules[m] = types.ModuleType(m)

    widgets = [
        "QWidget",
        "QVBoxLayout",
        "QHBoxLayout",
        "QPushButton",
        "QLabel",
        "QGraphicsDropShadowEffect",
        "QFrame",
        "QMessageBox",
        "QApplication",
    ]
    for w in widgets:
        if not hasattr(sys.modules["PyQt6.QtWidgets"], w):
            setattr(
                sys.modules["PyQt6.QtWidgets"],
                w,
                type(w, (), {"__init__": lambda self, *a, **k: None}),
            )

    if not hasattr(sys.modules["PyQt6.QtCore"], "Qt"):
        sys.modules["PyQt6.QtCore"].Qt = type(
            "Qt",
            (),
            {
                "AlignmentFlag": type("AlignmentFlag", (), {"AlignCenter": 0}),
                "CursorShape": type("CursorShape", (), {"PointingHandCursor": 0}),
            },
        )
    if not hasattr(sys.modules["PyQt6.QtCore"], "QProcess"):
        sys.modules["PyQt6.QtCore"].QProcess = type("QProcess", (), {})
    if not hasattr(sys.modules["PyQt6.QtGui"], "QColor"):
        sys.modules["PyQt6.QtGui"].QColor = type(
            "QColor", (), {"__init__": lambda self, *a, **k: None}
        )

    loader = importlib.machinery.SourceFileLoader(
        "welcome_test_mod", str(WELCOME_APP_PATH)
    )
    mod = types.ModuleType("welcome_test_mod")
    loader.exec_module(mod)
    return mod


def load_neospacstrap_module():
    """Load neospacstrap/main.py with mock libcalamares."""
    mock_lib = types.ModuleType("libcalamares")
    mock_lib.utils = types.ModuleType("utils")
    mock_lib.utils.gettext_path = lambda: ""
    mock_lib.utils.gettext_languages = lambda: []
    mock_lib.globalstorage = types.ModuleType("globalstorage")
    mock_lib.globalstorage.value = lambda key: None
    mock_lib.job = types.ModuleType("job")
    mock_lib.job.setprogress = lambda p: None

    sys.modules["libcalamares"] = mock_lib
    sys.modules["libcalamares.utils"] = mock_lib.utils

    loader = importlib.machinery.SourceFileLoader(
        "neospacstrap_test_mod", str(PACSTRAP_MODULE_PATH)
    )
    mod = types.ModuleType("neospacstrap_test_mod")
    loader.exec_module(mod)
    return mod


welcome_mod = load_welcome_module()
pacstrap_mod = load_neospacstrap_module()


class TestNeosWelcomeApp(unittest.TestCase):
    """Test environment detection and version resolution in neos-welcome-app."""

    def test_is_live_mode_archiso_bootmnt(self):
        with patch("os.path.exists") as mock_exists, patch.dict(os.environ, {}, clear=True):
            mock_exists.side_effect = lambda p: p == "/run/archiso/bootmnt"
            self.assertTrue(welcome_mod.is_live_mode())

    def test_is_live_mode_archiso_dir(self):
        with patch("os.path.exists") as mock_exists, patch.dict(os.environ, {}, clear=True):
            mock_exists.side_effect = lambda p: p == "/run/archiso"
            self.assertTrue(welcome_mod.is_live_mode())

    def test_is_live_mode_user_liveuser(self):
        with patch("os.path.exists", return_value=False), patch.dict(
            os.environ, {"USER": "liveuser"}
        ):
            self.assertTrue(welcome_mod.is_live_mode())

    def test_is_live_mode_installed(self):
        with patch("os.path.exists", return_value=False), patch.dict(
            os.environ, {"USER": "regularuser"}
        ):
            self.assertFalse(welcome_mod.is_live_mode())

    def test_get_os_version_version_id_quoted(self):
        os_release = 'NAME="NeOS"\nVERSION_ID="2026.11.12"\nPRETTY_NAME="NeOS 2026.11.12"\n'
        with patch("os.path.exists", return_value=True), patch(
            "builtins.open", mock_open(read_data=os_release)
        ):
            version = welcome_mod.get_os_version()
            self.assertEqual(version, "v2026.11.12")

    def test_get_os_version_unquoted(self):
        os_release = "NAME=NeOS\nVERSION_ID=2026.11.01\n"
        with patch("os.path.exists", return_value=True), patch(
            "builtins.open", mock_open(read_data=os_release)
        ):
            version = welcome_mod.get_os_version()
            self.assertEqual(version, "v2026.11.01")

    def test_get_os_version_fallback_pretty_name(self):
        os_release = 'NAME="NeOS"\nPRETTY_NAME="NeOS Rolling"\n'
        with patch("os.path.exists", return_value=True), patch(
            "builtins.open", mock_open(read_data=os_release)
        ):
            version = welcome_mod.get_os_version()
            self.assertEqual(version, "NeOS Rolling")

    def test_get_os_version_missing_file(self):
        with patch("os.path.exists", return_value=False):
            version = welcome_mod.get_os_version()
            self.assertEqual(version, "NeOS")


class TestNeospacstrapModule(unittest.TestCase):
    """Test regex pattern parsing and error handling in neospacstrap/main.py."""

    def test_install_regex_variants(self):
        # Installing
        m = pacstrap_mod._INSTALL_RE.match("(1/340) installing linux-firmware")
        self.assertIsNotNone(m)
        self.assertEqual(m.groups(), ("1", "340", "installing", "linux-firmware"))

        # Upgrading
        m = pacstrap_mod._INSTALL_RE.match("(42/100) upgrading glibc")
        self.assertIsNotNone(m)
        self.assertEqual(m.groups(), ("42", "100", "upgrading", "glibc"))

        # Reinstalling
        m = pacstrap_mod._INSTALL_RE.match("(99/99) reinstalling systemd")
        self.assertIsNotNone(m)
        self.assertEqual(m.groups(), ("99", "99", "reinstalling", "systemd"))

        # Non-matching lines
        self.assertIsNone(pacstrap_mod._INSTALL_RE.match(":: Proceed with installation? [Y/n]"))
        self.assertIsNone(pacstrap_mod._INSTALL_RE.match("(1/1) checking keys in keyring"))

    def test_download_regex_variants(self):
        # Pacman 6/7 non-TTY format: "<filename> downloading..."
        m = pacstrap_mod._DOWNLOAD_RE.match(" linux-firmware-20260916-1-any downloading...")
        self.assertIsNotNone(m)
        self.assertEqual(m.group(1), "linux-firmware-20260916-1-any")

        # Older pacman format: "downloading <file>..."
        m = pacstrap_mod._DOWNLOAD_RE.match("downloading linux-firmware...")
        self.assertIsNotNone(m)
        self.assertEqual(m.group(2), "linux-firmware")

    def test_total_pkgs_regex(self):
        m = pacstrap_mod._TOTAL_PKGS_RE.match("Packages (1042)")
        self.assertIsNotNone(m)
        self.assertEqual(m.group(1), "1042")

        m = pacstrap_mod._TOTAL_PKGS_RE.match("installing 50 packages")
        self.assertIsNotNone(m)
        self.assertEqual(m.group(2), "50")

    def test_overlay_and_retry_regex(self):
        self.assertTrue(pacstrap_mod._OVERLAY_RE.search("==> applying NeOS overlay to /mnt"))
        m = pacstrap_mod._RETRY_RE.search("pacstrap attempt 2/3")
        self.assertIsNotNone(m)
        self.assertEqual(m.groups(), ("2", "3"))

    def test_run_fails_when_root_mount_point_missing(self):
        with patch.object(sys.modules["libcalamares"].globalstorage, "value", return_value=""):
            res = pacstrap_mod.run()
            self.assertIsInstance(res, tuple)
            self.assertEqual(len(res), 2)
            self.assertIn("rootMountPoint is not set", res[0])

    def test_pretty_name_and_status(self):
        self.assertEqual(pacstrap_mod.pretty_name(), "Installing the base system")
        self.assertIsInstance(pacstrap_mod.pretty_status_message(), str)


if __name__ == "__main__":
    unittest.main()

