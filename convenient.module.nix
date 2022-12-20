{ pkgs, config, ... }:

{

  ## almost essential, but blowing up closure size
  environment.systemPackages = with pkgs; [
    ## graal
    jet
    ## rust
    nix-du
  ];

}
