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
          extraPackages = with pkgs; [ leiningen git ];
          auth = "none";
          package = pkgs.openvscode-server;
          extraArguments = [
            "--disable-telemetry"
            "--extensions-dir"
            "${(pkgs.buildEnv {
              name = "code-server-extensions";
              paths = with pkgs.vscode-utils; [
                (extensionFromVscodeMarketplace {
                  name = "calva";
                  publisher = "betterthantomorrow";
                  version = "2.0.286";
                  sha256 = "sha256-2N+QhKO2KQNAlOSmXsfXGGX5xAvUGiv7bp+PL//kesk=";
                })
                (extensionFromVscodeMarketplace {
                  name = "nix-ide";
                  publisher = "jnoortheen";
                  version = "0.1.20";
                  sha256 = "sha256-Q6X41I68m0jaCXaQGEFOoAbSUrr/wFhfCH5KrduOtZo=";
                })
              ];
            })}/share/vscode/extensions"
          ];
        };
      };
    })
    config.bendlas.code-server-container;

}
