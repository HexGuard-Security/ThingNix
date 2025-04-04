{ config, pkgs, lib, ... }:

{
  # Radio Frequency (RF) and Software Defined Radio (SDR) tools
  
  # Install RF and SDR tools
  environment.systemPackages = with pkgs; [
    # Core SDR packages
    gnuradio
    gr-osmosdr
    hackrf
    rtl-sdr
    limesuite
    soapysdr
    
    # SDR applications
    gqrx
    sdrpp
    sdrangel
    cubicsdr
    
    # Signal analysis
    inspectrum
    baudline
    qspectrumanalyzer
    
    # Protocol analysis and decoding
    multimon-ng
    direwolf # AX.25 decoder
    dump1090 # ADS-B decoder
    
    # Radio automation
    gnuradio-osmosdr
    
    # Universal Radio Hacker
    urh
    
    # RF scanning
    rtl_433
    
    # Satellite tools
    gnss-sdr
    
    # RF utilities
    airspy
    
    # Libraries
    liquid-dsp
    
    # Signal processing
    sox
    
    # Python tools for SDR
    python3
    python3Packages.numpy
    python3Packages.scipy
    python3Packages.matplotlib
    python3Packages.pyrtlsdr
    
    # DAB/DAB+ tools
    dabtools
    
    # FM tools
    redsea # RDS decoder
    
    # Recording and playback
    audacity
    
    # Miscellaneous utilities
    kalibrate-rtl # GSM frequency calibration
    
    # GNU Radio companion
    gnuradio-with-packages
    
    # Development tools for SDR
    cmake
    gcc
    
    # Documentation
    gnuradio-manual
    
    # Frequency databases
    # (usually provided as separate data files or services)
  ];
  
  # Create helpful scripts for RF analysis
  environment.systemPackages = with pkgs; [
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
      
      echo "Scanning from $START to $END for $TIME, saving to $OUTPUT"
      ${rtl-sdr}/bin/rtl_power -f $START:$END:1M -g 50 -i 10 -e $TIME $OUTPUT
      
      echo "Scan complete. Results saved to $OUTPUT"
      echo "To visualize: use heatmap.py or import into spreadsheet software"
    '')
    
    (writeShellScriptBin "decode-signal" ''
      #!/bin/sh
      # Quick signal decoding utility
      
      if [ $# -lt 2 ]; then
        echo "Usage: decode-signal <protocol> <frequency> [gain] [ppm]"
        echo "Supported protocols: weather, tpms, doorbell, car, am, fm, flex"
        exit 1
      fi
      
      PROTOCOL=$1
      FREQ=$2
      GAIN=''${3:-50}
      PPM=''${4:-0}
      
      case "$PROTOCOL" in
        weather)
          echo "Decoding weather station signals at $FREQ MHz"
          ${rtl_433}/bin/rtl_433 -f $FREQ"e6" -g $GAIN -p $PPM
          ;;
        tpms)
          echo "Decoding tire pressure monitoring signals at $FREQ MHz"
          ${rtl_433}/bin/rtl_433 -f $FREQ"e6" -g $GAIN -p $PPM -R 13 -R 51 -R 60 -R 82 -R 83 -R 84 -R 86 -R 89
          ;;
        doorbell)
          echo "Decoding doorbell/chime signals at $FREQ MHz"
          ${rtl_433}/bin/rtl_433 -f $FREQ"e6" -g $GAIN -p $PPM -R 19 -R 30 -R 31
          ;;
        car)
          echo "Decoding car remote signals at $FREQ MHz"
          ${rtl_433}/bin/rtl_433 -f $FREQ"e6" -g $GAIN -p $PPM -R 15 -R 39
          ;;
        am)
          echo "Listening to AM radio at $FREQ MHz"
          ${rtl-sdr}/bin/rtl_fm -M am -f $FREQ"e6" -g $GAIN -p $PPM | ${sox}/bin/play -r 24k -t raw -e signed-integer -b 16 -c 1 -V1 -
          ;;
        fm)
          echo "Listening to FM radio at $FREQ MHz"
          ${rtl-sdr}/bin/rtl_fm -M fm -f $FREQ"e6" -g $GAIN -p $PPM | ${sox}/bin/play -r 24k -t raw -e signed-integer -b 16 -c 1 -V1 -
          ;;
        flex)
          echo "Decoding FLEX pager signals at $FREQ MHz"
          ${multimon-ng}/bin/rtl_fm -f $FREQ"e6" -g $GAIN -p $PPM -s 22050 | ${multimon-ng}/bin/multimon-ng -t raw -a FLEX -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -f alpha -
          ;;
        *)
          echo "Unsupported protocol: $PROTOCOL"
          exit 1
          ;;
      esac
    '')
    
    (writeShellScriptBin "start-gqrx" ''
      #!/bin/sh
      # Start GQRX with optimal settings
      
      # Kill any existing instances
      pkill -f gqrx || true
      
      # Set realtime priority if possible
      if [ "$(id -u)" = "0" ]; then
        echo "Starting GQRX with realtime priority"
        ${coreutils}/bin/nice -n -20 ${gqrx}/bin/gqrx
      else
        echo "Starting GQRX (use sudo for realtime priority)"
        ${gqrx}/bin/gqrx
      fi
    '')
  ];
  
  # Set up udev rules for SDR devices
  services.udev.extraRules = ''
    # RTL-SDR
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2832", GROUP="plugdev", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", GROUP="plugdev", MODE="0666"
    
    # HackRF
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6089", GROUP="plugdev", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="cc15", GROUP="plugdev", MODE="0666"
    
    # LimeSDR
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="6108", GROUP="plugdev", MODE="0666"
    
    # Airspy
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="60a1", GROUP="plugdev", MODE="0666"
  '';
  
  # Create workshop directory structure for RF analysis
  system.activationScripts.rfWorkshop = ''
    mkdir -p /home/thingnix/rf-workshop/{captures,signals,decoders,flowgraphs}
    chown -R thingnix:users /home/thingnix/rf-workshop
  '';
  
  # Configure system for optimal SDR performance
  boot.kernel.sysctl = {
    # Increase USB buffer for SDR devices
    "net.core.rmem_max" = 104857600;
    "net.core.wmem_max" = 104857600;
  };
  
  # Real-time scheduling for SDR applications
  security.pam.loginLimits = [
    { domain = "thingnix"; type = "-"; item = "rtprio"; value = "99"; }
  ];
  
  # Blacklist DVB-T kernel drivers that interfere with RTL-SDR
  boot.blacklistedKernelModules = [
    "dvb_usb_rtl28xxu"
    "rtl2832"
    "rtl2830"
    "dvb_usb_v2"
  ];
  
  # Create desktop files for common SDR applications
  environment.etc."xdg/autostart/rtl-sdr-setup.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=RTL-SDR Setup
    Comment=Set up RTL-SDR devices at startup
    Exec=sh -c "sleep 5 && rtl_test -t"
    Terminal=false
    Categories=System;
    NoDisplay=true
    X-GNOME-Autostart-enabled=true
  '';
}
