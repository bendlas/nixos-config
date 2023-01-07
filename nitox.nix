{ config, pkgs, lib, ... }:

{
  require = [ ./desktop.nix ./dev.nix # ./distributed-build.nix
              ./dev/forth.nix ./dev/qemu.nix # ./zfs.nix
              ./ark.module.nix ./tmpfs.module.nix
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
    initrd.availableKernelModules = [ "ehci_pci" "ahci" "nvme" "xhci_pci" "usbhid" "sd_mod" "sr_mod" "bcache" ];
    kernelModules = [ "kvm-intel" "nct6775" ];
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    kernelParams = [ "resume=UUID=a0056ae3-75e7-45aa-8b13-9cdeb395b96e" ];
    extraModprobeConfig = ''
      options libahci             skip_host_reset=1
    '';
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b3f6dbba-8c4c-422d-80e3-b396c92b9c2a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/bf4791ad-62c0-481d-bc8c-a800ad9cf8f8";
    fsType = "ext4";
  };

  fileSystems."/var/spinning-rust" = {
    device = "/dev/disk/by-uuid/3d369f1e-b1b5-4c36-90da-f34f2e0f6af0";
    fsType = "btrfs";
    options = [ "nossd" "discard" "compress=lzo" "noatime" "autodefrag" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/a0056ae3-75e7-45aa-8b13-9cdeb395b96e"; }
  ];

  hardware.cpu.intel.updateMicrocode = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      # vaapiVdpau
      ## amdgpu opencl
      rocm-opencl-icd
      rocm-opencl-runtime
      ## open source vulcan
      amdvlk
      ## video
      vaapiIntel
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
  hardware.bluetooth.enable = true;
  hardware.firmware = [ pkgs.firmwareLinuxNonfree ];

  networking = rec {
    ## for network forwarding
    # nat.externalInterface = "ww+";

    hostId = "f26c47cc";
    bridges.br0.interfaces = [ "enp6s0" ];
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

  # systemd.network.networks."10-enp6s0" = {
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
  #   unmanaged = [ "lo" "br0" "enp6s0" "anbox0" ];
  # };

  services.xserver = {
    videoDrivers = [ "amdgpu" "intel" "vesa" ]; # "amdgpu-pro" "nvidia" "nouveau" "nv" "vesa" ];
    # deviceSection = ''
    #   Option "Coolbits" "12"
    # '';
  };

  # ## AMD ROCM / HIP support

  # systemd.tmpfiles.rules = [
  #   "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
  # ];

  # nixpkgs.overlays = [
  #   (import ((import <nixpkgs> {}).fetchFromGitHub {
  #     owner = "nixos-rocm";
  #     repo = "nixos-rocm";
  #     rev = "baa7e3b14f10dc4fc057cb83847e1a727f080b2d";
  #     sha256 = "sha256-0hEQPooixFP4nqtsAdN2RYcyatNgO0w5xE7SfhS0+SE=";
  #   }))
  # ];
  # nixpkgs.config.rocmTargets = [ "gfx803" ];

  services.avahi.interfaces = [ "br0" ];

  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
  # hardware.nvidia.modesetting.enable = true;
  # services.xserver.displayManager.gdm.wayland = true;

  nix.settings.max-jobs = 2;
}
