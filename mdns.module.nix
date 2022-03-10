{ lib, config, ... }:
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

  ## avoid clashing with resolved
  ## https://www.reddit.com/r/archlinux/comments/djg602/are_avahi_and_systemdresolved_really_incompatible/f47jhs6/
  services.resolved.extraConfig = ''
    MulticastDNS=resolve
  '';

}
