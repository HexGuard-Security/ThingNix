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
    # Reconnaissance
    nmap
    masscan
    rustscan
    netcat
    socat
    tcpdump
    wireshark
    aircrack-ng
    kismet
    dirb
    nikto
    
    # Web testing
    burpsuite
    zaproxy
    sqlmap
    wfuzz
    gobuster
    
    # Exploitation frameworks
    metasploit
    social-engineer-toolkit
    thc-hydra
    john
    hashcat
    
    # Network utilities
    iptables
    iproute2
    dnsutils
    whois
    netcat-gnu
    ettercap
    macchanger
    
    # Wireless tools
    wpa_supplicant
    hostapd
    iw
    wavemon
    
    # Password and crypto tools
    john
    hashcat
    hashdeep
    sshpass
    pwgen
    
    # Vulnerability scanners
    lynis
    openvas-scanner
    
    # Forensics
    sleuthkit
    testdisk
    foremost
    scalpel
    ddrescue
    
    # Monitoring and defense
    snort
    fail2ban
    
    # Anonymity
    tor
    torsocks
    proxychains
    
    # Development/Scripting tools for exploit dev
    python3
    python3Packages.pwntools
    python3Packages.scapy
    python3Packages.requests
    python3Packages.pycryptodome
    python3Packages.paramiko
    
    # Version control for exploit repositories
    git
    
    # Documentation and reporting
    texlive.combined.scheme-full
    libreoffice
    
    # Virtualization for testing exploits
    qemu
    qemu_kvm
    virt-manager
  ];
  
  # Enable services needed for security tools
  services = {
    # For database-backed tools
    postgresql.enable = true;
    
    # For web proxies and interceptors
    tor.enable = true;
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
    wireshark = {};
    vboxusers = {};
    libvirtd = {};
  };
  
  # Add user to security groups
  users.users.thingnix.extraGroups = [ 
    "wireshark" 
    "vboxusers"
    "libvirtd"
    "docker"
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
