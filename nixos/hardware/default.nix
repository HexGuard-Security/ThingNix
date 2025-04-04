{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Include the basic hardware scan results
    (modulesPath + "/installer/scan/detected.nix")
    # Override/Extend with specialized hardware modules
    ./sdr-hardware.nix
    ./debugging-hardware.nix
    ./usb-gadget.nix
  ];

  # Hardware scanning enabled
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # Basic drivers for common hardware
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" "rtl8xxxu" "r8169"
  ];
}
