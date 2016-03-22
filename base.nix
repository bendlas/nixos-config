{ config, pkgs, ... }:
let npc = import ./nixpkgs-config.nix;
in {

  environment.systemPackages = (with pkgs; [

    file screen tmux htop wget psmisc utillinuxCurses zip unzip lsof
    bind hdparm pmutils iotop rlwrap traceroute emacs which nix-repl
    iptables telnet reptyr tree multipath_tools lm_sensors ent davfs2
    btrfsProgs dmidecode nmap gitFull gnupg1compat vde2 gradle gnumake
    socat libressl diffoscope vim patchelf gcc clisp

    leiningen gettext jdk jdk.jre maven3 s3cmd sqlite python criu
    (callPackage ./git-update-channel.nix {})

  ]);

  ## Outsource nixpkgs.config to be shared with nix-env
  nixpkgs.config = npc;
  ## TODO replace with full config include
  system.copySystemConfiguration = true;

  users.extraUsers = {
    "herwig" = {
      description = "Herwig Hochleitner";
      extraGroups = [ "wheel" ];
      shell = "/run/current-system/sw/bin/zsh";
      isNormalUser = true;
      uid = 1000;
    };
    "giuls" = {
      description = "Giuls";
      isNormalUser = true;
      uid = 1001;
    };
  };
  users.extraGroups = { nobody = {}; };

  networking = {
    connman.enable = true;
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

  services = {
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
    locate.enable = true;
    postgresql = {
      enable = true;
      package = pkgs.postgresql;
      enableTCPIP = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  programs.zsh = {
    enable = true;
    promptInit = "";
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
    '';
  };
  
}
