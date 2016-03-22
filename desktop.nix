{ config, pkgs, ... }:
{

  environment.systemPackages = (with pkgs; [

    abiword gnumeric thunderbird skype

    pciutils ntfs3g wireshark xpra roxterm nodejs unetbootin gparted

    debootstrap mercurial subversion cmake rustc cargo nim ant pypy dust go
    pythonPackages.ipython guile guile_lib nodePackages.grunt-cli lua mono
    luajit luarocks androidsdk_4_4 racket

    dmenu glxinfo liberation_ttf xlibs.xkill xlibs.xmodmap
    xlibs.xbacklight xlibs.xrandr xlibs.xev xlibs.xkbcomp aspell
    aspellDicts.en aspellDicts.de dunst libnotify

    firefoxWrapper deluge dosbox alsaUtils clementine gimp geoip
    idea.idea-ultimate chromium vlc inkscape steam dropbox-cli bitcoin
    unrar p7zip bsdiff blender gitAndTools.hub # antimony
    links2 texLiveFull wine winetricks qjackctl jack2Full beep radare2
    valgrind sbcl npm2nix lyx nix-generate-from-cpan paprefs pavucontrol
    pinentry pgadmin audacity dos2unix
    google-musicmanager teamspeak_client

    qemu_kvm qemu # virtmanager
    
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
      displayManager.gdm.enable = true;
      #displayManager.sddm.enable = true;
      desktopManager.gnome3.enable = true;
    };
    upower.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  virtualisation = {
    ## xen build is broken
    libvirtd.enable = false;
    virtualbox.host.enable = true;
  };

  hardware.opengl.driSupport32Bit = true;

  programs.cdemu.enable = true;
  
}
