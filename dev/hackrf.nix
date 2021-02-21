{ pkgs, ... }:
{
  services.udev.extraRules = ''
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="604b", SYMLINK+="hackrf-jawbreaker-%k", MODE="660", GROUP="plugdev"
    ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", SYMLINK+="hackrf-one-%k", MODE="660", GROUP="plugdev"
    ATTR{idVendor}=="1fc9", ATTR{idProduct}=="000c", SYMLINK+="hackrf-dfu-%k", MODE="660", GROUP="plugdev"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
  environment.systemPackages = with pkgs; [
    hackrf welle-io cubicsdr gnuradio-with-packages gqrx
  ];
}
