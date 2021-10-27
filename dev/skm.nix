{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    teams dbeaver
  ];

}
