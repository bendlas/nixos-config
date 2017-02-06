{ config, pkgs, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.lenix.nix ./dev.nix ./power-savings.nix ./xsession.nix ];

  environment.systemPackages = (with pkgs; [
    bluez5
  ]);

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "resume=UUID=6567b6fd-c570-412e-8f53-b6ba1733640c" ];
  };

  networking = rec {
    hostName = "lenix";
    hostId = "f26c47cd";
    nat.externalInterface = "wlp3s0";
    wireless = {
      enable = true;
      userControlled.enable = true;
    };
  };

  services = {
    xserver = {
      videoDrivers = [ "intel" ];
      libinput.enable = false;
      synaptics = {
          enable = true;
          twoFingerScroll = true;
      };
    };
    printing = {
      enable = true;
      drivers = [ pkgs.splix ];
    };
  };

  hardware = {
    trackpoint.emulateWheel = true;
    bluetooth.enable = true;
  };

  #  boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];

}
