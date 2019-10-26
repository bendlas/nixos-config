{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, mkShell ? pkgs.mkShell
, fetchgit ? pkgs.fetchgit
, runCommand ? pkgs.runCommand
, machine ? "test-config"
, pkgs-path ? null
, config-path ? null
}:
let
  sources = lib.importJSON ./sources.json;
  fetch = src: fetchgit {
    inherit (sources.${src}) url rev sha256 fetchSubmodules;
  };
  nixpkgs = if isNull pkgs-path then fetch "nixpkgs" else pkgs-path;
  configs = runCommand "nixos-config" {
    configs = if isNull config-path then fetch "nixos-config" else config-path;
    sources = ./sources.json;
  } ''
    mkdir $out
    for n in $configs/*
    do if [ $(basename $n) == sources.json ]
       then ln -s $sources $out/sources.json
       else cp $n $out/
       fi
    done
  '';
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
