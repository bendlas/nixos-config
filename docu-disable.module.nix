{ pkgs, ... }:

{

  ## disable man and gnome-help
  documentation.enable = false;
  environment.gnome.excludePackages = [ pkgs.gnome.yelp ];

}
