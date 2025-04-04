{ config, pkgs, lib, ... }:

{
  # Bluetooth and BLE (Bluetooth Low Energy) tools for IoT security testing
  
  # Install Bluetooth-related packages and helper scripts
  environment.systemPackages = with pkgs; [
    # Core Bluetooth tools
    bluez      # includes gattool, hcitool, and other BT utilities
    bluez-tools
    bluez-alsa
    
    # BLE scanning and sniffing
    aioblescan  # Library to listen for BLE advertized packets
    # gattool is included in the bluez package
    # btlejack - removed due to compatibility issues
    
    # Bluetooth security testing
    crackle # Bluetooth Smart (BLE) encryption cracking
    # ubertooth - removed due to compatibility issues
    # rfcat - removed due to compatibility issues
    
    # Bluetooth utilities
    blueman
    
    # Zigbee tools
    killerbee
    
    # Python libraries for BLE development and testing
    python3
    python3Packages.bluepy
    python3Packages.pybluez
    python3Packages.gattlib
    
    # Hardware support
    # ubertooth - removed due to compatibility issues
    # rfcat - removed due to compatibility issues
    
    # Bluetooth development
    # btstack - removed due to compatibility issues
    
    # Misc
    nrf-tools # Nordic Semiconductor tools for BLE development
    
    # Visualization tools
    wireshark # For Bluetooth protocol analysis
    
    # Bluetooth scanners and info tools
    hcitool
    
    # BLE exploitation
    bettercap # Has BLE scanning/exploitation modules
    
    # Documentation
    bluez-docs
    
    # Helper scripts for Bluetooth analysis
    (writeShellScriptBin "ble-scan" ''
      #!/bin/sh
      # Scan for BLE devices and display detailed information
      
      echo "Scanning for BLE devices..."
      ${pkgs.bluez}/bin/hcitool lescan --duplicate
    '')
    
    (writeShellScriptBin "bt-monitor" ''
      #!/bin/sh
      # Monitor all Bluetooth traffic
      
      echo "Starting Bluetooth traffic monitor..."
      ${pkgs.bluez}/bin/btmon
    '')
    
    (writeShellScriptBin "zigbee-scan" ''
      #!/bin/sh
      # Scan for Zigbee devices
      
      if [ $# -lt 1 ]; then
        echo "Usage: zigbee-scan <interface>"
        echo "Example: zigbee-scan /dev/ttyUSB0"
        exit 1
      fi
      
      INTERFACE=$1
      
      echo "Scanning for Zigbee devices on $INTERFACE..."
      ${pkgs.killerbee}/bin/zbstumbler -i $INTERFACE
    '')
    
    (writeShellScriptBin "ble-info" ''
      #!/bin/sh
      # Get detailed information about a BLE device
      
      if [ $# -lt 1 ]; then
        echo "Usage: ble-info <MAC_address>"
        echo "Example: ble-info 00:11:22:33:44:55"
        exit 1
      fi
      
      MAC=$1
      
      echo "Getting information for device $MAC..."
      ${pkgs.bluez}/bin/gatttool -b $MAC --primary
      echo "\nServices discovered. Retrieving characteristics..."
      ${pkgs.bluez}/bin/gatttool -b $MAC --characteristics
    '')
    
    (writeShellScriptBin "bt-pair-crack" ''
      #!/bin/sh
      # Use Crackle to decrypt and crack Bluetooth pairing
      
      if [ $# -lt 1 ]; then
        echo "Usage: bt-pair-crack <pcap_file>"
        echo "Example: bt-pair-crack capture.pcap"
        exit 1
      fi
      
      PCAP=$1
      
      echo "Analyzing Bluetooth pairing in $PCAP..."
      ${pkgs.crackle}/bin/crackle -i $PCAP -o decrypted.pcap
    '')
  ];
  
  # Enable Bluetooth services
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        ControllerMode = "dual";
        FastConnectable = true;
        JustWorksRepairing = "always";
        Privacy = "device";
      };
    };
  };
  
  # Bluetooth service configuration for security testing
  services.blueman.enable = true;
  
  # Create workshop directory structure for Bluetooth analysis
  system.activationScripts.bluetoothWorkshop = ''
    mkdir -p /home/thingnix/bluetooth-workshop/{captures,analysis,keys}
    chown -R thingnix:users /home/thingnix/bluetooth-workshop
  '';
  
  # Add udev rules for Bluetooth hardware
  services.udev.extraRules = ''
    # Ubertooth
    # SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6002", GROUP="plugdev", MODE="0660"
    
    # Sniffle BLE Sniffer
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="16b3", GROUP="plugdev", MODE="0660"
    
    # Nordic Semiconductor nRF development devices
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", GROUP="plugdev", MODE="0660"
    
    # RFCat
    # SUBSYSTEM=="usb", ATTRS{idVendor}=="0451", ATTRS{idProduct}=="4715", GROUP="plugdev", MODE="0660"
  '';
  
  # Configure Bluetooth hardware for optimal performance
  boot.extraModprobeConfig = ''
    # Increase buffer sizes for Bluetooth sniffers
    options bluetooth hci_reserve_dev=1
  '';
  
  # Add desktop shortcuts for common Bluetooth tools
  environment.etc."xdg/autostart/bluetooth-reset.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Bluetooth Reset
    Comment=Reset Bluetooth adapter at startup
    Exec=sh -c "sleep 3 && ${pkgs.bluez}/bin/hciconfig hci0 reset"
    Terminal=false
    Categories=System;
    NoDisplay=true
    X-GNOME-Autostart-enabled=true
  '';
}
