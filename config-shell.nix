{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, mkShell ? pkgs.mkShell
, fetchgit ? pkgs.fetchgit
, runCommand ? pkgs.runCommand
, machine ? "test-config"
, configs ? pkgs.nix-gitignore.gitignoreSource [ ".git" ] ./.
, pkgs-path ? null
, mnos-path ? null
}:
let
  nixpkgs = if isNull pkgs-path
            then
              fetchgit {
                inherit (lib.importJSON ./nixpkgs.json) url rev sha256 fetchSubmodules;
              }
            else pkgs-path;
  mobile-nixos = if isNull mnos-path
                 then
                   fetchgit {
                     inherit (lib.importJSON ./mobile-nixos.json) url rev sha256 fetchSubmodules;
                   }
                 else mnos-path;
  newPkgs = import nixpkgs {
    config = import ./nixpkgs-config.nix;
    overlays = import ./nixpkgs-overlays.nix;
  };
in
mkShell {
  shellHook = ''
    export NIX_PATH=nixpkgs=${nixpkgs}:nixos=${nixpkgs}/nixos:mobile-nixos=${mobile-nixos}:nixos-config=${configs}/${machine}.nix
    export NIXPKGS_CONFIG=${configs}/nixpkgs-config.nix
  '';
  buildInputs = [
    newPkgs.taalo-build
  ];
  passthru = {
    inherit nixpkgs configs machine;
    nixos-config = "${configs}/${machine}.nix";
    pkgs = newPkgs;
  };
}
