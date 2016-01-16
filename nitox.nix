# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.nitox.nix ./xsession.nix ./dev.nix ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sdb";
    };
    kernelParams = [ "nomodeset" "resume=UUID=b3254264-6843-4eed-b817-81f692d2ca07" ];
    initrd.availableKernelModules = [ "bcache" ];
  };

  networking = rec {
    hostName = "nitox";
    hostId = "f26c47cc";
    nat.externalInterface = "enp5s0";
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
  
}
