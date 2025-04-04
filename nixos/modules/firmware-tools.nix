{ config, pkgs, lib, ... }:

{
  # Firmware analysis and exploitation tools
  
  # Install firmware analysis tools and helper scripts
  environment.systemPackages = with pkgs; [
    # Firmware extraction and analysis - keeping binwalk as it's essential
    binwalk
    # firmwalker - commented out for build stability
    # firmware-mod-kit - commented out for build stability
    
    # Binary analysis tools
    # ghidra - commented out for build stability
    # radare2 - commented out for build stability
    # radare2-cutter - commented out for build stability
    # rizin - commented out for build stability
    # gdb - commented out for build stability
    # rz-ghidra - commented out for build stability
    
    # Disassemblers and decompilers
    # radare2 - commented out for build stability
    # ida-free - commented out for build stability
    # binary-ninja-demo - commented out for build stability
    
    # Emulation
    # qemu - commented out for build stability
    # unicorn - commented out for build stability
    # qemu_kvm - commented out for build stability
    
    # Debugging
    # gdb - commented out for build stability
    # gdb-multitarget - commented out for build stability
    # gdbgui - commented out for build stability
    
    # Hardware debugging
    # openocd - commented out for build stability
    # stlink - commented out for build stability
    
    # Hex/binary viewers
    # hexedit - commented out for build stability
    # xxd - commented out for build stability
    # okteta - commented out for build stability
    
    # Memory forensics
    # volatility - commented out for build stability
    
    # Code analysis
    # clang - commented out for build stability
    # llvm - commented out for build stability
    
    # Static analysis tools
    # flawfinder - commented out for build stability
    # rats - commented out for build stability
    # cppcheck - commented out for build stability
    
    # Flash memory tools
    # flashrom - commented out for build stability
    # serialdump - commented out for build stability
    
    # JTAG tools
    # urjtag - commented out for build stability
    
    # Firmware building
    # gcc - commented out for build stability
    # gcc-arm-embedded - commented out for build stability
    # avr-gcc - commented out for build stability
    
    # Utilities
    # dtc - commented out for build stability
    # squashfsTools - commented out for build stability
    # cpio - commented out for build stability
    # mtd-utils - commented out for build stability
    
    # File format specific tools
    # p7zip - commented out for build stability
    # unzip - commented out for build stability
    # zip - commented out for build stability
    # bzip2 - commented out for build stability
    # xz - commented out for build stability
    
    # Python for scripting
    # python3 - commented out for build stability
    # python3Packages.capstone - commented out for build stability
    # python3Packages.keystone-engine - commented out for build stability
    # python3Packages.pwntools - commented out for build stability
    # python3Packages.unicorn - commented out for build stability
    
    # Development environments
    # vscode - commented out for build stability
    
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
      ${pkgs.binwalk}/bin/binwalk -e -C "$OUTPUT_DIR" "$FIRMWARE"
      
      echo "Creating firmware summary..."
      ${pkgs.binwalk}/bin/binwalk "$FIRMWARE" > "$OUTPUT_DIR/firmware-summary.txt"
      
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
          QEMU=${pkgs.qemu}/bin/qemu-arm
          ;;
        arm64)
          QEMU=${pkgs.qemu}/bin/qemu-aarch64
          ;;
        mips)
          QEMU=${pkgs.qemu}/bin/qemu-mips
          ;;
        mipsel)
          QEMU=${pkgs.qemu}/bin/qemu-mipsel
          ;;
        ppc)
          QEMU=${pkgs.qemu}/bin/qemu-ppc
          ;;
        x86)
          QEMU=${pkgs.qemu}/bin/qemu-i386
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
      settings = {
        # Configuration for firmware emulation network
        interface = "fw-net0";
        dhcp-range = ["192.168.200.50,192.168.200.150,12h"];
        dhcp-option = ["option:router,192.168.200.1"];
      };
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
