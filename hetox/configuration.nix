# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./gitlab.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = [ "/dev/sda" ];
  networking.hostName = "hetox"; # Define your hostname.
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;
  networking.nat.externalInterface = "ens3";

  environment.systemPackages = with pkgs; [
    # emacsBendlasNox
    emacs-nox
  ];

  system.stateVersion = "21.05"; # Did you read the comment?

}
