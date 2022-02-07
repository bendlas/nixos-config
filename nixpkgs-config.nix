let
  enableDebugInfo_ = lib: pkg:
    # lib.overrideDerivation
    pkg.overrideAttrs (attrs: {
      outputs = attrs.outputs or [ "out" ] ++ [ "debug" ];
      buildInputs = attrs.buildInputs ++ [
        <nixpkgs/pkgs/build-support/setup-hooks/separate-debug-info.sh>
      ];
    });
  setPrio' = lib: num: drv: lib.addMetaAttrs { priority = num; } drv;
in {
  allowUnfree = true;
  allowBroken = false;
  android_sdk.accept_license = true;

  # permittedInsecurePackages = [
  #   "python2.7-Pillow-6.2.2"
  # ];

  firefox = {
   enableGnomeExtensions = true;
#  jre = true;
  };

  wine = {
    release = "staging";
    build = "wineWow";
  };

  packageOverrides = pkgs: let setPrio = setPrio' pkgs.lib; in rec {
    # localPackages = pkgFile: config: pkgs.callPackage ./local-packages.nix {
    #   pkgFile = ./desktop.packages;
    #   source = pkgs.fetchgit {
    #     inherit (pkgs.lib.importJSON ./nixpkgs.json) url rev sha256 fetchSubmodules;
    #   };
    # };

    ## this is unconditionally installed by gnome module, so disable it here
    gnome-tour = pkgs.writeScriptBin "gnome-tour" ''
      #!/bin/sh -eu
      echo >&2 "gnome-tour has been removed"
      exit 1
    '';

    ## prioritize packages to avoid path collisions
    nettools = setPrio 9 pkgs.nettools; ## nettools are deprecated in favor of inetutils
    traceroute = setPrio 2 pkgs.traceroute; ## traceroute should override inetutils, see https://askubuntu.com/questions/1017286/what-is-the-difference-between-traceroute-from-traceroute-and-inetutils-tracerou
    ncurses = setPrio 6 pkgs.ncurses; ## defer to per-terminal terminfo
    androidsdk_9_0 = setPrio 6 pkgs.androidsdk_9_0; ## defer to e2fsprogs
    unrar = setPrio 4 pkgs.unrar; ## open-source unrar should override proprietary rar

    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    git-new-workdir = pkgs.runCommand "git-new-workdir" {} ''
      mkdir $out
      ln -s ${pkgs.git}/share/git/contrib/workdir $out/bin
    '';
    taalo-build = pkgs.callPackage ./taalo-build.nix { };
    # inherit (pkgs.callPackage ./emacs-packages.nix { enableDebugInfo = enableDebugInfo_ pkgs.lib; }) emacsPackages emacs emacsWithPackages;
    inherit (pkgs.callPackage ./emacs-packages.nix { enableDebugInfo = enableDebugInfo_ pkgs.lib; }) emacsWithPackages emacsPackages;
    chromium = pkgs.chromium.override {
      enableWideVine = builtins.currentSystem == "x86_64-linux";
      pulseSupport = true;
      commandLineArgs = "--enable-features=VaapiVideoDecoder";
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
