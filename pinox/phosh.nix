{ pkgs, ... }:
{

  services.xserver.enable = true;
  services.xserver.desktopManager = {
    phosh = {
      enable = true;
      user = "nixos";
      group = "users";
      # package = pkgs.phosh.overrideDerivation (d: rec {
      #   name = "${d.pname}-${version}";
      #   version = assert d.version == "0.17.0"; "0.20.0_beta3";
      #   src = pkgs.fetchFromGitLab {
      #     domain = "gitlab.gnome.org";
      #     group = "World";
      #     owner = "Phosh";
      #     repo = d.pname;
      #     rev = "v${version}";
      #     fetchSubmodules = true; # including gvc and libcall-ui which are designated as subprojects
      #     sha256 = "sha256-876/fCwsDJUsPZNcX4ZA4y3xLhttCdXzo8ZkxGKH/BE=";
      #   };
      # });
    };
  };

  # systemd.defaultUnit = "graphical.target";
  # systemd.services.phosh = {
  #   wantedBy = [ "graphical.target" ];
  #   # path = [ "/run/wrappers/bin" ];
  #   serviceConfig = {
  #     ExecStart = "${pkgs.phosh}/bin/phosh";
  #     User = 1000;
  #     Group = 100;
  #     # User = "nixos";
  #     PAMName = "login";
  #     WorkingDirectory = "~";

  #     TTYPath = "/dev/tty7";
  #     TTYReset = "yes";
  #     TTYVHangup = "yes";
  #     TTYVTDisallocate = "yes";

  #     StandardInput = "tty-fail";
  #     StandardOutput = "journal";
  #     StandardError = "journal";

  #     UtmpIdentifier = "tty7";
  #     UtmpMode = "user";

  #     Restart = "always";
  #   };
  # };
  # programs.phosh.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # # unpatched gnome-initial-setup is partially broken in small screens
  # services.gnome.gnome-initial-setup.enable = false;

  environment.gnome.excludePackages = with pkgs.gnome; [
    gnome-terminal
  ];

}
