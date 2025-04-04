{ config, pkgs, lib, ... }:

{
  # Networking tools for IoT penetration testing and network analysis
  
  # Install networking tools
  environment.systemPackages = with pkgs; [
    # Network scanning
    nmap
    masscan
    netdiscover
    arp-scan
    
    # Low-level network tools
    tcpdump
    wireshark
    wireshark-cli
    tshark
    kismet
    
    # Traffic manipulation
    ettercap
    bettercap
    mitmproxy
    sslsplit
    
    # Network device emulation
    mininet
    
    # IoT specific network tools
    routersploit
    expliot
    
    # Network infrastructure
    dnsmasq
    hostapd
    dhcpcd
    iptables
    bridge-utils
    
    # Network monitoring
    ntopng
    iftop
    nethogs
    
    # Protocol analyzers
    sngrep # SIP analyzer
    
    # Network fuzzing
    radamsa
    afl
    
    # VPN tools
    openvpn
    wireguard
    wireguard-tools
    
    # Remote access
    openssh
    sshfs
    
    # Network troubleshooting
    traceroute
    mtr
    inetutils
    bind
    whois
    
    # IoT protocols
    mosquitto # MQTT broker
    mosquitto-clients # MQTT clients
    coap-client # CoAP client
    
    # Network load testing
    siege
    
    # Wireless networking
    aircrack-ng
    wpa_supplicant
    iw
    crda
    wavemon
    wifi-analyzer
    
    # Network utilities
    netcat-gnu
    socat
    ngrep
    
    # Bluetooth networking (overlaps with bluetooth-tools)
    bluez
    bluez-tools
    
    # SDN/NFV tools
    openvswitch
    
    # Proxy tools
    torsocks
    proxychains
    
    # Network configuration
    networkmanager
    networkmanagerapplet
  ];
  
  # Enable network-related services
  services = {
    # DNS server
    dnsmasq = {
      enable = true;
      extraConfig = ''
        # Configuration for IoT network testing
        interface=pentestbr0
        dhcp-range=192.168.100.50,192.168.100.150,12h
        dhcp-option=option:router,192.168.100.1
      '';
    };
    
    # DHCP server
    dhcpd4 = {
      enable = false; # Disabled by default, can be enabled when needed
      interfaces = [ "pentestbr0" ];
      extraConfig = ''
        subnet 192.168.100.0 netmask 255.255.255.0 {
          option routers 192.168.100.1;
          option domain-name-servers 8.8.8.8, 8.8.4.4;
          range 192.168.100.50 192.168.100.150;
        }
      '';
    };
    
    # Tor proxy
    tor = {
      enable = true;
      client.enable = true;
    };
    
    # Network utilities
    sshd.enable = true;
  };
  
  # Network namespace isolation for testing
  security.wrappers.unshare = {
    source = "${pkgs.util-linux}/bin/unshare";
    capabilities = "cap_sys_admin=ep";
    owner = "root";
    group = "root";
    permissions = "u+rx,g+rx,o+rx";
  };
  
  # Custom NetworkManager dispatcher scripts for pentesting
  environment.etc."NetworkManager/dispatcher.d/99-pentest" = {
    mode = "0755";
    text = ''
      #!/bin/sh
      # This script runs when network connections change
      # It can be used to configure network interfaces for pentesting

      INTERFACE="$1"
      ACTION="$2"

      case "$ACTION" in
        up)
          # When a new interface comes up, you might want to set it up for 
          # packet capture or other pentesting activities
          logger -t pentest "Interface $INTERFACE is up, configuring for pentesting"
          ;;
        down)
          logger -t pentest "Interface $INTERFACE is down"
          ;;
      esac
    '';
  };
  
  # Network hardening for the pentesting system itself
  networking = {
    firewall = {
      enable = true;
      allowPing = true;
      
      # Common ports for network testing tools
      allowedTCPPorts = [ 
        22    # SSH 
        80    # HTTP
        443   # HTTPS
        8080  # HTTP Proxy
        9090  # Common testing port
      ];
      
      allowedUDPPorts = [
        53    # DNS
        67    # DHCP
        68    # DHCP
      ];
    };
    
    # Network namespaces for isolated testing
    iproute2.enable = true;
    
    # Network bridge for creating test networks
    bridges = {
      pentestbr0 = {
        interfaces = [ ];
      };
    };
    
    # Useful for creating virtual networks
    nat = {
      enable = true;
      internalInterfaces = [ "pentestbr0" ];
      externalInterface = "eth0"; # Replace with actual external interface
    };
  };
  
  # Network sysctls for pentesting
  boot.kernel.sysctl = {
    # Enable IP forwarding
    "net.ipv4.ip_forward" = 1;
    
    # Allow non-local bind
    "net.ipv4.ip_nonlocal_bind" = 1;
    
    # Increase network buffer sizes
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    
    # ARP configuration for network scanning
    "net.ipv4.conf.all.arp_ignore" = 0;
    "net.ipv4.conf.all.arp_announce" = 0;
  };
}
