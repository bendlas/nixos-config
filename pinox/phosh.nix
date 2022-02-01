{ pkgs, ... }:
{

  systemd.defaultUnit = "graphical.target";
  systemd.services.phosh = {
    wantedBy = [ "graphical.target" ];
    # path = [ "/run/wrappers/bin" ];
    serviceConfig = {
      ExecStart = "${pkgs.phosh}/bin/phosh";
      User = 1000;
      Group = 100;
      # User = "nixos";
      PAMName = "login";
      WorkingDirectory = "~";

      TTYPath = "/dev/tty7";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";

      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";

      UtmpIdentifier = "tty7";
      UtmpMode = "user";

      Restart = "always";
    };
  };
  programs.phosh.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # unpatched gnome-initial-setup is partially broken in small screens
  services.gnome.gnome-initial-setup.enable = false;

  environment.gnome.excludePackages = with pkgs.gnome; [
    gnome-terminal
  ];

}
