{ lib, config, pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    (pkgs.runCommand "custom-tools" {
      inherit (pkgs.stdenv) shell;
      inherit (pkgs) libraspberrypi tmux htop iftop;
    } ''
      mkdir -p $out/bin
      substituteAll ${./pistatus.in} $out/bin/pistatus
      substituteAll ${./server-monitor.in} $out/bin/server-monitor
      chmod -R +x $out/bin
    '')
  ];

}
