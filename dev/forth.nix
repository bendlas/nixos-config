{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    gforth ueforth
  ];

}
