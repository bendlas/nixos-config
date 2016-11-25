{ config, pkgs, lib, ... }:
{
  imports = [
    ./desktop.nix ./xsession.nix ./dev.nix ./power-savings.nix
  ];
  fileSystems."/" = { device = "/dev/null"; };
  boot.loader.grub.enable = false;
  networking.nat.externalInterface = "dummy";
}
