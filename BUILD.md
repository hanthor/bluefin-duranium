# Building Duranium+Bluefin

## What This Builds

**One single `.raw.zst` image** (~2-4GB compressed) that:
- Boots on arm64 devices with EFI (X13s, generic ARM boards, etc.)
- Includes GNOME desktop + Bluefin tools/packages
- Includes Duranium immutable OS with atomic updates
- Works on X13s with optimized boot policy included

## Quick Build

### Prerequisites
- `mkosi` installed (on postmarketOS/Alpine/systemd-based distro)
- ~50GB free disk space for build
- Internet connection

### Build
```bash
cd /tmp/duranium-bluefin
mkosi -C . summary     # Show build plan
mkosi -C . build       # Build the image
```

### Output
```
mkosi.output/duranium-bluefin-arm64.raw.zst  (~2-4GB)
```

## Deploying to Disk

### On Linux
```bash
# Decompress
zstd -d duranium-bluefin-arm64.raw.zst

# Write to USB/disk (replace sdX with your target)
sudo dd if=duranium-bluefin-arm64.raw of=/dev/sdX bs=8M status=progress
sync

# Eject and boot
```

### On X13s Specifically
Same process, but optionally set boot kargs in U-Boot or bootloader:
```
arm64.nopauth clk_ignore_unused pd_ignore_unused efi=noruntime rd.driver.blacklist=qcom_q6v5_pas
```

(The image includes these settings, so they may be optional depending on bootloader behavior.)

## First Boot

1. Boot the image
2. GNOME should start
3. Create user account / login
4. System is ready

## Updating

Use Duranium's built-in `systemd-sysupdate`:
```bash
sudo systemctl start systemd-sysupdate
sudo reboot
```

## What's Included

✅ Duranium (immutable OS, atomic updates)
✅ GNOME Shell
✅ Bluefin packages: neovim, helix, git, ripgrep, fzf, zsh, starship, tmux, etc.
✅ Development: Python, Node.js, Rust, Go, Podman
✅ Multimedia: PipeWire, GStreamer, codecs
✅ X13s support: Qualcomm firmware, module ordering, boot policy reference

## Customization

After boot, edit `/etc/os-release` to:
- Switch between releases (edge, stable, etc.)
- Switch between UI variants (experimental - gnome, phosh, plasma-mobile, console)

Then run:
```bash
sudo systemctl start systemd-sysupdate --verify=false update
sudo reboot
```

## Troubleshooting

### Image won't build
- Ensure `mkosi` is recent (24.x or later)
- Check `/tmp` has 50GB+ free
- Verify postmarketOS repos are accessible

### Image won't boot
- Try with debug shell: press Space at boot splash
- Check BIOS/bootloader: ensure EFI boot is enabled
- For X13s: verify firmware is current and set kargs mentioned above

### GNOME won't start
- Check `/var/log/syslog` or `journalctl -u gnome-shell`
- Ensure GPU drivers are loaded: `lsmod | grep -i gpu`

## Resources

- Duranium wiki: https://wiki.postmarketos.org/wiki/Duranium_(Immutable_postmarketOS)
- Duranium design: https://gitlab.postmarketos.org/postmarketOS/duranium/-/blob/main/DESIGN.md
- mkosi docs: https://mkosi.dev/
- X13s bootability: `/var/home/james/postmarketos-x13s/docs/X13S-LINUX-BOOTABILITY-GUIDE.md`
