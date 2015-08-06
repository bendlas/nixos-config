{ config, pkgs, ... }:

{ 
  programs.cdemu.enable = true;

  environment = {
    systemPackages = (with pkgs; [
      ## dev-essentials 
      binutils gcc gdb gnumake pkgconfig python git patchelf radare2 valgrind
      
      ## essentials
      file screen tmux htop wget psmisc gptfdisk gparted gnupg file unzip lsof bind hdparm pmutils iotop rlwrap traceroute emacs which nmap wireshark nix-repl iptables telnet tree reptyr pciutils ntfs3g multipath_tools lm_sensors xpra roxterm nodejs #e19.terminology

      ## dev
      debootstrap mercurial subversion cmake rustc cargo nim leiningen gettext # pypy
      jdk jdk.jre maven3 ant nodejs s3cmd pythonPackages.ipython guile guile_lib # nodePackages.grunt-cli
      lua luajit luarocks
      androidsdk_4_4 #sdlmame

      ## desktop
      dmenu glxinfo liberation_ttf xlibs.xkill xlibs.xmodmap xlibs.xbacklight xlibs.xrandr
      aspell aspellDicts.en aspellDicts.de

      
      ## apps
      firefoxWrapper deluge dosbox alsaUtils clementine gimp winetricks geoip idea.idea-ultimate chromium vlc inkscape texLiveFull steam dropbox-cli bitcoin nmap_graphical unrar p7zip wine gitAndTools.hub bsdiff antimony blender links2
      
      ## sound
      qjackctl jack2Full beep

      ##virt
      qemu_kvm qemu virtmanager
    ] ++ (with haskellngPackages; [
      ghc cabal-install cabal2nix
    ]));
    sessionVariables = {
      NIX_PATH = pkgs.lib.mkForce([
        "nixpkgs=/etc/nixos/nixpkgs-unstable-channel"
        "nixos=/etc/nixos/nixpkgs-unstable-channel/nixos"
        "nixos-config=/etc/nixos/configuration.nix"
        "/nix/var/nix/profiles/per-user/root/channels/nixos"
        "/nix/var/nix/profiles/per-user/root/channels"
      ]);
    };
    gnome3.packageSet = pkgs.gnome3_16;
  };
    
  users = {
    extraUsers = {
      herwig = {
        description = "Herwig Hochleitner";
        extraGroups = [ "wheel" "vboxusers" "cdrom" "networkmanager" "realtime" "libvirtd" "wireshark" ];
        shell = "/run/current-system/sw/bin/zsh";
        isNormalUser = true;
        uid = 1000;
      };
      christine = {
        description = "Christine Brameshuber";
        isNormalUser = true;
	uid = 1001;
      };
    };
    extraGroups = {
      realtime = {};
      wireshark = {};
    };
  };

  services = {
    i2p.enable = true;
    # freenet.enable = true;
    virtualboxHost.enable = true;
    postgresql = {
      enable = true;
      package = pkgs.postgresql;
      enableTCPIP = true;
      authentication = pkgs.lib.mkForce ''
        local all all                trust
        host  all all 127.0.0.1/32   trust
        host  all all ::1/128        trust
      '';
    };
  };

  networking = {
    extraHosts = ''
      127.0.0.1 leihfix.local static.local jk.local hdnews.local hdirect.local
    '';
    firewall.enable = false;
  };

  virtualisation.libvirtd.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_4_1;
    kernel.sysctl."fs.inotify.max_user_watches" = 100000;
  };

  hardware = {
    opengl.driSupport32Bit = true;
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
}
