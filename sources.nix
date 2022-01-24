{ lib, config, pkgs, ... }:

with lib;
with types;
let
  inherit (pkgs.callPackage ./config-shell.nix {
    inherit (config.bendlas) machine;
  }) nixpkgs configs mobile-nixos nixos-hardware machine;
in {

  options.bendlas.machine = mkOption {
    type = str;
  };

  # keep synchronized with ./config-shell.nix
  config = {
    environment.etc."nixos".source = configs;
    environment.etc."nixpkgs".source = nixpkgs;
    environment.etc."mobile-nixos".source = mobile-nixos;
    environment.etc."nixos-hardware".source = nixos-hardware;
    ## this is set non-configurable in <nixos/modules/programs/environment.nix>
    ## to /etc/nix/nixpkgs-config.nix
    # environment.variables.NIXPKGS_CONFIG = "/etc/nixos/nixpkgs-config.nix";
    environment.etc."nix/nixpkgs-config.nix".source = "${configs}/nixpkgs-config.nix";
    nix.nixPath = [
      "nixpkgs=/etc/nixpkgs"
      "nixos=/etc/pkgs/nixos"
      "mobile-nixos=/etc/mobile-nixos"
      "nixos-hardware=/etc/nixos-hardware"
      "nixos-config=/etc/nixos/${machine}.nix"
    ];
  };

}
