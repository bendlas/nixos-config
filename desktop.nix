{ config, pkgs, ... }:
{

  environment.systemPackages = (with pkgs; [

    abiword gnumeric thunderbird skype

    pciutils ntfs3g wireshark xpra eterm st finalterm nodejs unetbootin gparted

    debootstrap mercurial subversion cmake rustc cargo nim ant go pypy dust
    pythonPackages.ipython guile guile_lib nodePackages.grunt-cli lua mono
    luajit luarocks racket

    dmenu glxinfo liberation_ttf xlibs.xkill
    xlibs.xbacklight xlibs.xrandr xlibs.xev xlibs.xkbcomp aspell
    aspellDicts.en aspellDicts.de dunst libnotify

    firefox deluge dosbox alsaUtils clementine gimp geoip
    idea.idea-community chromium vlc inkscape steam dropbox-cli bitcoin
    unrar p7zip bsdiff blender gitAndTools.hub # antimony
    links2 qjackctl jack2Full beep wine winetricks # radare2
    valgrind sbcl npm2nix lyx nix-generate-from-cpan paprefs pavucontrol
    pinentry dos2unix audacity pgadmin
    google-musicmanager teamspeak_client

    thunderbird ffmpeg sauerbraten # stalin ipfs

    nixui gnome3.cheese youtube-dl imagemagick

    qemu_kvm qemu virtmanager zcash

    (sbt.override { jre = jdk7.jre; })
    (texlive.combine {
      inherit (texlive) scheme-medium koma-script mathpazo
                        booktabs pdfpages hyperref g-brief xstring numprint unravel
                        collection-latex collection-latexextra collection-latexrecommended
                        collection-fontsrecommended
                        ; # g-brief numprint unravel xstring -- sha-mismatch??
    })
    androidenv.androidsdk_7_1_1_extras
    linuxPackages.systemtap

    # dwarf-fortress dwarf-therapist dwarf-fortress-packages.phoebus-theme
    
#  ] ++ (with haskellPackages; [
#    ghc cabal-install cabal2nix
  ] ++ pkgs.gnome3.corePackages ++ pkgs.gnome3.optionalPackages);

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
  security.setuidOwners = [{
    program = "dumpcap";
    owner = "root";
    group = "wireshark";
    setuid = true;
    setgid = false;
    permissions = "u+rx,g+x";
  }];
  
  require = [ ./base.nix ];
  services = {
    i2p.enable = true;
    tor = {
      enable = true;
      client.enable = true;
      relay.enable = true;
      relay.isBridge = true;
      relay.portSpec = "80";
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
      #displayManager.gdm.enable = true;
      #desktopManager.gnome3.enable = true;
      displayManager.kdm.enable = true;
      #desktopManager.kde4.enable = true;
    };
    upower.enable = true;
    dbus.packages = with pkgs; [
      miraclecast
    ];
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  virtualisation = {
    ## xen build is broken
    libvirtd.enable = false;
    virtualbox.host.enable = false;
  };

  hardware.opengl.driSupport32Bit = true;

  programs.cdemu.enable = true;
  
}
