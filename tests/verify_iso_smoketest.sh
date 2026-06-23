#!/bin/bash
set -e

OUT_DIR="out"

if [[ ! -d "$OUT_DIR" ]]; then
    if [[ "${REQUIRE_ISO:-0}" == "1" ]]; then
        echo "❌ Missing output directory: $OUT_DIR"
        echo "Run: sudo ./build.sh"
        exit 1
    else
        echo -e "\n================================================================================"
        echo -e "⏭️  SKIPPED: Missing output directory: $OUT_DIR."
        echo -e "   ISO smoke test bypassed gracefully as REQUIRE_ISO!=1."
        echo -e "================================================================================\n"
        exit 0
    fi
fi

shopt -s nullglob
files=("$OUT_DIR"/*.iso)
ISO_COUNT=${#files[@]}

if [[ "$ISO_COUNT" -eq 0 ]]; then
    if [[ "${REQUIRE_ISO:-0}" == "1" ]]; then
        echo "❌ No ISO found in $OUT_DIR"
        echo "Run: sudo ./build.sh"
        exit 1
    else
        echo -e "\n================================================================================"
        echo -e "⏭️  SKIPPED: No ISO found in $OUT_DIR."
        echo -e "   ISO smoke test bypassed gracefully as REQUIRE_ISO!=1."
        echo -e "================================================================================\n"
        exit 0
    fi
fi

echo "✅ Found $ISO_COUNT ISO file(s) in $OUT_DIR"
for file in "${files[@]}"; do
    # Bolt: Use native bash globbing and stat instead of slow find subprocesses
    size=$(stat -c%s "$file")
    name="${file##*/}"
    echo "$name ($size bytes)"

    if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
        echo "⏭️  SKIPPED: qemu-system-x86_64 not found. Cannot perform boot test."
        continue
    fi

    # Locate an OVMF firmware image so we can also exercise the UEFI/GRUB boot
    # path (previously only the BIOS/syslinux path was ever tested).
    OVMF=""
    for f in \
        /usr/share/edk2/x64/OVMF_CODE.4m.fd \
        /usr/share/edk2/x64/OVMF.4m.fd \
        /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
        /usr/share/OVMF/OVMF_CODE.fd \
        /usr/share/ovmf/x64/OVMF.fd; do
        [[ -f "$f" ]] && OVMF="$f" && break
    done

    # Treat a kernel panic or systemd emergency/failure as a boot failure even if
    # QEMU itself survives the timeout window.
    boot_log_is_clean() {
        ! grep -qiE 'kernel panic|---\[ end Kernel panic|Entering emergency mode|Failed to mount|Cannot open root device|VFS: Unable to mount root' "$1"
    }

    run_boot() {
        local mode="$1"; shift
        local log="qemu_boot_${mode}.log"
        echo "Starting QEMU $mode boot test for $name..."
        set +e
        timeout 90s qemu-system-x86_64 -nographic -m 2048 -no-reboot \
            -cdrom "$file" -boot d "$@" > "$log" 2>&1
        local exit_code=$?
        set -e

        if ! boot_log_is_clean "$log"; then
            echo "❌ QEMU $mode boot test failed: boot error detected in log."
            grep -iE 'kernel panic|emergency mode|Failed to mount|Unable to mount root' "$log" | head -n 5
            exit 1
        fi

        if [[ $exit_code -eq 124 || $exit_code -eq 0 ]]; then
            echo "✅ QEMU $mode boot test passed (no boot errors detected)."
        else
            echo "❌ QEMU $mode boot test failed with exit code $exit_code."
            tail -n 20 "$log"
            exit 1
        fi
    }

    run_boot "bios"

    if [[ -n "$OVMF" ]]; then
        run_boot "uefi" -drive "if=pflash,format=raw,readonly=on,file=$OVMF"
    else
        echo "⏭️  SKIPPED: no OVMF firmware found; UEFI boot path not tested."
    fi
done

echo "ISO smoke test passed."
