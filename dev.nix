{ config, pkgs, ... }:

{
  require = [ ./taalo.nix ];
  vuizvui.user.aszlig.programs.taalo-build.enable = true;

  networking = {
    extraHosts = ''
      127.0.0.1 leihfix.local static.local jk.local hdnews.local hdirect.local stats.local
    '';
    firewall = {
      allowedTCPPorts = [ 22 8023 8580 8581 8582 ]; # 80 443 3449 8000 8080 8020
      allowPing = true;
    };
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
    };
  };
  environment.systemPackages = (with pkgs; [
    emacs.emacs.debug
  ]);
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
}
