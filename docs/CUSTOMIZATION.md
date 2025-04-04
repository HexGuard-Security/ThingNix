# ThingNix Customization Guide

This guide explains how to customize your ThingNix installation to better suit your needs and preferences.

## Table of Contents
- [Visual Customization](#visual-customization)
- [Tool Configuration](#tool-configuration)
- [Adding Custom Tools](#adding-custom-tools)
- [System Configuration](#system-configuration)
- [User Environment](#user-environment)

## Visual Customization

### Desktop Wallpaper

To change the desktop wallpaper:

1. Replace the files in `assets/wallpapers/` with your custom images
2. Ensure your images are at least 1920x1080 resolution
3. Rebuild the system or manually apply:
   ```bash
   cp /path/to/your/wallpaper-01.png /etc/nixos/wallpapers/wallpaper-01.png
   cp /path/to/your/wallpaper-02.png /etc/nixos/wallpapers/wallpaper-02.png
   cp /path/to/your/wallpaper-03.png /etc/nixos/wallpapers/wallpaper-03.png
   cp /path/to/your/wallpaper-04.png /etc/nixos/wallpapers/wallpaper-04.png
   cp /path/to/your/wallpaper-05.png /etc/nixos/wallpapers/wallpaper-05.png
   ```

### Themes

ThingNix comes with light and dark themes. To switch between them:

1. Open XFCE Settings Manager → Appearance
2. Select either "ThingNix Dark" or "ThingNix Light"
3. Rebuild the system or manually apply:
   ```bash
   cp /path/to/your/theme.theme /etc/nixos/themes/thingnix-theme.theme
   ```

To create a custom theme:

1. Copy an existing theme from `assets/themes/` to `assets/themes/custom/your-theme-name.theme`
2. Edit the color values and settings
3. Rebuild or manually install your theme

### Icons

To customize application icons:

1. Replace or add icons to `assets/icons/desktop/` directory
2. For tool-specific icons, use `assets/icons/tools/`
3. Follow the size guidelines in the README.md in those directories

### Terminal Appearance

To customize the terminal appearance:

1. Open Terminal → Edit → Preferences
2. Adjust colors, fonts, and transparency settings
3. Save as a new profile

## Tool Configuration

### Default Tool Settings

Key tools in ThingNix have custom configurations in:

- `/etc/thingnix/tool-configs/`

To modify these:

1. Copy the configuration file
2. Make your changes
3. Either rebuild or replace the original

### Creating Tool Groups

You can organize related tools by:

1. Creating a new desktop folder
2. Adding related tool shortcuts
3. Adding a custom `*.desktop` file to launch related tools together

Example desktop file to launch multiple SDR tools:
```
[Desktop Entry]
Type=Application
Name=SDR Toolkit
Comment=Launch all SDR tools
Exec=bash -c "gqrx & gnuradio-companion & urh"
Icon=/path/to/custom/icon.png
Terminal=false
Categories=SDR;Radio;
```

## Adding Custom Tools

### Temporary Installation

For quick testing of tools not included in ThingNix:

```bash
# Using Python pip
pip install --user tool_name

# Using Nix package manager
nix-env -iA nixpkgs.package_name
```

### Permanent Installation

To permanently add a tool to your ThingNix build:

1. Create a custom package configuration in `nixos/packages/`
2. Add the package to the relevant module file
3. Rebuild your system

Example package configuration (`nixos/packages/my-tool.nix`):
```nix
{ lib, stdenv, fetchFromGitHub, cmake, boost }:

stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "username";
    repo = "my-tool";
    rev = "v${version}";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost ];

  meta = with lib; {
    description = "Custom security tool";
    homepage = "https://github.com/username/my-tool";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
```

Then add it to the relevant module file:
```nix
environment.systemPackages = with pkgs; [
  # Existing packages...
  (callPackage ../packages/my-tool.nix {})
];
```

## System Configuration

### Hardware Support

To add support for additional hardware:

1. Create or modify udev rules in `nixos/hardware/`
2. Add necessary kernel modules to the configuration
3. Ensure proper permissions are set

Example udev rule for a custom device:
```
# Custom rule for SuperFooDevice
SUBSYSTEM=="usb", ATTRS{idVendor}=="abcd", ATTRS{idProduct}=="1234", GROUP="thingnix", MODE="0660", SYMLINK+="superfoo"
```

### Network Configuration

To modify network settings:

1. Edit the network options in `nixos/configurations/thingnix/default.nix`
2. Change wireless, firewall, or proxy settings as needed

## User Environment

### Shell Customization

To customize your shell:

1. Edit `nixos/home/thingnix.nix`
2. Add or modify shell aliases, functions, and settings

### Default Applications

To change default applications:

1. Modify XFCE settings via the Settings Manager
2. Edit xdg associations in `nixos/home/thingnix.nix`

### Keyboard Shortcuts

To customize keyboard shortcuts:

1. Open XFCE Settings Manager → Keyboard → Application Shortcuts
2. Add or modify shortcuts for your most-used tools

## Advanced Customization

### Creating Custom Modules

For significant customizations, create your own module:

1. Create a new file in `nixos/modules/` (e.g., `my-custom-module.nix`)
2. Define your custom configuration
3. Import it in `nixos/configurations/thingnix/default.nix`

Example custom module:
```nix
{ config, pkgs, lib, ... }:

{
  # Custom environment settings
  environment.variables = {
    MY_CUSTOM_VAR = "value";
  };
  
  # Add specific tools
  environment.systemPackages = with pkgs; [
    my-custom-tool
    another-tool
  ];
  
  # Custom system services
  systemd.services.my-custom-service = {
    description = "My Custom Service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.my-custom-tool}/bin/start-service";
      Restart = "on-failure";
    };
  };
}
```

### Persistence Between Reboots

ThingNix is designed for reproducibility, but you can make certain directories persistent:

1. Create a persistent data partition
2. Mount it at boot time
3. Symlink important directories to the persistent storage

Specify persistent directories in your configuration:
```nix
fileSystems."/persistent" = {
  device = "/dev/disk/by-label/persistent";
  fsType = "ext4";
  options = [ "noatime" ];
};

system.activationScripts.persistent = ''
  mkdir -p /persistent/home
  ln -sfn /persistent/home /home/thingnix
'';
```
