{ config, pkgs, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.lenix-270.nix
              ./dev.nix ./power-savings.nix ./dev/hackrf.nix ./dev/maple.nix ./dev/muart.nix ./dev/gd32.nix ./dev/saleae.nix ./dev/stlink.nix ];

  bendlas.machine = "lenix";
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
    hostName = "lenix";
    hostId = "f26c47cd";
    
    wireless = {
      enable = true;
      ## temp disable, as this interferes with /etc/wpa_supplicant.conf
      # userControlled.enable = true;
      interfaces = [ "wlp3s0" ];
    };

    interfaces = {
      enp0s31f6.useDHCP = true;
      wlp3s0.useDHCP = true;
    };

    nat.externalInterface = "wlp3s0";
    nat.internalInterfaces = [ "enp0s31f6" ];

    # for dhcp
    firewall.allowedUDPPorts = [ 67 ];

    networkmanager = {
      enable = pkgs.lib.mkForce true;
      unmanaged = [ "lo" "wlp3s0" "enp0s31f6" "anbox0" ];
    };
  };

  systemd.network-wait-online.ignore = [ "enp0s31f6" ];

  systemd.network.networks."10-enp0s31f6" = {
    matchConfig.Name = "enp0s31f6";
    address = [ "10.0.0.1/24" ];
    networkConfig = {
      ## handled by firewall config
      # IPMasquerade = "yes";
      DHCPServer = "yes";
    };
    dhcpServerConfig = {
      PoolOffset= 32;
      PoolSize= 32;
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
    avahi.hostName = "lenix";
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

  services.pcscd.enable = true;

}
