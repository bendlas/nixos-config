{ config, pkgs, lib, ... }:
{
  imports = [ ./desktop.nix ./dev.nix ./power-savings.nix ];
  fileSystems."/" = { device = "/dev/null"; };
  boot.loader.grub.enable = false;
  networking.nat.externalInterface = "dummy";
  services.xserver.videoDrivers = [ "nvidia" "nouveau" "nv" "vesa" "intel" ];

}
