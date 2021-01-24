{
  services.udev.extraRules = ''
    ATTRS{idProduct}=="0403", ATTRS{idVendor}=="6015", MODE="660", GROUP="plugdev" SYMLINK+="muart"
  '';
  users.extraUsers.herwig.extraGroups = [
    "plugdev"
  ];
  users.extraGroups = {
    plugdev = {};
  };
}
