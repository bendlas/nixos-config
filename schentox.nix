{ config, pkgs, lib, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.schentox.nix ./dev.nix ]; # ./power-savings.nix

  environment.systemPackages = (with pkgs; [
    bluez5
  ]);

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    kernelParams = [ "resume=UUID=d71e0b01-5042-4456-8a72-d4653d0b7e4e" ];
  };

  networking = rec {
    hostName = "schentox";
    hostId = "99cfb55e";
    nat.externalInterface = "wlp3s0";
    wireless = {
      enable = true;
      userControlled.enable = true;
    };
  };

  services = {
    xserver = {
      videoDrivers = [ "nouveau" "vesa" ];
    };
    printing = {
      enable = true;
      drivers = [ pkgs.splix ];
    };
    i2p.enable = lib.mkForce false;
    tor.enable = lib.mkForce false;
  };

  hardware = {
    trackpoint.emulateWheel = true;
    bluetooth.enable = true;
    sane.enable = true;
  };

  users.extraUsers = {
    "augustine" = {
      description = "Augustine Hochleitner";
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
    };
    "dorothea" = {
      description = "Dorothea Hochleitner";
      isNormalUser = true;
      extraGroups = [ "networkmanager" ];
    };
  };

}
