{ config, pkgs, lib, ... }:
{
  imports = [
    ./base.nix
    ./desktop.nix
    # ./dev.nix
    # ./xsession.nix
  ];

  users.extraUsers.root.password = "123";
  users.extraUsers.vm.password = "123";
  users.extraUsers.vm.isNormalUser = true;
  users.mutableUsers = false;

  networking.hostName = "vm";

  environment.systemPackages = with pkgs; [ sudo ];
  environment.enableDebugInfo = true;

  #services.xserver = {
  #  enable = true;
  #  layout = "de";
  #  xkbOptions = "eurosign:e";
  #  displayManager.qingy.enable = true;
  #  displayManager.kdm.enable = lib.mkForce false;
  #  displayManager.gdm.enable = true;
  #  desktopManager.gnome3.enable = true;
  #  windowManager.exwm.enable = true;
  #  desktopManager.gnome3.enable = true;
  #};

  #time.timeZone = "Europe/Vienna";

  #i18n = {
  #  consoleFont = "lat9w-16";
  #  consoleKeyMap = "de";
  #  defaultLocale = "de_AT.UTF-8";
  #};

}
