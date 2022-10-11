{ pkgs, ... }:
{

  # services.xserver.enable = true;
  services.xserver.desktopManager = {
    gnome.enable = true;
    phosh = {
      enable = true;
      user = "herwig";
      group = "users";
    };
  };

  # # unpatched gnome-initial-setup is partially broken in small screens
  # services.gnome.gnome-initial-setup.enable = false;

  environment.gnome.excludePackages = with pkgs.gnome; [
    gnome-terminal
  ];

}
