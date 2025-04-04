# ThingNix Icons

This directory contains icon assets for the ThingNix operating system.

## Icon Structure

- `thingnix-icon.svg` - Main ThingNix logo in scalable vector format
- `desktop/` - Desktop application icons
  - `thingnix-desktop.svg` - Main ThingNix desktop application icon
- `tools/` - Security tool specific icons
  - `firmware-icon.svg` - Icon for firmware analysis tools
  - `sdr-icon.svg` - Icon for SDR and RF tools
  - `bluetooth-icon.svg` - Icon for Bluetooth/Zigbee tools
  - `network-icon.svg` - Icon for network/exploitation tools
  - `utilities-icon.svg` - Icon for general utilities
- `png/` - Generated PNG versions in various resolutions (after running generate-pngs.sh)

## PNG Generation

We've included a script to generate PNG versions of all SVG icons in multiple resolutions:

```bash
# Make sure the script is executable
chmod +x generate-pngs.sh

# Run the script to generate PNG files
./generate-pngs.sh
```

This script requires Inkscape to be installed on your system.

## How to Customize

1. Replace any icon with your custom version using the same filename
2. Run the `generate-pngs.sh` script to create PNG versions in multiple resolutions (16x16, 32x32, 48x48, 128x128, 256x256)
3. SVG format is preferred for scalability

## Icon Requirements

- Main logo should be recognizable even at small sizes
- Tool icons should visually represent their function
- Follow the ThingNix color palette when possible:
  - Primary blue: #4a86e8
  - Accent red: #ff5555
  - Accent green: #50fa7b
  - Background: #1a1a1a
  - Secondary background: #2c2c2c
- Transparent background for PNG files
- Optimized file sizes
