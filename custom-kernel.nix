{ config, pkgs, ... }:
{
  programs = {
    criu.enable = true;
    systemtap.enable = true;
  };
}
