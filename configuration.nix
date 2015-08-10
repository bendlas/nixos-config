# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  nixpkgs.config = import ./nixpkgs-config.nix;

  require = [
     # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./local-packages.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sdb";
    };
    kernelParams = [ "nomodeset" "resume=UUID=b3254264-6843-4eed-b817-81f692d2ca07" ];
  };

  networking = rec {
    hostName = "nitox";
    hostId = "f26c47cc";
    networkmanager.enable = true;
    extraHosts = ''
      127.0.0.1 ${hostName}
      ::1 ${hostName}
    '';
  };

  time.timeZone = "Europe/Vienna";
  i18n = {
    consoleFont = "lat9w-16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
   
  services = {
    fail2ban = import ./fail2ban.nix;
    openssh = {
      enable = true;
      passwordAuthentication = false;
      startWhenNeeded = true;
    };
    locate.enable = true;
    xserver = {
      enable = true;
      exportConfiguration = true;
      layout = "us";
      xkbOptions = "eurosign:e";
      #displayManager.slim.enable = true;
      displayManager.lightdm.enable = true;
      #displayManager.gdm.enable = true;
      #desktopManager.gnome3.enable = true;
      #desktopManager.e19.enable = true;
      windowManager = {
        stumpwm.enable = true;
        exwm.enable = true;
      };
      synaptics = {
        enable = true;
        twoFingerScroll = true;
      };
    };
  };
  hardware.trackpoint.emulateWheel = true;
  security.sudo.wheelNeedsPassword = false;
  nix = {
    buildCores = 4;
    extraOptions = ''
      binary-caches-parallel-connections = 24
      gc-keep-outputs = false
      gc-keep-derivations = false
    '';
  };

  programs.zsh.enable = true;

}
