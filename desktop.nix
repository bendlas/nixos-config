{ config, pkgs, ... }:
{

  environment.systemPackages = (with pkgs; [

    pciutils ntfs3g wireshark st gparted

    paprefs pavucontrol alsaUtils ffmpeg imagemagick

    glxinfo xlibs.xkill xlibs.xbacklight xlibs.xrandr xlibs.xev
    xlibs.xhost xlibs.xkbcomp aspell aspellDicts.en aspellDicts.de
    dunst libnotify xorg.xdpyinfo gcolor3 pinentry

    geoip unrar bsdiff gitAndTools.hub links2 jack2Full beep

    nixui dbus_tools dfeet systool

    texlive-bendlas
    (localPackages ./desktop.packages config)
  ]);

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

  ## Define a group for jack and the like
  security.pam.loginLimits = [{
    domain = "@realtime";
    type   = "-";
    item   = "rtprio";
    value  = "99";
  }{
    domain = "@realtime";
    type   = "-";
    item   = "memlock";
    value  = "unlimited";
  }];

  require = [ ./base.nix ./io-scheduler.nix ];
  services = {
    compton = {
      enable = true;
      fade = true;
      fadeDelta = 2;
    };
    i2p.enable = true;
    tor = {
      enable = true;
      client.enable = true;
      client.dns.enable = true;
      controlSocket.enable = true;
      relay.enable = false;
      relay.role = "bridge";
      relay.port = "80";
    };
    xserver = {
      enable = true;
      exportConfiguration = true;
      layout = "us";
      xkbOptions = "eurosign:e";
      desktopManager.gnome3.enable = true;
      displayManager.gdm = {
        enable = false;
        wayland = false;
      };
      displayManager.lightdm.enable = true;
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
    avahi = {
      enable = true;
      nssmdns = true;
      wideArea = false;
    };
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    tcp.enable = true;
    zeroconf = {
      discovery.enable = true;
      publish.enable = true;
    };
  };

  # Pulseaudio uses 4713
  networking.firewall.allowedTCPPorts = [ 4713 ];

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
