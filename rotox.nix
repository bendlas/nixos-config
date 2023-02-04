{ config, pkgs, lib, ... }:

{

  bendlas.machine = "rotox";

  imports = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix ./convenient.module.nix
    ./mdns.module.nix ./networkd.module.nix ./sound.module.nix
    # shared with ./desktop.nix
    ./desktop.essential.module.nix ./desktop.layout-us-gerextra.module.nix
    # new base
    ./access.module.nix ./docu-disable.module.nix # ./tmpfs.module.nix
    (import <mobile-nixos/lib/configuration.nix> {
      device = "pine64-pinephonepro";
      # device = null;
    })
    # ./kodi-wayland.nix
    ./rastox/kodi-xorg.nix
    ./rastox/users.nix
  ];

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    # displayManager.lightdm.enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.autoSuspend = false;
    displayManager.gdm.wayland = false;
    # videoDrivers = [ "panfrost" "vesa" ];
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.murmur = {
    enable = true;
    openFirewall = true;
  };

  services.cron.enable = false;
  services.avahi.interfaces = [ "end0" ];

  networking.useDHCP = false;
  networking.interfaces.end0.useDHCP = true;

  environment.systemPackages = with pkgs; [
  ];

  system.stateVersion = "23.05";

  ## Hardware config

  boot.consoleLogLevel = 7;
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  mobile.bootloader.enable = false;

  # nixpkgs.overlays = [(import <mobile-nixos/overlay/overlay.nix>)];
  # boot.kernelPackages = lib.recurseIntoAttrs
  #   (pkgs.linuxPackagesFor (pkgs.callPackage ./rotox.kernel.nix {
  #     inherit (config.boot) kernelPatches;
  #   }));
  # boot.kernelParams = [
  #   "console=ttyS2,115200n8"
  #   # "loglevel=7"
  # ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/62fcf4f0-0cac-4d13-8acc-ad12901312cb";
    fsType = "ext4";
  };

  swapDevices = [{
    device = "/dev/disk/by-uuid/4ac61bb0-3ba3-4169-a9c8-b45aae91e074";
  }];

  nixpkgs.hostPlatform = "aarch64-linux";
  powerManagement.cpuFreqGovernor = "ondemand";

}
