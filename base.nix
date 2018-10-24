{ config, pkgs, ... }:
let npc = import ./nixpkgs-config.nix;
in {
  system.stateVersion = "18.03";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.cleanTmpDir = true;

  environment.systemPackages = with pkgs; [

    file screen tmux htop wget psmisc utillinuxCurses zip unzip lsof
    bind hdparm pmutils iotop rlwrap traceroute which # emacs ## is added by enabling exwm
    iptables telnet reptyr tree multipath_tools lm_sensors ent davfs2
    btrfsProgs dmidecode nmap gitFull vde2 gradle gnumake
    socat libressl diffoscope vim patchelf gcc clisp parted usbutils
    rsync gnupg gdb powertop lshw libxslt letsencrypt dvtm abduco dtach
    nox pv nethogs iftop jq

    boot leiningen gettext jdk maven3 s3cmd sqlite python mkpasswd # cask criu
    
    cowsay
    
    taalo-build git-new-workdir update-git-channel

  ];

  ## Outsource nixpkgs.config to be shared with nix-env
  nixpkgs.config = npc;
  ## TODO replace with full config include
  system.copySystemConfiguration = true;

  users.extraUsers = {
    "herwig" = {
      description = "Herwig Hochleitner";
      extraGroups = [ "wheel" "networkmanager" ];
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
    useNetworkd = true;
    extraHosts = ''
      127.0.0.1 ${config.networking.hostName}
      ::1 ${config.networking.hostName}
    '';
  };

  time.timeZone = "Europe/Vienna";

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  ## boot.supportedFilesystems = [ "zfs" ];

  environment.etc."resolv.conf" = pkgs.lib.mkForce {
    text = ''
      ## Use systemd-resolved.service as dns service
      nameserver 127.0.0.53
      ## Fallback server on Xiala.net in case we got a sig stripping dns server
      nameserver 77.109.148.136
    '';
  };

  services = {
    nscd.enable = false;
    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      fallbackDns = [ "77.109.148.136" "2001:1620:2078:136::" ];
    };
    fail2ban = {
      enable = true;
      jails = {
        # this is predefined
        ssh-iptables = ''
          enabled  = true
        '';
      };
    };
    openssh = {
      enable = true;
      passwordAuthentication = false;
      startWhenNeeded = true;
    };
    locate = {
      enable = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  programs = {
    mosh.enable = true;
    criu.enable = true;
    systemtap.enable = true;
    zsh = {
      enable = true;
      promptInit = "";
      interactiveShellInit = ''
        unalias run-help
        autoload -Uz run-help
      '';
    };
  };

  nix = {
    nixPath = [
      "nixpkgs=/etc/nixos/pkgs"
      "nixos=/etc/nixos/pkgs/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
    ];
    buildCores = 4;
    extraOptions = ''
      binary-caches-parallel-connections = 24
      gc-keep-outputs = false
      gc-keep-derivations = false
      build-use-sandbox = true
    '';
  };
  
}
