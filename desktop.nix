{ config, pkgs, ... }:
{

  environment.systemPackages = (with pkgs; [

    pciutils ntfs3g wireshark xpra roxterm nodejs unetbootin gparted

    debootstrap mercurial subversion cmake rustc cargo nim ant pypy pixie
    pythonPackages.ipython guile guile_lib nodePackages.grunt-cli lua
    luajit luarocks androidsdk_4_4 racket # sdlmame ## ftp.archlinux.org unavailable

    dmenu glxinfo liberation_ttf xlibs.xkill xlibs.xmodmap
    xlibs.xbacklight xlibs.xrandr xlibs.xev xlibs.xkbcomp aspell
    aspellDicts.en aspellDicts.de dunst libnotify google-musicmanager

    firefoxWrapper deluge dosbox alsaUtils clementine gimp geoip
    idea.idea-ultimate chromium vlc inkscape steam dropbox-cli bitcoin
    unrar p7zip gitAndTools.hub bsdiff antimony blender
    links2 texLiveFull wine winetricks qjackctl jack2Full beep radare2
    valgrind sbcl npm2nix lyx nix-generate-from-cpan paprefs pavucontrol
    pinentry

    qemu_kvm qemu virtmanager
    
  ] ++ (with haskellPackages; [
    ghc cabal-install cabal2nix
  ] ++ pkgs.gnome3.corePackages ++ pkgs.gnome3.optionalPackages));

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
      #displayManager.slim.enable = true;
      #displayManager.lightdm.enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome3.enable = true;
      #desktopManager.e19.enable = true;
#      windowManager = {
#        stumpwm.enable = true;
#        exwm.enable = true;
#      };
    };
    upower.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  virtualisation = {
    libvirtd.enable = true;
    virtualbox.host.enable = true;
  };

  hardware.opengl.driSupport32Bit = true;

  programs.cdemu.enable = true;
  
}
