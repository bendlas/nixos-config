{

  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    windowManager.exwm = {
      enable = true;
      enableDefaultConfig = false;
    };
  };

}
