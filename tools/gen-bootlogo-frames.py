#!/usr/bin/env python3
"""Generate the NeOS Plymouth boot-splash animation frames from a source GIF.

The boot splash is a Plymouth `script` theme (themes/neos/neos.script) that
cycles through cat-NN.png frames centered on a dark background — "plain": just
the animation, no extra wordmark or spinner ring.

CI never runs this (it builds the ISO with mkarchiso from checked-in files), so
the generated cat-*.png frames are COMMITTED. Re-run this only when the source
GIF changes:

    python3 tools/gen-bootlogo-frames.py

Source : tools/loader-cat.gif
Output : profile/airootfs/usr/share/plymouth/themes/neos/cat-NN.png
"""
from pathlib import Path
from PIL import Image

REPO = Path(__file__).resolve().parent.parent
SRC = REPO / "tools" / "loader-cat.gif"
DEST = REPO / "profile/airootfs/usr/share/plymouth/themes/neos"
SCALE = 2  # 280x200 -> 560x400, readable on a 1080p+ boot screen

def main() -> None:
    im = Image.open(SRC)
    n = im.n_frames
    w, h = im.size
    out_w, out_h = w * SCALE, h * SCALE
    DEST.mkdir(parents=True, exist_ok=True)
    for i in range(n):
        im.seek(i)
        # Sequential seek + RGBA convert lets Pillow apply GIF disposal so each
        # frame is the fully-composited image (transparent background preserved).
        frame = im.convert("RGBA").resize((out_w, out_h), Image.LANCZOS)
        frame.save(DEST / f"cat-{i:02d}.png")
    print(f"Wrote {n} frames ({out_w}x{out_h}) to {DEST}")

if __name__ == "__main__":
    main()
