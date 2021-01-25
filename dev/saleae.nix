{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pulseview
  ];
  services.udev.extraRules = ''
    ATTRS{idProduct}=="3881", ATTRS{idVendor}=="0925", MODE="660", GROUP="plugdev" SYMLINK+="saleae"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
