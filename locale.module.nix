{ pkgs, ... }:
{
  time.timeZone = "Europe/Vienna";
  console = {
    keyMap = pkgs.lib.mkDefault "us";
    font = "lat9w-16";
    # font = "Lat2-Terminus16";
  };
  i18n = {
    defaultLocale = pkgs.lib.mkDefault "en_US.UTF-8";
  };
}
