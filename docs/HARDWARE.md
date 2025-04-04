# ThingNix Hardware Compatibility

This document details hardware devices that have been tested and confirmed working with ThingNix.

## Table of Contents
- [Software Defined Radio (SDR)](#software-defined-radio-sdr)
- [Hardware Debugging](#hardware-debugging)
- [Flash Programming](#flash-programming)
- [Wireless](#wireless)
- [Development Boards](#development-boards)
- [Compatibility Status](#compatibility-status)

## Software Defined Radio (SDR)

| Device | Status | Driver | Notes |
|--------|--------|--------|-------|
| RTL-SDR | Full Support | rtl-sdr | All models based on RTL2832U |
| HackRF | Full Support | hackrf | All models |
| LimeSDR | Full Support | limesuite | All models |
| SDRplay | Partial Support | sdrplay | RSP1, RSP1A tested |
| Airspy | Full Support | airspy | All models |
| BladeRF | Partial Support | bladerf | x40, x115 tested |
| USRP | Partial Support | uhd | B200, B210 tested |

## Hardware Debugging

| Device | Status | Driver/Tool | Notes |
|--------|--------|-------------|-------|
| ST-Link V2 | Full Support | openocd | All versions |
| J-Link | Full Support | openocd, jlink | EDU, BASE, ULTRA models tested |
| FTDI FT232H | Full Support | ftdi_eeprom | SPI, JTAG, I2C supported |
| Bus Pirate | Full Support | pyBusPirate | All versions |
| Black Magic Probe | Full Support | native gdb | All versions |
| CH341A BIOS Programmer | Full Support | ch341eeprom | Compatible with 24/25xx series |
| FT2232H | Full Support | ftdi_eeprom | All breakout boards |
| DSLogic | Full Support | sigrok | Basic, Plus models |

## Flash Programming

| Device | Status | Driver/Tool | Notes |
|--------|--------|-------------|-------|
| CH341A | Full Support | flashrom | Most SPI flash chips supported |
| FT2232H | Full Support | flashrom | With proper wiring |
| SPI Flash Clip | Full Support | flashrom | With compatible programmer |
| Raspberry Pi | Full Support | flashrom | Via GPIO headers |
| BusPirate | Full Support | flashrom | Slower but reliable |
| Teensy | Partial Support | custom | With custom firmware |

## Wireless

| Device | Status | Driver/Tool | Notes |
|--------|--------|-------------|-------|
| Alfa AWUS036ACH | Full Support | RTL8812AU | 2.4/5GHz WiFi, Monitor mode |
| Alfa AWUS036NH | Full Support | RTL8187 | 2.4GHz WiFi, Monitor mode |
| TP-Link TL-WN722N (v1) | Full Support | Atheros AR9271 | 2.4GHz WiFi, Monitor mode |
| Crazyradio PA | Full Support | native | 2.4GHz, Enhanced Shockburst |
| Ubertooth One | Full Support | ubertooth | Bluetooth sniffing |
| RFCat Yard Stick One | Full Support | rfcat | Sub-1GHz, 300-928MHz |
| Texas Instruments CC1352 LaunchPad | Full Support | cc-tool | Zigbee, Thread, BLE |
| Nordic nRF52840 Dongle | Full Support | nrf-tools | BLE 5.0, Thread, Zigbee |

## Development Boards

| Device | Status | Driver/Tool | Notes |
|--------|--------|-------------|-------|
| Raspberry Pi 4 | Full Support | native | All models |
| ESP32 | Full Support | esptool | All variants |
| Arduino | Full Support | avrdude | All official models |
| STM32 Discovery | Full Support | stlink, openocd | F4, F7, L4 series tested |
| BeagleBone Black | Full Support | native | All variants |
| Nordic nRF52 DK | Full Support | openocd, nrfjprog | All models |
| Teensy | Full Support | teensy_loader_cli | 3.x, 4.x models |
| RISC-V boards | Partial Support | openocd | SiFive HiFive1, GD32V tested |

## Compatibility Status

### Status Definitions

- **Full Support**: Device works out-of-the-box with all features available
- **Partial Support**: Device works with some limitations or requires manual configuration
- **Experimental**: Device has been tested but reliability issues exist
- **Planned**: Support is in development

### Reporting Compatibility Issues

If you encounter hardware compatibility issues:

1. Check if the hardware is listed in this document
2. Ensure proper driver installation with `lsusb` and `dmesg`
3. Report the issue on GitHub with:
   - Exact hardware model and revision
   - Output of `lsusb` and `dmesg | grep <device>`
   - Steps to reproduce the issue
   - Any workarounds attempted

### Adding New Hardware Support

To request support for new hardware:

1. Open an issue on GitHub with the hardware details
2. Include links to existing Linux drivers or tools
3. If possible, provide information about the hardware protocol
4. Mention if you're willing to test support

### USB Device Permissions

Most hardware devices are accessible to the `thingnix` user via pre-configured udev rules. If you encounter permission issues:

```bash
# Check if your device has proper permissions
ls -la /dev/ttyUSB*
ls -la /dev/bus/usb/$(lsusb | grep "your device" | cut -d' ' -f2,4 | sed 's/://g' | sed 's/ /\//g')

# If needed, you can temporarily fix permissions
sudo chmod 666 /dev/<device>
```

For permanent solutions, create additional udev rules in `/etc/udev/rules.d/`.
