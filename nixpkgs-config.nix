let enableDebugInfo_ = lib: pkg:
  lib.overrideDerivation pkg (attrs: {
    outputs = attrs.outputs or [ "out" ] ++ [ "debug" ];
    buildInputs = attrs.buildInputs ++ [ <nixpkgs/pkgs/build-support/setup-hooks/separate-debug-info.sh> ];
  });
in {
  nix.trustedBinaryCaches = [ "http://nixos.org/binary-cache" "http://cache.nixos.org" ];
  allowUnfree = true;
  allowBroken = false;
    
  virtualbox.enableExtensionPack = true;

  firefox = {
   enableGoogleTalkPlugin = true;
   enableAdobeFlash = false;
   enableGnomeExtensions = true;
#  jre = true;
  };

  chromium = {
   enablePepperFlash = true;
  };

  wine = {
    release = "staging";
    build = "wineWow";
  };

  packageOverrides = pkgs: rec {
    postgresql = pkgs.postgresql95;
    gnupg = pkgs.gnupg21;
    nmap = pkgs.nmap_graphical;
    inherit (pkgs.callPackage ./emacs.nix { enableDebugInfo = enableDebugInfo_ pkgs.lib; }) emacsPackages emacs;
    chromium = pkgs.chromium.override {
      enablePepperFlash = true;
      pulseSupport = true;
      ## broken
      # enableNaCl = true;
    };
    wine = pkgs.wineFull;
    linuxPackages = pkgs.linuxPackages_4_8;
    pixie = pkgs.pixie.override {
      buildWithPypy = true;
    };
    stdenv = pkgs.stdenv // {
      platform = pkgs.stdenv.platform // {
        /*kernelExtraConfig = ''
          EXPERT y
          CHECKPOINT_RESTORE y
          RFKILL_INPUT y
        '';*/
        # http://pkgs.fedoraproject.org/cgit/rpms/kernel.git/tree/Kbuild-Add-an-option-to-enable-GCC-VTA.patch
        kernelExtraConfig = ''
          ## criu support
          EXPERT y
          CHECKPOINT_RESTORE y
          # modified by EXPERT y
          RFKILL_INPUT y
          ## systemtap support
          DEBUG_INFO y
          ## default correct
          #KPROBES y
          #RELAY y
          #DEBUG_FS y
          #MODULES y
          #MODULE_UNLOAD y
          #UPROBES y
        '';
      };
    };
  };
}
