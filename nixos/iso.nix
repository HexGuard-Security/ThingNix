{ config, lib, pkgs, ... }:

{
  imports = [
    ./configurations/thingnix/hardware/default.nix
    ./modules/base.nix
    ./modules/desktop.nix
    ./modules/security-tools.nix
    ./modules/hardware-tools.nix
    ./modules/networking-tools.nix
    ./modules/firmware-tools.nix
    ./modules/rf-tools.nix
    ./modules/bluetooth-tools.nix
  ];
  
  # Basic system configuration
  system.stateVersion = "23.11";
  
  # Boot configuration
  boot = {
    # Use a stable kernel
    kernelPackages = pkgs.linuxPackages_6_1;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    
    # Enable kernel modules for hardware hacking
    kernelModules = [ 
      "ftdi_sio"    # FTDI serial adapters
      "cp210x"      # Silicon Labs CP210x
      "ch341"       # CH341 (common for flash programmers)
      "cdc_acm"     # USB ACM (many microcontrollers)
    ];
    
    # Increase USB polling rate for low latency SDR
    kernelParams = [ "usbcore.autosuspend=-1" ];
  };

  # Networking
  networking = {
    hostName = "thingnix";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # User configuration
  users.users.thingnix = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "dialout" "plugdev" "wireshark" "uucp" "input" ];
    initialPassword = "thingnix";
    shell = pkgs.zsh;
  };

  # Enable documentation 
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    man.enable = true;
    info.enable = true;
  };

  # Enable nix flakes
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
    };
  };

  # Internationalization
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Time zone
  time.timeZone = "UTC";

  # Security settings
  security = {
    sudo.wheelNeedsPassword = false; # For ease of use in live environment
    polkit.enable = true;
  };
  
  # Explicitly set ISO image properties
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  
  # Disable virtualisation options that might cause issues
  virtualisation = {
    docker.enable = false;
    libvirtd.enable = false;
    vmware.guest.enable = false;
    virtualbox.guest.enable = false;
  };
}
