{ config, pkgs, lib, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./dev.nix ./power-savings.nix ./dev/hackrf.nix
              # ./dev/maple.nix ./dev/saleae.nix ## pulseview is broken
              ./dev/muart.nix ./dev/gd32.nix ./dev/stlink.nix
              ./dev/qemu.nix ./dev/forth.nix ./dev/skm.nix
              # ./dev/android.nix
              ./dev/container.nix ./dev/ft2232h.nix
              # ./ark.module.nix
              ./tmpfs.module.nix
              ./waydroid.module.nix ./docker.module.nix

              # { # Ethernet Server (for nitox)
              #   networking.nat.externalInterface = "wlan0";
              #   networking.nat.internalInterfaces = [ "enp0s31f6" ];
              #   systemd.network-wait-online.ignore = [ "enp0s31f6" ];

              #   systemd.network.networks."10-enp0s31f6" = {
              #     matchConfig.Name = "enp0s31f6";
              #     address = [ "10.0.0.1/24" ];
              #     networkConfig = {
              #       ## handled by firewall config
              #       # IPMasquerade = "yes";
              #       DHCPServer = "yes";
              #     };
              #     dhcpServerConfig = {
              #       PoolOffset= 32;
              #       PoolSize= 32;
              #     };
              #   };

              #   services.avahi.allowInterfaces = [ "enp0s31f6" ];
              #   # for dhcp
              #   networking.firewall.allowedUDPPorts = [ 67 ];
              # }

              # { ## USB Modem
              #   services.networkmanager = {
              #     enable = pkgs.lib.mkForce true;
              #     unmanaged = [ "lo" "wlan0" "enp0s31f6" "anbox0" ];
              #     packages = [ pkgs.networkmanager-openconnect pkgs.networkmanager-vpnc ];
              #   };
              # }

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
    "/boot" = {
      device = "/dev/disk/by-uuid/D45C-9B25";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/083e3aab-29cd-4d4c-a9b6-027c9b413af5"; }
  ];

  networking = rec {
    wireless = {
      iwd.enable = true;
      ## temp disable, as this interferes with /etc/wpa_supplicant.conf
      # userControlled.enable = true;
      # interfaces = [ "wlp3s0" ];
    };

    interfaces = {
      wlan0.useDHCP = true;
      enp0s31f6.useDHCP = true;
      enp0s20f0u6.useDHCP = true; ## USB Net from phone
      # ve-virtox.useDHCP = true;
    };
  };

  services = {
    avahi.allowInterfaces = [ "wlan0" "enp0s31f6" ];
    # teamspeak3 = {
    #   enable = true;
    #   openFirewall = true;
    # };
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
    borgbackup.jobs = {
      herwig_dropbox = {
        user = "herwig";
        paths = [
          "/home/herwig/Dropbox"
        ];
        repo = "borg@hetox.bendlas.net:Dropbox";
        encryption = {
          mode = "repokey-blake2";
          passCommand = "${pkgs.pass}/bin/pass borgbackup/herwig";
        };
        compression = "auto,zstd";
        startAt = "daily";
        environment.BORG_RSH = "ssh -i /home/herwig/.ssh/id_ed25519_borgbackup";
      };
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

  nix.settings.max-jobs = 2;
  # powerManagement.cpuFreqGovernor = "powersave";

}
