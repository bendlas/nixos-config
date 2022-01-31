{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, mkShell ? pkgs.mkShell
, fetchgit ? pkgs.fetchgit
, runCommand ? pkgs.runCommand
, machine ? "test-config"
, configs ? pkgs.nix-gitignore.gitignoreSource [ ".git" ] ./.
, pkgs-path ? null
, pkgs-stable-path ? null
, mnos-path ? null
, nohw-path ? null
}:
let
  pathOrJson = path: json:
    if isNull path
    then
      fetchgit {
        inherit (lib.importJSON json) url rev sha256 fetchSubmodules;
      }
    else path;
  stability = import ./Prop.nix "machine" machine "stability" "unstable";
  nixpkgs-stable = pathOrJson pkgs-stable-path ./nixpkgs-stable.json;
  nixpkgs-unstable = pathOrJson pkgs-path ./nixpkgs.json;
  nixpkgs = if "stable" == stability
            then nixpkgs-stable
            else nixpkgs-unstable;
  mobile-nixos = pathOrJson mnos-path ./mobile-nixos.json;
  nixos-hardware = pathOrJson nohw-path ./nixos-hardware.json;
  newPkgs = import nixpkgs {
    config = import ./nixpkgs-config.nix;
    overlays = import ./nixpkgs-overlays.nix;
  };
in
mkShell {
  # keep synchronized with ./sources.nix
  shellHook = ''
    export NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-unstable=${nixpkgs-unstable}:nixpkgs-stable=${nixpkgs-stable}:nixos=${nixpkgs}/nixos:mobile-nixos=${mobile-nixos}:nixos-hardware=${nixos-hardware}:nixos-config=${configs}/${machine}.nix
    export NIXPKGS_CONFIG=${configs}/nixpkgs-config.nix
  '';
  buildInputs = [
    newPkgs.taalo-build
  ];
  passthru = {
    inherit nixpkgs configs mobile-nixos nixos-hardware machine stability
      nixpkgs-stable nixpkgs-unstable;
    nixos-config = "${configs}/${machine}.nix";
    pkgs = newPkgs;
  };
}
