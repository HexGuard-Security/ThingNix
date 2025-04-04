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
    # htop - commented out for build stability
    # btop - commented out for build stability
    # lsof - commented out for build stability
    # tree - commented out for build stability
    file
    unzip
    zip
    pciutils
    usbutils
    nmap
    # tcpdump - commented out for build stability
    # netcat - commented out for build stability
    # inetutils - commented out for build stability
    # iputils - commented out for build stability
    # traceroute - commented out for build stability
    # whois - commented out for build stability
    
    # Shell environment
    zsh
    # oh-my-zsh - commented out for build stability
    # tmux - commented out for build stability
    # fzf - commented out for build stability
    
    # Development utilities
    # gcc - commented out for build stability
    # gnumake - commented out for build stability
    python3
    # python3Packages.pip - commented out for build stability
    # python3Packages.virtualenv - commented out for build stability
    
    # Editor
    # neovim - commented out for build stability
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
      # nssmdns4 option doesn't exist in NixOS 23.11, use nssmdns instead
      nssmdns = true;  # For NixOS 23.11 compatibility
    };
  };
  
  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      # noto-fonts-emoji - commented out for build stability
      # liberation_ttf - commented out for build stability
      # fira-code - commented out for build stability
      # fira-code-symbols - commented out for build stability
      # mplus-outline-fonts.githubRelease - commented out for build stability
      # dina-font - commented out for build stability
      # proggyfonts - commented out for build stability
      # font-awesome - commented out for build stability
      # hack-font - commented out for build stability
    ];
    fontconfig = {
      defaultFonts = {
        monospace = [ "Noto Sans Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };
  
  # Sound configuration handled in desktop.nix via PipeWire
  # Removing hardware.alsa configuration here to avoid conflicts
  
  # Enable dconf
  programs.dconf.enable = true;
}
