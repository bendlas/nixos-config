let
  enableDebugInfo_ = lib: pkg:
    # lib.overrideDerivation
    pkg.overrideAttrs (attrs: {
      outputs = attrs.outputs or [ "out" ] ++ [ "debug" ];
      nativeBuildInputs = attrs.nativeBuildInputs ++ [
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

  packageOverrides = pkgs: let
    setPrio = setPrio' pkgs.lib;
    enableDebugInfo = enableDebugInfo_ pkgs.lib;
    ## workaround. `emacs` from this misses .override method, so can't be set as main `emacs` pkg
    customEmacs = pkgs.callPackage ./emacs-packages.nix { inherit enableDebugInfo; };
  in rec {

    inherit enableDebugInfo;

    gitignoreNix = import ./gitignore.nix pkgs;

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

    # waydroid = pkgs.waydroid.overrideDerivation (args: {
    #   patches = args.patches or [] ++ [
    #     ./waydroid.patch
    #     # (pkgs.fetchpatch {
    #     #   url = "https://github.com/bendlas/waydroid/commit/2ea666e083a65e674333239962b7b3a2c822fa77.patch";
    #     #   sha256 = "sha256-jKO3W81gllgD/QQY6me/5nAQVZtgQlDTisfWjmr8jhw=";
    #     # })
    #   ];
    # });

    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    git-new-workdir = pkgs.runCommand "git-new-workdir" {} ''
      mkdir $out
      ln -s ${pkgs.git}/share/git/contrib/workdir $out/bin
    '';
    taalo-build = pkgs.callPackage ./taalo-build.nix { };
    # inherit (pkgs.callPackage ./emacs-packages.nix { enableDebugInfo = enableDebugInfo_ pkgs.lib; }) emacsPackages emacs emacsWithPackages;
    inherit (customEmacs) emacsWithPackages emacsPackages emacsWithPackagesNox emacsPackagesNox;
    emacsBendlas = customEmacs.emacs;
    emacsBendlasNox = customEmacs.emacsNox;
    emacsCommercial = pkgs.callPackage (
      { emacsGit }: (emacsGit.override {
        nativeComp = false;
        withPgtk = false;
      }).overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "commercial-emacs";
          repo = "commercial-emacs";
          rev = "4311c820b69e7861690163d75f9ea0f74800c23a";
          sha256 = "sha256-Hs+UZc8wgxT4GtWM8k5gOV6gygVU5ogSzF4E00Na5vc=";
        };
      })
    ) { };
    chromium = pkgs.chromium.override {
      enableWideVine = builtins.currentSystem == "x86_64-linux";
      pulseSupport = true;
      commandLineArgs = "--enable-features=VaapiVideoDecoder";
    };
    # Mass rebuild
    #xdg-open = pkgs.xdg-open.override {
    #  mimiSupport = true;
    #};
    wine = pkgs.winePackages.full;
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
        collection-fontsrecommended komacv biblatex-ieee fontawesome;
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

    steam-run-bendlas = (pkgs.steamPackages.override {
      buildFHSUserEnv = pkgs.buildFHSUserEnvBubblewrap.override {
        bubblewrap = pkgs.bubblewrap.overrideDerivation (drv: {
          patches = (drv.patches or []) ++ [(pkgs.fetchpatch {
            url = "https://github.com/containers/bubblewrap/pull/402.patch";
            sha256 = "sha256-0gHpmaHxxKXIzeUaRcFjkl0Du9Hy6xsfS++quc7D+iI=";
          })];
        });
      };
    }).steam-fhsenv.run;
  };
}
