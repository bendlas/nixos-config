let enableDebugInfo_ = lib: pkg:
  lib.overrideDerivation pkg (attrs: {
    outputs = attrs.outputs or [ "out" ] ++ [ "debug" ];
    buildInputs = attrs.buildInputs ++ [ <nixpkgs/pkgs/build-support/setup-hooks/separate-debug-info.sh> ];
  });
in {
  allowUnfree = true;
  allowBroken = false;
    
  virtualbox.enableExtensionPack = true;

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
    taalo-build = pkgs.callPackage ./taalo-build.nix { };
    nmap = pkgs.nmap_graphical;
    inherit (pkgs.callPackage ./emacs.nix { enableDebugInfo = enableDebugInfo_ pkgs.lib; }) emacsPackages emacs emacsWithPackages;
    chromium = pkgs.chromium.override {
      enablePepperFlash = true;
      enableWideVine = false; ## FIX elfinfo
      pulseSupport = true;
      #gnomeSupport = true;
      #gnomeKeyringSupport = true;
      #enableNaCl = false; # broken
      #gconfPackage = pkgs.gnome3.gconf;
    };
    # Mass rebuild
    #xdg-open = pkgs.xdg-open.override {
    #  mimiSupport = true;
    #};
    wine = pkgs.wineFull;
    linuxPackages = pkgs.linuxPackages_4_14;
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
    };
    texlive-bendlas = pkgs.texlive.combine {
      inherit (pkgs.texlive)
        scheme-medium koma-script mathpazo gtl
        booktabs pdfpages hyperref g-brief xstring numprint unravel
        collection-latex collection-latexextra collection-latexrecommended
        collection-fontsrecommended;
    };
    stdenv = pkgs.stdenv // {
      platform = pkgs.stdenv.platform // {
        # http://pkgs.fedoraproject.org/cgit/rpms/kernel.git/tree/Kbuild-Add-an-option-to-enable-GCC-VTA.patch
        ## criu support
        #  EXPERT y
        #  CHECKPOINT_RESTORE y
        ## modified by EXPERT y
        #  RFKILL_INPUT y
        ## systemtap support
        #  DEBUG_INFO y
        ## default correct
        #  KPROBES y
        #  RELAY y
        #  DEBUG_FS y
        #  MODULES y
        #  MODULE_UNLOAD y
        #  UPROBES y
        kernelExtraConfig = ''
          EXPERT y
          CHECKPOINT_RESTORE y
          RFKILL_INPUT y
          DEBUG_INFO y
        '';
      };
    };
  };
}
