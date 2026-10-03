#!/usr/bin/env python3
"""Render the NeOS logo from its SVG source.

Source of truth: tools/brand/neos-logo.svg, the mark used on the NeOS website
(uthsarad/NeOSweb, public/assets/favicon.svg): a hexagon outline around a dot
on a dark rounded square, in the site's Tokyo Night colours. Change the logo
there and copy it here; this script only rasterises it.

Usage: tools/gen-logo.py [output.png] [--size WxH]
       tools/gen-logo.py --all     regenerate every shipped copy of the logo:
                                   the Calamares branding logo, docs/assets,
                                   the Plymouth splash, and the `neos-logo`
                                   icon set (hicolor PNGs + scalable SVG +
                                   pixmaps) that /etc/os-release LOGO= names

Needs PyQt6 (QtSvg) and Pillow.
"""
import os
import shutil
import sys
from pathlib import Path

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")

from PIL import Image
from PyQt6.QtCore import QBuffer, QByteArray, QIODevice, Qt
from PyQt6.QtGui import QGuiApplication, QImage, QPainter
from PyQt6.QtSvg import QSvgRenderer

ROOT = Path(__file__).resolve().parent.parent
SVG = ROOT / "tools/brand/neos-logo.svg"
_app = None


def render(size):
    """Return the logo as a Pillow RGBA image of `size` (w, h)."""
    global _app
    if _app is None:
        _app = QGuiApplication.instance() or QGuiApplication(sys.argv[:1])
    w, h = size
    image = QImage(w, h, QImage.Format.Format_ARGB32)
    image.fill(Qt.GlobalColor.transparent)
    painter = QPainter(image)
    painter.setRenderHint(QPainter.RenderHint.Antialiasing)
    QSvgRenderer(str(SVG)).render(painter)
    painter.end()
    data = QByteArray()
    buf = QBuffer(data)
    buf.open(QIODevice.OpenModeFlag.WriteOnly)
    image.save(buf, "PNG")
    buf.close()
    from io import BytesIO
    return Image.open(BytesIO(bytes(data))).convert("RGBA")


def save(img, out):
    out = ROOT / out
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out, "PNG", optimize=True)
    print(f"wrote {out.relative_to(ROOT)} ({img.width}x{img.height})")


def main(argv):
    if "--all" in argv:
        save(render((256, 256)), "profile/airootfs/etc/calamares/branding/neos/logo.png")
        save(render((256, 256)), "docs/assets/neos-logo.png")
        save(render((128, 128)), "profile/airootfs/usr/share/plymouth/themes/neos/logo.png")
        save(render((256, 256)), "profile/airootfs/usr/share/pixmaps/neos-logo.png")
        for px in (16, 22, 24, 32, 48, 64, 128, 256, 512):
            save(render((px, px)), f"profile/airootfs/usr/share/icons/hicolor/{px}x{px}/apps/neos-logo.png")
        scalable = ROOT / "profile/airootfs/usr/share/icons/hicolor/scalable/apps/neos-logo.svg"
        scalable.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(SVG, scalable)
        print(f"wrote {scalable.relative_to(ROOT)}")
        return
    out = "profile/airootfs/etc/calamares/branding/neos/logo.png"
    size = (256, 256)
    for arg in argv:
        if arg.startswith("--size"):
            w, h = arg.split("=", 1)[1].split("x")
            size = (int(w), int(h))
        else:
            out = arg
    save(render(size), out)


if __name__ == "__main__":
    main(sys.argv[1:])
