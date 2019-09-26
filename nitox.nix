# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.nitox.nix ./dev.nix # ./distributed-build.nix
    {
      networking.firewall.allowedTCPPorts = [ 2049 111 4000 4001 ];
      networking.firewall.allowedUDPPorts = [ 2049 111 4000 4001 ];
      services.nfs.server = {
        enable = true;
        statdPort = 4000;
        lockdPort = 4001;
        exports = ''
          /var/public    10.0.2.0/24(rw,nohide,insecure,no_subtree_check,fsid=0) 192.168.0.0/24(rw,nohide,insecure,no_subtree_check,fsid=0)
        '';
      };
    }
  ];

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

  networking = rec {
    hostName = "nitox.bendlas.net";
    hostId = "f26c47cc";
    nat.externalInterface = "enp6s0+";
    nat.internalInterfaces = [ "enp5s0" ];
    firewall.allowedTCPPorts = [ 80 443 ];
    nat.forwardPorts = [
      { destination = ":8080";  sourcePort = 80; }
      { destination = ":8443"; sourcePort = 443; }
    ];
  };

  services.xserver = {
    videoDrivers = [ "nvidia" "nouveau" "nv" "vesa" ];
    deviceSection = ''
      Option "Coolbits" "12"
    '';
  };

  security.acme = {
    certs = {
      "nitox.bendlas.net" = {
        email = "herwig@bendlas.net";
        webroot = "/var/lib/letsencrypt-nitox/webroot";
        extraDomains = {
          "rastox.bendlas.net" = null;
          "testextra.bendlas.net" = null;
        };
        postRun = ''
          ROOT=/etc/letsencrypt/live/nitox.bendlas.net
          OUT=/var/lib/letsencrypt-nitox
          mkdir -p $OUT
          ${pkgs.openssl}/bin/openssl pkcs12 -export \
            -in fullchain.pem -inkey $ROOT/privkey.pem \
            -out $OUT/keystore.p12 \
            -name nitox -CAfile $ROOT/chain.pem -caname root \
            -password file:$OUT/keystore.pw
          chmod a+r $OUT/keystore.p12
        '';
      };
    };
  };
}
