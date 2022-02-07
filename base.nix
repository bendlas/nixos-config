
{ config, pkgs, ... }:

{
  require = [
    ./log.nix ./sources.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix
  ];
  system.stateVersion = "20.03";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.cleanTmpDir = true;
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  environment.systemPackages = with pkgs; [

    bind # emacs ## is added by enabling exwm
    iptables multipath_tools davfs2 # reptyr
    btrfsProgs dmidecode vde2 gradle gnumake
    vim patchelf gcc clisp parted # diffoscope
    gdb libxslt dvtm abduco dtach # letsencrypt
    nox nethogs yq moreutils dhcp

    mkpasswd

    cowsay elfutils binutils
    ncurses ncurses.dev ## for infocmp, figwheel repl

    taalo-build git-new-workdir vnstat

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

}
