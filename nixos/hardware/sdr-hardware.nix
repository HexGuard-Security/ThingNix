{ config, lib, pkgs, ... }:

{
  # Support for Software Defined Radio hardware
  
  # Enable rtlsdr support
  hardware.rtl-sdr.enable = true;
  
  # Enable udev rules for common SDR hardware
  services.udev.packages = with pkgs; [
    rtl-sdr
    hackrf
    limesuite
  ];
  
  # Blacklist DVB-T drivers that may interfere with RTL-SDR
  boot.blacklistedKernelModules = [
    "dvb_usb_rtl28xxu"
    "rtl2832"
    "rtl2830"
  ];
  
  # Increase USB buffer size for SDR devices
  boot.kernelParams = [
    "usbcore.usbfs_memory_mb=1000"  # Increase USB buffer for high sample rates
  ];
  
  # Group membership for SDR access
  users.groups.sdr = {};
  users.users.thingnix.extraGroups = [ "sdr" "plugdev" ];
  
  # Add udev rules to allow non-root users to access SDR devices
  services.udev.extraRules = ''
    # RTL-SDR
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", GROUP="sdr", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="sdr", MODE="0666"
    
    # HackRF
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", GROUP="sdr", MODE="0666"
    
    # LimeSDR
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="6108", GROUP="sdr", MODE="0666"
  '';
}
