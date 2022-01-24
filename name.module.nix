{ lib, config, ... }:

with lib;
with types;
{

  options.bendlas.machine = mkOption {
    type = str;
  };

  config = {
    networking.hostName = config.bendlas.machine;
    services.avahi.hostName = config.bendlas.machine;
  };

}
