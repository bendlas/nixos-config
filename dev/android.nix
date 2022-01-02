{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    androidsdk_9_0
  ];
  services.udev.extraRules = ''
    ATTRS{idVendor}=="12d1", ATTRS{idProduct}=="107e", MODE="660", GROUP="plugdev" SYMLINK+="huawei-p20"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
