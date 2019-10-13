{ config, pkgs, ... }:
{

  environment.systemPackages = (with pkgs; [

    abiword gnumeric visualvm thunderbird skype

    pciutils ntfs3g wireshark st nodejs unetbootin gparted

    debootstrap mercurial subversion cmake rustc cargo nim ant go
    pythonPackages.ipython guile nodePackages.grunt-cli mono
    luajit luarocks racket dust pypy

    dmenu glxinfo liberation_ttf xlibs.xkill
    xlibs.xbacklight xlibs.xrandr xlibs.xev xlibs.xkbcomp aspell
    aspellDicts.en aspellDicts.de dunst libnotify

    firefox deluge dosbox alsaUtils gimp geoip clementine
    chromium vlc inkscape steam idea.idea-community bitcoin
    unrar p7zip bsdiff gitAndTools.hub blender antimony
    links2 qjackctl jack2Full beep wine winetricks radare2 radare2-cutter
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

    tdesktop webtorrent_desktop teamspeak_client

    dbus_tools dfeet systool openscad

  ]);

  system.extraDependencies = [ pkgs.virtualboxExtpack ];

  fonts = {
    fonts = with pkgs; [
      noto-fonts proggyfonts dejavu_fonts inconsolata profont anonymousPro fira-code
    ];
  };

  users = {
    extraUsers."herwig".extraGroups = [
      "vboxusers" "cdrom" "networkmanager" "realtime" "libvirtd" "wireshark"
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
    i2p.enable = true;
    tor = {
      enable = true;
      client.enable = true;
      relay.enable = true;
      relay.role = "bridge";
      relay.port = "80";
    };
    postgresql.authentication = pkgs.lib.mkForce ''
      local all all                trust
      host  all all 127.0.0.1/32   trust
      host  all all ::1/128        trust
    '';
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
      publish = {
        enable = true;
        userServices = true;
      };
      nssmdns = false;
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
    virtualbox.host = {
      enable = false;
      enableExtensionPack = true;
    };
  };

  hardware.opengl.driSupport32Bit = true;

  programs.cdemu.enable = true;
  programs.wireshark.enable = true;

}
