# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{ ## Outsource nixpkgs.config to be shared with nix-env
  require = [ ./desktop.nix ./hardware-configuration.nitox.nix ./dev.nix ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sdb";
    };
    kernelParams = [ "nomodeset" "resume=UUID=58a029ec-27e3-49cd-9ec1-2452ede1cec5" "resume=UUID=c4bd389b-dd2d-4777-a2f3-d55bbe000566" ];
    initrd.availableKernelModules = [ "bcache" ];
  };

  networking = rec {
    hostName = "nitox";
    hostId = "f26c47cc";
    nat.externalInterface = "enp5s0";
    firewall.allowedTCPPorts = [ 80 443 ];
    nat.forwardPorts = [
      { destination = ":80";  sourcePort = 8080; }
      { destination = ":443"; sourcePort = 8443; }
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
