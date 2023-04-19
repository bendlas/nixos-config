{ lib, config, pkgs, ... }:
{
  require = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./essential.module.nix ./convenient.module.nix
    # ./mdns.module.nix ./ssh.module.nix
    # ./networkd.module.nix
    ./nginx.module.nix
    # ./keycloak.module.nix
    ./gitea.module.nix

    # { require = [ ./code-server.module.nix ];
    #   bendlas.enableSSL = false; }
    # ./factorio-server.module.nix
    # { require = [ ./valheim-server.module.nix ];
    #   services.valheim-server.password = "nope"; }
  ];
  bendlas.machine = "virtox";
  boot.isContainer = true;
  # networking.interfaces.eth0.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  # networking.firewall.enable = false;

  services.oauth2_proxy = {
    cookie.secure = lib.mkForce false;
    extraConfig.ssl-insecure-skip-verify = true;

    keyFile = null;
    cookie.secret = "&NO,*kkvGJRIlVNt";
    clientID = "news";
    clientSecret = "jZtdyObdVpNdHwoB38zjG9h6iLuD95Qe";

  };

}
