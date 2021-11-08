{ pkgs, lib, ... }:
{

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
  boot.supportedFilesystems = [ "zfs" ];

}
