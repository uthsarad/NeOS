#!/bin/bash
# ISO smoke test — boots the built image under QEMU and requires POSITIVE
# evidence that the live graphical session came up.
#
# Previously this test passed whenever QEMU merely survived its 90s timeout
# without a kernel panic: a black screen, a session dropped to a TTY, or a dead
# SDDM were all reported as success, and `-nographic` captured no guest output
# because the ISO's kernel command line had no serial console
# (reports/v2026.09.18 H4). The gate is now:
#
#   1. the guest's serial log must contain the marker emitted by
#      neos-boot-probe.service ("NEOS-BOOT-OK ... graphical.target active"),
#      which only runs once systemd reports graphical.target as active; and
#   2. a QEMU screendump taken after that marker must not be a blank frame
#      (corroboration; skipped with a warning if python3/QMP is unavailable).
#
# A panic/emergency/mount-failure boot is a hard failure, and a guest that dies
# or times out before the marker is a failure — never a "pass by timeout".
set -euo pipefail

OUT_DIR="out"
MARKER="NEOS-BOOT-OK"
# Seconds to wait for the marker. Without KVM the guest runs under QEMU's TCG
# interpreter, where bringing up a full Plasma live session takes several times
# longer than on hardware — so the default scales with the accelerator instead
# of reporting a slow-but-healthy boot as a dead one. Override explicitly with
# BOOT_TIMEOUT=<seconds> (e.g. on a very slow host or under CI load).
if [[ -z "${BOOT_TIMEOUT:-}" ]]; then
    if [[ -w /dev/kvm ]]; then
        BOOT_TIMEOUT=300
    else
        BOOT_TIMEOUT=900
    fi
fi
# Set ALLOW_BLANK_FRAME=1 only to debug a real session that genuinely renders
# an (almost) all-black frame; the marker assertion still applies.
ALLOW_BLANK_FRAME="${ALLOW_BLANK_FRAME:-0}"

skip() {
    echo -e "\n================================================================================"
    echo -e "[INFO] SKIPPED: $1"
    echo -e "   ISO smoke test bypassed gracefully as REQUIRE_ISO!=1."
    echo -e "================================================================================\n"
    exit 0
}

if [[ ! -d "$OUT_DIR" ]]; then
    if [[ "${REQUIRE_ISO:-0}" == "1" ]]; then
        echo "[FAIL] Missing output directory: $OUT_DIR"
        echo "Run: sudo ./build.sh"
        exit 1
    fi
    skip "Missing output directory: $OUT_DIR."
fi

