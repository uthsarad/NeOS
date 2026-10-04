#!/usr/bin/env python3
"""Render the Calamares installer slideshow headless, one image per slide.

Loads profile/airootfs/etc/calamares/branding/neos/show.qml unchanged against a
stand-in `Calamares 1.0` module (Presentation is just an Item here), advances
through every slide and saves each frame. Use it to review slideshow changes
without booting the ISO. Exits non-zero if the QML fails to load, so it doubles
as a parse check.

Needs PyQt6:  tools/render-installer-slides.py [out-dir]
"""
import os
import sys
import tempfile
import time
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
os.environ.setdefault("QT_QUICK_BACKEND", "software")

from PyQt6.QtCore import QMetaObject, QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQuick import QQuickView

ROOT = Path(__file__).resolve().parent.parent
SHOW = ROOT / "profile/airootfs/etc/calamares/branding/neos/show.qml"


def settle(app, seconds):
    end = time.monotonic() + seconds
    while time.monotonic() < end:
        app.processEvents()
        time.sleep(0.02)


def main():
    out_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("slides")
    out_dir.mkdir(parents=True, exist_ok=True)
    stub = Path(tempfile.mkdtemp()) / "Calamares"
    stub.mkdir()
    (stub / "qmldir").write_text("module Calamares\nPresentation 1.0 Presentation.qml\n")
    (stub / "Presentation.qml").write_text("import QtQuick 2.15\nItem { }\n")

    app = QGuiApplication(sys.argv[:1])
    view = QQuickView()
    view.engine().addImportPath(str(stub.parent))
    view.setSource(QUrl.fromLocalFile(str(SHOW)))
    if view.status() != QQuickView.Status.Ready:
        for err in view.errors():
            print(err.toString(), file=sys.stderr)
        sys.exit(1)
    view.show()
    root = view.rootObject()
    total = int(root.property("totalSlides"))
    for i in range(total):
        settle(app, 1.0)  # past the 600 ms crossfade
        path = out_dir / f"slide-{i + 1}.png"
        view.grabWindow().save(str(path))
        print(f"wrote {path}")
        QMetaObject.invokeMethod(root, "advance")
    view.setSource(QUrl())


if __name__ == "__main__":
    main()
