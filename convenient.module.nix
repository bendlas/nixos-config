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
  ];

}
