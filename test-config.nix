{ config, pkgs, lib, ... }:
{
  imports = [ ./desktop.nix ./dev.nix ];
  fileSystems."/" = { device = "/dev/null"; };
  boot.loader.grub.enable = false;
  networking.hostId = "cafebabe";
  networking.nat.externalInterface = "dummy";
  services.xserver.videoDrivers = [ "nvidia" "nouveau" "nv" "vesa" "intel" ];

}
