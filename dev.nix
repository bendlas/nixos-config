{ config, pkgs, ... }:

{
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
}
