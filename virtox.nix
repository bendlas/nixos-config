{ lib, config, pkgs, ... }:
{
  require = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./essential.module.nix # ./mdns.module.nix ./ssh.module.nix
    ./networkd.module.nix ./nginx.module.nix

    ./code-server.module.nix ./factorio-server.module.nix
  ];
  bendlas.machine = "virtox";
  bendlas.enableSSL = false;
  boot.isContainer = true;
  # networking.interfaces.eth0.useDHCP = true;
  # networking.firewall.allowedTCPPorts = [ 80 ];
  # networking.firewall.enable = false;

  services.oauth2_proxy = lib.mkForce {
    cookie.secure = false;

    keyFile = null;
    cookie.secret = "&NO,*kkvGJRIlVNt";
    clientID = "bccba414c3706b9950ea04da435916bb0b397d0006ccb3ad58b1395b576d9ca8";
    clientSecret = "1919f7137df6cf915d9ffe5cc68b108396e79d19be1bffe865f9f53469151172";
  };

}
