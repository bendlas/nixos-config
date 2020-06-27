{ config, pkgs, ... }:

{

  services.journald.extraConfig = ''
    SystemMaxUse=128M
    SystemMaxFileSize=32M
  '';

  services.logrotate.enable = true;
  services.logrotate.extraConfig = ''
    /var/log/*.log {
      weekly
      size 1M
      dateext
      rotate 2
      compress
      delaycompress
      copytruncate
      notifempty
      missingok
    }
  '';

}
