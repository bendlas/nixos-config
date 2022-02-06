{ config, pkgs, ... }:
{

  environment.systemPackages = (with pkgs; [

    pciutils ntfs3g st gparted

    paprefs pavucontrol alsaUtils ffmpeg imagemagick

    glxinfo xlibs.xkill xlibs.xbacklight xlibs.xrandr xlibs.xev
    xlibs.xhost xlibs.xkbcomp aspell aspellDicts.en aspellDicts.de
    dunst libnotify xorg.xdpyinfo gcolor3 pinentry

    geoip unrar bsdiff gitAndTools.hub links2 jack2Full beep

    dbus_tools dfeet systool # nixui

    libva-utils

    texlive-bendlas
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

  require = [ ./base.nix ./io-scheduler.nix ./desktop-packages.nix ];
  console.useXkbConfig = true;

  services = {
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
      # exportConfiguration = true;
      # layout = "us";

      layout = "us-gerextra";
      extraLayouts.us-gerextra = {
        description = ''
          English layout with german umlauts on AltGr
        '';
        languages = [ "eng" "ger" ];
        keycodesFile = pkgs.writeText "us-gerextra-keycodes" ''
          xkb_keycodes "us-gerextra" { include "evdev+aliases(qwerty)" };
        '';
        geometryFile = pkgs.writeText "us-gerextra-geometry" ''
          xkb_geometry "us-gerextra" { include "pc(pc104)" };
        '';
        typesFile = pkgs.writeText "us-gerextra-types" ''
          xkb_types "us-gerextra" { include "complete" };
        '';
        symbolsFile = pkgs.writeText "us-gerextra-symbols" ''
          xkb_symbols "us-gerextra" {
            key <AD03> { [ e, E, EuroSign ] };
            key <AD07> { [ u, U, udiaeresis, Udiaeresis ] };
            key <AD09> { [ o, O, odiaeresis, Odiaeresis ] };
            key <AC01> { [ a, A, adiaeresis, Adiaeresis ] };
            key <AC02> { [ s, S, ssharp, U1E9E ] };
            augment "pc+us+inet(evdev)+ctrl(nocaps)+level3(ralt_switch)"
          };
        '';
      };

      xkbOptions = "eurosign:e";
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
  programs.steam.enable = true;

}
