{

  virtualisation = {
    waydroid.enable = true;
    lxd.enable = true;
    lxc.enable = true;
    lxc.lxcfs.enable = true;
  };

  # networking.interfaces.waydroid0.useDHCP = true;
  # services.avahi.interfaces = [ "waydroid0" ];
  # networking.bridges.waydroid0.interfaces = [ ];
  # networking.bridges.waydroid0.interfaces = [ "wlan0" "wwan0" ];
  # systemd.network-wait-online.ignore = [ "waydroid0" ];
  # networking.networkmanager.unmanaged = [ "waydroid0" ];

}
