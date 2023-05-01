{ config, lib, pkgs, ... }:
let
  hostname = "virtox.local";
  gitHost = "git.virtox.local";
  environment = {
    systemPackages = with pkgs; [ traceroute tcptraceroute htop ];
  };
  files = pkgs.linkFarm "protected" [{
    name = "foo.html";
    path = pkgs.writeText "foo.html" ''
                <dl>
                <dt>user</dt>
                <dd><!--# echo var="auth_user" default="no" --></dd>
                <dt>email</dt>
                <dd><!--# echo var="auth_email" default="no" --></dd>
                <dt>preferred_username</dt>
                <dd><!--# echo var="auth_name" default="no" --></dd>
                <dt>groups</dt>
                <dd><!--# echo var="auth_groups" default="no" --></dd>
                </dl>
              '';
  } {
    name = "cgi/echo";
    path = pkgs.writeScript "echo.cgi" ''
                #!${pkgs.stdenv.shell}
                set -eu
                cat <<EOF
                Content-type: text/html

                <pre>$(env | sort)</pre>
                EOF
              '';
  }];
in {

  inherit environment;

  services.gitea = {
    enable = true;
    package = pkgs.forgejo;
    database.type = "postgres";
    settings = {
      server = {
        ROOT_URL = "https://${gitHost}/";
        DOMAIN = gitHost;
        PROTOCOL = "http+unix";
        #HTTP_ADDR = "127.137.0.2";
      };
      log.LEVEL = "Warn";
      # log.LEVEL = "Error";
      # log.LEVEL = "Trace";
      service = {
        DISABLE_REGISTRATION = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION  = true;

        ENABLE_REVERSE_PROXY_AUTHENTICATION = true;
        ENABLE_REVERSE_PROXY_AUTO_REGISTRATION = true;
        ENABLE_REVERSE_PROXY_EMAIL = true;
        ENABLE_REVERSE_PROXY_FULL_NAME = true;
      };
      session.PROVIDER = "db";
      security = {
        # PASSWORD_HASH_ALGO = "argon2";
        # PASSWORD_CHECK_PWN = true;
        # REVERSE_PROXY_TRUSTED_PROXIES = "*";
        # REVERSE_PROXY_LIMIT = 1;
        # REVERSE_PROXY_AUTHENTICATION_USER = "X-WEBAUTH-USER";
      };
    };
  };

  services.fcgiwrap.enable = true;

  services.nginx = {
    upstreams.forgejo.servers."unix:${toString config.services.gitea.settings.server.HTTP_ADDR}" = {};

    virtualHosts = {
      "${gitHost}" = {
        forceSSL = true;
        enableACME = true;
        locations = config.bendlas.auth.nginxAuthRequestLocations // {
          "/" = {
            # proxyPass = "http://${toString config.services.gitea.settings.server.HTTP_ADDR}:${toString config.services.gitea.settings.server.HTTP_PORT}/";
            proxyPass = "http://forgejo/";
            extraConfig = ''
              proxy_set_header X-WEBAUTH-USER $auth_user;
              proxy_set_header X-WEBAUTH-EMAIL $auth_email;
              proxy_set_header X-WEBAUTH-FULLNAME $auth_name;
              proxy_set_header X-Real-IP $remote_addr;
              ${config.bendlas.auth.nginxAuthRequestConfig}
            '';
          };
        };
      };

      "protected.${hostname}" = {
        forceSSL = true;
        enableACME = true;
        locations = config.bendlas.auth.nginxAuthRequestLocations // {
          "/" = {
            alias = "${files}/";
            extraConfig = ''
              autoindex on;
              ssi on;
              ${config.bendlas.auth.nginxAuthRequestConfig}
            '';
          };
          "/cgi/" = {
            alias = "${files}";
            extraConfig = ''
              include ${pkgs.nginx}/conf/fastcgi.conf;
              fastcgi_pass unix:/run/fcgiwrap.sock;
              # fastcgi_param  AUTH_USER $auth_user;
              # fastcgi_param  AUTH_EMAIL $auth_email;
              # fastcgi_param  AUTH_FULLNAME $auth_name;
              # fastcgi_param  AUTH_GROUPS $auth_groups;
              # ${config.bendlas.auth.nginxAuthRequestConfig}
            '';
          };
          "/cgi-auth/" = {
            proxyPass = "https://127.0.0.1/cgi/";
            extraConfig = ''
              proxy_set_header X-WEBAUTH-USER $auth_user;
              proxy_set_header X-WEBAUTH-EMAIL $auth_email;
              proxy_set_header X-WEBAUTH-FULLNAME $auth_name;
              proxy_set_header X-Real-IP $remote_addr;
              ${config.bendlas.auth.nginxAuthRequestConfig}
            '';
          };
        };
      };
    };
  };

}
