{ config, lib, pkgs, ... }:

{
  # USB Gadget functionality for turning the device into USB peripherals
  # Useful for BadUSB attacks and USB-based exploitation
  
  # Enable required kernel modules
  boot.kernelModules = [ 
    "libcomposite"  # For USB composite devices
    "usb_f_acm"     # For USB CDC ACM (serial)
    "usb_f_ecm"     # For USB Ethernet
    "usb_f_eem"     # For USB Ethernet
    "usb_f_hid"     # For USB HID (keyboard, mouse)
    "usb_f_mass_storage" # For USB storage
    "usb_f_rndis"   # For USB RNDIS (Ethernet)
    "usb_f_midi"    # For USB MIDI
  ];
  
  # Install USB gadget tools
  environment.systemPackages = with pkgs; [
    usbutils     # Tools for working with USB
    libusb1      # USB library (renamed from libusb)
    # libcomposite is a kernel module, not a userspace package
  ];
  
  # Create systemd service for implementing USB gadget modes
  # This is a template that can be customized for specific USB gadget configurations
  systemd.services.usb-gadget = {
    description = "Setup USB Gadget functionality";
    requires = [ "dev-configfs.mount" ];
    after = [ "dev-configfs.mount" ];
    wantedBy = [ "multi-user.target" ];
    
    # Script to set up a USB HID (keyboard) gadget - default config
    script = ''
      # Define gadget directory
      CONFIGFS_ROOT=/sys/kernel/config/usb_gadget
      GADGET_DIR=$CONFIGFS_ROOT/hidkeyboard
      
      # Remove any existing gadget
      if [ -d "$GADGET_DIR" ]; then
        echo "Removing existing gadget"
        echo "" > $GADGET_DIR/UDC
        rm -rf $GADGET_DIR
      fi
      
      # Make sure configfs is mounted
      if ! grep -qs "configfs" /proc/mounts; then
        mount -t configfs none /sys/kernel/config
      fi
      
      # Create gadget directory
      mkdir -p $GADGET_DIR
      cd $GADGET_DIR
      
      # Set USB device identifiers (using common keyboard values)
      echo 0x1d6b > idVendor  # Linux Foundation
      echo 0x0104 > idProduct # Multifunction Composite Gadget
      echo 0x0100 > bcdDevice # v1.0.0
      echo 0x0200 > bcdUSB    # USB2
      
      # Set English localization
      mkdir -p strings/0x409
      echo "fedcba9876543210" > strings/0x409/serialnumber
      echo "ThingNix" > strings/0x409/manufacturer
      echo "USB Keyboard" > strings/0x409/product
      
      # Create HID function
      mkdir -p functions/hid.usb0
      echo 1 > functions/hid.usb0/protocol
      echo 1 > functions/hid.usb0/subclass
      echo 8 > functions/hid.usb0/report_length
      
      # Write keyboard descriptor
      echo -ne \\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0 > functions/hid.usb0/report_desc
      
      # Create configuration
      mkdir -p configs/c.1/strings/0x409
      echo "Config 1: HID" > configs/c.1/strings/0x409/configuration
      echo 250 > configs/c.1/MaxPower
      
      # Link HID function to configuration
      ln -s functions/hid.usb0 configs/c.1/
      
      # Get available UDC drivers
      UDC=$(ls /sys/class/udc | head -n1)
      if [ -n "$UDC" ]; then
        echo $UDC > UDC  # Enable gadget
        echo "USB Gadget enabled with UDC: $UDC"
      else
        echo "No UDC driver available"
      fi
    '';
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
