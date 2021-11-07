{

  networking = {
    useNetworkd = true;
    useDHCP = false;
    networkmanager.enable = false;
  };

  services.resolved = {
    enable = true;
  };

}
