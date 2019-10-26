{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, mkShell ? pkgs.mkShell
, fetchgit ? pkgs.fetchgit
, machine ? "test-config"
, pkgs-path ? null
, config-path ? null
}:
let
  sources = lib.importJSON ./sources.json;
  fetch = src: fetchgit { inherit (sources.${src}) url rev sha256 fetchSubmodules; };
  nixpkgs = if isNull pkgs-path then fetch "nixpkgs" else pkgs-path;
  configs = if isNull config-path then fetch "nixos-config" else config-path;
in
mkShell {
  shellHook = ''
    export NIX_PATH=nixpkgs=${nixpkgs}:nixos=${nixpkgs}/nixos:nixos-config=${configs}/${machine}.nix
  '';
  passthru = {
    inherit nixpkgs configs machine;
    nixos-config = "${configs}/${machine}.nix";
  };
}
