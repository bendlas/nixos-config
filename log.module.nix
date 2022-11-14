{ config, pkgs, ... }:

{

  services.journald.extraConfig = ''
    SystemMaxUse=128M
    SystemMaxFileSize=32M
  '';

  services.logrotate.enable = true;
  services.logrotate.settings = {
    "/var/log/*.log" = {
      weekly = true;
      size = "1M";
      dateext = true;
      rotate = 2;
      compress = true;
      delaycompress = true;
      copytruncate = true;
      notifempty = true;
      missingok = true;
    };
  };

}
