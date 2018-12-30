{ config, pkgs, ... }:
{

  environment.systemPackages = (with pkgs; [

    abiword gnumeric thunderbird visualvm # skype

    pciutils ntfs3g wireshark st nodejs unetbootin gparted

    debootstrap mercurial subversion cmake rustc cargo nim ant go pypy dust
    pythonPackages.ipython guile nodePackages.grunt-cli mono
    luajit luarocks racket

    dmenu glxinfo liberation_ttf xlibs.xkill
    xlibs.xbacklight xlibs.xrandr xlibs.xev xlibs.xkbcomp aspell
    aspellDicts.en aspellDicts.de dunst libnotify

    firefox deluge dosbox alsaUtils gimp geoip clementine
    chromium vlc inkscape steam idea.idea-community bitcoin
    unrar p7zip bsdiff gitAndTools.hub blender # antimony
    links2 qjackctl jack2Full beep wine winetricks radare2 cutter
    valgrind sbcl lyx nix-generate-from-cpan paprefs pavucontrol npm2nix
    pinentry dos2unix audacity pgadmin
    google-musicmanager xlibs.xhost # teamspeak_client
    gcolor3 signal-desktop xorg.xdpyinfo

    texlive-bendlas

    ffmpeg ipfs # stalin sauerbraten

    gnome3.cheese youtube-dl imagemagick nixui

    qemu_kvm qemu ja2-stracciatella # virtmanager zcash

    # androidenv.androidsdk_7_1_1_extras

    # dwarf-fortress dwarf-therapist dwarf-fortress-packages.phoebus-theme
    dwarf-fortress
    dwarf-therapist

    # telegram webtorrent
    tdesktop webtorrent_desktop

#  ] ++ (with haskellPackages; [
#    ghc cabal-install cabal2nix
  ] ++ pkgs.gnome3.corePackages ++ pkgs.gnome3.optionalPackages);

  system.extraDependencies = [ pkgs.virtualboxExtpack ];

  fonts = {
    fonts = with pkgs; [
      font-droid proggyfonts dejavu_fonts inconsolata profont anonymousPro fira-code
    ];
  };

  users = {
    extraUsers."herwig".extraGroups = [
      "vboxusers" "cdrom" "networkmanager" "realtime" "libvirtd" "wireshark"
    ];
    extraGroups = { realtime = {}; wireshark = {}; };
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

  ## wireshark fix
  security.wrappers = {
    dumpcap = {
      source = "${pkgs.wireshark}/bin/dumpcap";
      owner = "root";
      group = "wireshark";
      setuid = true;
      setgid = false;
      permissions = "u+rx,g+x";
    };
  };

  require = [ ./base.nix ];
  services = {
    i2p.enable = true;
    tor = {
      enable = true; # FIXME true;
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
    gnome3 = {
      gnome-keyring.enable = true;
      at-spi2-core.enable = true;
      gnome-user-share.enable = true;
      gvfs.enable = true;
    };
    xserver = {
      enable = true;
      exportConfiguration = true;
      layout = "us";
      xkbOptions = "eurosign:e";
      desktopManager.gnome3.enable = true;
      displayManager.gdm.enable = false;
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
    virtualbox.host.enable = true;
  };

  hardware.opengl.driSupport32Bit = true;

  programs.cdemu.enable = true;

}
