{ writeScriptBin, nix }:

writeScriptBin "update-git-channel" ''
  REV=$1
  TARGET="/etc/nixos/pkgs"

  if [ -z "$REV" ]; then
   echo "$0 <revision>"
   exit 1
  else
    echo "Updating '$TARGET' to '$REV'"
  fi

  exec ${./git-channel.sh} $TARGET $REV
''
