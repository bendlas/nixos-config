{ pkgs, ... }:
{

  require = [ ./mdns.module.nix ];

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    tcp.enable = true;
    zeroconf = {
      discovery.enable = true;
      publish.enable = true;
    };
  };

  # Pulseaudio uses 4713
  networking.firewall.allowedTCPPorts = [ 4713 ];

}
