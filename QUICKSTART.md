# Bluefin+Duranium Quick Start

## TL;DR

**Fastest path**: Download pre-built image from releases

```bash
# Download from releases
wget https://github.com/hanthor/bluefin-duranium/releases/download/v1.0.0-alpha/bluefin-duranium-arm64.raw.zst

# Decompress
zstd -d bluefin-duranium-arm64.raw.zst

# Write to USB/disk
sudo dd if=bluefin-duranium-arm64.raw of=/dev/sdX bs=4M status=progress

# Boot and enjoy!
```

**Or build locally** (requires mkosi + 50GB space):

```bash
git clone https://github.com/hanthor/bluefin-duranium
cd bluefin-duranium
sudo mkosi build
zstd -19 bluefin-duranium-arm64.raw
sudo dd if=bluefin-duranium-arm64.raw of=/dev/sdX bs=4M status=progress
```

## One Image. All Devices.

This is a **universal arm64 image**:
- ✅ Works on Lenovo ThinkPad X13s (Snapdragon)
- ✅ Works on generic arm64 systems with EFI boot
- ✅ Single `.raw.zst` file for all devices

## What's Included

- **Base OS**: Debian Trixie (modern, widely supported)
- **Immutable OS**: Duranium with atomic updates via `systemd-sysupdate`
- **Desktop**: GNOME Shell with Bluefin defaults
- **CLI Tools**: neovim, helix, ripgrep, git, zsh, starship, tmux, fzf, etc.
- **Development**: Python, Node.js, Rust, Go, Podman, containers
- **Multimedia**: PipeWire, GStreamer, video/audio codecs
- **X13s Ready**: Qualcomm firmware + optimized boot policy included

## Download Fastest Option ⚡

Pre-built images available at:
https://github.com/hanthor/bluefin-duranium/releases

Just download, decompress, and write to USB.

## Build Locally (Advanced)

### Requirements

- Ubuntu 24.04 or Debian Trixie (with mkosi v20.2+)
- 50GB free disk space (will use ~40GB for build)
- 4GB RAM minimum (8GB+ recommended)
- Internet connection
- sudo access

### Install Prerequisites

**Ubuntu/Debian**:
```bash
sudo apt update
sudo apt install mkosi zstd
```

### Build

```bash
# Clone repository
git clone https://github.com/hanthor/bluefin-duranium
cd bluefin-duranium

# View build plan
mkosi summary

# Build the image (~20-40 minutes)
sudo mkosi build

# Compress for smaller downloads
zstd -19 --long bluefin-duranium-arm64.raw
# Produces: bluefin-duranium-arm64.raw.zst (~3GB)

# Verify
ls -lh bluefin-duranium-arm64.raw*
```

## Deploy to USB/Disk

### Find Your Device

```bash
# List all block devices
lsblk

# OR list with details
sudo fdisk -l
```

**⚠️ WARNING**: Double-check the device name! Using wrong device deletes data!

### Write Image

**Linux**:
```bash
# Decompress if needed
zstd -d bluefin-duranium-arm64.raw.zst

# Write to USB (replace sdX with YOUR device!)
sudo dd if=bluefin-duranium-arm64.raw of=/dev/sdX bs=4M status=progress

# Flush and verify
sudo sync
```

**macOS**:
```bash
# Unmount first
diskutil unmountDisk /dev/diskX

# Write
sudo dd if=bluefin-duranium-arm64.raw of=/dev/rdiskX bs=4M

# Eject
diskutil eject /dev/diskX
```

## First Boot

### X13s

1. Insert USB into X13s
2. Power on and press **Delete** during startup
3. Go to **Boot** menu → set USB as first boot device
4. Press **F10** to save and exit
5. System boots into GNOME
6. Default login: `root` (blank password)

### Generic ARM64

1. Insert USB
2. Boot (may need to press Boot key during startup)
3. Select USB from boot menu
4. GNOME appears
5. Login as `root` (blank password)

### After Login

```bash
# Update system (optional)
sudo systemctl start systemd-sysupdate
sudo reboot

# Install packages
sudo apt install package-name

# Verify hardware
lsmod | head -20
```

## System Features

### Immutable Root Filesystem

Root filesystem is read-only. Changes go in `/etc` and `/home`:

```bash
# Install packages (persists across updates)
sudo apt install neovim git htop

# Edit system config
sudo nano /etc/networkmanager/conf.d/wifi.conf

# User files
echo "data" > ~/myfile.txt
```

### Atomic Updates

```bash
# Check for updates
sudo systemctl status systemd-sysupdate

# Install (happens at reboot)
sudo systemctl start systemd-sysupdate
sudo reboot

# Automatic rollback if something fails
```

### SSH Access

SSH server is enabled by default:

```bash
# From another machine
ssh root@192.168.1.100

# Find your IP
hostname -I
```

## Next Steps

- ✅ Download or build image
- ✅ Write to USB/disk
- ✅ Boot on your device
- ✅ Test and customize
- 📝 Report issues: https://github.com/hanthor/bluefin-duranium/issues

## Need Help?

- **Installation**: See [DEPLOYMENT.md](DEPLOYMENT.md)
- **Troubleshooting**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Building**: See [BUILD.md](BUILD.md)
- **X13s specific**: See [README.md](README.md) X13s Boot Policy section

---

**First time with Linux on ARM?** Start here:
- https://www.debian.org/support
- https://wiki.postmarketos.org/wiki/Duranium_(Immutable_postmarketOS)
