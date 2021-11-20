{ config, pkgs, ... }:
let
  container-host-ip = "10.233.2.1";
  vitox-ip = "10.233.2.2";
in
{
  ## require = [ ./matrix.nix ];

  networking = {
    extraHosts = ''
      127.0.0.1  app.phoenix.dev mobile.phoenix.dev
      ${vitox-ip} jk.local hdnews.local hdirect.local static.local stats.local sub.hdnews.local
    '';
    firewall = {
      # allowedTCPPorts = [ 22 80 443 3449 8081 8000 8050 8080 9981 9982 ];
      # allowedUDPPorts = [ 9981 9982 ];
      #allowedTCPPortRanges = [
      #  { from = 8000; to = 9000; }
      #];
      allowPing = true;
      checkReversePath = "loose";
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" "anbox0" ];
    };
  };
  environment.systemPackages = with pkgs; [
    # emacs.emacs.debug
    docker_compose
    # nixops
    virtmanager
    androidsdk_9_0
    nodePackages.tern
    # ml-workbench
    clojure-lsp
    elixir ruby
  ];
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;

  };
  virtualisation.anbox = {
    enable = false;
  };
  systemd.network-wait-online.ignore = [ "anbox0" ];
  # systemd.services.systemd-networkd-wait-online.serviceConfig.ExecStart = [
  #   "" # clear old command
  #   ## "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --ignore anbox0"
  #   "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online -i lo:carrier"
  # ];
  environment.enableDebugInfo = true;
  services = {
    postgresql = {
      enable = true;
      enableTCPIP = true;
      # authentication = pkgs.lib.mkForce ''
      #   local all all                trust
      #   host  all all 127.0.0.1/32   trust
      #   host  all all ::1/128        trust
      # '';
    };
    # pgmanage = {
    #   enable = true;
    #   # allowCustomConnections = true;
    #   connections = {
    #     nitox = "hostaddr=127.0.0.1 port=5432 dbname=postgres sslmode=prefer";
    #   };
    # };
  };
  nix = {
    trustedBinaryCaches = [ "https://headcounter.org/hydra" "ssh://nitox.local" ];
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
