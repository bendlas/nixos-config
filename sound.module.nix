{ pkgs, ... }:
{

  require = [ ./mdns.module.nix ];

  sound.enable = true;
  hardware.bluetooth.enable = true;
  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
    package = pkgs.pulseaudioFull;
    tcp.enable = true;
    zeroconf = {
      discovery.enable = true;
      publish.enable = true;
    };
  };

  # Pulseaudio uses 4713
  networking.firewall.allowedTCPPorts = [ 4713 ];

  environment.systemPackages = with pkgs; [
    beep alsa-utils
    paprefs pavucontrol
    qjackctl jack2
  ];

  ## Define a group for jack and the like
  security.pam.loginLimits = [{
    domain = "@realtime";
    type   = "-";
    item   = "rtprio";
    value  = "99";
  }{
    domain = "@realtime";
    type   = "-";
    item   = "memlock";
    value  = "unlimited";
  }];

}
