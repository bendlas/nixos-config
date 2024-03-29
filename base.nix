{ lib, config, pkgs, ... }:

{
  require = [
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix ./convenient.module.nix
    ./mdns.module.nix ./networkd.module.nix
  ];
  system.stateVersion = "20.03";
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
  boot.tmp.cleanOnBoot = true;

  environment.systemPackages = with pkgs; [

    bind # emacs ## is added by enabling exwm
    iptables multipath-tools davfs2 # reptyr
    dmidecode vde2 gradle gnumake
    vim patchelf gcc clisp parted
    gdb libxslt dvtm abduco dtach
    nox nethogs

    ncurses ncurses.dev ## for infocmp, figwheel repl

    taalo-build vnstat

  ];

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

  ## boot.supportedFilesystems = [ "bcachefs" ]; ## "zfs" ];

  services = {
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "herwig";
    };
    dnsmasq = {
      enable = false;
      settings.servers = [ "77.109.148.136" "2001:1620:2078:136::" "8.8.8.8" ];
    };
    resolved = {
      # dnssec = "allow-downgrade";
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

}
