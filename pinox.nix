{ lib, pkgs, config, ... }:
{
  bendlas.machine = "pinox";
  bendlas.wheel.logins = [ "nixos" ];
  imports= [
    # shared with ./base.nix
    ./log.nix ./sources.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix
    # new base
    ./access.module.nix ./tmpfs.module.nix
    # mobile-nixos
    (import <mobile-nixos/lib/configuration.nix> { device = "pine64-pinephone"; })
    ./mobile-nixos-bootloader.nix
    ./pinox/phosh.nix
    # ./pinox/plasma-mobile.nix
  ];

  mobile-nixos.install-bootloader.enable = true;

  ## disable man and gnome-help
  documentation.enable = false;
  environment.gnome.excludePackages = [ pkgs.gnome.yelp ];

  users.users.nixos = {
    isNormalUser = true;
    home = "/home/nixos";
    createHome = true;
    extraGroups = [
      "networkmanager"
      "video"
      "feedbackd"
      "dialout" # required for modem access
    ];
    uid = 1000;
  };

  # "desktop" environment configuration
  powerManagement.enable = true;
  hardware.opengl.enable = true;

  services.locate.enable = false;
  services.flatpak.enable = true;

  services.geoclue2.enable = true;
  users.users.geoclue.extraGroups = [ "networkmanager" ];

  programs.calls.enable = true;

  environment.systemPackages = with pkgs; [
    git htop iotop tmux
    (kgx.override { genericBranding = true; })

    chatty megapixels firefox-mobile

    # (chromium.override {
    #   enableWideVine = false;
    #   # commandLineArgs = "--ozone-platform-hint=wayland";
    #   # --enable-features=VaapiVideoDecoder --ozone-platform-hint=auto --process-per-site
    # })
  ];

  ## may not be necessary with recent kernel
  environment.etc."machine-info".text = lib.mkDefault ''
      CHASSIS="handset"
    '';

  ##########################################################################
  ## networking, modem and misc.
  ##########################################################################

  networking = {
    wireless.enable = false;
    wireless.iwd.enable = true;
    networkmanager.wifi.backend = "iwd";

    # FIXME : configure usb rndis through networkmanager in the future.
    # Currently this relies on stage-1 having configured it.
    networkmanager.unmanaged = [ "rndis0" "usb0" ];
  };

  # Setup USB gadget networking in initrd...
  # mobile.boot.stage-1.networking.enable = lib.mkDefault true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  mobile.boot.stage-1.firmware = [
    config.mobile.device.firmware
  ];
  # Accelerometer
  hardware.sensor.iio.enable = true;
  hardware.firmware = [
    config.mobile.device.firmware
    # pkgs.firmwareLinuxNonfree
  ];

  # ====

  ##########################################################################
  # default quirks
  ##########################################################################

  # Ensures this demo rootfs is useable for platforms requiring FBIOPAN_DISPLAY.
  #mobile.quirks.fb-refresher.enable = true;

  # Okay, systemd-udev-settle times out... no idea why yet...
  # Though, it seems fine to simply disable it.
  # FIXME : figure out why systemd-udev-settle doesn't work.
  #systemd.services.systemd-udev-settle.enable = false;

  # Force userdata for the target partition. It is assumed it will not
  # fit in the `system` partition.
  #mobile.system.android.system_partition_destination = "userdata";

  ##########################################################################
  ## misc "system"
  ##########################################################################

  ## No mutable users. This requires us to set passwords with hashedPassword.
  # users.mutableUsers = false;

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 8d";
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.05"; # Did you read the comment?

}
