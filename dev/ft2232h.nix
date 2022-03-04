{ pkgs, ... }:
{
  services.udev.extraRules = ''
    ATTRS{idProduct}=="6010", ATTRS{idVendor}=="0403", MODE="660", GROUP="plugdev" SYMLINK+="ft2232h"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
