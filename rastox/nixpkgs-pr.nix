# From https://discourse.nixos.org/t/how-to-try-a-pr/15410/5
# Idea by Bas van Dijk (https://www.youtube.com/watch?v=J4DgATIjx9E)

# Use like
#     nixos-rebuild -I nixpkgs="$(nix-build nixpkgs-pr.nix --argstr pr 117102)" ...
# To restore
#     nixos-rebuild -I nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos ...

{ pr }:
let
  pkgs = import <nixpkgs> {};
  patches = [
    (builtins.fetchurl {
      url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/${pr}.patch";
    })
  ];
in pkgs.runCommand "nixpkgs-PR${pr}" { inherit patches; } ''
  cp -R ${pkgs.path} $out
  chmod -R +w $out
  for p in $patches; do
    echo "Applying patch $p"
    patch -d $out -p1 < "$p"
  done
''
