{ config, pkgs, lib, ... }:

{
  # Core security tools for ThingNix
  
  # Create a custom overlay for tools not in nixpkgs
  nixpkgs.overlays = [
    (final: prev: {
      # Example of a custom package (to be implemented)
      # custom-tool = final.callPackage ../packages/custom-tool.nix {};
    })
  ];
  
  # Install core security tools
  environment.systemPackages = with pkgs; [
    # Reconnaissance - keeping nmap as it's essential
    nmap
    # masscan - commented out for build stability
    # rustscan - commented out for build stability
    # netcat - commented out for build stability
    # socat - commented out for build stability
    # tcpdump - commented out for build stability
    # wireshark - commented out for build stability
    # aircrack-ng - commented out for build stability
    # kismet - commented out for build stability
    # dirb - commented out for build stability
    # nikto - commented out for build stability
    
    # Web testing
    # burpsuite - commented out for build stability
    # zaproxy - commented out for build stability
    # sqlmap - commented out for build stability
    # wfuzz - commented out for build stability
    # gobuster - commented out for build stability
    
    # Exploitation frameworks
    # metasploit - commented out for build stability
    # social-engineer-toolkit - commented out for build stability
    # thc-hydra - commented out for build stability
    # john - commented out for build stability
    # hashcat - commented out for build stability
    
    # Network utilities - keeping iptables as it's essential
    iptables
    # iproute2 - commented out for build stability
    # dnsutils - commented out for build stability
    # whois - commented out for build stability
    # netcat-gnu - commented out for build stability
    # ettercap - commented out for build stability
    # macchanger - commented out for build stability
    
    # Wireless tools
    # wpa_supplicant - commented out for build stability
    # hostapd - commented out for build stability
    # iw - commented out for build stability
    # wavemon - commented out for build stability
    
    # Password and crypto tools
    # john - commented out for build stability
    # hashcat - commented out for build stability
    # hashdeep - commented out for build stability
    # sshpass - commented out for build stability
    # pwgen - commented out for build stability
    
    # Vulnerability scanners
    # lynis - commented out for build stability
    # openvas-scanner - commented out for build stability
    
    # Forensics
    # sleuthkit - commented out for build stability
    # testdisk - commented out for build stability
    # foremost - commented out for build stability
    # scalpel - commented out for build stability
    # ddrescue - commented out for build stability
    
    # Monitoring and defense
    # snort - commented out for build stability
    # fail2ban - commented out for build stability
    
    # Anonymity
    # tor - commented out for build stability
    # torsocks - commented out for build stability
    # proxychains - commented out for build stability
    
    # Development/Scripting tools for exploit dev
    # python3 - commented out for build stability
    # python3Packages.pwntools - commented out for build stability
    # python3Packages.scapy - commented out for build stability
    # python3Packages.requests - commented out for build stability
    # python3Packages.pycryptodome - commented out for build stability
    # python3Packages.paramiko - commented out for build stability
    
    # Version control for exploit repositories
    # git - commented out for build stability
    
    # Documentation and reporting
    # texlive.combined.scheme-full - commented out for build stability
    # libreoffice - commented out for build stability
    
    # Virtualization for testing exploits
    # qemu - commented out for build stability
    # qemu_kvm - commented out for build stability
    # virt-manager - commented out for build stability
  ];
  
  # Enable services needed for security tools
  services = {
    # For database-backed tools
    # postgresql.enable = true; # Commented out for build stability
    
    # For web proxies and interceptors
    # tor.enable = true; # Commented out for build stability
  };
  
  # Add virtual bridge for isolated network testing
  networking = {
    bridges = {
      pentestbr0 = {
        interfaces = [];
      };
    };
    
    # Firewall rules for pentesting
    firewall = {
      allowedTCPPorts = [ 
        22    # SSH
        80    # HTTP
        443   # HTTPS
        8080  # Common proxy port
      ];
      allowedUDPPorts = [
        53    # DNS
      ];
      # Uncomment to disable firewall entirely during pentesting
      # enable = false;
    };
  };
  
  # Create special groups for security tools
  users.groups = {
    # wireshark = {}; # Commented out for build stability
    # vboxusers = {}; # Commented out for build stability
    # libvirtd = {}; # Commented out for build stability
  };
  
  # Add user to security groups
  users.users.thingnix.extraGroups = [ 
    # "wireshark" # Commented out for build stability
    # "vboxusers" # Commented out for build stability
    # "libvirtd" # Commented out for build stability
    # "docker" # Commented out for build stability
  ];
  
  # Security configurations
  security = {
    # Allow capturing packets with tcpdump/wireshark without root
    wrappers = {
      tcpdump = {
        source = "${pkgs.tcpdump}/bin/tcpdump";
        capabilities = "cap_net_raw,cap_net_admin=eip";
        owner = "root";
        group = "wireshark";
        permissions = "u+rx,g+rx,o-rwx";
      };
    };
  };
  
  # Enable virtualization capabilities
  virtualisation = {
    libvirtd.enable = true;
    
    # Docker for containerized pentesting
    docker = {
      enable = true;
      autoPrune.enable = true;
    };
  };
  
  # Enable promiscuous mode on network interfaces
  systemd.services.enable-promiscuous = {
    description = "Enable promiscuous mode on all interfaces";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.iproute2}/bin/ip link | ${pkgs.gnugrep}/bin/grep -v lo | ${pkgs.gawk}/bin/awk -F': ' '{print $2}' | while read -r interface; do
        if [ -n "$interface" ]; then
          ${pkgs.iproute2}/bin/ip link set "$interface" promisc on
        fi
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
