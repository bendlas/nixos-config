{ config, pkgs, ... }:
let npc = import ./nixpkgs-config.nix;
in {
  require = [ ./log.nix ];
  system.stateVersion = "18.03";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.cleanTmpDir = true;
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  environment.systemPackages = with pkgs; [

    file screen tmux htop wget psmisc utillinuxCurses zip unzip lsof
    bind hdparm pmutils iotop rlwrap traceroute which # emacs ## is added by enabling exwm
    iptables telnet reptyr tree multipath_tools lm_sensors ent davfs2
    btrfsProgs dmidecode nmap gitFull vde2 gradle gnumake
    socat libressl diffoscope vim patchelf gcc clisp parted usbutils
    rsync gnupg gdb powertop lshw libxslt letsencrypt dvtm abduco dtach
    nox pv nethogs iftop jq iftop

    boot leiningen gettext jdk maven3 s3cmd sqlite python mkpasswd cask # criu
    clojure # lumo
    graphviz

    cowsay elfutils binutils nettools
    ncurses ncurses.dev ## for infocmp, figwheel repl

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
    useDHCP = true;
    useNetworkd = true;
    # Hacky fix for lo losing address on wakeup
    interfaces.lo = {
      ipv4.addresses = [ { address = "127.0.0.1"; prefixLength = 8; } ];
      ipv6.addresses = [ { address = "::1"; prefixLength = 128; } ];
    };
    extraHosts = ''
      127.0.0.1 ${config.networking.hostName}
      ::1 ${config.networking.hostName}
    '';
    defaultMailServer = {
      directDelivery = true;
      domain = config.networking.hostName;
      hostName = "mail.bendlas.net";
    };
  };

  time.timeZone = "Europe/Vienna";

  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  ## boot.supportedFilesystems = [ "bcachefs" ]; ## "zfs" ];

  services = {
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
      dnssec = "false";
      # dnssec = "allow-downgrade";
      #  DNS=8.8.8.8
      extraConfig = ''
        DNSOverTLS=opportunistic
      '';
      fallbackDns = [ "77.109.148.136" "2001:1620:2078:136::" "8.8.8.8" ];
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
      challengeResponseAuthentication = false;
      startWhenNeeded = true;
    };
    locate.enable = false;
    physlock.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  programs = {
    mosh.enable = true;
    criu.enable = false;
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
    # sandboxPaths = [ "/var/cache/ccache-chromium/" ];
    buildCores = 4;
    extraOptions = ''
      binary-caches-parallel-connections = 24
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';
  };

}
