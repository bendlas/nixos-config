let enableDebugInfo_ = lib: pkg:
  lib.overrideDerivation pkg (attrs: {
    outputs = attrs.outputs or [ "out" ] ++ [ "debug" ];
    buildInputs = attrs.buildInputs ++ [ <nixpkgs/pkgs/build-support/setup-hooks/separate-debug-info.sh> ];
  });
in {
  allowUnfree = true;
  allowBroken = false;
  android_sdk.accept_license = true;

  firefox = {
   enableGoogleTalkPlugin = true;
   enableAdobeFlash = false;
   enableGnomeExtensions = true;
#  jre = true;
  };

  wine = {
    release = "staging";
    build = "wineWow";
  };

  packageOverrides = pkgs: rec {
    git-new-workdir = pkgs.runCommand "git-new-workdir" {} ''
      mkdir $out
      ln -s ${pkgs.git}/share/git/contrib/workdir $out/bin
    '';
    taalo-build = pkgs.callPackage ./taalo-build.nix { };
    update-git-channel = pkgs.callPackage ./update-git-channel.nix {};
    inherit (pkgs.callPackage ./emacs.nix { enableDebugInfo = enableDebugInfo_ pkgs.lib; }) emacsPackages emacs emacsWithPackages;
    chromium = pkgs.chromium.override {
      enablePepperFlash = true;
      enableWideVine = false; ## FIX elfinfo
      pulseSupport = true;
      #gnomeSupport = true;
      #gnomeKeyringSupport = true;
      #enableNaCl = false; # broken
      #gconfPackage = pkgs.gnome2.GConf;
    };
    # Mass rebuild
    #xdg-open = pkgs.xdg-open.override {
    #  mimiSupport = true;
    #};
    wine = pkgs.wineFull;
    pixie = pkgs.pixie.override {
      buildWithPypy = true;
    };
    pinentry = pkgs.pinentry.override {
      gtk2 = null;
      gcr = pkgs.gnome3.gcr;
    };
    dwarf-fortress = pkgs.dwarf-fortress.override {
      theme = "phoebus";
      enableDFHack = true;
      enableSoundSense = true;
      enableStoneSense = true;
      enableTWBT = true;
    };
    texlive-bendlas = pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-medium koma-script mathpazo gtl
        booktabs pdfpages hyperref g-brief xstring numprint unravel
        collection-latex collection-latexextra collection-latexrecommended
        collection-fontsrecommended;
    };
  };
}
