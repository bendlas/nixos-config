{ config, pkgs, lib, ... }:
{
  imports = [
    #./base.nix
    ./desktop.nix # ./xsession.nix
  ];

  users.extraUsers.root.password = "123";
  users.extraUsers.vm.password = "123";
  users.extraUsers.vm.isNormalUser = true;
  users.mutableUsers = false;

  networking.hostName = "vm";

  environment.systemPackages = with pkgs; [ ];
  environment.enableDebugInfo = true;

  services.xserver.displayManager.qingy.enable = true;
  services.xserver.displayManager.kdm.enable = lib.mkForce false;
}
