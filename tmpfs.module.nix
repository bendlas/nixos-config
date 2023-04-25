{

  ## tmpfs for /tmp
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "150%";

  ## tmpfs for /var/tmp
  systemd.mounts = [{
    what = "vartmpfs";
    where = "/var/tmp";
    type = "tmpfs";
    mountConfig.Options = [ "mode=1777" "strictatime" "rw" "nosuid" "nodev" "size=20%" ];
  }];

}
