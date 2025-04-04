{ config, pkgs, lib, ... }:

{
  # Base system configuration for ThingNix
  
  # Base packages that should be available on any ThingNix installation
  environment.systemPackages = with pkgs; [
    # Basic system utilities
    coreutils
    curl
    wget
    git
    vim
    nano
    htop
    btop
    lsof
    tree
    file
    unzip
    zip
    pciutils
    usbutils
    nmap
    tcpdump
    netcat
    inetutils
    iputils
    traceroute
    whois
    
    # Shell environment
    zsh
    oh-my-zsh
    tmux
    fzf
    
    # Development utilities
    gcc
    gnumake
    python3
    python3Packages.pip
    python3Packages.virtualenv
    
    # Editor
    neovim
  ];
  
  # Zsh as default shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "python" "docker" "sudo" "tmux" ];
    };
    promptInit = ''
      # Custom prompt for ThingNix
      PROMPT="%F{red}[ThingNix]%f %F{blue}%n@%m%f:%F{green}%~%f$ "
    '';
  };
  
  # SSH server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };
  
  # Sudo configuration
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false; # For ease of use
  };
  
  # Services for pentesting environment
  services = {
    # Automatic mount of removable devices
    gvfs.enable = true;
    udisks2.enable = true;
    
    # Network time
    timesyncd.enable = true;
    
    # Printing
    printing.enable = true;
    
    # Avahi for mDNS/DNS-SD
    avahi = {
      enable = true;
      nssmdns = true;
    };
  };
  
  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      hack-font
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Hack" "Fira Code" ];
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        serif = [ "Noto Serif" "Liberation Serif" ];
      };
    };
  };
  
  # Sound configuration using the newer approach
  # Removed sound.enable as it's deprecated
  hardware.alsa = {
    enable = true;
    support32Bit = true;
  };
  
  # Enable dconf
  programs.dconf.enable = true;
}
