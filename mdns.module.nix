{ lib, ... }:
{

  require = [ ./name.module.nix ];

  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.addresses = true;
    nssmdns = true;
    wideArea = false;
    # extraServiceFiles.ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
    interfaces = lib.mkDefault (throw "Please set `services.avahi.interfaces` explicitly, in order to avoid configuring ve-* interfaces");
  };

}
