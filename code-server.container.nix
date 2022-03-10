{ lib, config, options, pkgs, ... }:
with lib;
with types;
{

  options.bendlas.code-server-container = mkOption {
    type = attrsOf (submodule {
      options = {
        user = mkOption {
          type = str;
        };
        containerOptions = mkOption {
          # type = options.containers.type.nestedTypes.elemType;
          type = attrsOf anything;
          default = {};
        };
      };
    });
  };

  config.containers = mapAttrs (name: { user, containerOptions }:
    containerOptions // {
      config = {config, pkgs, ...}: {
        bendlas.machine = name;
        require = [
          (containerOptions.config or {})
          ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
          ./locale.module.nix ./essential.module.nix # ./mdns.module.nix ./ssh.module.nix
          # ./networkd.module.nix
        ];
        networking.firewall.allowedTCPPorts = [ 4444 ];
        systemd.services.systemd-networkd-wait-online.enable = false;
        services.code-server = {
          enable = true;
          host = containerOptions.localAddress;
          extraPackages = [ pkgs.git pkgs.clojure ];
          auth = "none";
        };
      };
    })
    config.bendlas.code-server-container;

}
