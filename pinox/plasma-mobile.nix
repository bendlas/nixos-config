{

  services.xserver.enable = true;
  services.xserver.displayManager = {
    sddm.enable = true;
    autoLogin = {
      enable = true;
      user = "nixos";
    };
    defaultSession = "plasma-mobile";
  };
  services.xserver.desktopManager.plasma5 = {
    enable = true;
    mobile.enable = true;
    # mobile.installRecommendedSoftware = true;
    # runUsingSystemd = true;
    # useQTScaling = true;
  };

}
