{ lib, ... }:
{

  virtualisation = {
    waydroid.enable = true;
    lxd.enable = true;
    lxc.enable = true;
    lxc.lxcfs.enable = true;
  };

  ## override default from nixos. necessary since lineageos 18
  ## should be no problem any more
  ## https://wiki.debian.org/LXC/CGroupV2
  ## https://github.com/lxc/lxc/issues/3206
  systemd.enableUnifiedCgroupHierarchy = lib.mkForce true;

  # networking.interfaces.waydroid0.useDHCP = true;
  # services.avahi.interfaces = [ "waydroid0" ];
  # networking.bridges.waydroid0.interfaces = [ ];
  # networking.bridges.waydroid0.interfaces = [ "wlan0" "wwan0" ];
  # systemd.network-wait-online.ignore = [ "waydroid0" ];
  networking.networkmanager.unmanaged = [ "waydroid0" "interface-name:veth*" ];
  # networking.nat.enable = true;
  # networking.firewall.checkReversePath = "loose";

}
