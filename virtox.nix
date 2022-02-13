{ config, pkgs, ... }:
# let
#   ## nix-shell -p nix-prefetch-github --run "nix-prefetch-github breakds nixvital"
#   nixvital = pkgs.fetchFromGitHub {
#     owner = "breakds";
#     repo = "nixvital";
#     rev = "1e4bde2ec4a07b547079654e87c4ac242c6e3d90";
#     sha256 = "yHkpIyISiBj2s2asu7zA7As1BEhAFaZKSSmStO/gCBI=";
#   };
# in
{
  require = [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix ./mdns.module.nix
    # virtox specific
    ./code-server.module.nix
  ];
  bendlas.machine = "virtox";
  vital.code-server = {
    enable = true;
    domain = "code.bendlas.net";
    user = "root";
  };
  boot.isContainer = true;
  networking = rec {
    #useHostResolvConf = false;
  };
  #services.resolved.enable = true;

  # nix.nixPath = [ "nixos-config=/etc/nixos-config/instances/vitox.nix" ];

  # bendlas.web.devMode = true;
  # systemd.services.hdnews.enable = pkgs.lib.mkForce false;
}
