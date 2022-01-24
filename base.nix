
{ config, pkgs, ... }:
let npc = import ./nixpkgs-config.nix;
in {
  require = [
    ./log.nix ./sources.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix
  ];
  system.stateVersion = "20.03";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.cleanTmpDir = true;
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  environment.systemPackages = with pkgs; [

    file screen tmux btop htop wget psmisc utillinux zip unzip lz4 lsof
    bind hdparm pmutils iotop rlwrap traceroute which # emacs ## is added by enabling exwm
    iptables telnet tree multipath_tools lm_sensors ent davfs2 # reptyr
    btrfsProgs dmidecode nmap gitFull vde2 gradle gnumake
    socat libressl vim patchelf gcc clisp parted usbutils # diffoscope
    rsync gnupg gdb powertop lshw libxslt dvtm abduco dtach # letsencrypt
    nox pv nethogs iftop jq yq iftop moreutils dhcp

    sqlite mkpasswd

    cowsay elfutils binutils
    ncurses ncurses.dev ## for infocmp, figwheel repl

    taalo-build git-new-workdir vnstat

    inotify-tools direnv pass

    ed nano

  ];

  environment.variables = {
    EDITOR = "ed -p\\*";
    VISUAL = "emacsclient -a 'emacs -nw'";
    ALTERNATE_EDITOR = "nano";
  };

  users.extraUsers = {
    "herwig" = {
      description = "Herwig Hochleitner";
      extraGroups = [ "wheel" "networkmanager" "dialout" ];
      shell = "/run/current-system/sw/bin/zsh";
      isNormalUser = true;
      uid = 1000;
    };
  };
  users.extraGroups = { nobody = {}; };

  networking = {
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 ];
    networkmanager.enable = false;
    useDHCP = false;
    useNetworkd = true;
    extraHosts = ''
      127.0.0.1 ${config.networking.hostName}
      ::1 ${config.networking.hostName}
    '';
  };

  ## boot.supportedFilesystems = [ "bcachefs" ]; ## "zfs" ];

  services = {
    flatpak.enable = true;
    ssmtp = {
      enable = true;
      domain = config.networking.hostName;
      hostName = "mail.bendlas.net";
    };
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "herwig";
    };
    dnsmasq = {
      enable = false;
      servers = [ "77.109.148.136" "2001:1620:2078:136::" "8.8.8.8" ];
    };
    resolved = {
      enable = true;
      # dnssec = "allow-downgrade";
      dnssec = "false";
      extraConfig = ''
        DNS=8.8.8.8
        DNSOverTLS=opportunistic
      '';
    };
    locate.enable = false;
    physlock.enable = true;
    vnstat.enable = true;
  };
  security.sudo.wheelNeedsPassword = false;
  programs.gnupg.agent.enable = true;

}
