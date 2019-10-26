let filterGit = builtins.filterSource (p: t: t != "directory" || baseNameOf p != ".git"); in
{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, mkShell ? pkgs.mkShell
, fetchgit ? pkgs.fetchgit
, runCommand ? pkgs.runCommand
, machine ? "test-config"
, configs ? filterGit ./.
, pkgs-path ? null
}:
let
  sources = lib.importJSON ./sources.json;
  fetch = src: fetchgit {
    inherit (sources.${src}) url rev sha256 fetchSubmodules;
  };
  nixpkgs = if isNull pkgs-path then fetch "nixpkgs" else filterGit pkgs-path;
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
