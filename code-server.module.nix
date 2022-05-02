{ config, pkgs, ... }:
{
  require = [
    ./code-server.container.nix
  ];

  bendlas.code-server-container."code-server-container" = {
    user = "dev";
    containerOptions = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "10.9.8.1";
      localAddress = "10.9.8.32";
      config = {
        environment.systemPackages = with pkgs; [ babashka git clojure clojure-lsp leiningen ];
      };
      bindMounts = {
        "/home/code-server" = {
          hostPath = "/var/lib/code-server-home";
          isReadOnly = false;
        };
      };
    };
  };
  users.users = {
    dev.isNormalUser = true;
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-code-sermcxs" ];
  };

  services.nginx = let
    auth = ''
      auth_request /oauth2/auth;
      error_page 401 = /oauth2/start;

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
  in {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."code.bendlas.net" = {
      enableACME = true;
      forceSSL = true;
      locations."/oauth2/" = {
        proxyPass = config.services.oauth2_proxy.nginx.proxy;
        extraConfig = ''
          proxy_set_header X-Scheme                $scheme;
          proxy_set_header X-Auth-Request-Redirect $request_uri;
        '';
      };
      locations."/" = {
        proxyPass = "http://${config.containers."code-server-container".localAddress}:4444/";
        proxyWebsockets = true;
        extraConfig = auth;
      };
      locations."/preview" = {
        proxyPass = "http://${config.containers."code-server-container".localAddress}:8080/";
        proxyWebsockets = true;
        extraConfig = auth;
      };
    };
  };

  services.oauth2_proxy = {
    enable = true;
    cookie.secure = true;
    cookie.httpOnly = false;
    email.domains = [ "*" ];
    provider = "gitlab";
    scope = "openid read_user email";
    loginURL = "https://git.bendlas.net/oauth/authorize";
    redeemURL = "https://git.bendlas.net/oauth/token";
    validateURL = "https://git.bendlas.net/api/v4/user";
    reverseProxy = true;
    keyFile = "/etc/oauth2_proxy-secrets";

    extraConfig.oidc-issuer-url = "https://git.bendlas.net";
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
