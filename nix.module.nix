{ ... }:

let npc = import ./nixpkgs-config.nix; in
{
  
  ## Outsource nixpkgs.config to be shared with nix-env
  nixpkgs.config = npc;
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
