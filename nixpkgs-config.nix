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
    jdk = pkgs.oraclejdk8.override {
      installjce = true;
    };
    jre = jdk.jre;
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
    linuxPackages = pkgs.linuxPackages_4_5;
    stdenv = pkgs.stdenv // {
      platform = pkgs.stdenv.platform // {
        kernelExtraConfig = "CONFIG_CHECKPOINT_RESTORE y";
      };
    };
  };
}
