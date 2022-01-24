{ lib, config, ... }:
{

  # systemd.services.wpa_supplicant.enable = false;
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    Network = {
      EnableIPv6 = true;
      NameResolvingService = if config.services.resolved.enable
                             then "systemd"
                             else "resolvconf";
    };
  };

  # # disable wifi powersave
  # services.udev.extraRules = ''
  #   ACTION=="add", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", RUN+="${pkgs.iw}/bin/iw dev %k set power_save off"
  # '';

}
