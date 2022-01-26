{ lib, config, ... }:

with lib;
with types;
{

  options.bendlas.machine = mkOption {
    type = str;
  };
  options.bendlas.registry = mkOption {
    type = attrsOf (attrsOf (attrsOf anything));
    default = import ./Registry.nix;
  };
  options.bendlas.machineReg = mkOption {
    type = attrsOf anything;
    default = config.bendlas.registry.machine."${
      config.bendlas.machine
    }";
  };
  options.bendlas.stability = mkOption {
    type = enum ["stable" "unstable"];
  };
  config = {
    networking.hostName = config.bendlas.machine;
    services.avahi.hostName = config.bendlas.machine;
    bendlas.stability = config.bendlas.machineReg.stability or "unstable";
  };

}
