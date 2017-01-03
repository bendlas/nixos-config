{ config, pkgs, ... }:

{

  boot = {
    kernelParams = [ "pcie_aspm.policy=powersave" ];
    blacklistedKernelModules = [ "uvcvideo" ];
    extraModprobeConfig = ''
      options snd_hda_intel power_save=1
      options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
      options iwldvm force_cam=0
    '';
    kernel.sysctl = {
      "kernel.nmi_watchdog" = 0;
      "vm.dirty_writeback_centisecs" = 6000;
      "vm.laptop_mode" = 5;
    };
  };

  services = {
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth*", RUN+="${pkgs.ethtool}/bin/ethtool -s %k wol d"
      ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iw}/bin/iw dev %k set power_save on"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
      ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", ATTR{link_power_management_policy}="min_power"
    '';
    ## this leads to non-responsive input devices
    # ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    i2p.enable = pkgs.lib.mkForce false;
    tor.enable = pkgs.lib.mkForce false;
  };
}
