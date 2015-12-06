{ writeScriptBin, nix }:

writeScriptBin "update-git-channel" ''
  REV=$1
  TARGET=/etc/nixos/pkgs

  if [ -z "$REV" ]; then
   echo "$0 <revision>"
   exit 1
  else
    echo "Updating '$TARGET' to '$REV'"
  fi

  ${nix}/bin/nix-build \
    -E "with import <nixpkgs> {}; callPackage ${./git-channel.nix} { url = \"https://github.com/bendlas/nixpkgs.git\"; rev = \"$REV\"; }" \
    --out-link "$TARGET"
''
