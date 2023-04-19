{ config, lib, pkgs, ... }:
let
  hostname = "10.233.1.2";
  gitPath = "/forgejo";
  oapPgPath = "/pgadmin/auth";
  oapPrPath = "/protected/auth";
  environment = {
    systemPackages = with pkgs; [ traceroute tcptraceroute htop ];
  };
in {

  require = [
    ./oauth2-proxies.module.nix
  ];

  inherit environment;

  services.nginx = {
    enable = true;
    # package = pkgs.openresty;

    # enable recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "${hostname}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "${gitPath}/" = {
            proxyPass = "http://localhost:${toString config.services.gitea.httpPort}${gitPath}/";
            extraConfig = ''
              proxy_busy_buffers_size   512k;
              proxy_buffers   4 512k;
              proxy_buffer_size   256k;

              rewrite ${gitPath}(.*) $1 break;
            '';
          };
          # "${gitPath}/oauth/".extraConfig = ''
          #   add_header 'Access-Control-Allow-Origin' '*';
          #   add_header 'Access-Control-Allow-Credentials' 'true';
          #   add_header 'Access-Control-Allow-Headers' '*';
          #   add_header 'Access-Control-Allow-Methods' '*';
          # '';
          "${oapPgPath}/" = {
            proxyPass = "http://${config.containers.oauth2-pgadmin4.localAddress}:4180${oapPgPath}/";
            extraConfig = ''
              proxy_set_header X-Scheme                $scheme;
              proxy_set_header X-Auth-Request-Redirect $request_uri;

              proxy_busy_buffers_size   512k;
              proxy_buffers   4 512k;
              proxy_buffer_size   256k;
            '';
          };
          "/pgadmin/" = {
            proxyPass = "http://localhost:${toString config.services.pgadmin.port}/";
            extraConfig = ''
              auth_request ${oapPgPath}/auth;
              error_page 401 = ${oapPgPath}/start;

              # pass information via X-User and X-Email headers to backend,
              # requires running with --set-xauthrequest flag
              auth_request_set $user $upstream_http_x_auth_request_user;
              auth_request_set $email $upstream_http_x_auth_request_email;
              proxy_set_header X-User $user;
              proxy_set_header X-Email $email;

              # if you enabled --cookie-refresh, this is needed for it to work with auth_request
              auth_request_set $auth_cookie $upstream_http_set_cookie;
              add_header Set-Cookie $auth_cookie;

              rewrite /pgadmin(.*) $1 break;
              proxy_set_header X-Script-Name /pgadmin;
              proxy_set_header X-Forwarded-User $email;
            '';
          };
          "${oapPrPath}/" = {
            proxyPass = "http://${config.containers.oauth2-yolo-app.localAddress}:4180${oapPrPath}/";
            extraConfig = ''
              proxy_set_header X-Scheme                $scheme;
              proxy_set_header X-Auth-Request-Redirect $request_uri;

              proxy_busy_buffers_size   512k;
              proxy_buffers   4 512k;
              proxy_buffer_size   256k;
            '';
          };
          "/protected/" = {
            # alias = "/tmp/protected/";
            # root = "/tmp/";
            alias = "/var/www/protected/";
            # root = "/var/www";
            extraConfig = ''
              autoindex on;
              ssi on;

              auth_request ${oapPrPath}/auth;
              error_page 401 = ${oapPrPath}/start;

              # pass information via X-User and X-Email headers to backend,
              # requires running with --set-xauthrequest flag
              auth_request_set $user $upstream_http_x_auth_request_user;
              auth_request_set $email $upstream_http_x_auth_request_email;
              proxy_set_header X-User $user;
              proxy_set_header X-Email $email;

              # if you enabled --cookie-refresh, this is needed for it to work with auth_request
              auth_request_set $auth_cookie $upstream_http_set_cookie;
              add_header Set-Cookie $auth_cookie;

              auth_request_set $groups $upstream_http_x_auth_request_groups;
              auth_request_set $preferred_username $upstream_http_x_auth_request_preferred_username;
            '';
          };
        };
      };
    };
  };


  services.gitea = {
    enable = true;
    package = pkgs.forgejo;
    rootUrl = "https://${hostname}${gitPath}/";
    domain = hostname;
    database.type = "postgres";
  };

  services.pgadmin = {
    enable = true;
    initialEmail = "admin@bendlas.net";
    initialPasswordFile = "/etc/secrets/pgadmin-admin-password";
    settings = {
      AUTHENTICATION_SOURCES = [ "webserver" ];
      WEBSERVER_AUTO_CREATE_USER = true;
      WEBSERVER_REMOTE_USER = "X-Forwarded-User";
    };
  };

  bendlas.oauth2-proxies = {
    devMode = true;
    applications = let
      oauth2ProxyConfigGitea = {
        cookie.secure = true;
        cookie.httpOnly = false;
        email.domains = [ "*" ];
        provider = "oidc";
        extraConfig.provider-display-name = "Bendlas Forgejo";
        passAccessToken = true;
        setXauthrequest = true;
        extraConfig.oidc-issuer-url = "https://${hostname}${gitPath}/";
        reverseProxy = true;
      };
    in [{
      name = "pgadmin4";
      require = [ { inherit environment; } ];
      oauth2ProxyConfig = lib.recursiveUpdate oauth2ProxyConfigGitea {
        scope = "email openid";
        proxyPrefix = oapPgPath;
        redirectURL = "https://${hostname}${oapPgPath}/callback";
        cookie.secret = "=RuRnL,sNTzfPxb-";
        clientID = "8c5f58ba-531f-4e20-b754-048bb56198ad";
        clientSecret = "gto_uesjhhzo2pz3dxvcmbma7dp5qtdumcmyzgiiivowlohnqa7qtvpa";
      };
    } {
      name = "yolo-app";
      require = [ { inherit environment; } ];
      oauth2ProxyConfig = lib.recursiveUpdate oauth2ProxyConfigGitea {
        scope = "email openid groups";
        proxyPrefix = oapPrPath;
        redirectURL = "https://${hostname}${oapPrPath}/callback";
        extraConfig.allowed-group = "yolo-org:ui";
        cookie.secret = "=RuRnL,sNTyfPxb-";
        clientID = "e2533f6a-f2d3-4990-8643-d1cf701dff28";
        clientSecret = "gto_p7avf3vmeaimg3yzfngpf2qvx3yjt2y7we5oaqetuyvkdt74hjra";
      };
      # oauth2ProxyConfig = oauth2ProxyConfigGitea // {
      #   scope = "email openid groups";
      #   proxyPrefix = oapPrPath;
      #   redirectURL = "https://${hostname}${oapPrPath}/callback";
      #   cookie.secret = "=RuRnL,sNTyfPxb-";
      #   clientID = "e2533f6a-f2d3-4990-8643-d1cf701dff28";
      #   clientSecret = "gto_p7avf3vmeaimg3yzfngpf2qvx3yjt2y7we5oaqetuyvkdt74hjra";
      # };
      # oauth2ProxyConfig = {
      #   cookie.secure = true;
      #   cookie.httpOnly = false;
      #   email.domains = [ "*" ];
      #   provider = "gitlab";
      #   scope = "openid email";
      #   loginURL = "https://git.bendlas.net/oauth/authorize";
      #   redeemURL = "https://git.bendlas.net/oauth/token";
      #   validateURL = "https://git.bendlas.net/api/v4/user";
      #   extraConfig.oidc-issuer-url = "https://git.bendlas.net";
      #   passAccessToken = true;
      #   setXauthrequest = true;

      #   reverseProxy = true;
      #   proxyPrefix = oapPrPath;
      #   cookie.secret = "=RuRnL,sNTyfPwb-";
      #   clientID = "e2374e0dccf6deaa8b5849e6a3255c860d40eba9ffbffc522d55addc07533a61";
      #   clientSecret = "4660cd54d9a2d14eeb5d8f02f974221b8782e336b5e7c6ff9abb35334d242768";
      #   # keyFile = "/etc/oauth2_proxy-secrets";
      # };
    }];
    
  };

  # containers.pgadmin-oauth2-proxy = let
  #   localAddress = "10.137.1.2";
  # in {
  #   autoStart = true;
  #   privateNetwork = true;
  #   hostAddress = "10.137.1.1";
  #   inherit localAddress;
  #   config = {
  #     inherit environment;
  #     networking.firewall.enable = false;
  #     services.oauth2_proxy = {
  #       # for dev
  #       # cookie.secure = false;
  #       extraConfig.ssl-insecure-skip-verify = true;
  #       # --
  #       enable = true;
  #       httpAddress = "http://${localAddress}:4180";
  #       ## Fix Gitea provider in OAP
  #       ## https://github.com/oauth2-proxy/oauth2-proxy/issues/1636
  #       package = pkgs.oauth2-proxy.overrideAttrs
  #         (old: {
  #           patches = (old.patches or []) ++ [
  #             (pkgs.fetchpatch {
  #               url = "https://github.com/igsol/oauth2-proxy/commit/749851f1b3446e2bb5eec2b5d5943c5873c34006.patch";
  #               sha256 = "sha256-Kkx0QgKq9aMVJEepZIWRgpeAIGDsO87UtC9c4JmnR/Q=";
  #             })
  #           ];
  #         });
  #       extraConfig.validate-url-special = "https://${hostname}${gitPath}/api/v1/user/emails";
  #       proxyPrefix = oapPgPath;
  #       cookie.secure = true;
  #       cookie.httpOnly = false;
  #       email.domains = [ "*" ];
  #       provider = "github";
  #       extraConfig.provider-display-name = "Forgejo";
  #       setXauthrequest = true;
  #       scope = "email openid";
  #       loginURL = "https://${hostname}${gitPath}/login/oauth/authorize";
  #       redeemURL = "https://${hostname}${gitPath}/login/oauth/access_token";
  #       validateURL = "https://${hostname}${gitPath}/api/v1/";
  #       redirectURL = "https://${hostname}${oapPgPath}/callback";
  #       # ---
  #       cookie.secret = "=RuRnL,sNTzfPxb-";
  #       clientID = "8c5f58ba-531f-4e20-b754-048bb56198ad";
  #       clientSecret = "gto_uesjhhzo2pz3dxvcmbma7dp5qtdumcmyzgiiivowlohnqa7qtvpa";
  #     };
  #     systemd.services.oauth2_proxy.serviceConfig = {
  #       ## make sure that restart rate limiting doesn't permanently disable oauth2_proxy
  #       ## introduce pause before restarting
  #       RestartSec = 3;
  #       ## disable restart rate limiting
  #       StartLimitIntervalSec = 0;
  #     };
  #   };
  # };

}
