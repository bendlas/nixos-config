{ config, pkgs, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.lenix-270.nix ./dev.nix ./power-savings.nix ];

  environment.systemPackages = (with pkgs; [
    bluez5 crda wireless-regdb
  ]);

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "resume=UUID=6567b6fd-c570-412e-8f53-b6ba1733640c" ];
  };

  networking = rec {
    hostName = "lenix.bendlas.net";
    hostId = "f26c47cd";
    nat.externalInterface = "wlp3s0";
    interfaces.wlp3s0.useDHCP = true;
    interfaces.enp0s31f6.useDHCP = true;
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
      drivers = [ pkgs.splix pkgs.brgenml1cupswrapper ];
    };
  };

  hardware = {
    sane.enable = true;
    cpu.intel.updateMicrocode = true;
    trackpoint.emulateWheel = true;
    bluetooth.enable = true;
    # enableRedistributableFirmware = true;
    firmware = [ pkgs.firmwareLinuxNonfree ];
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiIntel
      ];
    };
  };

  #  boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];

  users.extraUsers = {
    "adele" = {
      isNormalUser = true;
    };
  };

}
