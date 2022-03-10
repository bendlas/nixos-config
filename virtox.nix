{ config, pkgs, ... }:
{
  require = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./essential.module.nix # ./mdns.module.nix ./ssh.module.nix
    ./networkd.module.nix

    ./code-server.container.nix
  ];
  bendlas.machine = "virtox";
  bendlas.code-server-container."code-server-test" = {
    user = "test";
    containerOptions = {
      privateNetwork = true;
      hostAddress = "10.9.8.1";
      localAddress = "10.9.8.32";
      config = {
        environment.systemPackages = [ pkgs.babashka ];
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
    test.isNormalUser = true;
  };

  boot.isContainer = true;
  # networking.interfaces.eth0.useDHCP = true;
  # networking.firewall.allowedTCPPorts = [ 80 ];
  networking.firewall.enable = false;

  services.nginx = {
    enable = true;
    recommendedProxySettings = false;
    # proxy_set_header        Host $host;
    # proxy_set_header        X-Real-IP $remote_addr;
    # proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    # proxy_set_header        X-Forwarded-Proto $scheme;
    # proxy_set_header        X-Forwarded-Host $host;
    # proxy_set_header        X-Forwarded-Server $host;
    virtualHosts."localhost" = {
      default = true;
      locations."/oauth2/" = {
        proxyPass = config.services.oauth2_proxy.nginx.proxy;
        extraConfig = ''
          proxy_set_header Host                    $host;
          proxy_set_header X-Real-IP               $remote_addr;
          proxy_set_header X-Scheme                $scheme;
          proxy_set_header X-Auth-Request-Redirect $request_uri;
        '';
      };
      locations."/" = {
        # proxyPass = "http://10.9.8.32:4444/";
        proxyPass = "http://${config.containers."code-server-test".localAddress}:4444/";
        proxyWebsockets = true;
        extraConfig = ''
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
      };
    };
  };

  services.oauth2_proxy = {
    enable = true;
    cookie.secure = false;
    email.domains = [ "*" ];
    provider = "gitlab";
    scope = "openid read_user email";
    loginURL = "https://git.bendlas.net/oauth/authorize";
    redeemURL = "https://git.bendlas.net/oauth/token";
    validateURL = "https://git.bendlas.net/api/v4/user";
    reverseProxy = true;

    cookie.secret = "&NO,*kkvGJRIlVNt";
    clientID = "bccba414c3706b9950ea04da435916bb0b397d0006ccb3ad58b1395b576d9ca8";
    clientSecret = "1919f7137df6cf915d9ffe5cc68b108396e79d19be1bffe865f9f53469151172";

    extraConfig.oidc-issuer-url = "https://git.bendlas.net";
    setXauthrequest = true;
  };
  users.groups.oauth2_proxy = {};
  users.users.oauth2_proxy.group = "oauth2_proxy";
}
