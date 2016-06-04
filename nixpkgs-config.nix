{
  nix.trustedBinaryCaches = [ "http://nixos.org/binary-cache" "http://cache.nixos.org" ];
  allowUnfree = true;
    
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

  splix.unstable = true;

  packageOverrides = pkgs: rec {
    postgresql = pkgs.postgresql95;
    gnupg = pkgs.gnupg21;
    nmap = pkgs.nmap_graphical;
    inherit (pkgs.callPackage ./emacs.nix { }) emacsPackages emacs;
    chromium = pkgs.chromium.override {
      enablePepperFlash = true;
      pulseSupport = true;
      ## broken
      # enableNaCl = true;
    };
    wine = pkgs.wineFull;
    linuxPackages = pkgs.linuxPackages_4_6;
    stdenv = pkgs.stdenv // {
      platform = pkgs.stdenv.platform // {
        kernelExtraConfig = ''
          EXPERT y
          CHECKPOINT_RESTORE y
          RFKILL_INPUT y
        '';
      };
    };
  };
}
