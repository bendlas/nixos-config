{ pkgs, config, ... }:
{
  services.factorio = {
    enable = true;
    ## in order to find local updates
    package = pkgs.callPackage "${config.environment.etc."nixpkgs-unstable".source}/pkgs/games/factorio" {
      releaseType = "headless";
    };
    admins = [
      "flowbot"
    ];
    openFirewall = true;
    game-name = "manulinarium";
    game-password = builtins.readFile /etc/secrets/factorio-server-password;
    requireUserVerification = false;
  };
}
