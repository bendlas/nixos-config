{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, mkShell ? pkgs.mkShell
, fetchgit ? pkgs.fetchgit
, runCommand ? pkgs.runCommand
, machine ? "test-config"
, configs ? (
  import (pkgs.fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore.nix";
    # put the latest commit sha of gitignore Nix library here:
    rev = "f2ea0f8ff1bce948ccb6b893d15d5ea3efaf1364";
    # use what nix suggests in the mismatch message here:
    sha256 = "sha256-wk38v/mbLsOo6+IDmmH1H0ADR87iq9QTTD1BP9X2Ags=";
  }) { inherit (pkgs) lib; }
).gitignoreSource ./.
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
    # keep synchronized with ./nix.module.nix
    config = import ./nixpkgs-config.nix;
    overlays = import ./nixpkgs-overlays.nix;
  };
in
mkShell {
  # keep synchronized with ./sources.module.nix
  shellHook = ''
    export NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-unstable=${nixpkgs-unstable}:nixpkgs-stable=${nixpkgs-stable}:nixos=${nixpkgs}/nixos:mobile-nixos=${mobile-nixos}:nixos-hardware=${nixos-hardware}:nixos-config=${configs}/${machine}.nix:nixpkgs-overlays=${configs}/nixpkgs-overlays.nix
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
