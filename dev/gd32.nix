{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dfu-util
  ];
  services.udev.extraRules = ''
    ATTRS{idProduct}=="0189", ATTRS{idVendor}=="28e9", MODE="660", GROUP="plugdev" SYMLINK+="gd32-dfu"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
