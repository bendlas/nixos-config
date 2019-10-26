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
    environment.etc."nixos".source = pkgs.runCommand "nixos-config" {
      inherit configs;
      sources = ./sources.json;
    } ''
      mkdir $out
      for n in $configs/*
      do if [ $(basename $n) == sources.json ]
         then ln -s $sources $out/sources.json
         else ln -s $n $out/
         fi
      done
    '';
    environment.etc."pkgs".source = nixpkgs;
    nix.nixPath = [
      "nixpkgs=/etc/pkgs"
      "nixos=/etc/pkgs/nixos"
      "nixos-config=/etc/nixos/${machine}.nix"
    ];
  };

}
