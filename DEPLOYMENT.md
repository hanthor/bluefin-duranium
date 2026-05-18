# Deployment Guide

This guide covers installing and booting Bluefin+Duranium on various hardware platforms.

## Supported Platforms

### ✅ Tested & Supported
- **Lenovo ThinkPad X13s** (Snapdragon X1 Gen 1)
  - Native Qualcomm firmware support
  - Full boot & GNOME desktop support
  - Camera, audio, GPU working

### ⚠️ Supported (Generic ARM64)
- Generic ARM64 devices with EFI bootloader
- Requires bootloader already installed
- May need custom kernel arguments for your hardware
- Bring Your Own Bootloader (BYOB) approach

### ❌ Not Supported
- Devices without EFI support
- Non-ARM64 architecture
- Closed bootloaders (Android devices, etc.)

## Download & Prepare

### 1. Download Image

From [GitHub Releases](https://github.com/hanthor/bluefin-duranium/releases):

```bash
# Download the latest .raw.zst file
wget https://github.com/hanthor/bluefin-duranium/releases/download/v1.0.0-alpha/bluefin-duranium-arm64.raw.zst

# Verify checksums (optional but recommended)
wget https://github.com/hanthor/bluefin-duranium/releases/download/v1.0.0-alpha/CHECKSUMS
sha256sum -c CHECKSUMS
```

### 2. Decompress Image

The image is compressed with zstd:

```bash
# Install zstd if needed
sudo apt install zstd  # Debian/Ubuntu
brew install zstd      # macOS

# Decompress
zstd -d bluefin-duranium-arm64.raw.zst
# Output: bluefin-duranium-arm64.raw (~10-12 GB)
```

## X13s Installation

### Prerequisites
- Lenovo ThinkPad X13s with functional Qualcomm firmware
- USB drive (16GB+ recommended)
- Decompressed .raw image file
- Another computer for flashing

### Steps

#### 1. Identify USB Device

On your flashing computer:

```bash
# List all block devices
lsblk

# OR use fdisk
sudo fdisk -l
```

Look for your USB device (typically `/dev/sdbX` on Linux, `/dev/diskX` on macOS).

**WARNING**: Double-check the device name! Using the wrong device will destroy data.

#### 2. Flash Image to USB

```bash
# Unmount if already mounted
sudo umount /dev/sdb*

# Flash the raw image (this is fast, ~1-2 minutes)
sudo dd if=bluefin-duranium-arm64.raw of=/dev/sdb bs=4M status=progress

# Flush and eject
sudo sync
sudo eject /dev/sdb
```

**On macOS:**
```bash
# Unmount
diskutil unmountDisk /dev/disk2

# Flash
sudo dd if=bluefin-duranium-arm64.raw of=/dev/rdisk2 bs=4M

# Eject
diskutil eject /dev/disk2
```

#### 3. Boot X13s from USB

1. Insert USB into X13s
2. Power on and quickly press **Delete** key to enter firmware setup
3. Navigate to **Boot** → **Boot Order**
4. Set USB as first boot device
5. Press **F10** to save and exit
6. System will boot from USB into GNOME login

#### 4. Initial Setup

At the GNOME login screen:

```
Username: root
Password: (blank - just press Enter)
```

Or use the guest session for quick testing.

#### 5. Install to Disk (Optional)

To make the installation permanent:

```bash
# As root
sudo -i

# Identify target disk (usually /dev/nvme0n1 for internal SSD)
lsblk

# Write to disk (same as USB installation)
dd if=/dev/sdb of=/dev/nvme0n1 bs=4M status=progress

# Verify
lsblk
```

Then reboot and remove USB.

## Generic ARM64 Installation

### Prerequisites
- ARM64 system with EFI bootloader
- Method to write raw images (dd, Etcher, Ventoy, etc.)
- Storage device (USB or internal)

### For UEFI/BIOS Systems

The Debian Trixie base includes systemd-boot, so any EFI-capable ARM64 system should boot.

#### 1. Write Image

```bash
# To USB or SD card
sudo dd if=bluefin-duranium-arm64.raw of=/dev/sdX bs=4M status=progress

# To internal storage
sudo dd if=bluefin-duranium-arm64.raw of=/dev/nvme0n1 bs=4M status=progress
```

#### 2. Boot & Configure

1. Plug storage into target device
2. Boot (may need to set boot order in firmware)
3. At GNOME login, enter credentials
4. System should detect and configure hardware automatically

### Troubleshooting Generic Devices

If the system doesn't boot:

1. **Check firmware boot order** - Ensure USB/storage is first
2. **Verify image integrity** - Compare SHA256 checksums
3. **Try different storage device** - USB issues are common
4. **Check EFI support** - Device must support EFI boot

If system boots but hardware isn't working:

1. **Check available modules** - `lsmod` lists loaded kernel modules
2. **Load missing drivers** - `sudo modprobe module-name`
3. **Add kernel arguments** - Edit bootloader entry for X13s arguments (see below)

### Custom Kernel Arguments

For non-X13s devices, you may need to adjust kernel boot arguments:

```bash
# Edit systemd-boot entry
sudo nano /efi/loader/entries/*.conf

# Common arguments:
#   arm64.nopauth          - Disable pointer authentication (if needed)
#   clk_ignore_unused      - Keep clocks active
#   pd_ignore_unused       - Keep power domains active
#   efi=noruntime          - Skip UEFI runtime (if crashes occur)
```

After editing, save and reboot.

## First Boot

### Expected Behavior

1. **Boot sequence** (~30-60 seconds):
   - systemd-boot menu appears briefly
   - Kernel loads and initializes hardware
   - systemd starts services
   - GNOME Display Manager appears

2. **Login screen**:
   - Default: `root` with blank password (or guest)
   - Confirm X13s drivers are loaded: `lsmod | grep qcom`

3. **Desktop**:
   - GNOME Shell with Bluefin defaults
   - All Bluefin tools available (starship, zsh, etc.)
   - Network manager should auto-detect networks

### Verify Hardware

```bash
# Check kernel modules loaded
lsmod

# Verify X13s-specific modules (if on X13s)
lsmod | grep qcom

# Check disk space
df -h

# List block devices
lsblk

# Verify EFI boot
efibootmgr -v
```

## System Administration

### Persistent Changes

Since root filesystem is immutable, changes must go in `/etc` or `/home`:

```bash
# Edit system configuration (survives updates)
sudo nano /etc/some-config

# Install additional packages
sudo apt install package-name
```

### System Updates

```bash
# Check available updates
sudo systemctl status systemd-sysupdate

# Install updates (atomic)
sudo systemctl start systemd-sysupdate

# Reboot to apply
sudo reboot
```

Updates are safe - failed updates automatically rollback.

### Performance Tuning

Common optimizations for X13s:

```bash
# Enable GPU (Adreno)
# Already configured in mkosi.finalize

# Verify GPU module loaded
lsmod | grep msm

# Enable audio
# Already configured in mkosi.finalize

# Verify audio
aplay -l
```

## Networking

### Wi-Fi

Network Manager handles Wi-Fi automatically:

```bash
# Check connection status
nmcli device

# Manual connection
nmcli device wifi list
nmcli device wifi connect "SSID" password "PASSWORD"

# Device info
nmcli -p device show wlan0
```

### SSH

SSH server is enabled by default:

```bash
# Connect from another machine
ssh root@192.168.1.100

# Or with username
ssh user@192.168.1.100

# Find your IP
ip addr
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues.

## Next Steps

1. **Customize** - Install additional packages or tools
2. **Configure** - Set up SSH keys, users, etc.
3. **Report issues** - GitHub issues for bugs or unsupported hardware

---

**For detailed build instructions**, see [BUILD.md](BUILD.md)

**For common issues**, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
