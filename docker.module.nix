{ lib, pkgs, ... }:
{
  # Recent version of docker should be able to handle this
  # necessary to freeze systemd units
  # see https://github.com/NixOS/nixpkgs/pull/104094#pullrequestreview-535717794
  systemd.enableUnifiedCgroupHierarchy = lib.mkForce true;

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  environment.systemPackages = [
    pkgs.docker-compose
  ];
  users.extraUsers = {
    "herwig".extraGroups = [ "docker" ];
  };
}
