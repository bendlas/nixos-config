# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.nitox.nix ./dev.nix # ./distributed-build.nix
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
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sdb";
    };
    kernelParams = [ "nomodeset" "resume=UUID=58a029ec-27e3-49cd-9ec1-2452ede1cec5" "resume=UUID=c4bd389b-dd2d-4777-a2f3-d55bbe000566" ];
    initrd.availableKernelModules = [ "bcache" ];
    supportedFilesystems = [ "zfs" ];
    extraModprobeConfig = ''
      options libahci             skip_host_reset=1
    '';
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiVdpau
    ];
  };

  services.avahi.hostName = "nitox";

  networking = rec {
    hostName = "nitox.bendlas.net";
    hostId = "f26c47cc";

    ## for network forwarding
    nat.externalInterface = "ww+";

    bridges.br0.interfaces = [ "enp5s0" ];
    interfaces.br0.macAddress = "52:CB:A3:76:0F:0E";

    interfaces.br0.useDHCP = true;
    nat.internalInterfaces = [ "br0" ];

    ## for dhcp
    # firewall.allowedUDPPorts = [ 67 ];

  };

  environment.etc."qemu/bridge.conf".text = ''
    allow br0
  '';

  systemd.network-wait-online.ignore = [ "br0" ];

  # systemd.network.networks."10-enp5s0" = {
  #   matchConfig.Name = "enp5s0";
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

  networking.networkmanager = {
    enable = pkgs.lib.mkForce true;
    unmanaged = [ "lo" "br0" "enp5s0" "anbox0" ];
  };

  services.xserver = {
    videoDrivers = [ "nvidia" "nouveau" "nv" "vesa" ];
    deviceSection = ''
      Option "Coolbits" "12"
    '';
  };

}