shopt -s nullglob
files=("$OUT_DIR"/*.iso)
ISO_COUNT=${#files[@]}

if [[ "$ISO_COUNT" -eq 0 ]]; then
    if [[ "${REQUIRE_ISO:-0}" == "1" ]]; then
        echo "[FAIL] No ISO found in $OUT_DIR"
        echo "Run: sudo ./build.sh"
        exit 1
    fi
    skip "No ISO found in $OUT_DIR."
fi

echo "[PASS] Found $ISO_COUNT ISO file(s) in $OUT_DIR"

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    if [[ "${REQUIRE_ISO:-0}" == "1" ]]; then
        echo "[FAIL] qemu-system-x86_64 not found but REQUIRE_ISO=1 — boot verification cannot be skipped."
        exit 1
    fi
    skip "qemu-system-x86_64 not found. Cannot perform boot test."
fi

# Locate an OVMF firmware image so we can also exercise the UEFI/GRUB boot
# path (previously only the BIOS/syslinux path was ever tested). CI installs
# edk2-ovmf for this; a host without it skips the UEFI half with a notice.
OVMF=""
OVMF_VARS=""
for f in \
    /usr/share/edk2/x64/OVMF_CODE.4m.fd \
    /usr/share/edk2/x64/OVMF.4m.fd \
    /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
    /usr/share/OVMF/OVMF_CODE.fd \
    /usr/share/ovmf/x64/OVMF.fd; do
    if [[ -f "$f" ]]; then
        OVMF="$f"
        # A matching variable store, when the distribution ships one. OVMF's
        # flash driver expects pflash0 = code and pflash1 = vars; running with a
        # read-only code image and no varstore leaves the firmware without a
        # place to keep its variables, so supply a writable copy when we can.
        vars_candidate="${f/OVMF_CODE/OVMF_VARS}"
        if [[ -f "$vars_candidate" ]]; then
            OVMF_VARS="$vars_candidate"
        elif [[ -f "${f%/*}/OVMF_VARS.4m.fd" ]]; then
            OVMF_VARS="${f%/*}/OVMF_VARS.4m.fd"
        fi
        break
    fi
done

PPM_STATS_PY=$(mktemp /tmp/neos_ppm_stats.XXXXXX.py)
QMP_PY=$(mktemp /tmp/neos_qmp.XXXXXX.py)
cat > "$PPM_STATS_PY" <<'PY'
import sys
# Minimal P6 PPM reader: reports distinct colours and mean brightness so the
# caller can tell a rendered desktop from a blank frame without Pillow.
try:
    with open(sys.argv[1], 'rb') as fh:
        data = fh.read()
except OSError as exc:
    print("error: %s" % exc)
    sys.exit(0)
if not data.startswith(b'P6'):
    print("error: not a P6 PPM")
    sys.exit(0)
idx = 2
fields = []
while len(fields) < 3:
    while idx < len(data) and data[idx:idx + 1].isspace():
        idx += 1
    if idx < len(data) and data[idx:idx + 1] == b'#':
        while idx < len(data) and data[idx:idx + 1] != b'\n':
            idx += 1
        continue
    start = idx
    while idx < len(data) and not data[idx:idx + 1].isspace():
        idx += 1
    fields.append(data[start:idx])
idx += 1
w, h = int(fields[0]), int(fields[1])
pixels = data[idx:idx + w * h * 3]
if len(pixels) < w * h * 3 or w == 0 or h == 0:
    print("error: truncated pixel data")
    sys.exit(0)
total = w * h
bright = 0
colours = set()
step = max(1, total // 20000)  # sample large frames; full 1280x800 is fine too
sampled = 0
for p in range(0, total, step):
    r, g, b = pixels[3 * p], pixels[3 * p + 1], pixels[3 * p + 2]
    colours.add((r, g, b))
    if r + g + b > 30:
        bright += 1
    sampled += 1
print("size=%dx%d sampled=%d distinct=%d bright_ratio=%.4f"
      % (w, h, sampled, len(colours), bright / sampled))
PY

cat > "$QMP_PY" <<'PY'
import json, socket, sys, time
# Fire one QMP command over the unix socket and print the reply (best effort).
sock_path, cmd, arg = sys.argv[1], sys.argv[2], (sys.argv[3] if len(sys.argv) > 3 else None)
try:
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(20)
    s.connect(sock_path)
except OSError as exc:
    print("qmp-error: %s" % exc)
    sys.exit(0)
buf = b""
def recv_obj():
    global buf
    deadline = time.time() + 20
    while time.time() < deadline:
        try:
            chunk = s.recv(65536)
        except OSError:
            return None
        if not chunk:
            return None
        buf += chunk
        while b"\r\n" in buf:
            line, buf = buf.split(b"\r\n", 1)
            if not line.strip():
                continue
            try:
                return json.loads(line.decode())
            except ValueError:
                continue
    return None

recv_obj()  # greeting
s.sendall(json.dumps({"execute": "qmp_capabilities"}).encode() + b"\r\n")
recv_obj()
request = {"execute": cmd}
if arg:
    request["arguments"] = json.loads(arg)
s.sendall(json.dumps(request).encode() + b"\r\n")
reply = recv_obj()
print(json.dumps(reply) if reply is not None else "qmp-error: no reply")
s.close()
PY

cleanup() {
    [[ -n "${QEMU_PID:-}" ]] && kill "$QEMU_PID" 2>/dev/null || true
    rm -f "$PPM_STATS_PY" "$QMP_PY"
    rm -f "${QMP_SOCK:-}" 2>/dev/null || true
}
trap cleanup EXIT

boot_log_is_clean() {
    ! grep -qiE 'kernel panic|---\[ end Kernel panic|Entering emergency mode|Failed to mount|Cannot open root device|VFS: Unable to mount root' "$1"
}

run_boot() {
    local mode="$1"; shift
    local serial_log="$OUT_DIR/smoke_${mode}.log"
    local console_log="$OUT_DIR/smoke_${mode}.qemu.log"
    local shot="$OUT_DIR/smoke_${mode}.ppm"
    QMP_SOCK="$OUT_DIR/smoke_${mode}.qmp"

    echo "Starting QEMU $mode boot test for $name (timeout: ${BOOT_TIMEOUT}s, acceleration: ${KVM_LABEL:-tcg})..."
    rm -f "$serial_log" "$shot" "$QMP_SOCK"
    : > "$serial_log"

    # -display none keeps the guest VGA device (so screendump works) while
    # -serial file: captures the console the ISO's cmdline points at. KVM is
    # used only when the host actually exposes it — GitHub-hosted runners do
    # not, so CI boots under TCG emulation; BOOT_TIMEOUT above accounts for it.
    local KVM_ARGS=()
    local KVM_LABEL="tcg"
    if [[ -w /dev/kvm ]]; then
        KVM_ARGS=(-enable-kvm)
        KVM_LABEL="kvm"
    fi

    qemu-system-x86_64 \
        "${KVM_ARGS[@]+${KVM_ARGS[@]}}" \
        -display none \
        -m 2048 -no-reboot \
        -cdrom "$file" -boot d \
        -serial "file:$serial_log" \
        -monitor none \
        -qmp "unix:$QMP_SOCK,server,nowait" \
        "$@" < /dev/null > "$console_log" 2>&1 &
    QEMU_PID=$!

    local waited=0
    local marker_seen=0
    while (( waited < BOOT_TIMEOUT )); do
        if grep -q "$MARKER" "$serial_log" 2>/dev/null; then
            marker_seen=1
            break
        fi
        if ! kill -0 "$QEMU_PID" 2>/dev/null; then
            break
        fi
        sleep 5
        waited=$((waited + 5))
    done

    if ! boot_log_is_clean "$serial_log"; then
        echo "[FAIL] QEMU $mode boot test failed: boot error detected in the guest log."
        grep -iE 'kernel panic|emergency mode|Failed to mount|Unable to mount root' "$serial_log" | head -n 5
        kill "$QEMU_PID" 2>/dev/null || true
        exit 1
    fi

    if (( ! marker_seen )); then
        echo "[FAIL] QEMU $mode boot test failed: the live session never reported an active graphical.target"
        echo "       (waited ${waited}s for '$MARKER' from neos-boot-probe.service)."
        echo "       A boot that reaches no desktop is a failure — a timeout is not a pass."
        if [[ -s "$serial_log" ]]; then
            echo "       Last guest console output:"
            tail -n 20 "$serial_log" | sed 's/^/       | /'
        else
            echo "       The guest serial log is empty: check that the boot entry passes console=ttyS0."
        fi
        kill "$QEMU_PID" 2>/dev/null || true
        exit 1
    fi

    echo "  [PASS] $MARKER seen after ${waited}s — graphical.target reached."

    # Corroboration: the framebuffer must not be a blank frame.
    if kill -0 "$QEMU_PID" 2>/dev/null; then
        local dumped=0
        if command -v python3 >/dev/null 2>&1; then
            if python3 "$QMP_PY" "$QMP_SOCK" screendump \
                "{\"filename\":\"$shot\",\"format\":\"ppm\"}" >/dev/null 2>&1 && [[ -s "$shot" ]]; then
                dumped=1
            elif python3 "$QMP_PY" "$QMP_SOCK" screendump \
                "{\"filename\":\"$shot\"}" >/dev/null 2>&1 && [[ -s "$shot" ]]; then
                dumped=1
            fi
        fi

        if (( dumped )); then
            local stats
            stats=$(python3 "$PPM_STATS_PY" "$shot")
            echo "  [INFO] Framebuffer check: $stats"
            local distinct bright
            distinct=$(sed -n 's/.*distinct=\([0-9]*\).*/\1/p' <<<"$stats")
            bright=$(sed -n 's/.*bright_ratio=\([0-9.]*\).*/\1/p' <<<"$stats")
            if [[ -z "$distinct" ]]; then
                echo "  [WARN] Could not analyse $shot ($stats); skipping the blank-frame check."
            elif (( distinct < 24 )) || [[ "${bright:-0}" == "0.0000" ]]; then
                if [[ "$ALLOW_BLANK_FRAME" == "1" ]]; then
                    echo "  [WARN] Blank-looking frame (distinct=${distinct}, bright_ratio=${bright}) ignored (ALLOW_BLANK_FRAME=1)."
                else
                    echo "[FAIL] QEMU $mode boot test failed: the framebuffer is blank (distinct=${distinct}, bright_ratio=${bright})."
                    echo "       graphical.target was reached but nothing was rendered — see $shot."
                    kill "$QEMU_PID" 2>/dev/null || true
                    exit 1
                fi
            else
                echo "  [PASS] Framebuffer shows a rendered session (distinct=${distinct}, bright_ratio=${bright})."
            fi
        else
            echo "  [WARN] No framebuffer screenshot could be taken (python3/QMP unavailable); marker evidence only."
        fi
    fi

    kill "$QEMU_PID" 2>/dev/null || true
    wait "$QEMU_PID" 2>/dev/null || true
    QEMU_PID=""
}

for file in "${files[@]}"; do
    size=$(stat -c%s "$file")
    name="${file##*/}"
    echo "$name ($size bytes)"

    run_boot "bios"

    if [[ -n "$OVMF" ]]; then
        UEFI_DRIVES=(-drive "if=pflash,format=raw,readonly=on,file=$OVMF")
        if [[ -n "$OVMF_VARS" ]]; then
            # Never write to the system's varstore: boot a throwaway copy.
            cp "$OVMF_VARS" "$OUT_DIR/ovmf_vars.fd"
            UEFI_DRIVES+=(-drive "if=pflash,format=raw,file=$OUT_DIR/ovmf_vars.fd")
        fi
        run_boot "uefi" "${UEFI_DRIVES[@]}"
    elif [[ "${REQUIRE_ISO:-0}" == "1" ]]; then
        echo "[FAIL] REQUIRE_ISO=1 but no OVMF firmware found — the UEFI boot path cannot be verified."
        exit 1
    else
        echo "[INFO] SKIPPED: no OVMF firmware found; UEFI boot path not tested (install edk2-ovmf to cover it)."
    fi
done

echo "ISO smoke test passed."
