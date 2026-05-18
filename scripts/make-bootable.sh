#!/bin/bash
# Add EFI bootloader to disk image for X13s and other arm64 systems
# Usage: ./scripts/make-bootable.sh <raw-image> [output-bootable-image]

set -e

INPUT_IMAGE="$1"
OUTPUT_IMAGE="${2:-${INPUT_IMAGE%.raw}-bootable.raw}"

if [ ! -f "$INPUT_IMAGE" ]; then
    echo "Error: Input image not found: $INPUT_IMAGE"
    exit 1
fi

echo "=== Making bootable disk image ==="
echo "Input:  $INPUT_IMAGE"
echo "Output: $OUTPUT_IMAGE"

# Copy original image  
cp "$INPUT_IMAGE" "$OUTPUT_IMAGE"
chmod 666 "$OUTPUT_IMAGE"

# Use loopback to mount and modify
LOOP_DEV=$(losetup -f --show "$OUTPUT_IMAGE")
trap "losetup -d $LOOP_DEV 2>/dev/null || true" EXIT

echo "Mounted as: $LOOP_DEV"
sleep 1

# Rescan partitions
partprobe "$LOOP_DEV" 2>/dev/null || true
sleep 1

# Create temporary mount point
MNTDIR=$(mktemp -d)
trap "umount -R $MNTDIR 2>/dev/null || true; rm -rf $MNTDIR; losetup -d $LOOP_DEV 2>/dev/null || true" EXIT

# Mount root partition (typically p3)
if [ -b "${LOOP_DEV}p3" ]; then
    mount "${LOOP_DEV}p3" "$MNTDIR"
    echo "Mounted root at $MNTDIR"
else
    echo "Error: Could not find root partition"
    losetup -l
    exit 1
fi

# Ensure /boot/efi exists
mkdir -p "$MNTDIR/boot/efi"

# Install systemd-boot if not present
BOOTPATH="$MNTDIR/boot/efi/EFI/BOOT/BOOTAA64.EFI"
if [ ! -f "$BOOTPATH" ]; then
    echo "Installing systemd-boot..."
    mkdir -p "$(dirname $BOOTPATH)"
    
    # Try to copy from host system
    if [ -f /usr/lib/systemd/boot/efi/systemd-bootaa64.efi ]; then
        cp /usr/lib/systemd/boot/efi/systemd-bootaa64.efi "$BOOTPATH"
        echo "Copied systemd-boot from host"
    else
        echo "Warning: systemd-boot binary not found, may need manual installation"
    fi
fi

# Create boot loader configuration
echo "Creating boot configuration..."
mkdir -p "$MNTDIR/boot/efi/loader/entries"

cat > "$MNTDIR/boot/efi/loader/loader.conf" << 'BOOT'
default bluefin
timeout 3
console-mode auto
editor false
BOOT

# Get installed kernel version
KERNEL_VERSION=$(ls -1 "$MNTDIR/boot/vmlinuz-"* 2>/dev/null | head -1 | xargs basename)
KERNEL_VERSION="${KERNEL_VERSION#vmlinuz-}"

if [ -z "$KERNEL_VERSION" ]; then
    echo "Warning: No kernel found, boot entry may not work"
    KERNEL_VERSION="generic"
fi

echo "Using kernel: $KERNEL_VERSION"

cat > "$MNTDIR/boot/efi/loader/entries/bluefin.conf" << ENTRY
title           Bluefin+Duranium ARM64
version         1.0.0-alpha
machine-id      @MACHINE_ID@
sort-key        bluefin
options         arm64.nopauth clk_ignore_unused pd_ignore_unused efi=noruntime rd.driver.blacklist=qcom_q6v5_pas
ENTRY

# Create fallback entry
cat > "$MNTDIR/boot/efi/loader/entries/bluefin-fallback.conf" << ENTRY
title           Bluefin+Duranium (Fallback)
version         1.0.0-alpha
machine-id      @MACHINE_ID@
sort-key        bluefin-fallback
ENTRY

echo "=== Bootable image created successfully ==="
echo "Image: $OUTPUT_IMAGE"
ls -lh "$OUTPUT_IMAGE"
