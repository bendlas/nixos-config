{ config, pkgs, ... }:
{
  imports = [
    ./base.nix
    #./desktop.nix ./xsession.nix
  ];

  users.extraUsers.herwig.password = "123";
  users.mutableUsers = false;

  networking = rec {
    hostName = "vm";
    hostId = "e26c37cc";
  };

  environment.systemPackages = (with pkgs; [
    systemtap
  ]);

}
