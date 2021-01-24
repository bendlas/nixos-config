{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dfu-util
  ];
  services.udev.extraRules = ''
    ATTRS{idProduct}=="28e9", ATTRS{idVendor}=="0189", MODE="660", GROUP="plugdev" SYMLINK+="gd32-dfu"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
