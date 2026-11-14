#!/usr/bin/env python3
"""Render the NeOS SDDM theme headless and write its preview image.

Loads profile/airootfs/usr/share/sddm/themes/neos/Main.qml unchanged, with
small stand-ins for the objects SDDM provides (`sddm`, `userModel`,
`sessionModel`, `config`), and grabs the result. The output is the theme's
`Screenshot=` image (metadata.desktop), shown in System Settings > Login Screen,
so it is always a real render of the current theme rather than a mock-up.

Needs PyQt6 (pip install PyQt6). Runs without a display:
    QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software tools/render-sddm-preview.py [out.png] [--full out-1920.png]
Exits non-zero if the QML fails to load, so it doubles as a parse check.
"""
import os
import sys
import time
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QUICK_BACKEND", "software")

from PyQt6.QtCore import QObject, QUrl, Qt, pyqtProperty, pyqtSignal, pyqtSlot
from PyQt6.QtGui import QGuiApplication, QStandardItem, QStandardItemModel
from PyQt6.QtQuick import QQuickView

ROOT = Path(__file__).resolve().parent.parent
THEME = ROOT / "profile/airootfs/usr/share/sddm/themes/neos"
WALLPAPER = ROOT / "profile/airootfs/usr/share/backgrounds/neos-wallpaper.png"


class Sddm(QObject):
    loginSucceeded = pyqtSignal()
    loginFailed = pyqtSignal()

    @pyqtProperty(bool, constant=True)
    def canSuspend(self):
        return True

    @pyqtProperty(bool, constant=True)
    def canReboot(self):
        return True

    @pyqtProperty(bool, constant=True)
    def canPowerOff(self):
        return True

    @pyqtSlot(str, str, int)
    def login(self, user, password, session):
        pass

    @pyqtSlot()
    def suspend(self):
        pass

    @pyqtSlot()
    def reboot(self):
        pass

    @pyqtSlot()
    def powerOff(self):
        pass


class Users(QObject):
    @pyqtProperty(str, constant=True)
    def lastUser(self):
        return ""


class Config(QObject):
    @pyqtProperty(str, constant=True)
    def background(self):
        return str(WALLPAPER)


class Sessions(QStandardItemModel):
    NAME = Qt.ItemDataRole.UserRole + 1

    def __init__(self):
        super().__init__()
        self.setItemRoleNames({self.NAME: b"name"})
        for name in ("Plasma (Wayland)", "Plasma (X11)"):
            item = QStandardItem()
            item.setData(name, self.NAME)
            self.appendRow(item)

    @pyqtProperty(int, constant=True)
    def lastIndex(self):
        return 0

    @pyqtProperty(int, constant=True)
    def count(self):
        return self.rowCount()


def main():
    args = sys.argv[1:]
    full = None
    if "--full" in args:
        i = args.index("--full")
        full = args[i + 1]
        del args[i:i + 2]
    out = args[0] if args else str(THEME / "preview.png")

    app = QGuiApplication(sys.argv[:1])
    view = QQuickView()
    # Parented to the application so they outlive the view during teardown.
    stubs = {"sddm": Sddm(app), "userModel": Users(app), "config": Config(app), "sessionModel": Sessions()}
    for name, obj in stubs.items():
        view.rootContext().setContextProperty(name, obj)
    view.setResizeMode(QQuickView.ResizeMode.SizeRootObjectToView)
    view.resize(1920, 1080)
    view.setSource(QUrl.fromLocalFile(str(THEME / "Main.qml")))
    if view.status() != QQuickView.Status.Ready:
        for err in view.errors():
            print(err.toString(), file=sys.stderr)
        sys.exit(1)
    view.show()
    # The wallpaper Image loads asynchronously; give it time to arrive.
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        app.processEvents()
        time.sleep(0.05)
    image = view.grabWindow()
    if full:
        image.save(full)
    image.scaled(640, 360, Qt.AspectRatioMode.KeepAspectRatio,
                 Qt.TransformationMode.SmoothTransformation).save(out)
    print(f"wrote {out}" + (f" and {full}" if full else ""))
    view.setSource(QUrl())


if __name__ == "__main__":
    main()
