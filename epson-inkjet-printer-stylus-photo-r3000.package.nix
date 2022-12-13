{ stdenv, lib
, fetchurl, fetchpatch, rpm2targz, autoreconfHook
, cups, libjpeg
, enableDebug ? false
}:

stdenv.mkDerivation rec {
  pname = "epson-inkjet-printer-stylus-photo-r3000";
  version = "1.0.0";

  src = fetchurl {
    url = "http://download.ebz.epson.net/dsc/op/stable/SRPMS/${pname}-${version}-1lsb3.2.src.rpm";
    sha256 = "sha256-JVW+WvjH8xvWZrHGMuo2BLIhXXMucZ3qMzlhlVqjoFQ=";
  };

  nativeBuildInputs = [ rpm2targz autoreconfHook ];
  buildInputs = [ cups libjpeg ];

  unpackPhase = ''
    rpm2tar -O $src | tar -xO ./$pname-$version.tar.gz | tar -xz
    sourceDir=epson-inkjet-printer-filter-$version
    rpm2tar -O $src | tar -xO ./$sourceDir.tar.gz | tar -xz
    cd $sourceDir
  '';

  ## From arch build. Apparently not needed, but kept in case we need it at some point
  # patches = [(fetchpatch {
  #   url = "https://aur.archlinux.org/cgit/aur.git/plain/fixbuild.patch?h=epson-inkjet-printer-stylus-photo-r3000";
  #   sha256 = "sha256-Pk7hpscWPUivf5+jGInXDCv25h8IKDCCH3sgNPd4Csg=";
  # })];

  LDFLAGS = "-Wl,--no-as-needed";

  configureFlags = lib.optional (enableDebug) "--enable-debug";

  dontMoveLib64 = 1;
  postInstall = ''
    ppdName=Epson_Stylus_Photo_R3000.ppd
    mkdir -p $out/share/cups/model/$pname $out/resource/ $out/lib64 $out/lib
    cp -a ../$pname-$version/resource/* $out/resource/
    cp -a ../$pname-$version/lib64/* $out/lib64
    cp -a ../$pname-$version/lib/* $out/lib
    sed "s#/opt/epson-inkjet-printer-stylus-photo-r3000/cups/lib/filter/epson_inkjet_printer_filter#$out/lib/cups/filter/epson_inkjet_printer_filter#" \
      < ../$pname-$version/ppds/$ppdName \
      > $out/share/cups/model/$pname/$ppdName
  '';
  
}
