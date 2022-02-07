{

  ## tmpfs for /tmp
  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "150%";

  ## tmpfs for /var/tmp
  systemd.mounts = [{
    what = "vartmpfs";
    where = "/var/tmp";
    type = "tmpfs";
    mountConfig.Options = [ "mode=1777" "strictatime" "rw" "nosuid" "nodev" "size=20%" ];
  }];

}
