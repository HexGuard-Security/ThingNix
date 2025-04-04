{ config, pkgs, lib, ... }:

{
  # Hardware-specific tools for embedded systems, IoT devices, and hardware hacking
  
  # Install hardware-related packages
  environment.systemPackages = with pkgs; [
    # JTAG/SWD debugging
    openocd
    stlink
    
    # Embedded systems programming
    avrdude
    arduino
    platformio
    
    # FPGA tools
    icestorm
    nextpnr
    yosys
    
    # Firmware flashing
    flashrom
    esptool
    
    # Logic analyzer
    sigrok
    pulseview
    
    # Bus analyzers
    i2c-tools
    spitools
    
    # GPIO tools
    wiringpi
    libgpiod
    
    # EEPROM/Flash tools
    # Specific tools for CH341A programmer
    
    # USB analyzers
    usbutils
    
    # PCB design tools
    kicad
    
    # Hardware simulation
    ngspice
    
    # Serial communication
    minicom
    picocom
    screen
    
    # Hardware monitoring
    lm_sensors
    smartmontools
    
    # Embedded Linux
    buildroot
    
    # Board support packages
    # Packages for popular IoT development boards
    # (Raspberry Pi, ESP32, Arduino, etc.)
    
    # Cross-compilation tools
    gcc-arm-embedded
    
    # Hardware documentation
    
    # Hardware testing
    stress-ng
    memtester
    
    # Oscilloscope software support
    # For compatible USB oscilloscopes
    
    # Power management tools
    powertop
    tlp
    
    # Hardware reverse engineering
    ghidra
    radare2
  ];
  
  # Hardware access permissions
  services.udev.extraRules = ''
    # USB to UART adapters
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0660"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", GROUP="dialout", MODE="0660"
    
    # USB logic analyzers
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0925", ATTRS{idProduct}=="3881", GROUP="plugdev", MODE="0660"
    
    # Programmable USB devices
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", GROUP="dialout", MODE="0660"
  '';
  
  # Add hardware-specific configuration for common development boards
  boot.extraModprobeConfig = ''
    # Realtek USB Ethernet adapter common in IoT dev kits
    options r8152 rx_copybreak=0
    
    # Enable USB serial converter debug
    options usbserial debug=1
  '';
  
  # Additional settings for hardware testing
  boot.kernel.sysctl = {
    # Allow non-root users to capture USB packets
    "dev.usbmon.max_buffers" = 32768;
    
    # Increase shared memory limits for hardware simulators
    "kernel.shmmax" = 68719476736;
    "kernel.shmall" = 4294967296;
  };
  
  # Enable real-time capabilities for hardware testing
  security.pam.loginLimits = [
    { domain = "@realtime"; type = "-"; item = "rtprio"; value = "99"; }
    { domain = "@realtime"; type = "-"; item = "memlock"; value = "unlimited"; }
    { domain = "@realtime"; type = "-"; item = "nice"; value = "-20"; }
  ];
  
  # Add user to appropriate hardware groups
  users.groups = {
    realtime = {};
    dialout = {}; # Already exists in most Linux systems
    plugdev = {}; # Already exists in most Linux systems
  };
  
  users.users.thingnix.extraGroups = [ "realtime" "dialout" "plugdev" ];
}
