{ lib, config, pkgs, ... }:
with lib;
with types;
let
  cfg = config.bendlas.auth;
in {

  imports = [ ./lldap.module.nix ];

  options.bendlas.auth = {
    baseDn = mkOption {
      type = str;
      default = "dc=bendlas,dc=net";
    };
    nginxAuthRequestConfig = mkOption {
      internal = true;
      default = ''
        auth_request /authelia/api/verify;
        error_page 401 =302 https://auth.virtox.local/authelia?rd=$target_url;
        ## Comment this line if you're using nginx without the http_set_misc module.
        # set_escape_uri $target_url $scheme://$http_host$request_uri;
        ## Uncomment this line if you're using NGINX without the http_set_misc module.
        set $target_url $scheme://$http_host$request_uri;
        auth_request_set $auth_user $upstream_http_remote_user;
        auth_request_set $auth_email $upstream_http_remote_email;
        auth_request_set $auth_groups $upstream_http_remote_groups;
        auth_request_set $auth_name $upstream_http_remote_name;
      '';
    # # if you enabled --cookie-refresh, this is needed for it to work with auth_request
    # auth_request_set $auth_cookie $upstream_http_set_cookie;
    # add_header Set-Cookie $auth_cookie;
    };

    nginxAuthRequestLocations = mkOption {
      internal = true;
      default = {
        "/authelia/api/verify" = {
          proxyPass = "http://127.137.0.1:8080/authelia/api/verify";
          extraConfig = ''
              internal;
              proxy_pass_request_body off;
              proxy_set_header Content-Length "";
              # [REQUIRED] Needed by Authelia to check authorizations of the resource.
              # Provide either X-Original-URL and X-Forwarded-Proto or
              # X-Forwarded-Proto, X-Forwarded-Host and X-Forwarded-Uri or both.
              # Those headers will be used by Authelia to deduce the target url of the user.
              #
              # Basic Proxy Config
              proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
              proxy_set_header X-Forwarded-Method $request_method;
              proxy_set_header X-Forwarded-For $remote_addr;
            '';
        };
      };
    };
    
  };

  config = {

    services.lldap.extraEnvironment = {
      LLDAP_LDAP_HOST = "127.137.0.1";
      LLDAP_HTTP_HOST = "127.137.0.1";
      LLDAP_HTTP_URL = "https://auth.virtox.local";
      LLDAP_LDAP_BASE_DN = cfg.baseDn;
      LLDAP_LDAP_USER_PASS_FILE = "/etc/secrets/lldap/userPass";
      LLDAP_VERBOSE = "false";
    };

    services.nginx.virtualHosts."auth.virtox.local" = {
      forceSSL = true;
      enableACME = true;
    };

    services.nginx.virtualHosts."auth.virtox.local".locations = config.bendlas.auth.nginxAuthRequestLocations // {
      "/" = {
        proxyPass = "http://127.137.0.1:17170";
        extraConfig = config.bendlas.auth.nginxAuthRequestConfig;
        # extraConfig = ''
        #   auth_request /authelia/api/verify;
        #   error_page 401 =302 https://auth.virtox.local/authelia?rd=$target_url;
        #   ## Comment this line if you're using nginx without the http_set_misc module.
        #   # set_escape_uri $target_url $scheme://$http_host$request_uri;

        #   ## Uncomment this line if you're using NGINX without the http_set_misc module.
        #   set $target_url $scheme://$http_host$request_uri;
        # '';
      };
      "/authelia/" = {
        proxyPass = "http://127.137.0.1:8080";
        extraConfig = ''
          ## Headers
          proxy_set_header Host $host;
          proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_set_header X-Forwarded-Uri $request_uri;
          proxy_set_header X-Forwarded-Ssl on;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header Connection "";

          ## Basic Proxy Configuration
          client_body_buffer_size 128k;
          proxy_next_upstream error timeout invalid_header http_500 http_502 http_503; ## Timeout if the real server is dead.
          proxy_redirect  http://  $scheme://;
          proxy_http_version 1.1;
          proxy_cache_bypass $cookie_session;
          proxy_no_cache $cookie_session;

          proxy_headers_hash_max_size 4096;
          proxy_buffers 64 256k;
          proxy_buffer_size   256k;

          ## Trusted Proxies Configuration
          ## Please read the following documentation before configuring this:
          ##     https://www.authelia.com/integration/proxies/nginx/#trusted-proxies
          # set_real_ip_from 10.0.0.0/8;
          # set_real_ip_from 172.16.0.0/12;
          # set_real_ip_from 192.168.0.0/16;
          # set_real_ip_from fc00::/7;
          real_ip_header X-Forwarded-For;
          real_ip_recursive on;

          ## Advanced Proxy Configuration
          send_timeout 5m;
          proxy_read_timeout 360;
          proxy_send_timeout 360;
          proxy_connect_timeout 360;
        '';
      };
    };

    services.authelia.instances.hen-dev = {
      enable = true;
      environmentVariables = {
        # TODO add to `secrets` option
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = "/etc/secrets/lldap/userPass";
      };
      secrets = {
        jwtSecretFile = "/etc/secrets/authelia/jwtSecret";
        storageEncryptionKeyFile = "/etc/secrets/authelia/storageEncryptionKey";
      };
      settings = {
        # log.level = "trace";
        log.level = "info";
        server.host = "127.137.0.1";
        server.port = 8080;
        server.path = "authelia";
        server.buffers.read = "262144";
        authentication_backend.password_reset.disable = false;
        authentication_backend.ldap = {
          implementation = "custom";
          url = "ldap://${config.services.lldap.extraEnvironment.LLDAP_LDAP_HOST}:3890";
          timeout = "5s";
          start_tls = false;
          base_dn = cfg.baseDn;
          username_attribute = "uid";
          additional_users_dn = "ou=people";
          # To allow sign in both with username and email, one can use a filter like
          # (&(|({username_attribute}={input})({mail_attribute}={input}))(objectClass=person))
          users_filter = "(&({username_attribute}={input})(objectClass=person))";
          groups_filter = "(member={dn})";
          group_name_attribute = "cn";
          mail_attribute = "mail";
          display_name_attribute = "displayName";
          user = "uid=admin,ou=people,${cfg.baseDn}";
        };
        access_control.default_policy = "one_factor";
        session.domain = "virtox.local";
        storage.postgres = {
          host = "/run/postgresql/";
          port = 5432;
          database = "authelia-hen-dev";
          username = "authelia-hen-dev";
          password = "<dummy>";
        };
        notifier.filesystem.filename = "/tmp/authelia-notification";
        # notifier.smtp = {
        #   host = "127.0.0.1";
        #   port = 25;
        #   timeout = "5s";
        #   sender = "Bendlas Auth <auth@bendlas.net>";
        #   identifier = "auth.bendlas.net";
        #   subject = "[AUTH] {title}";
        #   disable_require_tls = true;
        #   disable_starttls = true;
        #   disable_html_emails = true;
        # };
      };
    };

    services.postgresql = {
      ensureDatabases = [ "authelia-hen-dev" ];
      ensureUsers = [{
        name = "authelia-hen-dev";
        ensurePermissions = {
          "DATABASE \"authelia-hen-dev\"" = "ALL PRIVILEGES";
        };
      }];
    };

  };
}
