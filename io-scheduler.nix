{ config, pkgs, ... }:
{

  services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="bcache*", ATTR{queue/rotational}="1"
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/iosched/slice_idle}="0"
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

}
