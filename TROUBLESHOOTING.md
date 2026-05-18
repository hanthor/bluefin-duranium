# Troubleshooting Guide

Common issues and solutions for Bluefin+Duranium.

## Installation & Boot Issues

### Image won't boot

**Symptoms**: Boot loop, black screen, UEFI error, or no output

**Troubleshooting steps**:

1. **Verify image integrity**
   ```bash
   # Check SHA256 checksums
   sha256sum bluefin-duranium-arm64.raw
   # Compare against CHECKSUMS file from release
   ```

2. **Verify successful flash**
   ```bash
   # Compare file sizes (should match exactly)
   ls -lh bluefin-duranium-arm64.raw
   lsblk /dev/sdX
   ```

3. **Try different USB port/device**
   - USB 3 vs USB 2 can matter
   - Try different USB drives

4. **Reset firmware to defaults**
   - Reboot into firmware setup
   - Load factory defaults
   - Save and exit

5. **Check boot order**
   - Verify USB is first in boot order
   - Some systems default to internal storage

**If still fails**: File a GitHub issue with:
- Device model and firmware version
- Full dd output and file sizes
- Boot messages or error screens

### Stuck on GRUB or bootloader menu

**Solution**:
- System is installed but bootloader not configured
- Press Enter to boot with defaults
- Or select boot entry manually

### "No EFI variables" or UEFI errors

**Symptoms**: Firmware reports UEFI issues during boot

**Solution**:
- The system was booted in BIOS mode instead of UEFI
- Reboot and ensure UEFI/EFI boot mode is enabled in firmware

### Image boots but immediately reboots

**Symptoms**: Boot loop every 3-5 seconds

**Troubleshooting**:

1. **Boot into recovery mode**
   - Press Esc during boot to interrupt systemd-boot
   - Edit boot entry and add `rd.shell` to kernel arguments
   - Press Ctrl+D to continue

2. **Check disk space**
   ```bash
   df -h
   # If root is full, that's a problem
   ```

3. **Check kernel modules**
   ```bash
   lsmod | head -20
   # Verify modules are loading
   ```

4. **Review system logs**
   ```bash
   sudo journalctl -b -e
   # Look for errors in last 50 lines
   ```

**If issue persists**:
- Try different storage device
- Update firmware on X13s
- File GitHub issue with journal output

## Hardware Not Working

### X13s: Camera not detected

**Symptoms**: No camera in cheese or web apps

**Check**:
```bash
# List USB devices
lsusb

# List media devices
ls -la /dev/video*

# Verify driver loaded
lsmod | grep qcom
```

**Solution**:
1. Verify Qualcomm camera firmware is loaded (check journal)
2. Reboot and let firmware initialize (~2 minutes)
3. Try `sudo modprobe qcam` if not auto-loaded

### X13s: Audio not working

**Symptoms**: No sound output, silent system

**Check**:
```bash
# List audio devices
aplay -l
alsamixer

# Check volume levels
amixer get Master
```

**Solution**:
1. Unmute audio: `amixer set Master unmute`
2. Check volume isn't at 0%
3. Reboot if drivers aren't loaded
4. Check GNOME sound settings

### X13s: GPU not working

**Symptoms**: Laggy display, high CPU usage, no 3D acceleration

**Check**:
```bash
# Verify GPU module loaded
lsmod | grep msm

# Check GPU status
ls /sys/kernel/debug/dri/0/
```

**Solution**:
1. Ensure `linux-image-arm64` is installed
2. Reboot to trigger firmware initialization
3. Check kernel messages: `sudo dmesg | grep -i adreno`

### Generic ARM64: Hardware not recognized

**Symptoms**: Devices not showing up, missing drivers

**Troubleshooting**:

1. **List detected devices**
   ```bash
   lspci           # PCIe devices
   lsusb           # USB devices
   lsmod           # Loaded modules
   ```

2. **Load appropriate drivers**
   ```bash
   # For common devices
   sudo modprobe usbhid    # USB keyboards/mice
   sudo modprobe ixgbe     # Network adapters
   ```

3. **Check device tree**
   ```bash
   cat /proc/device-tree/compatible
   # Tells you what hardware is detected
   ```

4. **Add custom kernel arguments**
   - Edit `/efi/loader/entries/` boot entry
   - Add device-specific arguments
   - Example: `usb-storage.quirks=XXXX:YYYY:a,ZZZZ:WWWW:b`

### Networking doesn't work

**Symptoms**: No internet, Wi-Fi won't connect, Ethernet unplugged

**Check**:
```bash
# List network interfaces
ip link

# Check connection status
nmcli device

# View available networks
nmcli device wifi list
```

**Solutions**:

1. **Wi-Fi issues**
   ```bash
   # Reconnect to network
   nmcli device disconnect wlan0
   nmcli device wifi connect "SSID" password "PASSWORD"
   ```

2. **Ethernet not detected**
   ```bash
   # Check if driver loaded
   lsmod | grep ethernet
   # May need to load driver manually
   ```

3. **Verify firmware loaded**
   ```bash
   sudo dmesg | grep -i firmware
   ```

## Performance Issues

### System is slow or laggy

**Check first**:
```bash
# CPU usage
top

# Memory usage
free -h

# Disk I/O
iostat -x 1

# Verify GPU is working
glxinfo | grep "direct rendering"
```

**Solutions**:

