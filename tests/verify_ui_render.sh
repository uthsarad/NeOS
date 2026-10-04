#!/bin/bash
# Render the user-facing Qt surfaces headless (reports/v2026.10.03 Q4):
#   - SDDM login theme      (tools/render-sddm-preview.py, real Main.qml)
#   - installer slideshow   (tools/render-installer-slides.py, real show.qml)
#   - welcome app           (live and installed layouts)
# A QML error or JavaScript exception fails the gate. It also checks the
# slideshow really changes slides: a QML binding bug once kept slide 1 on
# screen for the whole install. Needs PyQt6 with QtQuick (Arch:
# python-pyqt6 + qt6-declarative); CI installs them and sets REQUIRE_TOOLS=1.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! python3 -c 'import PyQt6.QtQuick, PyQt6.QtWidgets' >/dev/null 2>&1; then
    if [[ "${REQUIRE_TOOLS:-0}" == "1" ]]; then
        echo "[FAIL] PyQt6 with QtQuick is required (REQUIRE_TOOLS=1)"
        exit 1
    fi
    echo "[WARN] PyQt6/QtQuick not installed — skipping UI render checks (pip install PyQt6)."
    exit 0
fi

export QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software PYTHONDONTWRITEBYTECODE=1
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT
FAIL=0

check() {  # name, log file, command...
    local name="$1" log="$2"
    shift 2
    if ! "$@" >"$log" 2>&1; then
        echo "[FAIL] $name failed to render:"
        sed 's/^/     /' "$log"
        FAIL=1
    elif grep -qE 'TypeError|ReferenceError|SyntaxError|is not defined|Cannot assign|Traceback' "$log"; then
        echo "[FAIL] $name rendered with errors:"
        grep -E 'TypeError|ReferenceError|SyntaxError|is not defined|Cannot assign|Traceback' "$log" | sed 's/^/     /'
        FAIL=1
    else
        echo "  [PASS] $name"
    fi
}

check "SDDM login theme" "$OUT/sddm.log" python3 tools/render-sddm-preview.py "$OUT/sddm.png"
check "installer slideshow" "$OUT/slides.log" python3 tools/render-installer-slides.py "$OUT/slides"

if compgen -G "$OUT/slides/slide-*.png" >/dev/null; then
    # Compare only the content area: the page dots and the Next button at the
    # bottom change on every slide even when the content itself is stuck.
    distinct="$(python3 - "$OUT/slides" <<'PY'
import hashlib, pathlib, sys
from PyQt6.QtGui import QImage
digests = set()
for path in pathlib.Path(sys.argv[1]).glob("slide-*.png"):
    img = QImage(str(path))
    content = img.copy(0, 0, img.width(), int(img.height() * 0.85))
    ptr = content.constBits()
    ptr.setsize(content.sizeInBytes())
    digests.add(hashlib.sha256(bytes(ptr)).hexdigest())
print(len(digests))
PY
)"
    total="$(find "$OUT/slides" -name 'slide-*.png' | wc -l)"
    if [[ "$distinct" -eq "$total" ]]; then
        echo "  [PASS] all $total slides render differently (the slideshow advances)"
    else
        echo "[FAIL] only $distinct of $total slides differ: the slideshow is not changing slides"
        FAIL=1
    fi
fi

cat > "$OUT/welcome.py" <<'PY'
import runpy, sys
from PyQt6.QtWidgets import QApplication
app = QApplication(sys.argv[:1])
ns = runpy.run_path("profile/airootfs/usr/local/bin/neos-welcome-app", run_name="welcome_render_check")
window = ns["NeosWelcome"]()
window.show()
app.processEvents()
window.grab().save(sys.argv[1])
PY
check "welcome app (installed layout)" "$OUT/welcome.log" env USER=checker python3 "$OUT/welcome.py" "$OUT/welcome.png"
check "welcome app (live layout)" "$OUT/welcome-live.log" env USER=liveuser python3 "$OUT/welcome.py" "$OUT/welcome-live.png"

if (( FAIL )); then
    echo "[FAIL] UI render verification failed."
    exit 1
fi
echo "[PASS] UI surfaces render cleanly."
