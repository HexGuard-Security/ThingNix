{ config, pkgs, lib, ... }:

{
  # Networking tools for IoT penetration testing and network analysis
  
  # Install networking tools
  environment.systemPackages = with pkgs; [
    # Network scanning - keeping nmap as it's essential
    nmap
    # masscan - commented out for build stability
    # netdiscover - commented out for build stability
    # arp-scan - commented out for build stability
    
    # Low-level network tools
    # tcpdump - commented out for build stability
    # wireshark - commented out for build stability
    # wireshark-cli - commented out for build stability
    # tshark - commented out for build stability
    # kismet - commented out for build stability
    
    # Traffic manipulation
    # ettercap - commented out for build stability
    # bettercap - commented out for build stability
    # mitmproxy - commented out for build stability
    # sslsplit - commented out for build stability
    
    # Network device emulation
    # mininet - commented out for build stability
    
    # IoT specific network tools
    # routersploit - commented out for build stability
    # expliot - commented out for build stability
    
    # Network infrastructure - keeping essential tools
    dnsmasq
    # hostapd - commented out for build stability
    dhcpcd
    iptables
    # bridge-utils - commented out for build stability
    
    # Network monitoring
    # ntopng - commented out for build stability
    # iftop - commented out for build stability
    # nethogs - commented out for build stability
    
    # Protocol analyzers
    # sngrep - commented out for build stability
    
    # Network fuzzing
    # radamsa - commented out for build stability
    # afl - commented out for build stability
    
    # VPN tools
    # openvpn - commented out for build stability
    # wireguard - commented out for build stability
    # wireguard-tools - commented out for build stability
    
    # Remote access
    # openssh - commented out for build stability
    # sshfs - commented out for build stability
    
    # Network troubleshooting
    # traceroute - commented out for build stability
    # mtr - commented out for build stability
    # inetutils - commented out for build stability
    # bind - commented out for build stability
    # whois - commented out for build stability
    
    # IoT protocols
    # mosquitto - commented out for build stability
    # mosquitto-clients - commented out for build stability
    # coap-client - commented out for build stability
    
    # Network load testing
    # siege - commented out for build stability
    
    # Wireless networking
    # aircrack-ng - commented out for build stability
    # wpa_supplicant - commented out for build stability
    # iw - commented out for build stability
    # crda - commented out for build stability
    # wavemon - commented out for build stability
    # wifi-analyzer - commented out for build stability
    
    # Network utilities
    # netcat-gnu - commented out for build stability
    # socat - commented out for build stability
    # ngrep - commented out for build stability
    
    # Bluetooth networking (overlaps with bluetooth-tools)
    # bluez - commented out for build stability
    # bluez-tools - commented out for build stability
    
    # SDN/NFV tools
    # openvswitch - commented out for build stability
    
    # Proxy tools
    # torsocks - commented out for build stability
    # proxychains - commented out for build stability
    
    # Network configuration
    # networkmanager - commented out for build stability
    # networkmanagerapplet - commented out for build stability
  ];
  
  # Enable network-related services
  services = {
    # DNS server
    dnsmasq = {
      enable = true;
      settings = {
        # Configuration for IoT network testing
        interface = "pentestbr0";
        dhcp-range = ["192.168.100.50,192.168.100.150,12h"];
        dhcp-option = ["option:router,192.168.100.1"];
      };
    };
    
    # Tor proxy
    # tor = {
    #   enable = true;
    #   client.enable = true;
    # };
    
    # Network utilities
    # sshd.enable = true;
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
