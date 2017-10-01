{ writeScriptBin, nix }:

writeScriptBin "update-git-channel" ''
  set -e
  REV=$1
  TARGET="/etc/nixos/pkgs.git"

  if [ -z "$REV" ]; then
   echo "$0 <revision>"
   exit 1
  else
    echo "Updating '$TARGET' to '$REV'"
  fi

  ${./git-channel.sh} $TARGET $REV
''