1. **Enable GPU acceleration**
   - Reboot to trigger GPU initialization
   - Check if GNOME using GPU: `gnome-shell --version` and GPU status

2. **Reduce running services**
   ```bash
   systemctl list-units --type=service --state=running
   # Disable unnecessary services
   ```

3. **Check disk space**
   ```bash
   df -h
   # If `/` is >90% full, system slows down
   ```

### High CPU usage

**Check**:
```bash
# Top process
top -o %CPU

# Running processes
ps aux --sort=-%cpu | head -20
```

**Solutions**:
1. Kill offending process: `killall process-name`
2. Check for runaway systemd services
3. Verify no build processes running in background

### High memory usage

**Check**:
```bash
# Memory breakdown
free -h
cat /proc/meminfo

# Top memory consumers
ps aux --sort=-%mem | head -20
```

**Solutions**:
1. Close unused applications
2. Check for memory leaks: `ps -eo rss,cmd | sort -rn | head -20`
3. Reboot if persistent

## System Administration Issues

### Can't edit files (Permission denied)

**Symptoms**: `Permission denied` when editing `/etc/`, even with `sudo`

**Reason**: Root filesystem is read-only outside of `/etc` and `/home`

**Solution**:
1. Verify you're editing `/etc/config` (not `/config` or elsewhere)
2. Use `sudo nano` for system files
3. Own files may be writable: `sudo chown root:root file.conf`

### System won't update

**Symptoms**: `systemd-sysupdate` fails or hangs

**Check**:
```bash
sudo systemctl status systemd-sysupdate
sudo journalctl -u systemd-sysupdate -n 50
```

**Solutions**:
1. Check internet connection: `ping 8.8.8.8`
2. Check disk space: `df -h /`
3. Manual update attempt: `sudo systemctl start systemd-sysupdate`
4. Verify system date/time: `date` (if wrong, updates fail)

### Lost network after update

**Symptoms**: Network worked before, broken after `systemd-sysupdate`

**Solution**:
1. Rollback: `systemd-sysupdate` should auto-rollback on failure
2. If stuck: Reboot and select previous boot entry in systemd-boot
3. Check network: `nmcli device`

## Login & Access Issues

### Can't login as root

**Symptoms**: Password rejected or login loop

**Recovery**:
1. Boot into recovery: Press Esc during systemd-boot, add `rd.shell` to kernel line
2. Drop to emergency shell (Ctrl+D)
3. Mount root: `mount /sysroot`
4. Change password: `passwd root`
5. Continue boot: `exit`

### Forgot password

**Solution**:
1. Same as above, use emergency shell
2. Reset password during recovery

### SSH won't connect

**Check**:
```bash
# Is SSH running?
sudo systemctl status ssh

# Can you reach the system?
ping 192.168.1.100

# Get your IP address
ip addr
```

**Solutions**:
1. Enable SSH: `sudo systemctl start ssh`
2. Enable on boot: `sudo systemctl enable ssh`
3. Check firewall isn't blocking port 22
4. Verify correct IP address and credentials

## Software & Package Issues

### Package installation fails

**Symptoms**: `sudo apt install package` fails with errors

**Check**:
```bash
# Update package lists
sudo apt update

# Try install again
sudo apt install package
```

**Solutions**:
1. **Repository errors** - Some repos may not have arm64 packages
2. **Conflicts** - Try `sudo apt install -f` to fix broken packages
3. **Disk full** - Make space: `sudo apt autoremove && sudo apt clean`

### Application won't start

**Symptoms**: App crashes or exits silently

**Debugging**:
```bash
# Run from terminal to see errors
/path/to/app

# Check for missing dependencies
ldd /path/to/app

# Check system logs
sudo journalctl -e -n 50
```

### Missing dependencies

**Symptoms**: "libXXX.so.Y not found"

**Solution**:
```bash
# Find which package provides library
apt-file search libname.so

# Install package
sudo apt install package-name
```

## Filesystem Issues

### Disk is full

**Symptoms**: "No space left on device", even though df shows space

**Causes**:
- `/tmp` is full
- Cache/logs too large
- Many small files using all inodes

**Solutions**:
```bash
# Clean package cache
sudo apt clean

# Clear old logs
sudo journalctl --vacuum=100M

# Find largest files
find / -type f -size +100M 2>/dev/null

# Check inode usage
df -i
```

### Immutable filesystem errors

**Symptoms**: "Read-only file system" when trying to write outside `/etc` or `/home`

**Reason**: This is expected behavior for Duranium

**Solution**:
- Move files to `/home` (user space)
- Edit system config in `/etc/` instead
- Or temporarily remount: `sudo mount -o remount,rw /` (loses on reboot)

## Getting Help

### Before reporting issues

1. **Collect system information**
   ```bash
   # Basic info
   uname -a
   cat /etc/os-release
   
   # Hardware
   lsb_release -a
   lsmod
   
   # Errors
   sudo journalctl -b > /tmp/journal.log
   dmesg > /tmp/dmesg.log
   ```

2. **Reproduce the issue**
   - Write down exact steps
   - Note what you tried to fix it

3. **Search existing issues**
   - Check GitHub: https://github.com/hanthor/bluefin-duranium/issues

### Report on GitHub

Include:
- Device model (X13s, RPi 5, etc.)
- What you're trying to do
- What you expected
- What actually happened
- Error messages or screenshots
- Output of commands above

---

**Not in this list?** File a GitHub issue or check [README.md](README.md) for related projects.
