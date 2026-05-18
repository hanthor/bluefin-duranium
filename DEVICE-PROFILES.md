# Duranium+Bluefin Device Profiles

Question: What device profiles should we build for?

The standard Duranium project typically builds for multiple postmarketOS devices.
This Duranium+Bluefin variant should support the same device profiles.

Common postmarketOS devices include:
- **aarch64 (arm64)**: Qualcomm Snapdragon (X13s, Poco F3, etc.), Apple silicon, other ARM boards
- **armv7**: 32-bit ARM devices
- **x86_64**: Intel/AMD laptops and desktops

## Proposed Profiles

Based on Bluefin + X13s focus:

1. **x13s-gnome** - Thinkpad X13s with GNOME (primary)
2. **generic-gnome-arm64** - Generic arm64 with GNOME
3. **generic-gnome-amd64** - Generic x86_64 with GNOME (optional)

Each profile would include:
- Device-specific kernel args
- Device-specific firmware
- Device-specific modules
- Shared Bluefin packages/desktop

## Current implementation

The mkosi approach builds for a single target (configured in mkosi.conf).
To support multiple profiles, we have options:

1. **mkosi profiles**: Use mkosi.d/ matrix to define multiple outputs
2. **Build wrapper script**: Loop over device profiles, calling mkosi with overrides
3. **Device-specific Containerfiles**: Separate Containerfile per device profile

Which approach would you prefer?
