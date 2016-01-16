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

  packageOverrides = let
    pkgs-stable = import ./pkgs-stable { config = {}; };
  in pkgs: rec {
    jdk = pkgs.oraclejdk8.override {
      installjce = true;
    };
    jre = jdk.jre;
    postgresql = pkgs.postgresql94;
    linuxPackages = pkgs.linuxPackages_4_3;
    gnupg = pkgs.gnupg21;
    nmap = pkgs.nmap_graphical;
    emacs = pkgs.emacsWithPackages.override {
      emacs = pkgs.emacs.override {
        inherit (pkgs) alsaLib imagemagick acl gpm;
        inherit (pkgs.gnome3) gconf;
        withGTK3 = true; withGTK2 = false;
      };
    } [
      pkgs.ghostscript
      pkgs.aspell
    ];
    chromium = pkgs.chromium.override {
      enablePepperFlash = true;
      pulseSupport = true;
      ## broken
      # enableNaCl = true;
    };
    fail2ban = pkgs-stable.fail2ban;
  };
}
