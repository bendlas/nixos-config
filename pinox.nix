{ lib, pkgs, config, ... }:
{
  imports= [
    (import <mobile-nixos/lib/configuration.nix> { device = "pine64-pinephone"; })
    ./mobile-nixos-bootloader.nix
  ];

  mobile-nixos.install-bootloader.enable = true;
  
  users.users.nixos = {
    isNormalUser = true;

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
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC70QgW3EnX781iFOlojPnwST1CiMZaWdQEJNgSbsvaEFeHwFNDr9Ma2kTzjFQnpLKfb7eAr7BsUX3uSJjFq6MDTfgynCSXtgOxaahTfoVFFvJdGZPtXU09k7xSW043A7Ziwi8iPM0EFKUb85W6v4S1VACpjD57SEs4enUsyrXO8XVBDpqRQLdPDXjyNqzZ0zafbs22bDYDUmgr3UTItSzrGG7fzPyP3D2cJ1HKptQNUBRwjMvduG5by+ONxtuNJ7XGtQfFOyLJl4QFCWCSNwVEzv0CqAfrbq3XmqsAMXZJeMNo0OG/XpgQT2W4oP0QcyW9hHvxe6S34DjXDCaN8SreTJqq/8n3gQIj2/bkW9gGOHceZ98BDVXAeVXQj4opd3qF1V3DkP7NhUZEpgqHZglpkmcZqiufpdJbhnbjjIAUPN9c2dpEKWiR+UTR0hUedERDEGge6caM0XpfKPDiFXQpNgMBhatRkp9iNwoCIbp1muzYZpiu8YFNFbZmRmXcW8o8b3/MoEWZZTvMcffk7Yk+K0lItLmR7wjAJVZXM/7CbP6bVECbYAGNaQ50ZlPgt1wAU9VoE9oV3U2bVmV6Vdic1w1LS3pCOT9DNOXkGvbxLxp/gwJVFwkHVBAHnSLCyRyNn3GL+rzPO0Mzej2Q9stPUExcoMBkm6e4pUatynHONw== herwig@lenotox"
    ];
  };

  # users.users.root.hashedPassword = "$6$WfCoQedRbl7KIWrB$JQ2dGRjIo2kWlV/105W.vuXIMjBZ00K8nAAhNEN/pQdJGyw794xFB3BNVyTV/5hQoandq782C0QwrBnl231VF0";

  # "desktop" environment configuration
  powerManagement.enable = true;
  # hardware.opengl.enable = true;

  # =====

  environment.systemPackages = with pkgs; [
    git
    # pipes
    # terminal
    # wget
  ];

  environment.etc."machine-info".text = lib.mkDefault ''
      CHASSIS="handset"
    '';

  ##########################################################################
  ## networking, modem and misc.
  ##########################################################################

  networking = {
    hostName = "pinox";

    wireless.enable = false;
    wireless.iwd.enable = true;
    # networkmanager.enable = true;

    # FIXME : configure usb rndis through networkmanager in the future.
    # Currently this relies on stage-1 having configured it.
    # networkmanager.unmanaged = [ "rndis0" "usb0" ];
  };

  # Setup USB gadget networking in initrd...
  # mobile.boot.stage-1.networking.enable = lib.mkDefault true;

  # Bluetooth
  # hardware.bluetooth.enable = true;

  ##########################################################################
  ## SSH
  ##########################################################################

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    # kbdInteractiveAuthentication = false;
    challengeResponseAuthentication = false;
  };

  # programs.mosh.enable = true;

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

    # nix flakes
    # package = pkgs.nixUnstable;
    extraOptions = ''
        experimental-features = nix-command flakes
      '';
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  # system.stateVersion = "21.11"; # Did you read the comment?

}

  
