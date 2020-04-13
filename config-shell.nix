{ pkgs ? import <nixpkgs> { }
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
  newPkgs = import nixpkgs { config = import ./nixpkgs-config.nix; };
  localPackages = pkgFile: newPkgs.callPackage ./local-packages.nix {
    inherit pkgFile;
    source = nixpkgs;
  };
in
mkShell {
  shellHook = ''
    export NIX_PATH=nixpkgs=${nixpkgs}:nixos=${nixpkgs}/nixos:nixos-config=${configs}/${machine}.nix
  '';
  buildInputs = [ (localPackages ./desktop.packages) newPkgs.taalo-build ];
  passthru = {
    inherit nixpkgs configs machine;
    nixos-config = "${configs}/${machine}.nix";
    pkgs = newPkgs;
  };
}
