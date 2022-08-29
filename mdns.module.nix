{ lib, config, ... }:
{

  require = [
    ./name.module.nix
    ## did not work, have to find another solution for cups
    # ({ pkgs, config, ... }: {
    #   ## fix CUPS issues
    #   ## see https://github.com/NixOS/nixpkgs/issues/118628
    #   services.avahi.nssmdns = pkgs.lib.mkForce false; # Use my settings from below
    #   # settings from avahi-daemon.nix where mdns is replaced with mdns4
    #   system.nssModules = with pkgs.lib; optional (!config.services.avahi.nssmdns) pkgs.nssmdns;
    #   system.nssDatabases.hosts = with pkgs.lib; optionals (!config.services.avahi.nssmdns) (mkMerge [
    #     (mkOrder 900 [ "mdns4_minimal [NOTFOUND=return]" ]) # must be before resolve
    #     (mkOrder 1501 [ "mdns4" ]) # 1501 to ensure it's after dns
    #   ]);
    # })
  ];

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
