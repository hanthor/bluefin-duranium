# Building Duranium+Bluefin

## Method 1: mkosi (Recommended - requires mkosi installed)

```bash
cd /tmp/duranium-bluefin

# Show build plan
mkosi -C . summary

# Build for arm64
mkosi -C . -o arm64 build

# Output image location
ls -lh mkosi.output/duranium-bluefin-*.raw
```

### mkosi Configuration

- **Base**: postmarketOS edge (Alpine Linux)
- **Package sets**: Base system + Bluefin packages + X13s firmware
- **System files**: GNOME defaults, branding, services
- **Finalize**: X13s boot policy, module ordering, gschema cache

## Method 2: Containerfile (Docker/Podman - alternative)

If mkosi is not available, build a container image:

```bash
podman build -f Containerfile.arm64 -t duranium-bluefin:latest .
```

The Containerfile approach:
1. Starts from postmarketOS base
2. Layers Bluefin packages
3. Applies system files and GNOME defaults
4. Configures X13s boot policy
5. Exports as OCI container

## Method 3: Manual assembly (development)

For quick iteration on specific components:

```bash
# Test GNOME schema compilation
glib-compile-schemas system_files/usr/share/glib-2.0/schemas

# Test dracut config
dracut --show-modules | grep -E "msm|panel_edp|nvme"

# Validate module softdeps
modprobe --show-depends qcom_q6v5_pas
```

## X13s-Specific Configuration

The build includes X13s bring-up:

1. **Boot arguments** (`/etc/x13s-bootargs.reference`):
   - `arm64.nopauth` - Pointer auth disabled
   - `clk_ignore_unused pd_ignore_unused` - Power management
   - `efi=noruntime` - Skip unsafe Qualcomm UEFI services
   - `rd.driver.blacklist=qcom_q6v5_pas` - Module loading order

2. **Initramfs drivers** (`/etc/dracut.conf.d/x13s-initramfs.conf`):
   - GPU, panel, NVMe, USB, Qualcomm power/device mapper

3. **Module ordering** (`/etc/modules-load.d/x13s-remoteproc.conf`):
   - `qcom_pd_mapper` before `qcom_q6v5_pas`

## Deployment

Once built, deploy to X13s:

```bash
# Direct to block device (if built as .raw)
sudo dd if=duranium-bluefin-*.raw of=/dev/sdX bs=4M conv=fsync

# Or use standard bootloader/ISO installation methods
```

## Validation

After deployment:

```bash
# Check os-release
cat /etc/os-release | grep -E "VARIANT|PRETTY_NAME"

# Check X13s modules loaded
lsmod | grep -E "qcom_pd_mapper|msm|panel_edp"

# Check GNOME defaults applied
gsettings get org.gnome.shell favorite-apps
```
