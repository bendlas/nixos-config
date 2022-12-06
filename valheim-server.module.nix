{config, pkgs, lib, ...}:
let
  serverName = "Manulinarium";
  worldName = "Manulinarium";
  public = false;
  port = 2456;
  # appUpdateArgs = "-beta public-test -betapassword yesimadebackups";
  appUpdateArgs = "";
in {
  users.users.valheim = {
    # Valheim puts save data in the home directory.
    home = "/var/lib/valheim";
    isNormalUser = true;
    group = "users";
  };

  networking.firewall.allowedUDPPorts = [ port (port + 1) ];

  systemd.services.valheim = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStartPre = ''
        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir $STATE_DIRECTORY \
          +login anonymous \
          +app_update 896660 ${appUpdateArgs} validate \
          +quit
      '';
      ExecStart = ''
        ${pkgs.steam-run}/bin/steam-run ./valheim_server.x86_64 \
          -nographics -batchmode \
          -name "${serverName}" \
          -port ${toString port} \
          -world "${worldName}" \
          -password "${builtins.readFile /etc/secrets/valheim-server-password}" \
          -public ${if public then "1" else "0"}
      '';
      Nice = "-5";
      Restart = "always";
      StateDirectory = "valheim";
      User = "valheim";
      WorkingDirectory = "/var/lib/valheim";
    };
    environment = {
      ## linux64 directory is required by Valheim.
      LD_LIBRARY_PATH = "linux64:${pkgs.glibc}/lib";
      ## this is defaulted from steam_appid.txt, which gets installed
      # SteamAppID = "892970";
    };
  };

  # # This is my custom backup machinery. Substitute your own 🙂
  # kevincox.backup.valheim = {
  # 	paths = [
  # 		"/var/lib/valheim/.config/unity3d/IronGate/Valheim/"
  # 	];
  # };
}
