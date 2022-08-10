{ lib, config, pkgs, ... }:
{
  require = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./essential.module.nix # ./mdns.module.nix ./ssh.module.nix
    ./networkd.module.nix

    ./access.module.nix ./docu-disable.module.nix

    (import <mobile-nixos/lib/configuration.nix> { device = "uefi-x86_64"; })
    ./pinox/phosh.nix
  ];

  mobile.boot.stage-1.kernel.additionalModules = [
    "virtio-gpu" "virtiofs"
    "sysfs" "ramfs" "tmpfs" "devpts" "proc" "devtmpfs"
  ];

  bendlas.machine = "pivitox";
  # boot.isContainer = true;

  bendlas.wheel.logins = [ "nixos" ];
  users.users.nixos = {
    isNormalUser = true;
    home = "/home/nixos";
    createHome = true;
    password = "123456";
    extraGroups = [
      "networkmanager"
      "video"
      "feedbackd"
      "dialout" # required for modem access
    ];
    uid = 1000;
  };

  environment.systemPackages = with pkgs; [
    sway
  ];

}
