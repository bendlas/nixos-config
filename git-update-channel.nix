{ writeScriptBin, nix }:

writeScriptBin "update-git-channel" ''
  REV=$1
  CHAN=$2
  
  if [ -z "$CHAN" ]; then
    CHAN="pkgs"
  fi

  TARGET="/etc/nixos/$CHAN"

  if [ -z "$REV" ]; then
   echo "$0 <revision> [<channel-name>]"
   exit 1
  else
    echo "Updating '$TARGET' to '$REV'"
  fi

  ${nix}/bin/nix-build \
    -E "with import <nixpkgs> {}; callPackage ${./git-channel.nix} { url = \"https://github.com/bendlas/nixpkgs.git\"; rev = \"$REV\"; name = \"$REV-$CHAN-channel\"; }" \
    --out-link "$TARGET"
''
