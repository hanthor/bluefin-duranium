# Bluefin+Duranium

A single universal `.raw.zst` bootable disk image combining:

- **Duranium**: postmarketOS immutable OS with atomic updates
- **Bluefin**: Curated packages, CLI tools, developer environment
- **GNOME**: Desktop environment
- **arm64**: Works on X13s, generic ARM64, and other EFI-capable devices

## Quick Start

```bash
# Download the image
wget https://github.com/ublue-os/bluefin-duranium/releases/download/latest/duranium-bluefin-arm64.raw.zst

# Decompress
zstd -d duranium-bluefin-arm64.raw.zst

# Write to USB/disk
sudo dd if=duranium-bluefin-arm64.raw of=/dev/sdX bs=8M status=progress
sync

# Boot and enjoy!
```

## What's Included

✅ **Immutable OS**: Duranium with atomic updates via `systemd-sysupdate`  
✅ **GNOME Desktop**: Full graphical environment  
✅ **Bluefin Tools**: neovim, helix, ripgrep, fzf, zsh, starship, tmux, etc.  
✅ **Development**: Python, Node.js, Rust, Go, Podman  
✅ **System**: OpenSSH, NetworkManager, PipeWire, GStreamer  
✅ **X13s Ready**: Qualcomm firmware, optimized boot policy  

## One Image. All Devices.

This single `.raw.zst` image works on:
- ✅ Thinkpad X13s (Snapdragon SC8280XP)
- ✅ Generic arm64 systems with EFI
- ✅ Any arm64 device with EFI bootloader

No per-device builds. No per-device configurations. One image for all.

## Building

Requires `mkosi` on a postmarketOS/Alpine-like system:

```bash
mkosi -C . build
# Output: mkosi.output/duranium-bluefin-arm64.raw.zst
```

See [BUILD.md](BUILD.md) for detailed instructions.

## Deploying

```bash
# Linux/Unix
zstd -d duranium-bluefin-arm64.raw.zst
sudo dd if=duranium-bluefin-arm64.raw of=/dev/sdX bs=8M status=progress

# For X13s (optional boot kargs in U-Boot)
arm64.nopauth clk_ignore_unused pd_ignore_unused efi=noruntime rd.driver.blacklist=qcom_q6v5_pas
```

See [QUICKSTART.md](QUICKSTART.md) for more details.

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

Duranium handles OS updates atomically:

```bash
sudo systemctl start systemd-sysupdate
sudo reboot
```

Updates are safe - if something goes wrong, the system rolls back automatically.

## Customization

After first boot, customize via:

```bash
# Install additional packages
sudo apk add [package]

# Edit system configuration
sudo nano /etc/some-config

# Changes persist across updates
```

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute build & deploy guide
- **[BUILD.md](BUILD.md)** - Detailed build instructions & troubleshooting
- **[mkosi.conf](mkosi.conf)** - Build configuration
- **[mkosi.finalize](mkosi.finalize)** - Post-build customization script

## X13s Boot Policy

For X13s, the image includes optimal boot arguments:
- `arm64.nopauth` - Pointer auth disabled (firmware safety)
- `clk_ignore_unused pd_ignore_unused` - Keep firmware clocks/power domains
- `efi=noruntime` - Skip unsafe Qualcomm UEFI runtime services
- `rd.driver.blacklist=qcom_q6v5_pas` - Module loading order

## Continuous Builds

This repository includes GitHub Actions workflows for:
- ✅ Automated builds on commit
- ✅ Weekly nightly builds
- ✅ Automatic releases with checksums
- ✅ Artifact retention and cleanup

New releases available at: https://github.com/ublue-os/bluefin-duranium/releases

## Related Projects

- **Duranium** (postmarketOS): https://wiki.postmarketos.org/wiki/Duranium_(Immutable_postmarketOS)
- **postmarketOS**: https://postmarketos.org
- **Bluefin** (Fedora): https://github.com/ublue-os/bluefin
- **X13s Upstream**: https://github.com/jhovold/linux/wiki/X13s

## Contributing

Issues and PRs welcome! Please:

1. Test on your device before submitting
2. Describe what changed and why
3. Link any related issues or discussions
4. Update documentation if needed

## License

Same as postmarketOS

---

**Built with**: mkosi, postmarketOS, Alpine Linux, GNOME, Bluefin
