{ config, pkgs, ... }:
with pkgs.lib;
with types;
let
  cfg = config.services.lldap;
  environment = {
    LLDAP_DATABASE_URL = "postgresql:///lldap?host=/run/postgresql";
    # postgresql:////var/lib/postgres
    LLDAP_KEY_FILE = "/var/lib/lldap/private_key";
    # LLDAP_SERVER_KEY_FILE = "/var/lib/lldap/private_key";
  } // cfg.extraEnvironment;
in {

  options.services.lldap = {
    # settings = mkOption {
    #   type = submodule {
    #     freeformType = (pkgs.formats.toml { }).type;
    #     options = {
          
    #     };
    #   };
    # };
    extraEnvironment = mkOption {
      description = ''
        see config values at https://github.com/lldap/lldap/blob/main/lldap_config.docker_template.toml
      '';
      type = attrsOf str;
      default = {};
    };
  };

  config = {
    systemd.services.lldap = {
      inherit environment;
      serviceConfig = {
        User = "lldap";
        Group = "lldap";
        ExecStartPre = [
          "!${pkgs.coreutils}/bin/mkdir -p /var/lib/lldap"
          "!${pkgs.coreutils}/bin/chown -R lldap:lldap /var/lib/lldap"
        ];
        ExecStart = "${pkgs.lldap}/bin/lldap run";
        WorkingDirectory = pkgs.lldap.wasm-app;
      };
    };

    environment.systemPackages = [ pkgs.lldap ];

    users.users.lldap.isSystemUser = true;
    users.users.lldap.group = "lldap";
    users.groups.lldap = {};

    services.postgresql = {
      ensureDatabases = [ "lldap" ];
      ensureUsers = [{
        name = "lldap";
        ensurePermissions = {
          "DATABASE lldap" = "ALL PRIVILEGES";
        };
      }];
    };
  };

}
