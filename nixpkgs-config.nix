let enableDebugInfo_ = lib: pkg:
  lib.overrideDerivation pkg (attrs: {
    outputs = attrs.outputs or [ "out" ] ++ [ "debug" ];
    buildInputs = attrs.buildInputs ++ [ <nixpkgs/pkgs/build-support/setup-hooks/separate-debug-info.sh> ];
  });
in {
  allowUnfree = true;
  allowBroken = false;
  android_sdk.accept_license = true;

  permittedInsecurePackages = [
    "python2.7-Pillow-6.2.2"
  ];

  firefox = {
   enableGnomeExtensions = true;
#  jre = true;
  };

  wine = {
    release = "staging";
    build = "wineWow";
  };

  packageOverrides = pkgs: rec {
    # localPackages = pkgFile: config: pkgs.callPackage ./local-packages.nix {
    #   pkgFile = ./desktop.packages;
    #   source = pkgs.fetchgit {
    #     inherit (pkgs.lib.importJSON ./nixpkgs.json) url rev sha256 fetchSubmodules;
    #   };
    # };
    git-new-workdir = pkgs.runCommand "git-new-workdir" {} ''
      mkdir $out
      ln -s ${pkgs.git}/share/git/contrib/workdir $out/bin
    '';
    taalo-build = pkgs.callPackage ./taalo-build.nix { };
    inherit (pkgs.callPackage ./emacs.nix { enableDebugInfo = enableDebugInfo_ pkgs.lib; }) emacsPackages emacs emacsWithPackages;
    chromium = pkgs.chromium.override {
      #enablePepperFlash = true;
      enableWideVine = true;
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
    pinentry = pkgs.pinentry.gnome3;
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
    ml-workbench = pkgs.mkShell {
      name = "ml-workbench";
      buildInputs = (with pkgs; [
        hy3 mkl opencl-icd cudatoolkit_10_1 intel-compute-runtime
      ]) ++ (with pkgs.python3Packages; [
        python pytorch ipython
        ## for gpt-2
        python requests tqdm fire numpy regex # tensorflow
      ]);
    };
    # hy3 = pkgs.hy.override {
    #   pythonPackages = pkgs.python3Packages;
    # };
    ungoogled-chromium-bendlas = pkgs.runCommand "ungoogled-chromium-bendlas" {
      orig = pkgs.ungoogled-chromium;
    } ''
      mkdir -p $out/bin
      for b in $orig/bin/*
      do
        ln -s $b $out/bin/ungoogled-$(basename $b)
      done
    '';
  };
}
