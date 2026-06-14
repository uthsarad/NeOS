#!/bin/bash
# NeOS Virtual Appliance Generator
# Creates a pre-configured VMDK and .vbox configuration for NeOS.

set -e

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
