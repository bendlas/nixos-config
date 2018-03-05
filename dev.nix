{ config, pkgs, ... }:

{
  ## require = [ ./taalo.nix ];
  ## vuizvui.user.aszlig.programs.taalo-build.enable = true;

  networking = {
    extraHosts = ''
      127.0.0.1 leihfix.local static.local jk.local hdnews.local hdirect.local stats.local sub.hdnews.local app.phoenix.dev mobile.phoenix.dev
    '';
    firewall = {
      #allowedTCPPorts = [ 22 ];
      allowedTCPPorts = [ 22 80 443 3449 8081 8000 8080 ];
      #allowedTCPPortRanges = [
      #  { from = 8000; to = 9000; }
      #];
      allowPing = true;
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
    };
  };
  environment.systemPackages = (with pkgs; [
    emacs.emacs.debug docker_compose
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
    teamviewer.enable = true;
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

}
