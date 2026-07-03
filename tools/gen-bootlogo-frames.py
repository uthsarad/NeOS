#!/usr/bin/env python3
"""Generate the NeOS Plymouth boot-splash animation frames from a source GIF.

The boot splash is a Plymouth `script` theme (themes/neos/neos.script) that
cycles through cat-NN.png frames centered on a dark background — "plain": just
the animation, no extra wordmark or spinner ring.

CI never runs this (it builds the ISO with mkarchiso from checked-in files), so
the generated cat-*.png frames are COMMITTED. The source GIF has repeated still
frames at the end; those are trimmed so Plymouth loops without a visible pause.
Re-run this only when the source GIF changes:

    python3 tools/gen-bootlogo-frames.py

Source : tools/loader-cat.gif
Output : profile/airootfs/usr/share/plymouth/themes/neos/cat-NN.png
"""
from pathlib import Path
from PIL import Image, ImageChops

REPO = Path(__file__).resolve().parent.parent
SRC = REPO / "tools" / "loader-cat.gif"
DEST = REPO / "profile/airootfs/usr/share/plymouth/themes/neos"
SCALE = 2  # source cels are drawn small; 2x keeps them readable on a 1080p+ boot screen
MARGIN = 20  # transparent breathing room around the animation on the output canvas

def same_image(a: Image.Image, b: Image.Image) -> bool:
    return ImageChops.difference(a, b).getbbox() is None

def main() -> None:
    im = Image.open(SRC)
    n = im.n_frames
    DEST.mkdir(parents=True, exist_ok=True)

    # Pass 1: composite + crop each frame to its opaque content. The source GIF
    # anchors the cat in the top-left of its canvas, so resizing the raw canvas
    # would leave the cat off-centre and wobbling as its content size changes
    # frame to frame. Cropping to the visible pixels lets us re-centre it.
    cels = []
    for i in range(n):
        im.seek(i)
        # Sequential seek + RGBA convert lets Pillow apply GIF disposal so each
        # frame is the fully-composited image (transparent background preserved).
        frame = im.convert("RGBA")
        bbox = frame.getbbox()  # smallest box enclosing non-transparent pixels
        cels.append(frame.crop(bbox) if bbox else frame)

    # Keep the first final pose, but remove extra identical copies that make
    # the boot animation appear to freeze before the loop restarts.
    while len(cels) > 1 and same_image(cels[-1], cels[-2]):
        cels.pop()

    # A single canvas sized to the largest cel keeps every output frame the same
    # dimensions, so neos.script centres them identically — the cat stays put.
    out_w = max(c.width for c in cels) * SCALE + 2 * MARGIN
    out_h = max(c.height for c in cels) * SCALE + 2 * MARGIN

    # Pass 2: scale each cel and paste it centred on the shared canvas.
    for stale in DEST.glob("cat-*.png"):
        stale.unlink()

    for i, cel in enumerate(cels):
        cel = cel.resize((cel.width * SCALE, cel.height * SCALE), Image.LANCZOS)
        canvas = Image.new("RGBA", (out_w, out_h), (0, 0, 0, 0))
        canvas.paste(cel, ((out_w - cel.width) // 2, (out_h - cel.height) // 2), cel)
        canvas.save(DEST / f"cat-{i:02d}.png")
    print(f"Wrote {len(cels)} centred frames ({out_w}x{out_h}) to {DEST}")

if __name__ == "__main__":
    main()
