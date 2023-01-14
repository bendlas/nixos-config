{ config, pkgs, ... }:
{

  # environment.systemPackages = (with pkgs; [
  #   polkit_gnome ## implements the pkexec dialog
  #   xorg.xkbcomp aspell aspellDicts.en aspellDicts.de
  #   pinentry
  #   # nixui
  # ]);

  # system.extraDependencies = [ pkgs.virtualboxExtpack ];

  fonts = {
    fonts = with pkgs; [
      noto-fonts proggyfonts dejavu_fonts inconsolata profont anonymousPro fira-code jetbrains-mono liberation_ttf
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrains Mono" ];
    };
  };

  users = {
    extraUsers."herwig".extraGroups = [
      "cdrom" "networkmanager" "realtime" "libvirtd" "wireshark" # "vboxusers"
    ];
    extraGroups = { realtime = {}; };
  };

  require = [
    ./base.nix ./io-scheduler.nix
    ./sound.module.nix
    ./steam.module.nix
    ./desktop.essential.module.nix
    ./desktop.convenient.module.nix
    ./desktop.layout-us-gerextra.nix
  ];

  services = {
    flatpak.enable = true;
    compton = {
      enable = false;
      fade = true;
      fadeDelta = 2;
    };
    i2p.enable = false; ## closure size
    tor = {
      enable = true;
      client.enable = true;
      client.dns.enable = true;
      controlSocket.enable = true;
      relay.enable = false;
      relay.role = "bridge";
      settings.ORPort = "80";
    };

    xserver = {
      enable = true;

      # xkbOptions = "eurosign:e";
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
        enable = false;
        # wayland = false;
      };
      displayManager.lightdm.enable = true;
      displayManager.startx.enable = true;
      windowManager.exwm = {
        enable = true;
        enableDefaultConfig = false;
      };
    };
    upower.enable = true;
    dbus.packages = with pkgs; [
      miraclecast
    ];
    openssh.forwardX11 = true;
  };

  virtualisation = {
    ## xen build is broken
    libvirtd.enable = true;
    # virtualbox.host = {
    #   enable = false;
    #   enableExtensionPack = true;
    # };
  };

  hardware.opengl.driSupport32Bit = true;

  programs.cdemu.enable = true;
  programs.wireshark.enable = true;

}
