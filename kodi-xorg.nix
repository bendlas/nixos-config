{
  services.xserver.enable = true;
  services.xserver.desktopManager.kodi.enable = true;
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "kodi";

  # Define a user account
  users.extraUsers.kodi.isNormalUser = true;
}
