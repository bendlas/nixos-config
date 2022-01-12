{ config, pkgs, lib, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./dev.nix ./power-savings.nix ./dev/hackrf.nix ./dev/maple.nix
              ./dev/muart.nix ./dev/gd32.nix ./dev/saleae.nix ./dev/stlink.nix
              ./dev/qemu.nix ./dev/forth.nix ./dev/skm.nix ./dev/android.nix
            ];

  bendlas.machine = "lenix";
  environment.systemPackages = (with pkgs; [
    bluez5 crda wireless-regdb intel-gpu-tools
  ]);

  environment.variables = {
    VAAPI_MPEG4_ENABLED = "true";
  };

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    kernelModules = [ "kvm-intel" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "resume=UUID=6567b6fd-c570-412e-8f53-b6ba1733640c" ];
  };

  fileSystems = {
    "/" ={
      device = "/dev/disk/by-uuid/cf7a2c05-5a08-4716-aa30-2c3556f5033c";
      fsType = "btrfs";
    };
    "/tmp" = {
      device = "TMP";
      fsType = "tmpfs";
      options = [ "size=16G" "mode=1777" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/D45C-9B25";
      fsType = "vfat";
    };
    "/var/tmp" = {
      device = "VARTMP";
      fsType = "tmpfs";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/083e3aab-29cd-4d4c-a9b6-027c9b413af5"; }
  ];

  networking = rec {
    hostName = "lenix";
    hostId = "f26c47cd";

    wireless = {
      iwd.enable = true;
      ## temp disable, as this interferes with /etc/wpa_supplicant.conf
      # userControlled.enable = true;
      # interfaces = [ "wlp3s0" ];
    };

    interfaces = {
      enp0s31f6.useDHCP = true;
      wlan0.useDHCP = true;
    };

    nat.externalInterface = "wlan0";
    nat.internalInterfaces = [ "enp0s31f6" ];

    # for dhcp
    firewall.allowedUDPPorts = [ 67 ];

    # ## for usb modem
    # networkmanager = {
    #   enable = pkgs.lib.mkForce true;
    #   unmanaged = [ "lo" "wlan0" "enp0s31f6" "anbox0" ];
    #   packages = [ pkgs.networkmanager-openconnect pkgs.networkmanager-vpnc ];
    # };
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
        # intel-media-driver
        vaapiIntel
      ];
      # extraPackages32 = with pkgs.pkgsi686Linux; [
      #   intel-media-driver
      #   # vaapiIntel
      # ];
    };
  };

  #  boot.extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];

  services.pcscd.enable = true;

  nix.maxJobs = lib.mkDefault 2;
  # powerManagement.cpuFreqGovernor = "powersave";

}
