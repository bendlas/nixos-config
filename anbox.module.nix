{

  virtualisation.anbox.enable = true;
  networking.nat.internalInterfaces = [ "anbox0" ];
  systemd.network-wait-online.ignore = [ "anbox0" ];

}
