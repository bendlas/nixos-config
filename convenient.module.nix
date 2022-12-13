{ pkgs, config, ... }:

{

  ## almost essential, but blowing up closure size
  environment.systemPackages = with pkgs; [
    jet
  ];

}
