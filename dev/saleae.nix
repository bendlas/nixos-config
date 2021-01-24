{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pulseview
  ];
  services.udev.extraRules = ''
    ATTRS{idProduct}=="0925", ATTRS{idVendor}=="3881", MODE="660", GROUP="plugdev" SYMLINK+="saleae"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
