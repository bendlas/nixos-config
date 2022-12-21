{config, pkgs, lib, ...}:
let
  serverName = "Manulinarium";
  worldName = "Manulinarium";
  public = false;
  port = 2456;
  steamId = "896660";
  branch = "public";
  # appUpdateArgs = "-beta public-test -betapassword yesimadebackups";
  appUpdateArgs = "-beta ${branch}"; # downgrade if changing branches
  installDir = "/var/lib/valheim";
in {
  require = with lib; with types; [{
    options.services.valheim-server.password = mkOption {
      type = str;
    };
  }];

  users.users.valheim = {
    # Valheim puts save data in the home directory.
    home = installDir;
    isNormalUser = true;
    group = "users";
  };

  networking.firewall.allowedUDPPorts = [ port (port + 1) ];

  ## periodically check steam for updates to valheim dedicated server
  ## restart server if update is available (will be picked up by server ExecStartPre)
  systemd.timers.valheim-update-scanner = {
    description = "Timer periodically re-scanning for valheim updates";
    wantedBy = [ "valheim.service" ];
    timerConfig.OnActiveSec = "10 minutes";
    timerConfig.OnUnitInactiveSec = "10 minutes";
  };
  systemd.services.valheim-update-scanner = {
    description = "Check for valheim server updates";
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "valheim";
    path = with pkgs; [ curl jq coreutils ];
    script = ''
      set -eu
      latest=$(curl https://api.steamcmd.net/v1/info/${steamId} | jq -r '.data."${steamId}".depots.branches.${branch}.buildid')
      installed=$(grep buildid ${installDir}/steamapps/appmanifest_896660.acf | cut -d'"' -f4)
      if [ "$latest" = "$installed" ]
      then
        echo "Installed version '$installed' matches latest '${branch}' version"
      else
        echo "Installed version '$installed' is different from latest '${branch}' version '$latest'; restarting valheim.service"
        /run/wrappers/bin/sudo /run/current-system/sw/bin/systemctl restart valheim.service
      fi
    '';
  };
  ## allow valheim user to restart valheim dedicated server
  ## used by update scanner timer service
  security.sudo.extraRules = [{
    users = [ "valheim" ];
    commands = [{
      command = "/run/current-system/sw/bin/systemctl restart valheim.service";
      options = [ "NOPASSWD" ];
    }];
  }];

  systemd.services.valheim = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStartPre = ''
        ${pkgs.steamcmd}/bin/steamcmd \
          +force_install_dir $STATE_DIRECTORY \
          +login anonymous \
          +app_update ${steamId} ${appUpdateArgs} validate \
          +quit
      '';
      # steam-run-bendlas to pass through SIGINT through bwrap
      # https://github.com/containers/bubblewrap/pull/402
      KillSignal = "SIGINT"; # for saving on shutdown
      ExecStart = ''
        ${pkgs.steam-run-bendlas}/bin/steam-run ./valheim_server.x86_64 \
          -nographics -batchmode \
          -name "${serverName}" \
          -port ${toString port} \
          -world "${worldName}" \
          -password "${config.services.valheim-server.password}" \
          -public ${if public then "1" else "0"}
      '';
      Nice = "-5";
      Restart = "always";
      StateDirectory = "valheim";
      User = "valheim";
      WorkingDirectory = installDir;
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
