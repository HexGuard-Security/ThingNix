{ config, pkgs, lib, ... }:

{
  # Firmware analysis and exploitation tools
  
  # Install firmware analysis tools and helper scripts
  environment.systemPackages = with pkgs; [
    # Firmware extraction and analysis
    binwalk
    firmwalker
    firmware-mod-kit
    
    # Binary analysis tools
    ghidra
    radare2
    radare2-cutter
    rizin
    gdb
    rz-ghidra
    
    # Disassemblers and decompilers
    radare2
    ida-free
    binary-ninja-demo
    
    # Emulation
    qemu
    unicorn
    qemu_kvm
    
    # Debugging
    gdb
    gdb-multitarget
    gdbgui
    
    # Hardware debugging
    openocd
    stlink
    
    # Hex/binary viewers
    hexedit
    xxd
    okteta
    
    # Memory forensics
    volatility
    
    # Code analysis
    clang
    llvm
    
    # Static analysis tools
    flawfinder
    rats
    cppcheck
    
    # Flash memory tools
    flashrom
    serialdump
    
    # JTAG tools
    urjtag
    
    # Firmware building
    gcc
    gcc-arm-embedded
    avr-gcc
    
    # Utilities
    dtc # Device Tree Compiler
    squashfsTools
    cpio
    mtd-utils
    
    # File format specific tools
    p7zip
    unzip
    zip
    bzip2
    xz
    
    # Python for scripting
    python3
    python3Packages.capstone
    python3Packages.keystone-engine
    python3Packages.pwntools
    python3Packages.unicorn
    
    # Development environments
    vscode
    
    # Custom scripts for firmware analysis
    (writeShellScriptBin "extract-firmware" ''
      #!/bin/sh
      # Quick firmware extraction utility
      
      if [ $# -lt 1 ]; then
        echo "Usage: extract-firmware <firmware_file> [output_directory]"
        exit 1
      fi
      
      FIRMWARE=$1
      OUTPUT_DIR=''${2:-./firmware-extracted}
      
      mkdir -p "$OUTPUT_DIR"
      
      echo "Extracting firmware $FIRMWARE to $OUTPUT_DIR..."
      ${binwalk}/bin/binwalk -e -C "$OUTPUT_DIR" "$FIRMWARE"
      
      echo "Creating firmware summary..."
      ${binwalk}/bin/binwalk "$FIRMWARE" > "$OUTPUT_DIR/firmware-summary.txt"
      
      echo "Done. Results saved to $OUTPUT_DIR"
    '')
    
    (writeShellScriptBin "emulate-firmware" ''
      #!/bin/sh
      # Firmware emulation helper
      
      if [ $# -lt 2 ]; then
        echo "Usage: emulate-firmware <architecture> <executable> [arguments]"
        echo "Supported architectures: arm, arm64, mips, mipsel, ppc, x86"
        exit 1
      fi
      
      ARCH=$1
      BINARY=$2
      shift 2
      
      case "$ARCH" in
        arm)
          QEMU=${qemu}/bin/qemu-arm
          ;;
        arm64)
          QEMU=${qemu}/bin/qemu-aarch64
          ;;
        mips)
          QEMU=${qemu}/bin/qemu-mips
          ;;
        mipsel)
          QEMU=${qemu}/bin/qemu-mipsel
          ;;
        ppc)
          QEMU=${qemu}/bin/qemu-ppc
          ;;
        x86)
          QEMU=${qemu}/bin/qemu-i386
          ;;
        *)
          echo "Unsupported architecture: $ARCH"
          exit 1
          ;;
      esac
      
      # Set up QEMU for emulation
      $QEMU -L /usr/lib "$BINARY" "$@"
    '')
  ];
  
  # Create directory for firmware samples
  system.activationScripts.firmwareDir = ''
    mkdir -p /opt/firmware
    chown thingnix:users /opt/firmware
  '';
  
  # Create workshop directory structure for firmware analysis
  system.activationScripts.firmwareWorkshop = ''
    mkdir -p /home/thingnix/firmware-workshop/{extracted,workbench,tools,reports}
    chown -R thingnix:users /home/thingnix/firmware-workshop
  '';
  
  # Add custom configurations for tools
  environment.etc = {
    # Radare2 config
    "radare2rc".text = ''
      # Custom radare2 configuration for firmware analysis
      e asm.syntax = intel
      e asm.pseudo = true
      e bin.demangle = true
      e cfg.fortunes = false
    '';
    
    # GDB initialization
    "gdbinit".text = ''
      set disassembly-flavor intel
      set print pretty on
      set pagination off
    '';
  };
  
  # Enable services needed for firmware analysis
  services = {
    # Network services for emulated firmware
    dnsmasq = {
      enable = true;
      extraConfig = ''
        # Configuration for firmware emulation network
        interface=fw-net0
        dhcp-range=192.168.200.50,192.168.200.150,12h
        dhcp-option=option:router,192.168.200.1
      '';
    };
  };
  
  # Network bridges for firmware emulation
  networking.bridges = {
    "fw-net0" = {
      interfaces = [];
    };
  };
  
  # Memory limits for analysis tools
  security.pam.loginLimits = [
    { domain = "thingnix"; type = "-"; item = "memlock"; value = "unlimited"; }
    { domain = "thingnix"; type = "-"; item = "nofile"; value = "65536"; }
  ];
}
