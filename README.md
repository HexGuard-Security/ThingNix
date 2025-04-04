# ThingNix

A reproducible NixOS-based operating system for IoT penetration testing and hardware hacking.

## Overview

ThingNix is a specialized NixOS distribution designed for security researchers, penetration testers, and hobbyists who work with Internet of Things (IoT) devices, embedded systems, and RF communications. It provides a declarative, reproducible environment with pre-configured tools for firmware analysis, radio frequency investigation, and hardware exploitation.

Part of the future "NixCraft" series for specialized pentesting domains.

## Key Features

- **Reproducible Environments**: Built on NixOS with Nix Flakes for consistent, declarative configurations
- **Atomic Updates**: Safe system upgrades with rollback capability
- **Pre-configured Hardware Support**: Ready-to-use drivers and udev rules for common pentesting hardware
- **Specialized Tooling**: Curated collection of tools for IoT security research
- **Community-Driven**: Open to contributions and tool suggestions

## Tool Categories

### Firmware Analysis
- Binwalk
- Ghidra
- Radare2
- OpenOCD
- Flashrom

### RF/SDR
- RTL-SDR
- GNURadio
- GQRX
- Inspectrum
- Universal Radio Hacker (URH)
- Multimon-NG

### Zigbee/BLE
- KillerBee
- Bleah
- Crackle
- BTLEJack

### Network/Exploitation
- Nmap
- Metasploit
- Bettercap
- RouterSploit
- Expliot

### Utilities
- Python3
- Wireshark
- QEMU
- Sigrok

## Getting Started

*Instructions will be added once initial ISO builds are available*

## Hardware Compatibility

ThingNix is designed to work with common IoT pentesting hardware:

- SDR receivers (RTL-SDR, HackRF, etc.)
- JTAG/SWD debuggers
- Flash programmers (CH341A, etc.)
- Zigbee/BLE sniffers

See [HARDWARE.md](HARDWARE.md) for detailed compatibility information.

## Building

```bash
# Clone the repository
git clone [https://github.com/yourusername/thingnix.git](https://github.com/yourusername/thingnix.git)
cd thingnix

# Build a minimal ISO with the current config
sudo nixos-generate -f iso --flake .#thingnix
```

## Contributing

ThingNix welcomes contributions! Please feel free to submit issues or pull requests for:

- Adding new tools to the distribution
- Creating Nix packages for tools not currently in nixpkgs
- Improving hardware compatibility
- Developing automation scripts for common tasks
- Documentation improvements
- For tools not available in nixpkgs or issues with current packages, please submit an issue on GitHub.

## Roadmap

- Complete base configuration
- Package missing tools (FAT, ZBGoodLord, SDRangel)
- Test hardware compatibility
- Create automation scripts
- Implement kernel tweaks for SDR latency
- Add USB gadget attack capabilities
- Release first ISO image

## License

ThingNix is released under the MIT License.

## Authors

- [HexGuard Developer](https://github.com/hexGuard-Security)
