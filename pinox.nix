{ lib, pkgs, config, ... }:
{
  bendlas.machine = "pinox";
  imports= [
    # shared with ./base.nix
    ./log.nix ./sources.nix ./nix.module.nix ./zsh.module.nix
    ./locale.module.nix ./ssh.module.nix
    # new base
    ./access.module.nix
    # mobile-nixos
    (import <mobile-nixos/lib/configuration.nix> { device = "pine64-pinephone"; })
    ./mobile-nixos-bootloader.nix
  ];

  mobile-nixos.install-bootloader.enable = true;
  
  users.users.nixos = {
    isNormalUser = true;
    shell = "/run/current-system/sw/bin/zsh";
    # hashedPassword = "$6$/iwm2tpFKRjDn9bD$BkSA.FIsYEjyRQXvKrSDDkXmzoDLuioVaeOOUJIURJBxrJQoser/oAa1t951ozROazzwQEyWYHQGR/s.0kgAQ0";

    home = "/home/nixos";
    createHome = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "feedbackd"
      "dialout" # required for modem access
    ];
    uid = 1000;
  };

  # users.users.root.hashedPassword = "$6$WfCoQedRbl7KIWrB$JQ2dGRjIo2kWlV/105W.vuXIMjBZ00K8nAAhNEN/pQdJGyw794xFB3BNVyTV/5hQoandq782C0QwrBnl231VF0";

  # "desktop" environment configuration
  powerManagement.enable = true;
  hardware.opengl.enable = true;

  systemd.defaultUnit = "graphical.target";
  systemd.services.phosh = {
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.phosh}/bin/phosh";
      User = 1000;
      PAMName = "login";
      WorkingDirectory = "~";

      TTYPath = "/dev/tty7";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";

      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";

      UtmpIdentifier = "tty7";
      UtmpMode = "user";

      Restart = "always";
    };
  };

  services.xserver.desktopManager.gnome.enable = true;

  # unpatched gnome-initial-setup is partially broken in small screens
  services.gnome.gnome-initial-setup.enable = false;

  services.locate.enable = false;

  services.geoclue2.enable = true;
  users.users.geoclue.extraGroups = [ "networkmanager" ];

  programs.phosh.enable = true;
  programs.calls.enable = true;
  environment.gnome.excludePackages = with pkgs.gnome3; [
    gnome-terminal
  ];

  environment.systemPackages = with pkgs; [
    git htop iotop tmux
    (kgx.override { genericBranding = true; })

    chatty megapixels
    # pipes
    # terminal
    # wget
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

  # Accelerometer
  hardware.sensor.iio.enable = true;
  hardware.firmware = [ config.mobile.device.firmware ];

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

  
