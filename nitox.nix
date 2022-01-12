# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./dev.nix # ./distributed-build.nix
              ./dev/forth.nix ./zfs.nix
    # {
    #   networking.firewall.allowedTCPPorts = [ 2049 111 4000 4001 ];
    #   networking.firewall.allowedUDPPorts = [ 2049 111 4000 4001 ];
    #   services.nfs.server = {
    #     enable = false;
    #     statdPort = 4000;
    #     lockdPort = 4001;
    #     exports = ''
    #       /var/public    10.0.2.0/24(rw,nohide,insecure,no_subtree_check,fsid=0) 192.168.0.0/24(rw,nohide,insecure,no_subtree_check,fsid=0)
    #     '';
    #   };
    # }
  ];

  bendlas.machine = "nitox";
  boot = {
    initrd.availableKernelModules = [ "bcache" "ehci_pci" "ata_piix" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
    kernelModules = [ "kvm-intel" ];
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sdb";
    };
    kernelParams = [ "nomodeset" "resume=UUID=58a029ec-27e3-49cd-9ec1-2452ede1cec5" "resume=UUID=c4bd389b-dd2d-4777-a2f3-d55bbe000566" ];
    extraModprobeConfig = ''
      options libahci             skip_host_reset=1
    '';
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3d369f1e-b1b5-4c36-90da-f34f2e0f6af0";
      fsType = "btrfs";
      options = [ "nossd" "discard" "compress=lzo" "noatime" "autodefrag" ];
    };

  fileSystems."/var/tmp" =
    { device = "vartmp";
      fsType = "tmpfs";
      options = [ "size=1G" "mode=1777" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/bf4791ad-62c0-481d-bc8c-a800ad9cf8f8";
      fsType = "ext4";
    };

  #fileSystems."/tmp" =
  #  { device = "tmp";
  #    fsType = "tmpfs";
  #    options = [ "size=48G" "mode=1777" ];
  #  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/58a029ec-27e3-49cd-9ec1-2452ede1cec5"; }
      { device = "/dev/disk/by-uuid/c4bd389b-dd2d-4777-a2f3-d55bbe000566"; }
    ];

  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };
  hardware.bluetooth.enable = true;
  hardware.firmware = [ pkgs.firmwareLinuxNonfree ];

  services.avahi.hostName = "nitox";

  networking = rec {
    hostName = "nitox";
    hostId = "f26c47cc";

    ## for network forwarding
    # nat.externalInterface = "ww+";

    bridges.br0.interfaces = [ "enp5s0" ];
    interfaces.br0.macAddress = "52:CB:A3:76:0F:0E";

    interfaces.br0.useDHCP = true;
    # nat.internalInterfaces = [ "br0" ];

    # for dhcp
    firewall.allowedUDPPorts = [ 67 ];

  };

  environment.etc."qemu/bridge.conf".text = ''
    allow br0
  '';

  systemd.network-wait-online.ignore = [ "br0" ];

  # systemd.network.networks."10-enp5s0" = {
  #   matchConfig.Name = "br0";
  #   address = [ "10.0.0.1/24" ];
  #   networkConfig = {
  #     ## handled by firewall config
  #     # IPMasquerade = "yes";
  #     DHCPServer = "yes";
  #   };
  #   dhcpServerConfig = {
  #     PoolOffset= 32;
  #     PoolSize= 32;
  #   };
  # };

  users.extraUsers = {
    "nara" = {
      description = "Nara Richter";
      isNormalUser = true;
    };
  };

  ## we don't need modemmanager any more
  # networking.networkmanager = {
  #   enable = lib.mkForce true;
  #   unmanaged = [ "lo" "br0" "enp5s0" "anbox0" ];
  # };

  services.xserver = {
    videoDrivers = [ "nvidia" "nouveau" "nv" "vesa" ];
    deviceSection = ''
      Option "Coolbits" "12"
    '';
  };

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  hardware.nvidia.modesetting.enable = true;
  services.xserver.displayManager.gdm.nvidiaWayland = true;

  nix.maxJobs = 2;
}
