{ pkgs, config, ... }:
let
  pname = "epson-stylus-photo-r3000";
  version = "1.0.0-1lsb3.2_amd64";
  pkg = pkgs.runCommand "dpkg-unpack" {
    inherit version pname;
    src = pkgs.fetchurl {
      url = "http://download.ebz.epson.net/dsc/op/stable/debian/dists/lsb3.2/main/binary-amd64/epson-inkjet-printer-stylus-photo-r3000_${version}.deb";
      sha256 = "sha256-p3PlBiBIXaSyvIyBuozGPXj7y7QnEsJbkusU/MNThfY=";
    };
    nativeBuildInputs = with pkgs; [ dpkg ];
  } ''
    dpkg -x $src $out
  '';
in
with pkgs.lib;
with types;
{

  options.bendlas.pkgs."${pname}" = mkOption { type = package; };
  config.bendlas.pkgs."${pname}" = pkg;

}
