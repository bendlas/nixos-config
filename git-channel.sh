#!/bin/sh -e

writeDescriptor () {
    cat <<EOF
{ fetchFromGitHub }:
fetchFromGitHub {
  owner = "bendlas";
  repo = "nixpkgs";
  rev = "$1";
  sha256 = "$2";
}
EOF
}

DUMMY=`mktemp -d`

cat > $DUMMY/default.nix <<EOF
{ channel = (import <nixpkgs> {}).callPackage ./channel.nix {}; }
EOF

rev=`git ls-remote https://github.com/bendlas/nixpkgs.git refs/heads/$2 | cut -f1`

writeDescriptor $rev 0000000000000000000000000000000000000000000000000000000000000000 > $DUMMY/channel.nix

sha256=$(nix-prefetch-url $DUMMY -A channel)
rm -r $DUMMY

writeDescriptor $rev $sha256 > $1

