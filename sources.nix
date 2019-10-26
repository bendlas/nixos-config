{ lib, config, pkgs, ... }:

with lib;
with types;
let
  inherit (pkgs.callPackage ./config-shell.nix {
    inherit (config.bendlas) machine;
  }) nixpkgs configs machine;
in {

  options.bendlas.machine = mkOption {
    type = str;
  };

  config = {
    environment.etc."nixos".source = configs;
    environment.etc."pkgs".source = nixpkgs;
    nix.nixPath = [
      "nixpkgs=/etc/pkgs"
      "nixos=/etc/pkgs/nixos"
      "nixos-config=/etc/nixos/${machine}.nix"
    ];
  };

}
