{ config, pkgs, ... }:

{
  networking = {
    extraHosts = ''
      127.0.0.1 leihfix.local static.local jk.local hdnews.local hdirect.local
    '';
    firewall.enable = true;
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
    };
  };
}
