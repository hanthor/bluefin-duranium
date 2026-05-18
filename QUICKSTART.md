# Duranium+Bluefin Quick Start

## TL;DR

```bash
# Build (on postmarketOS/Alpine with mkosi)
cd duranium-bluefin
mkosi -C . build

# Deploy (to any arm64 device with EFI)
zstd -d mkosi.output/duranium-bluefin-arm64.raw.zst
sudo dd if=duranium-bluefin-arm64.raw of=/dev/sdX bs=8M status=progress

# Boot and enjoy
```

## One Image. All Devices.

This is a **universal arm64 image**:
- ✅ Works on X13s (Snapdragon)
- ✅ Works on generic arm64 systems with EFI
- ✅ Single `.raw.zst` file, no per-device variants

## What You Get

- **Duranium**: Immutable OS with atomic updates via `systemd-sysupdate`
- **GNOME**: Desktop environment
- **Bluefin Tools**: neovim, ripgrep, git, zsh, starship, tmux, etc.
- **Dev Environment**: Python, Node.js, Rust, Go, Podman
- **X13s Ready**: Qualcomm firmware + optimized boot policy included

## Build Requirements

- **mkosi**: Modern version (24.x+)
- **50GB free space** for build
- **postmarketOS/Alpine-like system** (recommended)
- **Internet connection**

## Build Steps

1. **Prerequisites**:
   ```bash
   apk add mkosi zstd
   ```

2. **Clone/download**:
   ```bash
   cd /path/to/duranium-bluefin
   ```

3. **Build**:
   ```bash
   mkosi -C . build
   # Takes 20-30 minutes depending on network
   ```

4. **Output**:
   ```bash
   ls -lh mkosi.output/duranium-bluefin-arm64.raw.zst
   # ~2-4GB compressed
   ```

## Deploy to USB/Disk

### Linux/Unix
```bash
# Find target device (BE CAREFUL - this overwrites data!)
lsblk
# Decompress
zstd -d duranium-bluefin-arm64.raw.zst

# Write to device (replace sdX)
sudo dd if=duranium-bluefin-arm64.raw of=/dev/sdX bs=8M status=progress
sync

# Eject
sudo eject /dev/sdX
```

### For X13s Specifically

Same process above, but you can optionally configure boot kargs in U-Boot:

```
setenv bootargs "arm64.nopauth clk_ignore_unused pd_ignore_unused efi=noruntime rd.driver.blacklist=qcom_q6v5_pas"
saveenv
```

(These are already in the image, so this may be optional.)

## First Boot

1. Insert USB/disk into device
2. Boot from USB (may need to press boot menu key during startup)
3. GNOME should appear
4. Set up user account
5. Done!

## First Time Setup

### Update system
```bash
sudo systemctl start systemd-sysupdate
sudo reboot
```

### Install additional packages
```bash
sudo apk add [package-name]  # Alpine packages
```

### Switch to different UI (experimental)
Edit `/etc/os-release`:
```bash
sudo nano /etc/os-release
# Change VARIANT_ID=bluefin-duranium to something like phosh, plasma-mobile, console
```

Then:
```bash
sudo systemctl start systemd-sysupdate --verify=false update
sudo reboot
```

## Troubleshooting

### Won't boot
- Check BIOS: ensure EFI boot is enabled
- Try debug shell: press Space at boot splash
- Check `/var/log/syslog` after boot for errors

### GNOME won't start
```bash
# Check GPU drivers
lsmod | grep -i gpu

# Check logs
journalctl -u gnome-shell -n 50
```

### No network
```bash
# Check NetworkManager
nmcli dev status
nmcli con show
```

### For X13s specific issues
Refer to: `/var/home/james/postmarketos-x13s/docs/X13S-LINUX-BOOTABILITY-GUIDE.md`

## System Updates

Duranium handles updates atomically:

```bash
# Check for updates
sudo systemctl status systemd-sysupdate

# Start update (will complete on reboot)
sudo systemctl start systemd-sysupdate
sudo reboot
```

Updates are atomic - if something goes wrong, the system rolls back automatically.

## Project Files

- **mkosi.conf** - Main build configuration
- **mkosi.finalize** - Post-build setup script
- **system_files/** - GNOME defaults, services, branding
- **BUILD.md** - Detailed build guide
- **README.md** - Full project overview

## Next Steps

1. ✅ Review this guide
2. ✅ Check prerequisites (mkosi, space)
3. ✅ Run `mkosi -C . build`
4. ✅ Deploy to USB/disk
5. ✅ Boot and test
6. 📝 Report any issues or improvements

---

**Questions?** Refer to:
- Duranium wiki: https://wiki.postmarketos.org/wiki/Duranium_(Immutable_postmarketOS)
- postmarketOS docs: https://wiki.postmarketos.org
- X13s guide: `/var/home/james/postmarketos-x13s/docs/`
