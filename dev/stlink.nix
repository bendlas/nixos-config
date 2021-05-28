{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dfu-util
  ];
  services.udev.extraRules = ''
    ATTRS{idProduct}=="3748", ATTRS{idVendor}=="0483", MODE="660", GROUP="plugdev" SYMLINK+="stlink"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
