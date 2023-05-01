{ config, lib, pkgs, ... }:
let
  pgadminHost = "pgadmin.virtox.local";
in {

  services.pgadmin = {
    enable = true;
    initialEmail = "admin@bendlas.net";
    initialPasswordFile = "/etc/secrets/pgadmin/admin-password";
    settings = {
      DEFAULT_SERVER = "127.137.0.2";
      # DEFAULT_SERVER = "0.0.0.0";
      AUTHENTICATION_SOURCES = [ "webserver" ];
      WEBSERVER_AUTO_CREATE_USER = true;
      WEBSERVER_REMOTE_USER = "X-Forwarded-User";
    };
  };

  services.nginx = {
    upstreams.pgadmin.servers."127.137.0.2:${toString config.services.pgadmin.port}" = {};
    virtualHosts."${pgadminHost}" = {
      forceSSL = true;
      enableACME = true;
      locations = config.bendlas.auth.nginxAuthRequestLocations // {
        "/" = {
          proxyPass = "http://pgadmin/";
          extraConfig = ''
              proxy_set_header X-Forwarded-User $auth_email;
              ${config.bendlas.auth.nginxAuthRequestConfig}
            '';
        };
      };        
    };
  };

}
