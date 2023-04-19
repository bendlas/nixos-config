{ config, lib, pkgs, ... }:
with lib;
with types;
let
  cfg = config.bendlas.oauth2-proxies;
  # ## Fix Gitea provider in OAP
  # ## https://github.com/oauth2-proxy/oauth2-proxy/issues/1636
  # oauth2Proxy = pkgs.oauth2-proxy.overrideAttrs
  #   (old: {
  #     patches = (old.patches or []) ++ [
  #       (pkgs.fetchpatch {
  #         url = "https://github.com/igsol/oauth2-proxy/commit/749851f1b3446e2bb5eec2b5d5943c5873c34006.patch";
  #         sha256 = "sha256-Kkx0QgKq9aMVJEepZIWRgpeAIGDsO87UtC9c4JmnR/Q=";
  #       })
  #     ];
  #   });
  oauth2Proxy = pkgs.oauth2-proxy;
  oap = foldl (
    { count, containers, hostAddresses }:
    { name, require, oauth2ProxyConfig }: let
      localAddress = "${cfg.localSubnet24}.${toString count}";
      hostAddress = "${cfg.hostSubnet24}.${toString count}";
    in {
      count = count + 1;
      hostAddresses = hostAddresses ++ [ hostAddress ];
      containers = containers // {
        "oauth2-${name}" = {
          autoStart = true;
          privateNetwork = true;
          inherit localAddress hostAddress;
          config = {
            inherit require;
            # networking.useHostResolvConf = true;
            # environment.etc."resolv.conf".text = "nameserver ${hostAddress}";
            environment.etc."resolv.conf".text = "nameserver 8.8.8.8";
            networking.firewall.enable = false;
            services.oauth2_proxy = mkMerge [{
              enable = true;
              httpAddress = "http://${localAddress}:4180";
              package = oauth2Proxy;
            } oauth2ProxyConfig (optionalAttrs cfg.devMode {
              # cookie.secure = false;
              extraConfig.ssl-insecure-skip-verify = true;
            })];
            systemd.services.oauth2_proxy.serviceConfig = {
              ## make sure that restart rate limiting doesn't permanently disable oauth2_proxy
              ## introduce pause before restarting
              RestartSec = 3;
              ## disable restart rate limiting
              StartLimitIntervalSec = 0;
            };

          };
        };
      };
    }) {
      count = 0;
      hostAddresses = [];
      containers = {};
    }
    cfg.applications;
in {

  options.bendlas.oauth2-proxies = {
    devMode = mkOption {
      type = bool;
      default = false;
    };
    hostSubnet24 = mkOption {
      type = str;
      default = "10.12.1";
    };
    localSubnet24 = mkOption {
      type = str;
      default = "10.12.2";
    };
    applications = mkOption {
      type = listOf (submodule {
        options = {
          name = mkOption {
            type = str;
          };
          require = mkOption {
            type = listOf unspecified;
            default = [];
          };
          oauth2ProxyConfig = mkOption {
            type = attrs;
          };
        };
      });
    };
  };

  config.containers = oap.containers;

  # config.services.resolved.extraConfig = mkMerge (
  #   map (add: "DNSStubListenerExtra=${add}")
  #     oap.hostAddresses);

  config.networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "eth0";
  };

}
