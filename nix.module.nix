{ ... }:

{
  
  ## Outsource nixpkgs.config to be shared with nix-env
  # keep synchronized with ./config-shell.nix
  nixpkgs.config = import ./nixpkgs-config.nix;
  nixpkgs.overlays = import ./nixpkgs-overlays.nix;
  ## TODO replace with full config include
  system.copySystemConfiguration = true;
  nix.extraOptions = ''
    binary-caches-parallel-connections = 24
    gc-keep-outputs = true
    gc-keep-derivations = true
    experimental-features = nix-command flakes
  '';

}
