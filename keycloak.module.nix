{ config, pkgs, ... }:
let
  keycloakHostname = "10.233.1.2";
  keycloakPath = "/auth";
  keycloakRealm = "heterodoxnews";
  oapHostname = "10.233.1.2";
  oapPath = "/oauth2";
in {
  services.nginx = {
    enable = true;
    # package = pkgs.openresty;

    # enable recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "${config.services.keycloak.settings.hostname}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "${keycloakPath}/" = {
            proxyPass = "http://localhost:${toString config.services.keycloak.settings.http-port}${keycloakPath}/";
            extraConfig = ''
              proxy_busy_buffers_size   512k;
              proxy_buffers   4 512k;
              proxy_buffer_size   256k;
            '';
          };
          "${oapPath}/" = {
            proxyPass = config.services.oauth2_proxy.nginx.proxy;
            extraConfig = ''
              proxy_set_header X-Scheme                $scheme;
              proxy_set_header X-Auth-Request-Redirect $request_uri;

              proxy_busy_buffers_size   512k;
              proxy_buffers   4 512k;
              proxy_buffer_size   256k;
            '';
          };
          "/protected/" = {
            alias = "/tmp/";
            extraConfig = ''
              autoindex on;

              auth_request ${oapPath}/auth;
              error_page 401 = ${oapPath}/start;

              # pass information via X-User and X-Email headers to backend,
              # requires running with --set-xauthrequest flag
              auth_request_set $user $upstream_http_x_auth_request_user;
              auth_request_set $email $upstream_http_x_auth_request_email;
              proxy_set_header X-User $user;
              proxy_set_header X-Email $email;

              # if you enabled --cookie-refresh, this is needed for it to work with auth_request
              auth_request_set $auth_cookie $upstream_http_set_cookie;
              add_header Set-Cookie $auth_cookie;
            '';
          };
        };
      };
    };
  };

  services.keycloak = {
    enable = true;
    # sslCertificateKey = "${./kc-key.pem}";
    # sslCertificate = "${./kc-cert.pem}";
    ## settings.hostname = "${config.bendlas.machine}.local";
    settings.hostname = keycloakHostname;
    settings.http-port = 38080;
    settings.proxy = "edge";
    settings.http-relative-path = keycloakPath;
    database.passwordFile = "${pkgs.writeText "pass" "foobar"}";
  };

  services.oauth2_proxy = {
    enable = true;
    cookie.secure = true;
    cookie.httpOnly = false;
    email.domains = [ "*" ];
    provider = "keycloak-oidc";
    redirectURL = "https://${oapHostname}${oapPath}/callback";
    extraConfig.oidc-issuer-url = "https://${keycloakHostname}${keycloakPath}/realms/${keycloakRealm}";
    
    # scope = "openid read_user email";
    # loginURL = "https://git.bendlas.net/oauth/authorize";
    # redeemURL = "https://git.bendlas.net/oauth/token";
    # validateURL = "https://git.bendlas.net/api/v4/user";
    # reverseProxy = true;
    # keyFile = "/etc/oauth2_proxy-secrets";

    # extraConfig.oidc-issuer-url = "https://git.bendlas.net";
    setXauthrequest = true;
  };
  systemd.services.oauth2_proxy.serviceConfig = {
    ## make sure that restart rate limiting doesn't permanently disable oauth2_proxy
    ## introduce pause before restarting
    RestartSec = 3;
    ## disable restart rate limiting
    StartLimitIntervalSec = 0;
  };
  users.groups.oauth2_proxy = {};
  users.users.oauth2_proxy.group = "oauth2_proxy";

}
