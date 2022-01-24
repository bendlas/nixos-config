{ pkgs, ... }: {
  # Define a user account
  users.extraUsers.kodi.isNormalUser = true;
  services.cage.user = "kodi";
  services.cage.program = "${pkgs.kodi-wayland}/bin/kodi-standalone";
  services.cage.enable = true;
  # nixpkgs.config.kodi.enableAdvancedLauncher = true;
}
