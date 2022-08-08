{ pkgs, config, ... }:
let
  pname = "epson-stylus-photo-r3000";
  version = "1.0.0-1lsb3.2_amd64";
  pkgFor = pkgs: pkgs.runCommand "dpkg-unpack" {
    inherit version pname;
    src = pkgs.fetchurl {
      url = "http://download.ebz.epson.net/dsc/op/stable/debian/dists/lsb3.2/main/binary-amd64/epson-inkjet-printer-stylus-photo-r3000_${version}.deb";
      sha256 = "sha256-p3PlBiBIXaSyvIyBuozGPXj7y7QnEsJbkusU/MNThfY=";
    };
    nativeBuildInputs = with pkgs; [ dpkg ];
  } ''
    dpkg -x $src $out
  '';
  trampoline = pkgs.writeScript "trampoline" ''
    #!/bin/sh
    exec "$@"
  '';
  filterProgram = pkgs.buildFHSUserEnvBubblewrap rec {
    name = "${pname}-${version}";
    runScript = "/opt/epson-inkjet-printer-stylus-photo-r3000/cups/lib/filter/${passthru.binName}";
    # runScript = trampoline;
    targetPkgs = pkgs: [
      (pkgFor pkgs)
      pkgs.libjpeg
      pkgs.cups
    ];
    extraOutputsToInstall = [ "opt" ];
    # FIXME: add /lib emulation to lsb-release, similar to https://github.com/archlinux/svntogit-community/blob/packages/ld-lsb/trunk/PKGBUILD
    extraBuildCommands = ''
      (cd lib; ln -s ./ld-linux-x86-64.so.2 ld-lsb-x86-64.so.3)
    '';
    passthru.ppdName = "Epson-Stylus_Photo_R3000-epson-driver.ppd";
    passthru.binName = "epson_inkjet_printer_filter";
    passthru.ppdz = "${pkgFor pkgs}/opt/epson-inkjet-printer-stylus-photo-r3000/ppds/Epson/${passthru.ppdName}.gz";
  };
in
with pkgs.lib;
with types;
{

  options.bendlas.pkgs."${pname}" = mkOption { type = package; };
  # the /etc/cups location will have a mutable reference to the latest version of the filter program
  config.bendlas.pkgs."${pname}" = pkgs.runCommand "epson-driver" {
    passthru = { inherit filterProgram; };
  } ''
    mkdir -p $out/lib/cups/filter $out/share/cups/model/Epson
    ln -s ${filterProgram} $out/lib/cups/filter/${filterProgram.binName}
    zcat ${filterProgram.ppdz} \
      | sed "s#/opt/epson-inkjet-printer-stylus-photo-r3000/cups/lib/filter/epson_inkjet_printer_filter#/etc/cups/path/lib/cups/filter/epson_inkjet_printer_filter/bin/${filterProgram.name}#" \
      > $out/share/cups/model/Epson/${filterProgram.ppdName}
  '';
  config.services.printing.logLevel = "debug";
  config.services.printing.drivers = [ config.bendlas.pkgs."${pname}" ];

}
