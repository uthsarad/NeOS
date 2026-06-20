#!/bin/bash
# NeOS Virtual Appliance Generator
# Creates a pre-configured VMDK and .vbox configuration for NeOS.

set -euo pipefail

# Sentinel: [Security] Enforce strict PATH to prevent path hijacking
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Sentinel: [Security] Sanitize script name for safe logging to prevent log injection
SCRIPT_NAME="${0##*/}"
SCRIPT_NAME="${SCRIPT_NAME//[^a-zA-Z0-9_.-]/}"

_error_handler() {
    local err=$1
    local line=$2
    local cmd="${BASH_COMMAND//[^[:print:]]/}"
    # Palette: Ensure logged error messages are clear and contain actionable steps for users.
    # Bolt: Ensure trap commands and error logging minimize subshell overhead.
    printf -- "\n\\e[1m\\e[31m================================================================================\\e[0m\n\\e[1m\\e[31m🚨 CRITICAL ERROR: %s\\e[0m\n\\e[1m\\e[31m================================================================================\\e[0m\n\\e[1m\\e[36m💡 What went wrong:\\e[0m\n  Command: \"%s\"\n  Failed at line: %s\n  Exit code: %s\n\n\\e[1m\\e[36m🔧 How to fix:\\e[0m\n  1. Review system journal: \\e[1mjournalctl -t neos-%s\\e[0m\n  2. Check system state and script configuration.\n\\e[1m\\e[31m================================================================================\\e[0m\n\n" "$SCRIPT_NAME" "$cmd" "$line" "$err" "$SCRIPT_NAME" >&2 || true
    logger -t "neos-$SCRIPT_NAME" "CRITICAL: Script failed at line $line (Exit Code $err). Command: \"$cmd\". Please review the system journal." || true
    exit "$err"
}

# Sentinel: Verify that trap commands safely handle variable expansion without introducing command injection risks.
trap '_error_handler $? $LINENO' ERR

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 NeOS Virtual Appliance Generator starting...${NC}"

# Check for dependencies
DEPENDENCIES=("qemu-img" "uuidgen")
for cmd in "${DEPENDENCIES[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: $cmd is not installed. Please install it first.${NC}"
        exit 1
    fi
done

VM_NAME="NeOS-Appliance"
OUT_DIR="out/vm"
mkdir -p "$OUT_DIR"

# Generate UUIDs for VirtualBox
VM_UUID=$(uuidgen)
DISK_UUID=$(uuidgen)

echo -e "${GREEN}📦 Generating VirtualBox Configuration (.vbox)...${NC}"
sed -e "s/{4e454f53-0000-4000-8000-000000000001}/{$VM_UUID}/g" \
    -e "s/{4e454f53-0000-4000-8000-000000000002}/{$DISK_UUID}/g" \
    -e "s/NeOS-Virtual-Appliance/$VM_NAME/g" \
    profile/vm/neos.vbox > "$OUT_DIR/$VM_NAME.vbox"

echo -e "${GREEN}📦 Generating VMware Configuration (.vmx)...${NC}"
cp profile/vm/neos.vmx "$OUT_DIR/$VM_NAME.vmx"

echo -e "${YELLOW}ℹ️  To create the VMDK, you have two options:${NC}"
echo -e "1. ${GREEN}Convert an existing ISO to a Live-Disk:${NC}"
echo -e "   qemu-img convert -f raw -O vmdk out/neos.iso $OUT_DIR/$VM_NAME.vmdk"
echo -e ""
echo -e "2. ${GREEN}Create a blank 40GB sparse disk (recommended for installation):${NC}"
echo -e "   qemu-img create -f vmdk $OUT_DIR/$VM_NAME.vmdk 40G"

echo -e "\n${GREEN}✅ Virtual Appliance templates generated in $OUT_DIR${NC}"
echo -e "You can now distribute these files along with your ISO."
