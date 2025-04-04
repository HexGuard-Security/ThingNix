# ThingNix

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![NixOS](https://img.shields.io/badge/NixOS-25.05-blue.svg?logo=nixos&logoColor=white)](https://nixos.org)
[![Open Source Hardware](https://img.shields.io/badge/Hardware-Open%20Source-orange.svg?logo=open-source-initiative&logoColor=white)](https://www.oshwa.org)
[![Version](https://img.shields.io/badge/Version-0.1.0--alpha-brightgreen.svg)](https://github.com/HexGuard-Security/ThingNix/releases)
[![Maintained by HexGuard-Security](https://img.shields.io/badge/Maintained%20by-HexGuard--Security-red.svg)](https://github.com/HexGuard-Security)

A reproducible NixOS-based operating system for IoT penetration testing and hardware hacking.

<div align="left">
  <img src="https://nixos.org/logo/nixos-logo-only-hires.png" alt="NixOS Logo" height="100"/>
  <img src="https://upload.wikimedia.org/wikipedia/commons/f/fd/Open-source-hardware-logo.svg" alt="Open Source Hardware Logo" height="100"/>
  <img src="https://camo.githubusercontent.com/f4dde6518bf93a3a17b3b12c9c747d79c0e02984c1ce8f4fdcd0ccb339d02057/68747470733a2f2f7777772e6768696472612d7372652e6f72672f696d616765732f4748494452415f312e706e67" alt="Ghidra Logo" height="100"/>
  <img src="https://www.realtek.com/imgs/realtek_logo.png" alt="RTL-SDR Logo" height="100"/>
</div>

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
<div align="left">
  <img src="https://www.ghidra-sre.org/images/GHIDRA_1.png" alt="Ghidra" height="50"/>
  <img src="https://rada.re/n/r2logo.png" alt="Radare2" height="50"/>
  <img src="https://flashrom.org/_images/flashrom_logo.png" alt="Flashrom" height="50"/>
</div>

- Binwalk
- Ghidra
- Radare2
- OpenOCD
- Flashrom

### RF/SDR
<div align="left">
  <img src="https://www.gnuradio.org/gnuradio_logo_glyphs_as_paths.svg" alt="GNU Radio" height="50"/>
  <img src="https://raw.githubusercontent.com/gqrx-sdr/gqrx/refs/heads/master/new_logo/PNG/horizontal%20color.png" alt="GQRX" height="50"/>
</div>

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
<div align="left">
  <img src="https://www.uvexplorer.com/wp-content/uploads/2023/07/nmap-logo-256x256-1-150x150.png" alt="Nmap" height="50"/>
  <img src="https://raw.githubusercontent.com/bettercap/media/master/logo.png" alt="Bettercap" height="50"/>
  <img src="https://upload.wikimedia.org/wikipedia/commons/3/38/Metasploit_logo_and_wordmark.png" alt="Metasploit" height="50"/>
</div>

- Nmap
- Metasploit
- Bettercap
- RouterSploit
- Expliot

### Utilities
<div align="left">
  <img src="https://upload.wikimedia.org/wikipedia/commons/d/df/Wireshark_icon.svg" alt="Wireshark" height="50"/>
  <img src="https://upload.wikimedia.org/wikipedia/commons/5/51/Sigrok_logo.svg" alt="Sigrok" height="50"/>
  <img src="https://gitlab.com/uploads/-/system/project/avatar/11167699/logo.png" alt="QEMU" height="50"/>
</div>

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
git clone https://github.com/HexGuard-Security/ThingNix.git
cd ThingNix

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

## Community

[![Discord](https://img.shields.io/discord/1234567890?color=7289da&label=Discord&logo=discord&logoColor=white)](https://discord.gg/thingnix)
[![Twitter Follow](https://img.shields.io/twitter/follow/HexGuardSec?style=social)](https://twitter.com/HexGuardSec)

## License

ThingNix is released under the [MIT License](LICENSE).
