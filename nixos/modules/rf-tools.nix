{ config, pkgs, lib, ... }:

{
  # Radio Frequency (RF) and Software Defined Radio (SDR) tools
  
  # Install RF and SDR tools and helper scripts
  environment.systemPackages = with pkgs; [
    # Core SDR packages - keeping rtl-sdr as it's essential
    # gnuradio - commented out for build stability
    # gr-osmosdr - commented out for build stability
    # hackrf - commented out for build stability
    rtl-sdr
    # limesuite - commented out for build stability
    # soapysdr - commented out for build stability
    
    # SDR applications
    # gqrx - commented out for build stability
    # sdrpp - commented out for build stability
    # sdrangel - commented out for build stability
    # cubicsdr - commented out for build stability
    
    # Signal analysis
    # inspectro - commented out for build stability
    # inspectrum - commented out for build stability
    # baudline - commented out for build stability
    # gqrx-scanner - commented out for build stability
    
    # Protocol analysers
    # gnuradio-osmosdr - commented out for build stability
    # gnuradio-rds - commented out for build stability
    # gnuradio-iqbal - commented out for build stability
    # gnuradio-gsm - commented out for build stability
    # gnuradio-limesdr - commented out for build stability
    # gnuradio-rftap - commented out for build stability
    
    # Specific protocols
    # multimon-ng - commented out for build stability
    # rtl-433 - commented out for build stability
    # kalibrate-rtl - commented out for build stability
    
    # Zigbee and BLE tools
    # rfcat - removed due to compatibility issues
    # killerbee - commented out for build stability
    
    # Bluetooth tools
    # ubertooth - removed due to compatibility issues
    # btscanner - commented out for build stability
    # crackle - commented out for build stability
    
    # RF replay/fuzzing
    # rfcat - removed due to compatibility issues
    # rflib - commented out for build stability
    
    # RFID tools
    # proxmark3 - commented out for build stability
    # mfoc - commented out for build stability
    # mfcuk - commented out for build stability
    # libnfc - commented out for build stability
    
    # Frequency utilities
    # sox - commented out for build stability
    # sox-fmt-all - commented out for build stability
    
    # Spectrum analysis
    # rtl-sdr - already included
    # hackrf - commented out for build stability
    # airspy - commented out for build stability
    
    # Misc tools
    # gnuradio-iqbal - commented out for build stability
    # gnuradio-rds - commented out for build stability
    # bladerf - commented out for build stability
    # limesuite - commented out for build stability
    
    # Wireless tools
    # aircrack-ng - commented out for build stability
    # kismet - commented out for build stability
    # wireshark - commented out for build stability
    # wireshark-cli - commented out for build stability
    
    # Radio signal identification 
    # sigrok - commented out for build stability
    # sigrok-cli - commented out for build stability
    
    # Frequency databases
    # (usually provided as separate data files or services)
    
    # Custom scripts for RF analysis
    (writeShellScriptBin "scan-frequencies" ''
      #!/bin/sh
      # Scan frequency ranges with rtl_power
      
      if [ $# -lt 3 ]; then
        echo "Usage: scan-frequencies <start_freq> <end_freq> <output_file> [time]"
        echo "Example: scan-frequencies 400M 500M scan_results.csv 1h"
        exit 1
      fi
      
      START=$1
      END=$2
      OUTPUT=$3
      TIME=''${4:-1h}
      
      echo "Scanning frequencies from $START to $END for $TIME..."
      rtl_power -f "$START:$END:1M" -g 50 -i 1 -e "$TIME" "$OUTPUT"
      echo "Done! Results saved to $OUTPUT"
    '')
    
    (writeShellScriptBin "decode-signal" ''
      #!/bin/sh
      # Helper to decode common radio signals
      
      if [ $# -lt 2 ]; then
        echo "Usage: decode-signal <type> <device>"
        echo "Available types: fm, am, pocsag, flex, weather, adsb"
        echo "Example: decode-signal fm rtl_tcp::1234"
        exit 1
      fi
      
      TYPE=$1
      DEVICE=$2
      
      case "$TYPE" in
        fm)
          echo "Starting FM receiver..."
          rtl_fm -f 89.5M -M wbfm -s 200000 -r 48000 - | play -r 48000 -t raw -e s -b 16 -c 1 -V1 -
          ;;
        am)
          echo "Starting AM receiver..."
          rtl_fm -f 1000k -M am -s 12k -r 12k - | play -r 12k -t raw -e signed-integer -b 16 -c 1 -V1 -
          ;;
        pocsag)
          echo "Starting POCSAG decoder..."
          rtl_fm -f 152.5M -g 42 - | multimon-ng -t raw -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -f alpha -
          ;;
        flex)
          echo "Starting FLEX decoder..."
          rtl_fm -f 930.5M -g 42 - | multimon-ng -t raw -a FLEX -f alpha -
          ;;
        weather)
          echo "Starting NOAA Weather decoder..."
          rtl_fm -f 162.4M -s 48k - | multimon-ng -t raw -a AFSK1200 -a AFSK2400 -a AFSK2400_2 -a AFSK2400_3 -
          ;;
        adsb)
          echo "Starting ADS-B decoder..."
          rtl_adsb
          ;;
        *)
          echo "Unknown type: $TYPE"
          exit 1
          ;;
      esac
    '')
  ];
  
  # Add udev rules for various SDR devices
  services.udev.extraRules = ''
    # RTL-SDR
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", GROUP="plugdev", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="plugdev", MODE="0666"
    
    # HackRF
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="604b", SYMLINK+="hackrf-%k", MODE="660", GROUP="plugdev"
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", SYMLINK+="hackrf-jawbreaker-%k", MODE="660", GROUP="plugdev"
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", SYMLINK+="rad1o-%k", MODE="660", GROUP="plugdev"
    ATTR{idVendor}=="1fc9", ATTR{idProduct}=="000c", SYMLINK+="nxp-dfu-%k", MODE="660", GROUP="plugdev"
    ATTR{idVendor}=="1fc9", ATTR{idProduct}=="000d", SYMLINK+="nxp-dfu-%k", MODE="660", GROUP="plugdev"
    
    # SDRplay
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1df7", ATTRS{idProduct}=="2500", MODE="0660", GROUP="plugdev"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1df7", ATTRS{idProduct}=="3000", MODE="0660", GROUP="plugdev"
    
    # BladeRF
    ATTR{idVendor}=="2cf0", ATTR{idProduct}=="5246", MODE="660", GROUP="plugdev"
    
    # LimeSDR
    SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="6108", GROUP="plugdev", MODE="0666"
    SUBSYSTEM=="usb", ATTR{idVendor}=="04b4", ATTR{idProduct}=="00f3", GROUP="plugdev", MODE="0666"
    
    # YARD Stick One
    ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="605b", SYMLINK+="YARD-Stick-One-%k", MODE="660", GROUP="plugdev"
    
    # Ubertooth - commented out due to compatibility issues
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6002", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6003", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6004", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6005", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6006", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6007", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6008", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6009", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="600a", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="600b", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="600c", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="600d", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="600e", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="600f", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6010", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6011", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6012", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6013", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6014", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6015", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6016", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6017", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6018", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6019", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="601a", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="601b", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="601c", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="601d", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="601e", MODE="0660", GROUP="plugdev"
    # ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="601f", MODE="0660", GROUP="plugdev"
  '';
  
  # Group configuration for SDR/RF devices
  users.groups.plugdev = {};
}
