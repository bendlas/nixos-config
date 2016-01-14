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

  packageOverrides = pkgs: rec {
    jdk = pkgs.oraclejdk8;
    jre = jdk.jre;
    postgresql = pkgs.postgresql95;
    linuxPackages = pkgs.linuxPackages_4_4;
    gnupg = pkgs.gnupg21;
    nmap = pkgs.nmap_graphical;
    emacs = let
      customEmacsPackages = pkgs.emacsPackagesNg.override (super: self: {
        emacs = pkgs.emacs.override {
          inherit (pkgs) alsaLib imagemagick acl gpm;
          inherit (pkgs.gnome3) gconf;
          withGTK3 = true; withGTK2 = false;
        };
      });
    in customEmacsPackages.emacsWithPackages (epkgs: [
      pkgs.ghostscript pkgs.aspell
    ]);
    chromium = pkgs.chromium.override {
      enablePepperFlash = true;
      pulseSupport = true;
      ## broken
      # enableNaCl = true;
    };
    wine = pkgs.wine.override {
      wineRelease = "staging";
      wineBuild = "wineWow";
    };
  };
}
