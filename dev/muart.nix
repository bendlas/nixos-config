{
  services.udev.extraRules = ''
    ATTRS{idProduct}=="6015", ATTRS{idVendor}=="0403", MODE="660", GROUP="plugdev" SYMLINK+="muart"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
