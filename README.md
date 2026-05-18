# Bluefin+Duranium (Debian Edition)

A single universal `.raw.zst` bootable disk image combining:

- **Duranium**: Immutable OS architecture with atomic updates (via dracut + systemd)
- **Bluefin**: Curated packages, CLI tools, developer environment
- **GNOME**: Modern desktop environment (GNOME 48)
- **Debian**: Trixie base (testing branch) for modern packages and full arm64 support
- **arm64**: Works on X13s, generic ARM64, and other EFI-capable devices

## Quick Start

```bash
# Download the image
wget https://github.com/hanthor/bluefin-duranium/releases/download/latest/duranium-bluefin.raw.zst

# Decompress
zstd -d duranium-bluefin.raw.zst

# Write to USB/disk (replace sdX with your device!)
sudo dd if=duranium-bluefin.raw of=/dev/sdX bs=8M status=progress
sync

# Boot and enjoy!
```

## What's Included

✅ **Modern Base**: Debian Trixie (arm64) with latest packages  
✅ **Immutable Design**: Read-only root filesystem with persistent /etc  
✅ **GNOME 48 Desktop**: Full graphical environment  
✅ **Bluefin Tools**: neovim, ripgrep, fzf, zsh, starship, tmux, etc.  
✅ **Development**: Python 3, Node.js, Rust, Go, Podman, container tools  
✅ **System**: OpenSSH, NetworkManager, PipeWire, GStreamer, Dracut initramfs  
✅ **X13s Ready**: All Qualcomm Snapdragon packages, optimized boot policy  
✅ **Universal**: One image works on X13s, generic arm64, and EFI systems  

## One Image. All Devices.

This single `.raw.zst` image works on:
- ✅ Thinkpad X13s (Snapdragon SC8280XP)
- ✅ Generic arm64 systems with EFI
- ✅ Any arm64 device with EFI bootloader

No per-device builds. No per-device configurations. One image for all.

## Building

Builds are automated via GitHub Actions on native ARM64 runners (free!):

- ✅ **Automatic builds** on every commit
- ✅ **Weekly nightly builds** for latest packages
- ✅ **Pre-compressed** `.raw.zst` files ready for deployment
- ✅ **Native ARM64**: Builds on GitHub's free ubuntu-24.04-arm runners (~15 min)

### Manual Building

If you want to build locally, you need mkosi on an arm64 system:

```bash
# Install mkosi (Debian/Ubuntu)
sudo apt install mkosi

# Build the image
mkosi -C . build

# Output: mkosi.output/duranium-bluefin.raw.zst
```

For detailed build instructions, see [BUILD.md](BUILD.md).

## Deploying

See [DEPLOYMENT.md](DEPLOYMENT.md) for hardware-specific installation instructions.

### Quick Deployment (Linux)

```bash
# 1. Get the image
wget https://github.com/hanthor/bluefin-duranium/releases/download/latest/duranium-bluefin.raw.zst

# 2. Decompress
zstd -d duranium-bluefin.raw.zst

# 3. Write to USB/disk (CAUTION: Choose correct device!)
lsblk  # First, identify your device (e.g., /dev/sda, /dev/nvme0n1)
sudo dd if=duranium-bluefin.raw of=/dev/sdX bs=8M status=progress
sudo sync

# 4. Boot from USB and enjoy!
```

**For X13s specific boot arguments**, see [DEPLOYMENT.md](DEPLOYMENT.md#thinkpad-x13s).

## Key Features

### One Universal Image
- Single `.raw.zst` file for all arm64 devices
- No compilation needed per device
- Works out of the box on X13s and generic arm64 systems

### Duranium Architecture
- Immutable `/usr` (read-only)
- Persistent `/etc` (user configuration)
- Atomic OS updates via `systemd-sysupdate`
- Safe rollback on failed updates

### Bluefin Customizations
- Curated package set (CLI tools, dev tools, desktop apps)
- GNOME Shell with Bluefin defaults
- Starship prompt, zsh, neovim, helix, tmux, and more

### X13s Support
- Qualcomm Snapdragon firmware included
- Boot arguments pre-configured
- Module ordering optimized
- Camera, GPU, audio support

## System Updates

The OS uses dracut for immutability and updates:

```bash
# Check for updates
sudo systemctl status systemd-sysupdate

# Update the system
sudo systemctl start systemd-sysupdate

# Reboot to apply updates
sudo reboot
```

Updates are atomic - if something fails, the system automatically rolls back.

## Customization

After first boot, customize via package management:

```bash
# Install additional packages (persistent across updates)
sudo apt install [package-name]

# Edit system configuration
sudo nano /etc/some-config

# Check available packages
apt search keyword
```

**Note**: Root filesystem is immutable. Only `/etc` and `/home` are writable for user changes.

## Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Hardware-specific installation (X13s, generic arm64, etc.)
- **[BUILD.md](BUILD.md)** - Building your own images with mkosi
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions
- **[mkosi.conf](mkosi.conf)** - Build configuration reference
- **[mkosi.finalize](mkosi.finalize)** - Post-build customization script

## Continuous Builds & Releases

New builds happen automatically:
- **On every commit**: Full build on native ARM64 runner (~15 min)
- **Weekly (nightly)**: Automated build with latest packages
- **Manual**: Use GitHub UI to trigger builds

Releases available at: https://github.com/hanthor/bluefin-duranium/releases

## X13s Boot Policy

For X13s, the image includes optimal boot arguments:
- `arm64.nopauth` - Pointer auth disabled (firmware safety)
- `clk_ignore_unused pd_ignore_unused` - Keep firmware clocks/power domains
- `efi=noruntime` - Skip unsafe Qualcomm UEFI runtime services
- `rd.driver.blacklist=qcom_q6v5_pas` - Module loading order

## Related Projects

- **Duranium** (postmarketOS): https://wiki.postmarketos.org/wiki/Duranium_(Immutable_postmarketOS)
- **Bluefin** (Fedora): https://github.com/ublue-os/bluefin
- **X13s Upstream**: https://github.com/jhovold/linux/wiki/X13s
- **Debian**: https://www.debian.org

## Contributing

Issues and PRs welcome! Please:

1. Test on your device before submitting
2. Describe what changed and why
3. Link any related issues or discussions
4. Update documentation if needed

## License

Same as postmarketOS

---

**Built with**: mkosi, Debian Trixie, GNOME, Bluefin
