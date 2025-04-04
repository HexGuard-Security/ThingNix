{ config, lib, pkgs, ... }:

{
  # Support for hardware debugging tools like JTAG, SWD, SPI, I2C, etc.
  
  # Enable I2C
  hardware.i2c.enable = true;
  
  # Enable SPI
  # NixOS doesn't have a direct option for SPI, so we ensure kernel modules are loaded
  boot.kernelModules = [
    "spidev"    # SPI interface
    "i2c-dev"   # I2C interface
  ];
  
  # Add udev rules for common debugging hardware
  services.udev.extraRules = ''
    # Bus Pirate
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0660", SYMLINK+="buspirate"
    
    # ST-Link debuggers (V2, V2-1, V3)
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="3748", GROUP="dialout", MODE="0660"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="374b", GROUP="dialout", MODE="0660"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="374d", GROUP="dialout", MODE="0660"
    
    # FTDI (FT232/FT2232) - common for many debugging devices
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0660"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", GROUP="dialout", MODE="0660"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", GROUP="dialout", MODE="0660"
    
    # J-Link
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0101", GROUP="dialout", MODE="0660"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", GROUP="dialout", MODE="0660"
    
    # CH341 programmer (common for SPI flash programming)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="5512", GROUP="dialout", MODE="0660"
    
    # Black Magic Probe
    SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic GDB Server", SYMLINK+="ttyBmpGdb"
    SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic UART Port", SYMLINK+="ttyBmpTarg"
  '';
  
  # Add support for GPIO
  environment.systemPackages = with pkgs; [
    wiringpi  # GPIO interface library
    libgpiod  # GPIO library
  ];
}
