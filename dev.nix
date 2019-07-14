{ config, pkgs, ... }:
let
  container-host-ip = "10.233.2.1";
  vitox-ip = "10.233.2.2";
in
{
  ## require = [ ./taalo.nix ];
  ## vuizvui.user.aszlig.programs.taalo-build.enable = true;

  ## require = [ ./matrix.nix ];



  networking = {
    extraHosts = ''
      127.0.0.1  app.phoenix.dev mobile.phoenix.dev
      ${vitox-ip} jk.local hdnews.local hdirect.local static.local stats.local sub.hdnews.local
    '';
    firewall = {
      #allowedTCPPorts = [ 22 ];
      allowedTCPPorts = [ 22 80 443 3449 8081 8000 8050 8080 9981 9982 ];
      allowedUDPPorts = [ 9981 9982 ];
      #allowedTCPPortRanges = [
      #  { from = 8000; to = 9000; }
      #];
      allowPing = true;
      checkReversePath = false;
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
    };
    # interfaces = {
    #   docker0.useDHCP = false;
    #   virbr0.useDHCP = false;
    # };
  };
  systemd.network.networks = {
    "20-docker" = {
      matchConfig.Name = "docker*";
      linkConfig.Unmanaged = true;
    };
    "20-virbr" = {
      matchConfig.Name = "virbr*";
      linkConfig.Unmanaged = true;
    };
  };
  environment.systemPackages = (with pkgs; [
    emacs.emacs.debug docker_compose
    nixops virtmanager
    nodePackages.tern
  ]);
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;

  };
  environment.enableDebugInfo = true;
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql;
      enableTCPIP = true;
    };
  };
  nix = {
    trustedBinaryCaches = [ "https://headcounter.org/hydra" ];
    binaryCachePublicKeys = [ "headcounter.org:/7YANMvnQnyvcVB6rgFTdb8p5LG1OTXaO+21CaOSBzg=" ];
  };

  users.extraUsers = {
    "test" = {
      description = "Test User";
      shell = "/run/current-system/sw/bin/zsh";
      isNormalUser = true;
    };
    "herwig".extraGroups = [ "docker" ];
  };

  # containers.vitox = {
  #   config = /home/herwig/checkout/net.bendlas-next/etc/nixos/instances/vitox.nix;
  #   privateNetwork = true;
  #   hostAddress = container-host-ip;
  #   localAddress = vitox-ip;
  #   bindMounts."/src/net.bendlas".hostPath = "/home/herwig/checkout/net.bendlas-next";
  # };

}
