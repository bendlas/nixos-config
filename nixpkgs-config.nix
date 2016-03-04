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
    linuxPackages = pkgs.linuxPackages_4_4;
    gnupg = pkgs.gnupg21;
    nmap = pkgs.nmap_graphical;
    emacs = pkgs.callPackage ./emacs.nix {
      emacs = pkgs.emacs25pre;
    };
    chromium = pkgs.chromium.override {
      enablePepperFlash = true;
      pulseSupport = true;
      ## broken
      # enableNaCl = true;
    };
  };
}
