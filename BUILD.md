# Building Bluefin+Duranium

## What This Builds

**One single bootable `.raw.zst` image** (~3GB compressed, ~10-12GB uncompressed) that:
- Boots on arm64 devices with EFI bootloader
- **Debian Trixie + GNOME + Bluefin tools**
- Includes Duranium immutable OS with atomic updates
- Works on X13s and generic ARM64 hardware
- ~15 minute build on native ARM64 runners (GitHub Actions)

## Quick Build (Local)

### Prerequisites
- Ubuntu/Debian system (arm64 or x86_64)
- `mkosi` (v20.2+ from apt: `sudo apt install mkosi`)
- ~50GB free disk space for build
- 4+ GB RAM recommended
- Internet connection

### Build Steps

```bash
# Clone repository
git clone https://github.com/hanthor/bluefin-duranium
cd bluefin-duranium

# View build plan
mkosi summary

# Build the image
sudo mkosi build

# This produces: ./bluefin-duranium-arm64.raw (~10-12GB)
```

### Post-Build Compression

The build outputs an uncompressed `.raw` file. To compress:

```bash
# Install zstd if needed
sudo apt install zstd

# Compress the image
zstd -19 --long bluefin-duranium-arm64.raw

# Output: bluefin-duranium-arm64.raw.zst (~3GB)
```

## Automated Builds (GitHub Actions)

This repository includes automated workflows that build on every commit:

```bash
# Monitor builds
# https://github.com/hanthor/bluefin-duranium/actions

# Download from releases
# https://github.com/hanthor/bluefin-duranium/releases
```

**Build time**: ~15 minutes on native ARM64 runners (ubuntu-24.04-arm)

## Deploying Image to Disk

### Step 1: Decompress (if needed)

```bash
zstd -d bluefin-duranium-arm64.raw.zst
# Produces: bluefin-duranium-arm64.raw (~10-12GB)
```

### Step 2: Write to USB/Disk

**On Linux**:
```bash
# Identify target device
lsblk

# Write image (replace sdX with your device!)
sudo dd if=bluefin-duranium-arm64.raw of=/dev/sdX bs=4M status=progress

# Flush to disk
sudo sync

# Eject (if USB)
sudo eject /dev/sdX
```

**On macOS**:
```bash
# Identify device
diskutil list

# Unmount
diskutil unmountDisk /dev/diskX

# Write
sudo dd if=bluefin-duranium-arm64.raw of=/dev/rdiskX bs=4M

# Eject
diskutil eject /dev/diskX
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for full hardware-specific instructions.

## First Boot

1. **Insert USB/boot disk** into target device
2. **Power on** and press Delete to enter firmware
3. **Set boot order** to USB first
4. **Save and exit** (usually F10)
5. **GNOME login screen** appears
6. **Login**: `root` (blank password) or guest session

Expected boot time: 30-60 seconds

## System Administration

### Persistent Changes

Root filesystem is read-only. Store changes in `/etc` and `/home`:

```bash
# Install packages (persistent across updates)
sudo apt install package-name

# Edit system config
sudo nano /etc/some-config

# User files
echo "data" > ~/myfile.txt
```

### System Updates

```bash
# Check for updates
sudo systemctl status systemd-sysupdate

# Install updates (atomic)
sudo systemctl start systemd-sysupdate

# Reboot to apply
sudo reboot
```

## Customization & Build Options

Edit `mkosi.conf` to customize:

```ini
[Distribution]
Distribution=debian
Release=trixie
Architecture=arm64

[Content]
# Add/remove packages here
Packages=
    gnome-shell
    gnome-control-center
    # ... add more as needed

[Output]
ImageId=bluefin-duranium
Format=disk
```

After editing, rebuild:

```bash
sudo mkosi build
```

## mkosi Configuration Reference

### File Organization

- **mkosi.conf** - Main build configuration (base OS, packages, partitions)
- **mkosi.finalize** - Post-build customization script (runs as root after package install)
- **system_files/** - Files to include in image
- **.github/workflows/** - Automated build workflows

### Key Settings

```ini
[Distribution]
Distribution=debian        # Base OS
Release=trixie             # Release version
Architecture=arm64         # Target architecture

[Content]
Packages=                  # List of packages to install
ToolsTree=default         # Auto-download build tools (includes bootctl)

[Output]
ImageId=bluefin-duranium
Format=disk               # Output format
Bootable=yes              # Make bootable image
```

### Common Build Options

```bash
# Clean build (remove old artifacts)
sudo mkosi clean

# Build with debug output
sudo mkosi -vv build

# Summary without building
mkosi summary

# Shell into build environment
sudo mkosi shell
```

## Troubleshooting

### Build fails with "Unknown setting"

**Cause**: mkosi version mismatch (v20.2 is stricter)

**Solution**:
1. Check mkosi version: `mkosi --version` (should be v20.2+)
2. Verify settings in `mkosi.conf` are correct section
3. Remove unsupported settings: `Compress=`, `Sector=`

### Build fails with missing bootctl

**Cause**: systemd-boot tools not available

**Solution**: Add `ToolsTree=default` in `[Content]` section

### Build is very slow

**Cause**: Running on x86_64 with arm64 QEMU emulation

**Solution**:
- Build on native ARM64 system (if possible)
- Use GitHub Actions (native ARM64 runners available!)
- Increase RAM if running QEMU locally

### Image won't boot

**Troubleshooting**:
1. Verify image integrity: `sha256sum bluefin-duranium-arm64.raw`
2. Verify successful write: `lsblk /dev/sdX`
3. Check boot order in firmware
4. Try different USB port or device

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more help.

## Build Specifications

### Base OS: Debian Trixie

- Supported architectures: arm64, amd64, others
- Modern packages with security updates
- Large package repository
- Full systemd support

### Image Content

- **OS**: Debian Trixie + systemd-boot
- **Desktop**: GNOME Shell + Bluefin defaults
- **Tools**: starship, zsh, neovim, helix, git, ripgrep, fzf, tmux
- **Dev**: Python, Node.js, Rust, Go, Podman
- **Multimedia**: PipeWire, GStreamer, codecs
- **X13s**: Qualcomm firmware, optimized boot policy

### Image Specs

- **Size** (compressed): ~3 GB
- **Size** (uncompressed): ~10-12 GB
- **Format**: EFI bootable .raw disk image
- **Partitions**: EFI, root, optional data partitions (see mkosi.conf)

## CI/CD Workflows

### On Commit (build-duranium-bluefin.yml)

- Triggered on every push to main branch
- Runs on `ubuntu-24.04-arm` (native ARM64)
- Builds, compresses, uploads artifacts
- Creates releases automatically

### Nightly Builds (continuous-release.yml)

- Runs weekly (configurable)
- Same build process
- Updates release with latest packages

### Manual Builds

```bash
# Using GitHub CLI
gh workflow run build.yml

# Or trigger via GitHub UI
# https://github.com/hanthor/bluefin-duranium/actions
```

## Resources

- **mkosi Documentation**: https://mkosi.dev/
- **Duranium Design**: https://wiki.postmarketos.org/wiki/Duranium_(Immutable_postmarketOS)
- **Debian Trixie**: https://www.debian.org/
- **Bluefin Project**: https://github.com/ublue-os/bluefin
- **X13s Support**: https://github.com/jhovold/linux/wiki/X13s
