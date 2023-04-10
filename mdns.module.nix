{ pkgs, lib, config, ... }:
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

  ## This causes too many rebuilds
  # nixpkgs.config.packageOverrides = super: {
  #   avahi = super.avahi.overrideDerivation ({ patches ? [], ... }: {
  #     ## Prevent avahi from ever detecting mDNS conflicts. This works around
  #     ## https://github.com/lathiat/avahi/issues/117
  #     ## https://github.com/lopsided98/nixos-config/commit/f4c53bf60a7b016ef07f4c2ef72292922ef81784
  #     patches = patches ++ [ ./avahi-disable-conflicts.patch ];
  #   });
  # };

  services.avahi = {
    enable = true;
    openFirewall = true;
    publish.enable = true;
    publish.addresses = true;
    nssmdns = true;
    wideArea = false;
    # extraServiceFiles.ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
    allowInterfaces = lib.mkDefault (throw "Please set `services.avahi.allowInterfaces` explicitly, in order to avoid configuring ve-* interfaces");
    ## reflect incoming queries to all interfaces
    ## attempted to disable this for phony conflicts
    # reflector = true;
    ## this may help with phony naming conflicts
    ## enable if disabling reflector didn't help
    # cacheEntriesMax = 0;
    ## disallow-other-stacks: disallow interference from resolved and others
    extraConfig = ''

      [server]
      disallow-other-stacks=yes
    '';
  };

  ## avoid clashing with resolved
  ## https://www.reddit.com/r/archlinux/comments/djg602/are_avahi_and_systemdresolved_really_incompatible/f47jhs6/
  # services.resolved.extraConfig = ''
  #   MulticastDNS=resolve
  # '';
  ## revised: resolved started binding 5353, even just for `MulticastDNS=resolve`. So disable it completely.
  ## mDNS will be serviced at NSS level
  services.resolved.extraConfig = ''
    MulticastDNS=no
  '';

  # disable chromium-builtin mdns stack
  environment.etc."chromium/policies/managed/disable_mediarouter.json".text = ''
    { "EnableMediaRouter": false }
  '';

}
