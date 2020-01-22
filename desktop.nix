{ config, pkgs, ... }:
{

  environment.systemPackages = (with pkgs; [

    abiword gnumeric thunderbird

    pciutils ntfs3g wireshark st nodejs unetbootin gparted

    debootstrap mercurial subversion cmake
    guile nodePackages.grunt-cli mono
    luajit luarocks racket dust pypy

    dmenu glxinfo liberation_ttf xlibs.xkill
    xlibs.xbacklight xlibs.xrandr xlibs.xev xlibs.xkbcomp aspell
    aspellDicts.en aspellDicts.de dunst libnotify

    dosbox alsaUtils gimp geoip
    chromium vlc steam bitcoin
    unrar p7zip bsdiff gitAndTools.hub
    links2 qjackctl jack2Full beep radare2 radare2-cutter
    valgrind sbcl lyx nix-generate-from-cpan paprefs pavucontrol
    pinentry dos2unix audacity pgadmin
    google-musicmanager xlibs.xhost
    gcolor3 signal-desktop xorg.xdpyinfo

    texlive-bendlas

    ffmpeg ipfs sauerbraten pkgsi686Linux.stalin

    gnome3.cheese youtube-dl imagemagick nixui

    qemu_kvm qemu ja2-stracciatella zcash

    dwarf-fortress
    dwarf-therapist

    dbus_tools dfeet systool openscad

  ]) ++ [(pkgs.buildLazyBinaries {
    # nixpkgs = (<nixpkgs>);
    catalog = {
      "ml-workbench" = [ "hy" "python3" ];
      "tdesktop" = [ "telegram-desktop" ];
      "webtorrent_desktop" = [ "WebTorrent" ];
      "teamspeak_client" = [ "teamspeak" ];
      "idea.idea-community" = [ "idea-community" ];
    };
    installed = [
      "nixops" "hy" "python3" "skype" "visualvm"
      "telegram-desktop" "WebTorrent" "teamspeak"
      "inkscape" "idea-community" "firefox" "deluge"
      "clementine" "rustc" "cargo" "nim" "ant" "go"
      "wine" "winetricks" "blender" "antimony"
    ];
  })];

  # system.extraDependencies = [ pkgs.virtualboxExtpack ];

  fonts = {
    fonts = with pkgs; [
      noto-fonts proggyfonts dejavu_fonts inconsolata profont anonymousPro fira-code jetbrains-mono
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

  ## Pulseaudio uses 4713
  # networking.firewall.allowedTCPPorts = [ 4713 ];

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
