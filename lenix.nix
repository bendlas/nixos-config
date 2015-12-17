{ config, pkgs, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.lenix.nix ./xsession.nix ];

  environment.systemPackages = (with pkgs; [
    bluez5
  ]);

  boot = {
    loader = {
      gummiboot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "resume=UUID=6567b6fd-c570-412e-8f53-b6ba1733640c" ];
  };

  networking = rec {
    hostName = "lenix";
    hostId = "f26c47cd";
    extraHosts = ''
      127.0.0.1 leihfix.local static.local jk.local hdnews.local hdirect.local
    '';
    firewall.enable = true;
    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "wlp3s0";
    };
  };

  services = {
    xserver = {
      videoDrivers = [ "intel" ];
      synaptics = {
          enable = true;
          twoFingerScroll = true;
      };
    };
    printing.enable = true;
  };

  hardware = {
    trackpoint.emulateWheel = true;
    bluetooth.enable = true;
  };

  #containers.lintox.path = "/nix/var/nix/profiles/lintox";

}
