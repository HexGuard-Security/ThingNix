{ config, pkgs, lib, ... }:

{
  # Desktop environment configuration for ThingNix
  
  # Enable X11 and XFCE as the desktop environment
  # XFCE is lightweight but fully featured, ideal for a pentesting distro
  services.xserver = {
    enable = true;
    
    # Enable display manager
    displayManager = {
      lightdm.enable = true;
    };
    
    # Enable XFCE desktop environment
    desktopManager.xfce.enable = true;
    
    # Configure keyboard (using updated xkb structure)
    xkb = {
      layout = "us";
      options = "eurosign:e";
    };
  };
  
  # Display manager settings (moved from xserver as per new NixOS structure)
  services.displayManager = {
    defaultSession = "xfce";
    autoLogin = {
      enable = true;
      user = "thingnix";
    };
  };
  
  # Touchpad configuration (moved from xserver as per new NixOS structure)
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      disableWhileTyping = true;
    };
  };
  
  # Install desktop applications and utilities
  environment.systemPackages = with pkgs; [
    # Terminal emulators
    # alacritty - commented out for build stability
    # terminator - commented out for build stability
    
    # Web browsers
    firefox
    # chromium - commented out for build stability
    
    # File managers
    # thunar - commented out for build stability
    # pcmanfm - commented out for build stability
    
    # Terminal tools with GUI
    # gnome.gnome-terminal - commented out for build stability
    # xfce.xfce4-terminal - commented out for build stability
    
    # Text editors and IDEs
    # vscode - commented out for build stability
    # geany - commented out for build stability
    
    # Network tools with GUI
    # wireshark - commented out for build stability
    # networkmanagerapplet - commented out for build stability
    
    # System monitoring
    # xfce.xfce4-taskmanager - commented out for build stability
    
    # Security tools with GUI
    # keepassxc - commented out for build stability
    
    # Utility applications
    # flameshot - commented out for build stability
    # vlc - commented out for build stability
    # arandr - commented out for build stability
    # pavucontrol - commented out for build stability
    
    # PDF viewer
    # evince - commented out for build stability
    
    # Theming
    # arc-theme - commented out for build stability
    # papirus-icon-theme - commented out for build stability
    # gnome.adwaita-icon-theme - commented out for build stability
    
    # Clipboard manager
    # xfce.xfce4-clipman-plugin - commented out for build stability
    
    # System tray utilities
    # networkmanagerapplet - commented out for build stability
    # pasystray - commented out for build stability
    # blueman - commented out for build stability
  ];
  
  # XFCE configuration
  # Customizes the default XFCE setup for pentesting
  environment.etc = {
    # Custom wallpaper
    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfce4-desktop" version="1.0">
        <property name="backdrop" type="empty">
          <property name="screen0" type="empty">
            <property name="monitor0" type="empty">
              <property name="image-path" type="string">/etc/nixos/wallpapers/thingnix-wallpaper.png</property>
              <property name="last-image" type="string">/etc/nixos/wallpapers/thingnix-wallpaper.png</property>
              <property name="last-single-image" type="string">/etc/nixos/wallpapers/thingnix-wallpaper.png</property>
              <property name="image-style" type="int" value="5"/>
            </property>
          </property>
        </property>
      </channel>
    '';
    
    # Panel configuration
    "xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="xfce4-panel" version="1.0">
        <property name="panels" type="array">
          <value type="int" value="0"/>
          <property name="panel-0" type="empty">
            <property name="position" type="string" value="p=6;x=0;y=0"/>
            <property name="length" type="uint" value="100"/>
            <property name="position-locked" type="bool" value="true"/>
            <property name="plugin-ids" type="array">
              <value type="int" value="1"/>
              <value type="int" value="2"/>
              <value type="int" value="3"/>
              <value type="int" value="4"/>
              <value type="int" value="5"/>
              <value type="int" value="6"/>
              <value type="int" value="7"/>
              <value type="int" value="8"/>
              <value type="int" value="9"/>
              <value type="int" value="10"/>
              <value type="int" value="11"/>
              <value type="int" value="12"/>
            </property>
          </property>
        </property>
        <property name="plugins" type="empty">
          <property name="plugin-1" type="string" value="applicationsmenu"/>
          <property name="plugin-2" type="string" value="tasklist"/>
          <property name="plugin-3" type="string" value="separator"/>
          <property name="plugin-4" type="string" value="systray"/>
          <property name="plugin-5" type="string" value="notification-plugin"/>
          <property name="plugin-6" type="string" value="indicator"/>
          <property name="plugin-7" type="string" value="separator"/>
          <property name="plugin-8" type="string" value="mixer"/>
          <property name="plugin-9" type="string" value="battery"/>
          <property name="plugin-10" type="string" value="datetime"/>
          <property name="plugin-11" type="string" value="actions"/>
          <property name="plugin-12" type="string" value="pager"/>
        </property>
      </channel>
    '';
  };

  # Theming configuration
  environment.etc."xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xsettings" version="1.0">
      <property name="Net" type="empty">
        <property name="ThemeName" type="string" value="Arc-Dark"/>
        <property name="IconThemeName" type="string" value="Papirus-Dark"/>
      </property>
      <property name="Gtk" type="empty">
        <property name="CursorThemeName" type="string" value="Adwaita"/>
        <property name="CursorThemeSize" type="int" value="24"/>
        <property name="FontName" type="string" value="Noto Sans 10"/>
        <property name="MonospaceFontName" type="string" value="Hack 10"/>
      </property>
    </channel>
  '';
  
  # Create directories for wallpapers
  system.activationScripts.wallpapers = ''
    mkdir -p /etc/nixos/wallpapers
  '';
  
  # Enable cups for printing
  services.printing.enable = true;
  
  # Audio configuration - using PipeWire instead of PulseAudio
  # Removed sound.enable as it's deprecated
  services.pipewire = {
    enable = lib.mkForce true;  # Force enable to override alsa.nix's setting
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;  # PulseAudio compatibility
    jack.enable = true;   # JACK compatibility
  };
  
  # Explicitly disable PulseAudio to avoid conflicts with PipeWire
  services.pulseaudio.enable = false;
  
  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
  
  # Enable brightness control
  programs.light.enable = true;
  
  # Power management
  services.upower.enable = true;
  powerManagement.enable = true;
  
  # Automounting
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  
  # Network Manager applet
  programs.nm-applet.enable = true;
}
