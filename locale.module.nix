{ pkgs, ... }:
{
  time.timeZone = "Europe/Vienna";
  console = {
    keyMap = pkgs.lib.mkDefault "us";
    font = "lat9w-16";
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
}
