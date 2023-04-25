{

  services.xserver = {
    enable = true;
    updateDbusEnvironment = true;
    displayManager.startx.enable = true;
    windowManager.exwm = {
      enable = true;
      enableDefaultConfig = false;
    };
  };

}
