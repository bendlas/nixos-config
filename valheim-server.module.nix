{config, pkgs, lib, ...}: {
	users.users.valheim = {
		# Valheim puts save data in the home directory.
		home = "/var/lib/valheim";
    isNormalUser = true;
    group = "users";
  };

  networking.firewall.allowedUDPPorts = [ 2456 2457 ];

	systemd.services.valheim = {
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
      # steamcmd +@sSteamCmdForcePlatformType linux +force_install_dir /path/to/server +login anonymous +app_update 896660 validate +quit
			ExecStartPre = ''
				${pkgs.steamcmd}/bin/steamcmd \
					+login anonymous \
					+force_install_dir $STATE_DIRECTORY \
					+app_update 896660 validate \
					+quit
			'';
			ExecStart = ''
				${pkgs.glibc}/lib/ld-linux-x86-64.so.2 ./valheim_server.x86_64 \
					-name "Manulinarium" \
					-port 2456 \
					-world "Manulinarium" \
					-password "$(cat /etc/secrets/valheim-server-password)" \
					-public 0
			'';
			Nice = "-5";
			Restart = "always";
			StateDirectory = "valheim";
			User = "valheim";
			WorkingDirectory = "/var/lib/valheim";
		};
		environment = {
			# linux64 directory is required by Valheim.
			LD_LIBRARY_PATH = "linux64:${pkgs.glibc}/lib";
		};
	};

	# # This is my custom backup machinery. Substitute your own 🙂
	# kevincox.backup.valheim = {
	# 	paths = [
	# 		"/var/lib/valheim/.config/unity3d/IronGate/Valheim/"
	# 	];
	# };
}
