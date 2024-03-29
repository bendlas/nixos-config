{ lib, pkgs, config, ... }:
{
  bendlas.machine = "pinox";
  bendlas.wheel.logins = [ "herwig" ];
  imports= [
    # shared with ./base.nix
    ./log.module.nix ./sources.module.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix ./essential.module.nix ./mdns.module.nix
    # new base
    ./access.module.nix ./tmpfs.module.nix ./docu-disable.module.nix ./waydroid.module.nix
    ./nm-iwd.module.nix
    # ./networkd.module.nix {
    #   networking.wireless.iwd.enable = true;
    #   networking.interfaces.wlan0.useDHCP = true;
    # }
    # shared with ./desktop.nix
    ./sound.module.nix
    # mobile-nixos
    (import <mobile-nixos/lib/configuration.nix> { device = "pine64-pinephone"; })
    ./mobile-nixos-bootloader.nix
    ./pinox/phosh.nix
    # ./pinox/plasma-mobile.nix
  ];

  mobile-nixos.install-bootloader = {
    enable = true;
    target = "/dev/mmcblk2p3";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/95ae60eb-2058-431b-b566-51542172d1b0";
    fsType = "ext4";
  };

  fileSystems."/sdcard" = {
    device = "/dev/disk/by-uuid/ee8b2efa-17f4-4248-9e11-010937e2f458";
    fsType = "ext4";
  };

  fileSystems."/var/lib/waydroid" = {
    depends = [ "/sdcard" ];
    device = "/sdcard/var/lib/waydroid";
    options = [ "bind" ];
  };

  swapDevices =[{
    device = "/dev/disk/by-uuid/f3cb75f2-6045-4a40-b81b-075f0daf4328";
  }];


  users.users.herwig = {
    isNormalUser = true;
    home = "/home/herwig";
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

  programs.xwayland.enable = true;

  services.avahi.allowInterfaces = [ "wlan0" ];

  environment.systemPackages = with pkgs; [
    # (kgx.override { genericBranding = true; })
    kgx

    chatty megapixels firefox-mobile

    tdesktop # signal-desktop ## not yet available on aarch64

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
      # automatic = true;
      # options = "--delete-older-than 8d";
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11";

}
