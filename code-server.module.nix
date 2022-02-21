{ config, pkgs, lib, ... }:
# https://github.com/breakds/nixvital/blob/master/modules/services/code-server.nix
let cfg = config.bendlas.code-server;

in {
  options.bendlas.code-server = with lib; {
    enable = lib.mkEnableOption "Enable this to start a visual studio code server.";
    portBase = lib.mkOption {
      type = lib.types.port;
      description = "The port on which vs codes are served: portBase + (id -u)";
      default = 7800;
    };
    # domain = lib.mkOption {
    #   type = lib.types.str;
    #   description = "The domain to the code server.";
    #   default = "code.breakds.org";
    #   example = "code.breakds.org";
    # };
    user = lib.mkOption {
      type = lib.types.str;
      description = "The user under which the server runs.";
    };
  };

  config =
    let extensionDir = "/home/${cfg.user}/.local/share/code-server/extensions";
    in lib.mkIf cfg.enable {
      system.activationScripts.preinstall-vscode-extensions = let extensions = with pkgs; [
        vscode-extensions.ms-vscode.cpptools
      ]; in {
        text = ''
          mkdir -p ${extensionDir}
          chown -R ${cfg.user}:users /home/${cfg.user}/.local/share/code-server
          for x in ${lib.concatMapStringsSep " " toString extensions}; do
              ln -sf $x/share/vscode/extensions/* ${extensionDir}/
          done
          chown -R ${cfg.user}:users ${extensionDir}
        '';
        deps = [];
      };

      systemd.services."code-server@" = {
        # enable = false;
        description = "Visual Studio Code Server for %I";
        after = [ "network.target" ];
        # wantedBy = [ "multi-user.target" ];
        path = [ pkgs.git pkgs.clojure ];

        serviceConfig = {
          Type = "simple";
          User = "%I";
          Group = "users";
          ExecStart = "${pkgs.writeScript "code-server" ''
              #!/bin/sh -eu
              port=$(($(id -u)+${toString cfg.portBase}))
              echo "Starting coder server on port $port"
              exec ${pkgs.code-server}/bin/code-server \
                --port $port \
                --bind-addr 0.0.0.0:$port \
                --auth none
          ''} %I";
          #               --disable-updates \

          Restart = "always";
        };
      };

      # networking.firewall.allowedTCPPorts = [ cfg.port ];

      # services.nginx.virtualHosts = lib.mkIf config.bendlas.web.enable {
      #   "${cfg.domain}" = {
      #     enableACME = true;
      #     forceSSL = true;
      #     locations."/".proxyPass = "http://localhost:${toString cfg.port}";
      #   };
      # };
    };
}
