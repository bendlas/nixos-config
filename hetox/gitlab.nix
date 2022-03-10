{ config, pkgs, ... }:
{

  services.gitlab = {
    enable = true;
    https = true;
    host = "git.bendlas.net";
    port = 443;
    user = "gitlab";
    group = "gitlab";
    initialRootEmail = "root@bendlas.net";
    initialRootPasswordFile = "/etc/gitlab-secrets/initialRootPassword";
    databasePasswordFile = "/etc/gitlab-secrets/databasePassword";
    smtp = {
      enable = true;
      address = "mail.bendlas.net";
      port = 587;
      username = "git@bendlas.net";
      passwordFile = "/etc/gitlab-secrets/smtp.password";
    };
    extraConfig = {
      gitlab = {
        email_from = "git@bendlas.net";
        email_display_name = "Gitlab on bendlas.net";
      };
    };
    secrets = {
      dbFile = "/etc/gitlab-secrets/db";
      secretFile = "/etc/gitlab-secrets/secret";
      otpFile = "/etc/gitlab-secrets/otp";
      jwsFile = "/etc/gitlab-secrets/jws";
    };
  };

  services.nginx = {
    enable = true;
    ## user = config.services.gitlab.user;
    recommendedProxySettings = true;
    virtualHosts = {
      "${config.services.gitlab.host}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          # http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass
          proxyPass = "http://unix:/var/run/gitlab/gitlab-workhorse.socket";
          proxyWebsockets = true;
        };
      };
    };
  };

  security.acme.email = config.services.gitlab.initialRootEmail;
  security.acme.acceptTerms = true;

  networking.firewall = {
    enable = true;
    # allowPing = false;
    allowedTCPPorts = [
      # 22
      80 443
    ];
  };

  services.postgresql.package = pkgs.postgresql_14;

}
