{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pulseview
  ];
  services.udev.extraRules = ''
    ATTRS{idProduct}=="0003", ATTRS{idVendor}=="1eaf", MODE="660", GROUP="plugdev" SYMLINK+="maple", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idProduct}=="0004", ATTRS{idVendor}=="1eaf", MODE="660", GROUP="plugdev" SYMLINK+="maple", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev" "dialout"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
