{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, mkShell ? pkgs.mkShell
, fetchgit ? pkgs.fetchgit
, runCommand ? pkgs.runCommand
, machine ? "test-config"
, configs ? pkgs.nix-gitignore.gitignoreSource [ ".git" ] ./.
, pkgs-path ? null
}:
let
  nixpkgs = if isNull pkgs-path
            then
              fetchgit {
                inherit (lib.importJSON ./nixpkgs.json) url rev sha256 fetchSubmodules;
              }
            else pkgs.nix-gitignore.gitignoreSource [ ".git" ] pkgs-path;
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
