{ config, pkgs, ... }:
let npc = import ./nixpkgs-config.nix;
in {

  environment.systemPackages = (with pkgs; [

    file screen tmux htop wget psmisc utillinuxCurses zip unzip lsof
    bind hdparm pmutils iotop rlwrap traceroute emacs which nix-repl
    iptables telnet reptyr tree multipath_tools lm_sensors ent davfs2
    btrfsProgs dmidecode nmap git

    leiningen gettext jdk jdk.jre maven3 s3cmd sqlite

  ]);

/*  environment.sessionVariables = {
    NIX_PATH = pkgs.lib.mkForce([
      "nixpkgs=/etc/nixos/nixpkgs-unstable-channel"
      "nixos=/etc/nixos/nixpkgs-unstable-channel/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels/nixos"
      "/nix/var/nix/profiles/per-user/root/channels"
    ]);
  }; */

  ## Outsource nixpkgs.config to be shared with nix-env
  nixpkgs.config = npc;

  users.extraUsers = {
    "herwig" = {
      description = "Herwig Hochleitner";
      extraGroups = [ "wheel" ];
      shell = "/run/current-system/sw/bin/zsh";
      isNormalUser = true;
      uid = 1000;
    };
  };

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
      "nixpkgs=/etc/nixos/nixpkgs-unstable-channel"
      "nixos=/etc/nixos/nixpkgs-unstable-channel/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels/nixos"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
    buildCores = 4;
    extraOptions = ''
      binary-caches-parallel-connections = 24
      gc-keep-outputs = false
      gc-keep-derivations = false
    '';
  };
  
}
