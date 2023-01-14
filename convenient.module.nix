{ pkgs, config, ... }:

{

  ## almost essential, but blowing up closure size or build resources (due to non-cache)
  environment.systemPackages = with pkgs; [

    ## graal

    jet

    ## rust

    nix-du

    ## build time / tmp space
    ## these may be added to hydra

    config.boot.kernelPackages.perf

    yq

    ### Pure nice to have

    ## Admin

    ntfs3g btrfs-progs

    ## Dev

    gitAndTools.hub

    ## Video

    ffmpeg imagemagick

    ## Misc tools

    geoip links2 cowsay

  ];

}
