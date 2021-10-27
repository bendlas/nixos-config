{ config, pkgs, ... }:
let npc = import ./nixpkgs-config.nix;
in {
  require = [ ./log.nix ./sources.nix ];
  system.stateVersion = "20.03";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.cleanTmpDir = true;
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  environment.systemPackages = with pkgs; [

    file screen tmux htop wget psmisc utillinux zip unzip lsof
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

  ];

  ## Outsource nixpkgs.config to be shared with nix-env
  nixpkgs.config = npc;
  nixpkgs.overlays = import ./nixpkgs-overlays.nix;
  ## TODO replace with full config include
  system.copySystemConfiguration = true;

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

  time.timeZone = "Europe/Vienna";

  console = {
    keyMap = pkgs.lib.mkDefault "us";
    font = "lat9w-16";
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
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
    vnstat.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

  programs = {
    gnupg.agent.enable = true;
    mosh.enable = true;
    zsh = {
      enable = true;
      shellAliases = {
        l = "lid";
      };
      interactiveShellInit = ''
        export EDITOR="${pkgs.emacs}/bin/emacsclient -A '${pkgs.emacs}/bin/emacs -nw'"
        export VISUAL="$EDITOR"
        export ALTERNATE_EDITOR="${pkgs.vim}/bin/vim"
        source ${./zshrc}
      '';
      promptInit = ''
          LP_PS1_FILE=${./liquidprompt.ps1}
          LP_ENABLE_TEMP=0
          source ${pkgs.callPackage ./liquidprompt.nix {}}/liquidprompt
      '';
    };
    ssh = {
      setXAuthLocation = true;
    };
  };

  nix = {
    buildCores = 4;
    extraOptions = ''
      binary-caches-parallel-connections = 24
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';
  };

}
