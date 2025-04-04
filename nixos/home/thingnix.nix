{ config, pkgs, lib, ... }:

{
  # Home Manager configuration for the thingnix user
  
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Home Manager settings
  home = {
    username = "thingnix";
    homeDirectory = "/home/thingnix";
    stateVersion = "23.11";
    
    # Install user-specific packages
    packages = with pkgs; [
      # Terminal utilities
      tmux
      htop
      fzf
      ripgrep
      bat
      exa
      neofetch
      
      # Development tools
      git
      gh
      vscode
      
      # Security tools
      keepassxc
      
      # Browsers with pentesting extensions
      firefox
      chromium
      
      # Communication
      tdesktop
      
      # Screenshot and screen recording
      flameshot
      obs-studio
      
      # Document viewers
      zathura
      libreoffice
      
      # Utilities
      pcmanfm
      pavucontrol
      networkmanagerapplet
    ];
    
    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
      BROWSER = "firefox";
    };
    
    # Files to add to home directory
    file = {
      # Pentest workspace folders
      ".pentest".source = pkgs.runCommand "pentest-workspace" {} ''
        mkdir -p $out
        mkdir -p $out/targets
        mkdir -p $out/reports
        mkdir -p $out/tools
        mkdir -p $out/payloads
        mkdir -p $out/firmware
        mkdir -p $out/data
        touch $out/targets/.gitkeep
        touch $out/reports/.gitkeep
        touch $out/tools/.gitkeep
        touch $out/payloads/.gitkeep
        touch $out/firmware/.gitkeep
        touch $out/data/.gitkeep
      '';
      
      # Sample project structure for a pentest
      ".pentest-template".source = pkgs.writeTextFile {
        name = "pentest-template";
        text = ''
          # IoT Pentest Project Template
          
          ## Project Structure
          
          - firmware/ - Firmware images and extracted content
          - hardware/ - Hardware research, datasheets, pinouts
          - network/ - Network analysis, traffic captures
          - exploits/ - Developed exploits and proofs of concept
          - reports/ - Documentation and findings
          
          ## Common Tasks
          
          1. Firmware extraction: binwalk -e firmware.bin
          2. Network scanning: nmap -sV target
          3. Hardware analysis: Use OpenOCD for JTAG/SWD
          4. RF analysis: rtl_433 or gqrx for signal capture
          5. BLE scanning: btlejack -s
        '';
      };
    };
  };
  
  # Terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "Hack";
        size = 11;
      };
      colors = {
        primary = {
          background = "#1e1e1e";
          foreground = "#d4d4d4";
        };
      };
    };
  };
  
  # Shell configuration
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      plugins = [
        "git"
        "sudo"
        "docker"
        "tmux"
        "python"
        "nmap"
      ];
    };
    
    shellAliases = {
      ls = "exa";
      ll = "exa -l";
      la = "exa -la";
      cat = "bat";
      find = "fd";
      grep = "rg";
      top = "htop";
      vim = "nvim";
    };
    
    initExtra = ''
      # Custom thingnix prompt
      PROMPT="%F{red}[ThingNix]%f %F{blue}%n@%m%f:%F{green}%~%f$ "
      
      # Security aliases
      alias nmap-quick='sudo nmap -F'
      alias nmap-full='sudo nmap -sS -sV -O -A'
      alias wireshark-quick='sudo wireshark -i eth0 -k'
      alias binwalk-extract='binwalk -e'
      
      # RF tools aliases
      alias rtlsdr-fm='rtl_fm -f 100M -M wbfm -s 200000 -r 48000 - | play -r 48000 -t raw -e s -b 16 -c 1 -V1 -'
      
      # Quick ways to get into common directories
      alias cdp='cd ~/.pentest'
      alias cdf='cd ~/.pentest/firmware'
      
      # Function to start a new pentesting project
      pentest-new() {
        if [ -z "$1" ]; then
          echo "Usage: pentest-new <project-name>"
          return 1
        fi
        
        PROJECT_DIR=~/.pentest/projects/$1
        
        if [ -d "$PROJECT_DIR" ]; then
          echo "Project already exists: $PROJECT_DIR"
          return 1
        fi
        
        mkdir -p "$PROJECT_DIR"/{firmware,hardware,network,exploits,reports}
        echo "# Project: $1" > "$PROJECT_DIR/README.md"
        echo "Created new pentest project: $PROJECT_DIR"
        cd "$PROJECT_DIR"
      }
    '';
  };
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "ThingNix User";
    userEmail = "user@thingnix.org";
    extraConfig = {
      core.editor = "nvim";
      color.ui = true;
      pull.rebase = false;
    };
  };
  
  # Neovim configuration
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set cursorline
      set colorcolumn=80
      syntax on
      colorscheme default
    '';
  };
  
  # Tmux configuration
  programs.tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    clock24 = true;
    historyLimit = 10000;
    extraConfig = ''
      # Enable mouse mode
      set -g mouse on
      
      # Start window numbering at 1
      set -g base-index 1
      
      # Custom status bar
      set -g status-bg black
      set -g status-fg white
      set -g status-left "#[fg=green][#S] "
      set -g status-right "#[fg=cyan]%d %b %Y #[fg=yellow]%H:%M"
    '';
  };
  
  # Firefox configuration
  programs.firefox = {
    enable = true;
    profiles = {
      thingnix = {
        settings = {
          "browser.startup.homepage" = "about:blank";
          "browser.search.region" = "US";
          "browser.search.isUS" = true;
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.placeholderName.private" = "DuckDuckGo";
          "browser.search.hiddenOneOffs" = "Google,Yahoo,Bing,Amazon.com,Twitter";
          "browser.newtabpage.enabled" = false;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          privacy-badger
          https-everywhere
          cookie-autodelete
          foxyproxy-standard
        ];
      };
    };
  };
  
  # Desktop entries for common tools
  xdg.desktopEntries = {
    # Network scanner shortcut
    nmap-scan = {
      name = "Network Scanner";
      exec = "alacritty -e sudo nmap -sV -p- -T4 127.0.0.1";
      icon = "utilities-terminal";
      comment = "Scan a network with nmap";
      categories = [ "Security" "Network" ];
      terminal = false;
    };
    
    # SDR receiver shortcut
    gqrx-start = {
      name = "SDR Receiver";
      exec = "gqrx";
      icon = "gqrx";
      comment = "Start GQRX SDR receiver";
      categories = [ "HamRadio" "Radio" "Utility" ];
      terminal = false;
    };
    
    # BLE scanner shortcut
    ble-scanner = {
      name = "BLE Scanner";
      exec = "alacritty -e sudo btlejack -s";
      icon = "bluetooth";
      comment = "Scan for BLE devices";
      categories = [ "Security" "Utility" ];
      terminal = false;
    };
    
    # Firmware analyzer shortcut
    firmware-analyzer = {
      name = "Firmware Analyzer";
      exec = "alacritty -e binwalk";
      icon = "utilities-terminal";
      comment = "Analyze firmware with binwalk";
      categories = [ "Security" "Development" ];
      terminal = false;
    };
  };
}
